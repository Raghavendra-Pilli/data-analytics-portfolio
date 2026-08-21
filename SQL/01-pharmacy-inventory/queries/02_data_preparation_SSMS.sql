-- ============================================================
-- SQL-1: Pharmacy Inventory Replenishment Analysis
-- Script 02: Data Preparation
-- SQL Server / SSMS compatible version
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Create the table (run BEFORE importing CSV)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS pharma_sales;

CREATE TABLE pharma_sales (
    datum       DATE           NOT NULL PRIMARY KEY,
    m01ab       DECIMAL(10,2),
    m01ae       DECIMAL(10,2),
    n02ba       DECIMAL(10,2),
    n02be       DECIMAL(10,2),
    n05b        DECIMAL(10,2),
    n05c        DECIMAL(10,2),
    r03         DECIMAL(10,2),
    r06         DECIMAL(10,2)
);

-- After running this, use SSMS Import Wizard:
-- Right-click database > Tasks > Import Flat File > select salesdaily.csv
-- Choose "Use existing table" > pharma_sales

-- ------------------------------------------------------------
-- STEP 2: Add derived columns
-- ------------------------------------------------------------
ALTER TABLE pharma_sales ADD sales_year          INT;
ALTER TABLE pharma_sales ADD sales_month         INT;
ALTER TABLE pharma_sales ADD sales_quarter       INT;
ALTER TABLE pharma_sales ADD day_of_week         NVARCHAR(20);
ALTER TABLE pharma_sales ADD total_daily_sales   DECIMAL(12,2);

UPDATE pharma_sales SET
    sales_year        = YEAR(datum),
    sales_month       = MONTH(datum),
    sales_quarter     = DATEPART(QUARTER, datum),
    day_of_week       = DATENAME(WEEKDAY, datum),
    total_daily_sales = ROUND(
        ISNULL(m01ab,0) + ISNULL(m01ae,0) + ISNULL(n02ba,0) +
        ISNULL(n02be,0) + ISNULL(n05b,0)  + ISNULL(n05c,0)  +
        ISNULL(r03,0)   + ISNULL(r06,0), 2
    );

-- ------------------------------------------------------------
-- STEP 3: Drug category lookup table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS drug_categories;

CREATE TABLE drug_categories (
    category_code   NVARCHAR(10)  NOT NULL PRIMARY KEY,
    category_name   NVARCHAR(100) NOT NULL,
    drug_class      NVARCHAR(100) NOT NULL,
    typical_use     NVARCHAR(200)
);

INSERT INTO drug_categories VALUES
    ('M01AB', 'Acetic acid derivatives',    'Anti-inflammatory / Analgesic', 'Diclofenac — pain and inflammation'),
    ('M01AE', 'Propionic acid derivatives', 'Anti-inflammatory / Analgesic', 'Ibuprofen — pain, fever, inflammation'),
    ('N02BA', 'Salicylic acid derivatives', 'Analgesic / Antipyretic',       'Aspirin — pain, fever, cardiovascular'),
    ('N02BE', 'Anilides',                   'Analgesic / Antipyretic',       'Paracetamol — most common OTC painkiller'),
    ('N05B',  'Anxiolytics',                'Central Nervous System',        'Anti-anxiety medications'),
    ('N05C',  'Hypnotics and sedatives',    'Central Nervous System',        'Sleep aids'),
    ('R03',   'Obstructive airway drugs',   'Respiratory',                   'Asthma / COPD inhalers and tablets'),
    ('R06',   'Systemic antihistamines',    'Allergy / Respiratory',         'Hay fever, allergic reactions');

-- ------------------------------------------------------------
-- STEP 4: Verify preparation
-- ------------------------------------------------------------
SELECT
    COUNT(*)                         AS total_rows,
    MIN(datum)                       AS date_from,
    MAX(datum)                       AS date_to,
    ROUND(AVG(total_daily_sales), 2) AS avg_daily_total,
    ROUND(SUM(total_daily_sales), 2) AS grand_total_sales
FROM pharma_sales;
