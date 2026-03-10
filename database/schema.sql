-- =============================================================================
-- CAMPUS FOOD WASTE TRACKER — DATABASE SCHEMA
-- UN SDG 12: Responsible Consumption and Production
-- =============================================================================
--
-- This schema implements a fully normalized (3NF) relational database for
-- tracking food waste, coordinating donations to food banks, and managing
-- student volunteer activities across 5 campus dining facilities.
--
-- NORMALIZATION ANALYSIS (Third Normal Form):
--   1NF: All columns hold atomic values; no repeating groups or arrays.
--   2NF: Every non-key attribute is fully functionally dependent on the
--        entire primary key. The composite-key table HallAssignments
--        depends on both HallID and VolunteerID together.
--   3NF: No transitive dependencies exist. For example, FoodItems stores
--        the category directly rather than through a separate lookup,
--        because the category is strictly an attribute of the item itself.
--        Nutritional data belongs to FoodItems, not to WasteLogs.
--
-- DESIGN DECISIONS:
--   • SQLite is used for zero-configuration local development.
--   • TEXT types with ISO 8601 format are used for dates/times (SQLite best practice).
--   • REAL is used for decimal values (quantities, costs). In production
--     PostgreSQL, these would be NUMERIC(10,2).
--   • Foreign keys use ON DELETE RESTRICT to prevent accidental data loss.
--   • CHECK constraints enforce business-rule-level data integrity.
-- =============================================================================

-- Enable foreign key enforcement (SQLite default is OFF)
PRAGMA foreign_keys = ON;


-- =============================================================================
-- TABLE 1: DiningHalls
-- Represents the 5 campus dining facilities being monitored for food waste.
-- Each hall is a distinct physical location with its own operational schedule.
-- =============================================================================
CREATE TABLE IF NOT EXISTS DiningHalls (
    HallID          INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL UNIQUE,           -- Human-readable hall name
    Location        TEXT        NOT NULL,                  -- Building or campus zone
    OperatingHours  TEXT        NOT NULL,                  -- e.g. '07:00-21:00'

    -- Business rule: hall name must not be empty
    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(Location)) > 0)
);


-- =============================================================================
-- TABLE 2: FoodItems
-- Master catalogue of food items tracked across the campus. Each item has
-- nutritional metadata and a carbon footprint score used for sustainability
-- reporting. The CHECK constraint on Category enforces the three mandated
-- classification types.
-- =============================================================================
CREATE TABLE IF NOT EXISTS FoodItems (
    ItemID              INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name                TEXT        NOT NULL,                           -- Item name
    Category            TEXT        NOT NULL,                           -- Classification type
    NutritionalInfo     TEXT        NOT NULL DEFAULT 'N/A',            -- Descriptive nutritional summary
    CarbonFootprintPerUnit REAL    NOT NULL DEFAULT 0.0,              -- kg CO2e per unit

    -- Business rule: Category must be one of the three mandated types
    CHECK (Category IN ('prepared', 'raw', 'packaged')),
    -- Carbon footprint cannot be negative
    CHECK (CarbonFootprintPerUnit >= 0),
    CHECK (LENGTH(TRIM(Name)) > 0)
);


-- =============================================================================
-- TABLE 3: Volunteers
-- Records the 500+ student volunteers who participate in waste sorting and
-- donation coordination activities. Each volunteer has a designated role.
-- =============================================================================
CREATE TABLE IF NOT EXISTS Volunteers (
    VolunteerID     INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL,                   -- Full name
    ContactInfo     TEXT        NOT NULL,                   -- Email or phone
    Role            TEXT        NOT NULL DEFAULT 'Sorter',  -- Volunteer function

    -- Business rule: Role must be a recognized position
    CHECK (Role IN ('Sorter', 'Coordinator', 'Driver', 'Admin', 'Analyst')),
    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(ContactInfo)) > 0)
);


