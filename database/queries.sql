-- =============================================================================
-- CAMPUS FOOD WASTE TRACKER — ADVANCED SQL QUERIES
-- 8 optimized queries for sustainability analytics
-- =============================================================================
--
-- Query Categories:
--   Queries 1-2:  JOINs across 3+ tables
--   Queries 3-4:  Subqueries
--   Queries 5-6:  GROUP BY with HAVING
--   Queries 7-8:  Sustainability reporting
--
-- All indexes referenced here are defined in schema.sql.
-- =============================================================================

PRAGMA foreign_keys = ON;


-- =============================================================================
-- QUERY 1: Total Carbon Footprint Per Dining Hall (JOIN across 3+ tables)
-- =============================================================================
-- PURPOSE: Calculates the total environmental impact of food waste at each
-- dining hall by joining WasteLogs with FoodItems (for carbon data) and
-- DiningHalls (for hall names). This is a core sustainability KPI.
--
-- INDEXES USED: idx_wastelogs_hall, idx_wastelogs_item
-- =============================================================================
SELECT
    dh.Name                                                 AS DiningHall,
    dh.Location,
    COUNT(wl.LogID)                                         AS TotalWasteEvents,
    ROUND(SUM(wl.Quantity), 2)                              AS TotalWasteKg,
    ROUND(SUM(wl.Quantity * fi.CarbonFootprintPerUnit), 2)  AS TotalCarbonFootprintKg,
    ROUND(AVG(wl.Quantity * fi.CarbonFootprintPerUnit), 2)  AS AvgCarbonPerEventKg
FROM WasteLogs wl
    JOIN DiningHalls dh ON wl.HallID = dh.HallID
    JOIN FoodItems fi   ON wl.ItemID = fi.ItemID
GROUP BY dh.HallID, dh.Name, dh.Location
ORDER BY TotalCarbonFootprintKg DESC;


-- =============================================================================
-- QUERY 2: Full Donation Audit Trail with Food Bank and Item Details
--          (JOIN across 4 tables)
-- =============================================================================
-- PURPOSE: Produces a complete audit trail of every donation, linking the
-- donated item back through the waste log to the food item details and
-- forward to the receiving food bank. Essential for compliance reporting
-- and food safety traceability.
--
-- INDEXES USED: idx_donations_log, idx_donations_bank, idx_wastelogs_item
-- =============================================================================
SELECT
    d.DonationID,
    d.PickupTime,
    dh.Name                                             AS FromDiningHall,
    fb.Name                                             AS ToFoodBank,
    fi.Name                                             AS FoodItem,
    fi.Category,
    d.Quantity                                          AS DonatedKg,
    wl.Quantity                                         AS OriginalWasteKg,
    ROUND(d.Quantity * fi.CarbonFootprintPerUnit, 2)    AS CarbonSavedKg,
    d.Status
FROM Donations d
    JOIN WasteLogs wl   ON d.LogID   = wl.LogID
    JOIN FoodItems fi   ON wl.ItemID = fi.ItemID
    JOIN DiningHalls dh ON wl.HallID = dh.HallID
    JOIN FoodBanks fb   ON d.BankID  = fb.BankID
ORDER BY d.PickupTime DESC;


-- =============================================================================
-- QUERY 3: Dining Halls That Waste More Than the Campus Average (Subquery)
-- =============================================================================
-- PURPOSE: Identifies underperforming dining halls whose total waste exceeds
-- the campus-wide average. These halls should be prioritized for waste
-- reduction programmes. The subquery calculates the cross-campus average
-- total waste per hall as the threshold.
--
-- INDEXES USED: idx_wastelogs_hall
-- =============================================================================
SELECT
    dh.Name                         AS DiningHall,
    dh.Location,
    ROUND(SUM(wl.Quantity), 2)      AS TotalWasteKg,
    ROUND(
        (SELECT AVG(hall_total)
         FROM (
            SELECT SUM(wl2.Quantity) AS hall_total
            FROM WasteLogs wl2
            GROUP BY wl2.HallID
         )
        ), 2
    ) AS CampusAvgWasteKg
FROM WasteLogs wl
    JOIN DiningHalls dh ON wl.HallID = dh.HallID
GROUP BY dh.HallID, dh.Name, dh.Location
HAVING SUM(wl.Quantity) > (
    SELECT AVG(hall_total)
    FROM (
        SELECT SUM(wl2.Quantity) AS hall_total
        FROM WasteLogs wl2
        GROUP BY wl2.HallID
    )
)
ORDER BY TotalWasteKg DESC;


