-- =============================================================================
-- CAMPUS FOOD WASTE TRACKER — SEED DATA
-- Realistic sample data for all 7 tables
-- =============================================================================
-- Data volumes:  5 Dining Halls, 55 Food Items, 18 Volunteers,
--               25 Waste Logs, 3 Food Banks, 12 Donations, 15 Hall Assignments
-- =============================================================================

PRAGMA foreign_keys = ON;


-- =============================================================================
-- DiningHalls (5 campus facilities)
-- =============================================================================
INSERT INTO DiningHalls (Name, Location, OperatingHours) VALUES
    ('The Great Hall',       'Main Campus, Building A',        '07:00-21:00'),
    ('Lakeside Bistro',      'Lakeside Residence Block',       '07:30-20:30'),
    ('Science Quarter Café', 'Science & Engineering Hub',      '08:00-19:00'),
    ('The Green Kitchen',    'Sustainability Centre',          '08:00-18:00'),
    ('Arts & Social Eatery', 'Arts Faculty, West Wing',        '07:30-20:00');


-- =============================================================================
-- FoodItems (55 items across 3 categories)
-- Carbon footprint values sourced from published lifecycle assessment data
-- (kg CO2 equivalent per kg of food)
-- =============================================================================

-- Category: 'prepared' — Cooked dishes and ready-to-eat meals (20 items)
INSERT INTO FoodItems (Name, Category, NutritionalInfo, CarbonFootprintPerUnit) VALUES
    ('Grilled Chicken Breast',            'prepared', 'Cal:165 P:31g C:0g F:3.6g',     6.90),
    ('Beef Lasagne',                      'prepared', 'Cal:135 P:8.5g C:11g F:6.5g',   27.00),
    ('Vegetable Stir Fry',               'prepared', 'Cal:85 P:3.2g C:10.5g F:3.8g',  2.00),
    ('Margherita Pizza',                  'prepared', 'Cal:250 P:11g C:30g F:10g',     4.10),
    ('Fish and Chips',                    'prepared', 'Cal:310 P:15g C:35g F:13g',     3.40),
    ('Mushroom Risotto',                  'prepared', 'Cal:175 P:4.5g C:28g F:5.5g',   3.50),
    ('Lamb Curry',                        'prepared', 'Cal:220 P:18g C:8g F:14g',      39.20),
    ('Caesar Salad',                      'prepared', 'Cal:120 P:8g C:6g F:8.5g',      3.80),
    ('Spaghetti Bolognese',               'prepared', 'Cal:180 P:12g C:22g F:5.5g',    14.00),
    ('Thai Green Curry (Tofu)',           'prepared', 'Cal:160 P:10g C:12g F:9g',      2.50),
    ('Shepherds Pie',                     'prepared', 'Cal:195 P:10g C:18g F:9.5g',    25.00),
    ('Falafel Wrap',                      'prepared', 'Cal:290 P:9g C:38g F:12g',      1.20),
    ('Chicken Tikka Masala',              'prepared', 'Cal:210 P:17g C:10g F:12g',     8.50),
    ('Vegan Mac and Cheese',              'prepared', 'Cal:240 P:7g C:32g F:10g',      1.80),
    ('Roast Pork with Vegetables',        'prepared', 'Cal:230 P:20g C:8g F:14g',      12.10),
    ('Jacket Potato with Beans',          'prepared', 'Cal:200 P:9g C:35g F:2.5g',     1.50),
    ('Paneer Butter Masala',              'prepared', 'Cal:280 P:14g C:12g F:20g',     5.00),
    ('BBQ Pulled Pork Sandwich',          'prepared', 'Cal:350 P:22g C:30g F:15g',     12.50),
    ('Mediterranean Grilled Vegetables',  'prepared', 'Cal:95 P:3g C:12g F:4.5g',      1.80),
    ('Egg Fried Rice',                    'prepared', 'Cal:190 P:7g C:30g F:5g',       4.80);