-- =============================================================================
-- TABLE 4: WasteLogs
-- Core transactional table. Every food waste event is recorded here, linking
-- a specific food item to a specific dining hall on a specific date.
-- This is the primary data source for all sustainability analytics.
-- =============================================================================
CREATE TABLE IF NOT EXISTS WasteLogs (
    LogID           INTEGER     PRIMARY KEY AUTOINCREMENT,
    HallID          INTEGER     NOT NULL,                   -- Which dining hall
    ItemID          INTEGER     NOT NULL,                   -- Which food item
    Quantity        REAL        NOT NULL,                   -- Amount wasted (kg)
    LogDate         TEXT        NOT NULL,                       -- ISO 8601 date
    WasteType       TEXT        NOT NULL,                   -- Classification of waste

    -- Referential integrity
    FOREIGN KEY (HallID) REFERENCES DiningHalls(HallID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES FoodItems(ItemID)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Business rules
    CHECK (Quantity > 0),
    CHECK (WasteType IN ('expired', 'overproduction', 'plate_waste', 'spoiled', 'quality_issue'))
);


-- =============================================================================
-- TABLE 5: FoodBanks
-- Partner food banks that receive surplus edible food from the campus.
-- The university works with 3 partner organisations.
-- =============================================================================
CREATE TABLE IF NOT EXISTS FoodBanks (
    BankID          INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL UNIQUE,            -- Organisation name
    Location        TEXT        NOT NULL,                   -- Street address
    PickupSchedule  TEXT        NOT NULL,                   -- e.g. 'Mon/Wed/Fri 14:00'

    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(Location)) > 0)
);


-- =============================================================================
-- TABLE 6: Donations
-- Records individual food donations from the campus to partner food banks.
-- Each donation is linked to a WasteLog entry (specifically, edible surplus
-- that was diverted from waste to charitable use) and to a food bank.
-- =============================================================================
CREATE TABLE IF NOT EXISTS Donations (
    DonationID      INTEGER     PRIMARY KEY AUTOINCREMENT,
    LogID           INTEGER     NOT NULL,                   -- Linked waste log (edible surplus)
    BankID          INTEGER     NOT NULL,                   -- Destination food bank
    Quantity        REAL        NOT NULL,                   -- Amount donated (kg)
    PickupTime      TEXT        NOT NULL,                   -- ISO 8601 datetime of pickup
    Status          TEXT        NOT NULL DEFAULT 'Pending', -- Current status

    -- Referential integrity
    FOREIGN KEY (LogID) REFERENCES WasteLogs(LogID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (BankID) REFERENCES FoodBanks(BankID)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Business rules
    CHECK (Quantity > 0),
    CHECK (Status IN ('Pending', 'Scheduled', 'Picked Up', 'Delivered', 'Cancelled'))
);


-- =============================================================================
-- TABLE 7: HallAssignments
-- Junction/bridge table implementing the many-to-many relationship between
-- DiningHalls and Volunteers. A volunteer can be assigned to multiple halls,
-- and each hall can have multiple volunteers. The composite primary key
-- prevents duplicate assignments.
-- =============================================================================
CREATE TABLE IF NOT EXISTS HallAssignments (
    HallID          INTEGER     NOT NULL,
    VolunteerID     INTEGER     NOT NULL,

    -- Composite primary key enforces uniqueness of each assignment pair
    PRIMARY KEY (HallID, VolunteerID),

    -- Referential integrity
    FOREIGN KEY (HallID) REFERENCES DiningHalls(HallID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (VolunteerID) REFERENCES Volunteers(VolunteerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- =============================================================================
-- INDEXES
-- Purpose: Optimise the most common query access patterns identified in
-- queries.sql. Each index is justified against specific queries.
-- =============================================================================

-- Used by: Queries 1, 5, 7, 8 — waste analysis filtered by date range
CREATE INDEX idx_wastelogs_date ON WasteLogs(LogDate);

-- Used by: Queries 1, 3 — waste grouped/filtered by dining hall
CREATE INDEX idx_wastelogs_hall ON WasteLogs(HallID);

-- Used by: Queries 1, 2 — waste joined with food item details
CREATE INDEX idx_wastelogs_item ON WasteLogs(ItemID);

-- Used by: Query 2 — donations joined with food banks
CREATE INDEX idx_donations_bank ON Donations(BankID);

-- Used by: Query 2 — donations linked back to waste logs
CREATE INDEX idx_donations_log ON Donations(LogID);

-- Used by: Query 4 — volunteer lookup by role
CREATE INDEX idx_volunteers_role ON Volunteers(Role);

-- Used by: Queries 5, 7 — composite index for hall+date range scans
CREATE INDEX idx_wastelogs_hall_date ON WasteLogs(HallID, LogDate);

-- Used by: Query 6 — food items filtered by category
CREATE INDEX idx_fooditems_category ON FoodItems(Category);
