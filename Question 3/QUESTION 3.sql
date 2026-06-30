--QUESTION 3
USE Voltkart;
WITH revenue_cte AS (
    SELECT
        cat.category_name,
        p.product_name,
        SUM(o.order_total) AS total_revenue
    FROM dim_category AS cat
    INNER JOIN dim_product AS p
        ON cat.category_id = p.category_id
    INNER JOIN fact_order_items AS oi
        ON oi.product_id = p.product_id
    INNER JOIN fact_orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        cat.category_name,
        p.product_name
)
SELECT TOP 3
    category_name,
    product_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM revenue_cte
ORDER BY total_revenue DESC;