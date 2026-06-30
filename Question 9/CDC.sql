USE Voltkart;
GO
--1. Enable CDC at Database Level (Run Once)
IF NOT EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = DB_NAME()
      AND is_cdc_enabled = 1
)
BEGIN
    EXEC sys.sp_cdc_enable_db;
END
GO
--------------------
--dim_product has no primary key
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'dim_product'

---add pk constraint to dim_product
select * from dbo.dim_product;
ALTER TABLE dbo.dim_product
ADD CONSTRAINT PK_Product
PRIMARY KEY (product_id);

--pk added to dim_product
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'dim_product'
-------------------------

--2. Enable CDC for dbo.dim_product Table (Run Once)
IF NOT EXISTS (
    SELECT 1
    FROM cdc.change_tables
    WHERE source_object_id = OBJECT_ID('dbo.dim_product')
)
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema = 'dbo',
        @source_name = 'dim_product',
        @role_name = NULL,
        @supports_net_changes = 1;
END
GO

---
--3. Create Catalogue CDC Feed Table


IF OBJECT_ID('dbo.cdc_product_changes','U') IS NOT NULL
DROP TABLE dbo.cdc_product_changes;
GO
CREATE TABLE dbo.cdc_product_changes
(
    operation CHAR(1),     -- I = Insert, U = Update, D = Delete

    product_id INT,

    product_name VARCHAR(100),

    category_id INT,

    unit_price DECIMAL(10,2),

    unit_cost DECIMAL(10,2),

    launch_date DATE
);
GO
----
--5. Load Sample CDC Feed
INSERT INTO dbo.cdc_product_changes
(
    operation,
    product_id,
    product_name,
    category_id,
    unit_price,
    unit_cost,
    launch_date
)
VALUES

-- INSERT example
(
'I',
1001,
'Voltkart Laptops New',
10,
75000,
60000,
'2026-06-29'
),


-- UPDATE example
(
'U',
900002,
'Updated Phone',
20,
45000,
32000,
'2026-06-01'
),


-- DELETE example
(
'D',
900003,
NULL,
NULL,
NULL,
NULL,
NULL
);

GO
--6. SINGLE MERGE Handles I / U / D
MERGE dbo.dim_product AS target

USING dbo.cdc_product_changes AS source

ON target.product_id = source.product_id



/* Existing product + Update */

WHEN MATCHED
AND source.operation = 'U'

THEN UPDATE SET

    target.product_name = source.product_name,

    target.category_id  = source.category_id,

    target.unit_price   = source.unit_price,

    target.unit_cost    = source.unit_cost,

    target.launch_date  = source.launch_date



/* Existing product + Delete */

WHEN MATCHED
AND source.operation = 'D'

THEN DELETE



/* New product + Insert */

WHEN NOT MATCHED
AND source.operation = 'I'

THEN INSERT
(
    product_id,
    product_name,
    category_id,
    unit_price,
    unit_cost,
    launch_date
)

VALUES
(
    source.product_id,
    source.product_name,
    source.category_id,
    source.unit_price,
    source.unit_cost,
    source.launch_date
)


OUTPUT
    $action AS Merge_Action,
    inserted.product_id AS Inserted_Product,
    deleted.product_id AS Deleted_Product;

GO
--7. Verification Queries


SELECT *
FROM dbo.dim_product
WHERE product_id IN
(
    SELECT product_id
    FROM dbo.cdc_product_changes
    WHERE operation = 'I'
);

SELECT

    p.product_id,

    p.product_name AS product_now,

    p.product_name AS product_from_feed

FROM dbo.dim_product p

JOIN dbo.cdc_product_changes c

ON p.product_id = c.product_id

WHERE c.operation = 'U';

SELECT product_id

FROM dbo.cdc_product_changes

WHERE operation = 'D'

AND product_id IN
(
    SELECT product_id
    FROM dbo.dim_product
);

GO