-- Category: 'raw' — Unprocessed ingredients used in meal preparation (20 items)
INSERT INTO FoodItems (Name, Category, NutritionalInfo, CarbonFootprintPerUnit) VALUES
    ('Fresh Chicken (whole)',             'raw', 'Cal:215 P:18g C:0g F:15g',      6.90),
    ('Beef Mince',                        'raw', 'Cal:250 P:17g C:0g F:20g',      27.00),
    ('Atlantic Salmon Fillet',            'raw', 'Cal:208 P:20g C:0g F:13g',      11.90),
    ('Broccoli',                          'raw', 'Cal:34 P:2.8g C:7g F:0.4g',     0.90),
    ('White Potatoes',                    'raw', 'Cal:77 P:2g C:17g F:0.1g',      0.50),
    ('Basmati Rice',                      'raw', 'Cal:350 P:7g C:78g F:0.6g',     2.70),
    ('Fresh Tomatoes',                    'raw', 'Cal:18 P:0.9g C:3.9g F:0.2g',   1.40),
    ('Onions',                            'raw', 'Cal:40 P:1.1g C:9.3g F:0.1g',   0.50),
    ('Whole Milk (1L)',                   'raw', 'Cal:61 P:3.2g C:4.8g F:3.3g',   3.20),
    ('Free Range Eggs (dozen)',           'raw', 'Cal:155 P:13g C:1.1g F:11g',    4.80),
    ('Carrots',                           'raw', 'Cal:41 P:0.9g C:10g F:0.2g',    0.40),
    ('Bell Peppers (mixed)',              'raw', 'Cal:31 P:1g C:6g F:0.3g',       1.10),
    ('Fresh Spinach',                     'raw', 'Cal:23 P:2.9g C:3.6g F:0.4g',   0.50),
    ('Cheddar Cheese',                    'raw', 'Cal:403 P:25g C:1.3g F:33g',    13.50),
    ('Olive Oil (extra virgin, 1L)',      'raw', 'Cal:884 P:0g C:0g F:100g',      3.50),
    ('Plain Flour',                       'raw', 'Cal:364 P:10g C:76g F:1g',      0.70),
    ('Tofu (firm)',                        'raw', 'Cal:144 P:15g C:3g F:8.5g',     2.00),
    ('Lamb Leg',                          'raw', 'Cal:282 P:17g C:0g F:23g',      39.20),
    ('Dried Pasta (penne)',               'raw', 'Cal:350 P:12g C:72g F:1.5g',    1.20),
    ('Garlic',                            'raw', 'Cal:149 P:6.4g C:33g F:0.5g',   0.60);

-- Category: 'packaged' — Pre-packaged snacks, drinks, sealed items (15 items)
INSERT INTO FoodItems (Name, Category, NutritionalInfo, CarbonFootprintPerUnit) VALUES
    ('Bottled Water 500ml',               'packaged', 'Cal:0 P:0g C:0g F:0g',         0.30),
    ('Orange Juice Carton 1L',            'packaged', 'Cal:42 P:0.7g C:9g F:0.1g',    0.80),
    ('Granola Bar (mixed nuts)',           'packaged', 'Cal:450 P:8g C:60g F:20g',     2.50),
    ('Salted Crisps 150g',                'packaged', 'Cal:530 P:6g C:52g F:34g',     2.80),
    ('Chocolate Brownie (wrapped)',        'packaged', 'Cal:420 P:5g C:55g F:22g',     4.50),
    ('Fruit Yoghurt Pot 150g',            'packaged', 'Cal:95 P:4.5g C:16g F:1.5g',   2.40),
    ('Protein Shake 330ml',               'packaged', 'Cal:150 P:25g C:12g F:2g',     3.00),
    ('Chicken and Bacon Sandwich',        'packaged', 'Cal:380 P:22g C:35g F:16g',    5.50),
    ('Banana',                            'packaged', 'Cal:89 P:1.1g C:23g F:0.3g',   0.70),
    ('Apple',                             'packaged', 'Cal:52 P:0.3g C:14g F:0.2g',   0.40),
    ('Energy Drink 250ml',                'packaged', 'Cal:45 P:0g C:11g F:0g',       1.50),
    ('Mixed Salad Pot',                   'packaged', 'Cal:25 P:1.5g C:3g F:0.5g',    1.00),
    ('Hummus and Breadsticks',            'packaged', 'Cal:280 P:8g C:30g F:14g',     1.50),
    ('Sushi Selection Box',               'packaged', 'Cal:190 P:9g C:32g F:3g',      5.00),
    ('Trail Mix 200g',                    'packaged', 'Cal:480 P:14g C:45g F:28g',    2.20);


