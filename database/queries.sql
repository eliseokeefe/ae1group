PRAGMA foreign_keys = ON;

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
    SELECT DISTINCT wl.HallID
    FROM WasteLogs wl
        JOIN Donations d ON wl.LogID = d.LogID
)
ORDER BY dh.Name, v.Name;

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
    SELECT CAST(COUNT(*) AS REAL) / COUNT(DISTINCT fi2.Category)
    FROM WasteLogs wl2
        JOIN FoodItems fi2 ON wl2.ItemID = fi2.ItemID
)
ORDER BY TotalWasteKg DESC;

SELECT
    strftime('%Y-%m', wl.LogDate) AS Month,
    ROUND(SUM(wl.Quantity), 2)    AS TotalWasteKg,
    ROUND(SUM(wl.Quantity * fi.CarbonFootprintPerUnit), 2)  AS CarbonFromWasteKg,
    ROUND(COALESCE(don_agg.TotalDonatedKg, 0), 2)           AS TotalDonatedKg,
    ROUND(COALESCE(don_agg.CarbonSavedKg, 0), 2)            AS CarbonSavedByDonationsKg,
    ROUND(
        SUM(wl.Quantity * fi.CarbonFootprintPerUnit) -
        COALESCE(don_agg.CarbonSavedKg, 0),
    2) AS NetCarbonImpactKg,
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

SELECT
    fb.Name                                                 AS FoodBank,
    fb.Location,
    COUNT(d.DonationID)                                     AS TotalDonations,
    ROUND(SUM(d.Quantity), 2)                               AS TotalDonatedKg,
    
    ROUND(SUM(d.Quantity) * 0.15, 2)                        AS AvoidedDisposalCostGBP,
  
    ROUND(SUM(d.Quantity) * 2.50, 2)                        AS EstimatedFoodValueGBP,
    
    ROUND(SUM(d.Quantity) * (0.15 + 2.50), 2)               AS TotalEstimatedSavingsGBP,
    
    ROUND(SUM(d.Quantity * fi.CarbonFootprintPerUnit), 2)   AS TotalCarbonSavedKg
FROM Donations d
    JOIN WasteLogs wl ON d.LogID   = wl.LogID
    JOIN FoodItems fi ON wl.ItemID = fi.ItemID
    JOIN FoodBanks fb ON d.BankID  = fb.BankID
WHERE d.Status IN ('Delivered', 'Picked Up')
GROUP BY fb.BankID, fb.Name, fb.Location
ORDER BY TotalDonatedKg DESC;
