USE Voltkart;

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month
    FROM fact_orders
    WHERE order_status = 'Completed'
),

months AS (
    SELECT
        customer_id,
        order_month,
        LAG(order_month) OVER (
            PARTITION BY customer_id
            ORDER BY order_month
        ) AS prev_month
    FROM customer_months
),

groups_cte AS (
    SELECT
        customer_id,
        order_month,
        SUM(
            CASE
                WHEN prev_month IS NULL
                     OR DATEDIFF(MONTH, prev_month, order_month) <> 1
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY customer_id
            ORDER BY order_month
        ) AS grp
    FROM months
),

streaks AS (
    SELECT
        customer_id,
        grp,
        COUNT(*) AS streak_months
    FROM groups_cte
    GROUP BY customer_id, grp
)

SELECT
    c.customer_id,
    c.customer_name,
    ISNULL(MAX(s.streak_months), 0) AS longest_streak_months
FROM dim_customer c
LEFT JOIN streaks s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY longest_streak_months DESC;