-- =============================================================================
-- Volunteers (18 student volunteers)
-- =============================================================================
INSERT INTO Volunteers (Name, ContactInfo, Role) VALUES
    ('Aisha Khan',          'a.khan@student.uni.ac.uk',         'Coordinator'),
    ('Liam O''Brien',       'l.obrien@student.uni.ac.uk',       'Sorter'),
    ('Sofia Andersen',      's.andersen@student.uni.ac.uk',     'Coordinator'),
    ('Chen Wei',            'c.wei@student.uni.ac.uk',          'Sorter'),
    ('Fatima Al-Rashid',    'f.alrashid@student.uni.ac.uk',     'Driver'),
    ('Marcus Johnson',      'm.johnson@student.uni.ac.uk',      'Sorter'),
    ('Yuki Tanaka',         'y.tanaka@student.uni.ac.uk',       'Coordinator'),
    ('Emma Wilson',         'e.wilson@student.uni.ac.uk',       'Sorter'),
    ('Raj Patel',           'r.patel@student.uni.ac.uk',        'Driver'),
    ('Olivia Brown',        'o.brown@student.uni.ac.uk',        'Sorter'),
    ('Ahmed Hassan',        'a.hassan@student.uni.ac.uk',       'Coordinator'),
    ('Mia Garcia',          'mia.garcia@student.uni.ac.uk',     'Analyst'),
    ('Daniel Kim',          'd.kim@student.uni.ac.uk',          'Admin'),
    ('Grace Okafor',        'g.okafor@student.uni.ac.uk',       'Sorter'),
    ('Lucas Schmidt',       'l.schmidt@student.uni.ac.uk',      'Coordinator'),
    ('Zara Begum',          'z.begum@student.uni.ac.uk',        'Sorter'),
    ('Noah Davies',         'n.davies@student.uni.ac.uk',       'Driver'),
    ('Isabella Martinez',   'i.martinez@student.uni.ac.uk',     'Analyst');


-- =============================================================================
-- FoodBanks (3 partner organisations)
-- =============================================================================
INSERT INTO FoodBanks (Name, Location, PickupSchedule) VALUES
    ('City Harvest London',       '15 Bermondsey Street, SE1 3TQ',  'Mon/Thu 14:00'),
    ('FareShare Greater London',  'Unit 8, Imperial Way, NW10 7PA', 'Tue/Fri 15:00'),
    ('The Felix Project',         '43 Enfield Road, N1 5RP',        'Wed/Fri 13:00');