-- =============================================================================
-- QUERY 4: Volunteers Assigned to Halls with No Donations (Subquery)
-- =============================================================================
-- PURPOSE: Finds volunteers working at dining halls that have not yet
-- produced any donations. This helps coordinators identify halls where
-- donation processes may need to be initiated or improved.
--
-- INDEXES USED: idx_volunteers_role
-- =============================================================================
SELECT
    v.Name              AS VolunteerName,
    v.Role,
    v.ContactInfo,
    dh.Name             AS AssignedHall,
    dh.Location
FROM Volunteers v
    JOIN HallAssignments ha ON v.VolunteerID = ha.VolunteerID
    JOIN DiningHalls dh     ON ha.HallID     = dh.HallID
WHERE dh.HallID NOT IN (
    -- Subquery: halls that have at least one waste log linked to a donation
    SELECT DISTINCT wl.HallID
    FROM WasteLogs wl
        JOIN Donations d ON wl.LogID = d.LogID
)
ORDER BY dh.Name, v.Name;


-- =============================================================================
-- QUERY 5: Monthly Waste Totals — Only Months Exceeding 30kg (GROUP BY + HAVING)
-- =============================================================================
-- PURPOSE: Aggregates waste data by calendar month and filters to show only
-- months where total waste exceeded 30kg. This helps the sustainability
-- office identify high-waste periods that need targeted intervention.
--
-- INDEXES USED: idx_wastelogs_date
-- =============================================================================
SELECT
    strftime('%Y-%m', wl.LogDate)   AS Month,
    COUNT(wl.LogID)                 AS WasteEvents,
    ROUND(SUM(wl.Quantity), 2)      AS TotalWasteKg,
    ROUND(AVG(wl.Quantity), 2)      AS AvgPerEventKg,
    ROUND(MAX(wl.Quantity), 2)      AS LargestSingleEventKg,
    GROUP_CONCAT(DISTINCT wl.WasteType) AS WasteTypesObserved
FROM WasteLogs wl
GROUP BY strftime('%Y-%m', wl.LogDate)
HAVING SUM(wl.Quantity) > 30
ORDER BY Month;


-- =============================================================================
-- QUERY 6: Food Categories with Above-Average Waste Frequency
--          (GROUP BY + HAVING)
-- =============================================================================
-- PURPOSE: Groups waste data by food category and filters to show only
-- categories where the number of waste events is above the overall average.
-- Helps prioritize which food types need better handling procedures.
--
-- INDEXES USED: idx_fooditems_category, idx_wastelogs_item
-- =============================================================================
SELECT
    fi.Category,
    COUNT(wl.LogID)                                         AS WasteEvents,
    ROUND(SUM(wl.Quantity), 2)                              AS TotalWasteKg,
    ROUND(SUM(wl.Quantity * fi.CarbonFootprintPerUnit), 2)  AS TotalCarbonKg,
    COUNT(DISTINCT fi.ItemID)                               AS UniqueItemsWasted
FROM WasteLogs wl
    JOIN FoodItems fi ON wl.ItemID = fi.ItemID
GROUP BY fi.Category
HAVING COUNT(wl.LogID) > (
    -- The overall average number of events per category
    SELECT CAST(COUNT(*) AS REAL) / COUNT(DISTINCT fi2.Category)
    FROM WasteLogs wl2
        JOIN FoodItems fi2 ON wl2.ItemID = fi2.ItemID
)
ORDER BY TotalWasteKg DESC;


-- =============================================================================
-- QUERY 7: Waste Reduction Trend — Monthly Waste vs. Donations
--          (Sustainability Report)
-- =============================================================================
-- PURPOSE: The primary sustainability KPI report. For each month, it compares
-- total food wasted against food diverted to donations, and calculates the
-- "diversion rate" (percentage of surplus successfully donated rather than
-- discarded). A rising diversion rate indicates programme success.
--
-- INDEXES USED: idx_wastelogs_date, idx_donations_log
-- =============================================================================
SELECT
    strftime('%Y-%m', wl.LogDate) AS Month,
    ROUND(SUM(wl.Quantity), 2)    AS TotalWasteKg,
    ROUND(SUM(wl.Quantity * fi.CarbonFootprintPerUnit), 2)  AS CarbonFromWasteKg,
    ROUND(COALESCE(don_agg.TotalDonatedKg, 0), 2)           AS TotalDonatedKg,
    ROUND(COALESCE(don_agg.CarbonSavedKg, 0), 2)            AS CarbonSavedByDonationsKg,
    -- Net carbon impact = emissions from waste minus savings from donations
    ROUND(
        SUM(wl.Quantity * fi.CarbonFootprintPerUnit) -
        COALESCE(don_agg.CarbonSavedKg, 0),
    2) AS NetCarbonImpactKg,
    -- Diversion rate: what percentage of total surplus was donated
    CASE
        WHEN SUM(wl.Quantity) > 0
        THEN ROUND(
            COALESCE(don_agg.TotalDonatedKg, 0) * 100.0 /
            (SUM(wl.Quantity) + COALESCE(don_agg.TotalDonatedKg, 0)),
        2)
        ELSE 0
    END AS DiversionRatePct
