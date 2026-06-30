--INDEX

CREATE INDEX IX_fact_orders_OrderDate_Customer
ON dbo.fact_orders
(
    order_date,
    customer_id
)
INCLUDE (order_id);

CREATE INDEX IX_fact_order_items_Order
ON dbo.fact_order_items
(
    order_id
)
INCLUDE (line_amount);

--TURN ON PERFORMANCE STATISTICS
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

--REWRITTEN QUERY
SELECT
    o.customer_id,
    COUNT(*) AS orders_2024,
    lv.lifetime_value
FROM fact_orders o
JOIN
(
    SELECT
        o2.customer_id,
        SUM(oi.line_amount) AS lifetime_value
    FROM fact_orders o2
    JOIN fact_order_items oi
        ON o2.order_id = oi.order_id
    GROUP BY o2.customer_id
) AS lv
    ON o.customer_id = lv.customer_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01'
GROUP BY
    o.customer_id,
    lv.lifetime_value;