-- =============================================================================
-- WasteLogs (25 records spanning Jan–Mar 2026)
-- =============================================================================
INSERT INTO WasteLogs (HallID, ItemID, Quantity, LogDate, WasteType) VALUES
    -- January 2026
    (1, 1,  8.5,  '2026-01-13', 'overproduction'),
    (1, 2,  12.0, '2026-01-13', 'plate_waste'),
    (2, 4,  5.2,  '2026-01-14', 'expired'),
    (3, 3,  3.8,  '2026-01-15', 'overproduction'),
    (4, 6,  4.0,  '2026-01-15', 'plate_waste'),
    (5, 7,  6.5,  '2026-01-16', 'spoiled'),
    (1, 9,  9.0,  '2026-01-17', 'overproduction'),
    (2, 12, 2.5,  '2026-01-17', 'quality_issue'),
    -- February 2026
    (1, 5,  7.2,  '2026-02-03', 'overproduction'),
    (2, 21, 15.0, '2026-02-04', 'expired'),
    (3, 24, 6.0,  '2026-02-05', 'spoiled'),
    (4, 10, 3.5,  '2026-02-06', 'plate_waste'),
    (5, 14, 4.8,  '2026-02-07', 'overproduction'),
    (1, 27, 18.0, '2026-02-10', 'expired'),
    (2, 29, 10.5, '2026-02-11', 'spoiled'),
    (3, 8,  3.0,  '2026-02-12', 'plate_waste'),
    (4, 16, 5.5,  '2026-02-13', 'overproduction'),
    (5, 22, 8.0,  '2026-02-14', 'expired'),
    -- March 2026
    (1, 13, 6.8,  '2026-03-03', 'overproduction'),
    (2, 15, 5.5,  '2026-03-04', 'plate_waste'),
    (3, 34, 2.0,  '2026-03-05', 'quality_issue'),
    (4, 19, 4.2,  '2026-03-06', 'overproduction'),
    (5, 11, 7.5,  '2026-03-07', 'plate_waste'),
    (1, 25, 20.0, '2026-03-08', 'spoiled'),
    (2, 20, 3.0,  '2026-03-09', 'plate_waste');


-- =============================================================================
-- Donations (12 records — linked to overproduction waste logs)
-- Only edible surplus (overproduction) is donated; spoiled/expired is not.
-- =============================================================================
INSERT INTO Donations (LogID, BankID, Quantity, PickupTime, Status) VALUES
    (1,  1, 5.0,  '2026-01-13 14:00', 'Delivered'),      -- Grilled chicken surplus
    (4,  2, 2.5,  '2026-01-15 15:00', 'Delivered'),      -- Stir fry surplus
    (7,  1, 6.0,  '2026-01-17 14:00', 'Delivered'),      -- Spaghetti surplus
    (9,  3, 4.0,  '2026-02-03 13:00', 'Delivered'),      -- Fish & chips surplus
    (13, 2, 3.0,  '2026-02-07 15:00', 'Delivered'),      -- Vegan mac surplus
    (17, 1, 3.5,  '2026-02-13 14:00', 'Delivered'),      -- Jacket potato surplus
    (19, 3, 4.5,  '2026-03-03 13:00', 'Delivered'),      -- Chicken tikka surplus
    (22, 2, 2.5,  '2026-03-06 15:00', 'Picked Up'),      -- Grilled veg surplus
    (1,  3, 2.0,  '2026-01-13 16:00', 'Delivered'),      -- Second pickup for same log
    (7,  2, 2.0,  '2026-01-17 15:00', 'Delivered'),      -- Second pickup for same log
    (9,  1, 2.0,  '2026-02-03 14:00', 'Scheduled'),      -- Scheduled for pickup
    (22, 1, 1.5,  '2026-03-06 14:00', 'Pending');        -- Pending pickup


-- =============================================================================
-- HallAssignments (15 volunteer-to-hall assignments)
-- =============================================================================
INSERT INTO HallAssignments (HallID, VolunteerID) VALUES
    (1, 1),   -- Aisha at The Great Hall
    (1, 2),   -- Liam at The Great Hall
    (1, 13),  -- Daniel at The Great Hall
    (2, 3),   -- Sofia at Lakeside Bistro
    (2, 4),   -- Chen at Lakeside Bistro
    (2, 6),   -- Marcus at Lakeside Bistro
    (3, 7),   -- Yuki at Science Quarter
    (3, 9),   -- Raj at Science Quarter
    (3, 11),  -- Ahmed at Science Quarter
    (4, 5),   -- Fatima at The Green Kitchen
    (4, 12),  -- Mia at The Green Kitchen
    (4, 14),  -- Grace at The Green Kitchen
    (5, 8),   -- Emma at Arts & Social
    (5, 10),  -- Olivia at Arts & Social
    (5, 15);  -- Lucas at Arts & Social