FROM WasteLogs wl
    JOIN FoodItems fi ON wl.ItemID = fi.ItemID
    LEFT JOIN (
        -- Pre-aggregate donation data by month for efficient joining
        SELECT
            strftime('%Y-%m', wl2.LogDate) AS Month,
            SUM(d.Quantity) AS TotalDonatedKg,
            SUM(d.Quantity * fi2.CarbonFootprintPerUnit) AS CarbonSavedKg
        FROM Donations d
            JOIN WasteLogs wl2 ON d.LogID   = wl2.LogID
            JOIN FoodItems fi2 ON wl2.ItemID = fi2.ItemID
        WHERE d.Status IN ('Delivered', 'Picked Up')
        GROUP BY strftime('%Y-%m', wl2.LogDate)
    ) don_agg ON strftime('%Y-%m', wl.LogDate) = don_agg.Month
GROUP BY strftime('%Y-%m', wl.LogDate)
ORDER BY Month;


-- =============================================================================
-- QUERY 8: Estimated Annual Cost Savings from Donations (Sustainability Report)
-- =============================================================================
-- PURPOSE: Financial sustainability analysis. Estimates the monetary value
-- recovered through the donation programme by calculating avoided disposal
-- costs (£0.15/kg for commercial food waste) and the value of donated food
-- (estimated at £2.50/kg market replacement value). This makes the business
-- case for continued investment in the programme.
--
-- INDEXES USED: idx_donations_bank
-- =============================================================================
SELECT
    fb.Name                                                 AS FoodBank,
    fb.Location,
    COUNT(d.DonationID)                                     AS TotalDonations,
    ROUND(SUM(d.Quantity), 2)                               AS TotalDonatedKg,
    -- Avoided disposal cost at £0.15 per kg
    ROUND(SUM(d.Quantity) * 0.15, 2)                        AS AvoidedDisposalCostGBP,
    -- Estimated food value at £2.50 replacement cost per kg
    ROUND(SUM(d.Quantity) * 2.50, 2)                        AS EstimatedFoodValueGBP,
    -- Total savings = avoided disposal + food value
    ROUND(SUM(d.Quantity) * (0.15 + 2.50), 2)               AS TotalEstimatedSavingsGBP,
    -- Carbon saved through donation diversion
    ROUND(SUM(d.Quantity * fi.CarbonFootprintPerUnit), 2)   AS TotalCarbonSavedKg
FROM Donations d
    JOIN WasteLogs wl ON d.LogID   = wl.LogID
    JOIN FoodItems fi ON wl.ItemID = fi.ItemID
    JOIN FoodBanks fb ON d.BankID  = fb.BankID
WHERE d.Status IN ('Delivered', 'Picked Up')
GROUP BY fb.BankID, fb.Name, fb.Location
ORDER BY TotalDonatedKg DESC;


-- =============================================================================
-- INDEX JUSTIFICATION SUMMARY
-- =============================================================================
-- All CREATE INDEX statements are in schema.sql. Summary of each:
--
-- idx_wastelogs_date       : Accelerates date-range filtering in Queries 5, 7.
-- idx_wastelogs_hall       : Speeds up JOIN to DiningHalls in Queries 1, 3.
-- idx_wastelogs_item       : Speeds up JOIN to FoodItems in Queries 1, 2, 7.
-- idx_wastelogs_hall_date  : Composite index for combined hall+date predicates.
-- idx_donations_bank       : Accelerates JOIN to FoodBanks in Queries 2, 8.
-- idx_donations_log        : Speeds up the reverse lookup from Donations to
--                            WasteLogs in Queries 2, 7, 8.
-- idx_volunteers_role      : Optimizes volunteer filtering by role in Query 4.
-- idx_fooditems_category   : Speeds up GROUP BY category in Query 6.
--
-- Without these indexes, the database engine would perform full table scans
-- on every JOIN and WHERE clause. With the indexes, the engine can use
-- B-tree index lookups to locate matching rows in O(log n) time rather
-- than O(n), which is critical as the WasteLogs table grows to thousands
-- of records over multiple academic years.
-- =============================================================================
