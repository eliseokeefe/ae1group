
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS DiningHalls (
    HallID          INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL UNIQUE,           
    Location        TEXT        NOT NULL,                  
    OperatingHours  TEXT        NOT NULL,                  

    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(Location)) > 0)
);

CREATE TABLE IF NOT EXISTS FoodItems (
    ItemID              INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name                TEXT        NOT NULL,                           
    Category            TEXT        NOT NULL,                           
    NutritionalInfo     TEXT        NOT NULL DEFAULT 'N/A',            
    CarbonFootprintPerUnit REAL    NOT NULL DEFAULT 0.0,              

    CHECK (Category IN ('prepared', 'raw', 'packaged')),
    CHECK (CarbonFootprintPerUnit >= 0),
    CHECK (LENGTH(TRIM(Name)) > 0)
);

CREATE TABLE IF NOT EXISTS Volunteers (
    VolunteerID     INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL,                  
    ContactInfo     TEXT        NOT NULL,                   
    Role            TEXT        NOT NULL DEFAULT 'Sorter',  
    CHECK (Role IN ('Sorter', 'Coordinator', 'Driver', 'Admin', 'Analyst')),
    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(ContactInfo)) > 0)
);

CREATE TABLE IF NOT EXISTS WasteLogs (
    LogID           INTEGER     PRIMARY KEY AUTOINCREMENT,
    HallID          INTEGER     NOT NULL,                  
    ItemID          INTEGER     NOT NULL,                   
    Quantity        REAL        NOT NULL,                  
    LogDate         TEXT        NOT NULL,                   
    WasteType       TEXT        NOT NULL,                  

    FOREIGN KEY (HallID) REFERENCES DiningHalls(HallID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES FoodItems(ItemID)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (Quantity > 0),
    CHECK (WasteType IN ('expired', 'overproduction', 'plate_waste', 'spoiled', 'quality_issue'))
);


CREATE TABLE IF NOT EXISTS FoodBanks (
    BankID          INTEGER     PRIMARY KEY AUTOINCREMENT,
    Name            TEXT        NOT NULL UNIQUE,            
    Location        TEXT        NOT NULL,                   
    PickupSchedule  TEXT        NOT NULL,                  

    CHECK (LENGTH(TRIM(Name)) > 0),
    CHECK (LENGTH(TRIM(Location)) > 0)
);


CREATE TABLE IF NOT EXISTS Donations (
    DonationID      INTEGER     PRIMARY KEY AUTOINCREMENT,
    LogID           INTEGER     NOT NULL,                  
    BankID          INTEGER     NOT NULL,                  
    Quantity        REAL        NOT NULL,                   
    PickupTime      TEXT        NOT NULL,                   
    Status          TEXT        NOT NULL DEFAULT 'Pending', 

    FOREIGN KEY (LogID) REFERENCES WasteLogs(LogID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (BankID) REFERENCES FoodBanks(BankID)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CHECK (Quantity > 0),
    CHECK (Status IN ('Pending', 'Scheduled', 'Picked Up', 'Delivered', 'Cancelled'))
);


CREATE TABLE IF NOT EXISTS HallAssignments (
    HallID          INTEGER     NOT NULL,
    VolunteerID     INTEGER     NOT NULL,

    PRIMARY KEY (HallID, VolunteerID),

    FOREIGN KEY (HallID) REFERENCES DiningHalls(HallID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (VolunteerID) REFERENCES Volunteers(VolunteerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE INDEX idx_wastelogs_date ON WasteLogs(LogDate);


CREATE INDEX idx_wastelogs_hall ON WasteLogs(HallID);


CREATE INDEX idx_wastelogs_item ON WasteLogs(ItemID);

CREATE INDEX idx_donations_bank ON Donations(BankID);


CREATE INDEX idx_donations_log ON Donations(LogID);

CREATE INDEX idx_volunteers_role ON Volunteers(Role);

CREATE INDEX idx_wastelogs_hall_date ON WasteLogs(HallID, LogDate);

CREATE INDEX idx_fooditems_category ON FoodItems(Category);
