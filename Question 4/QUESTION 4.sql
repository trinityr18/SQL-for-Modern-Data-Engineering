--QUESTION 4
USE Voltkart;
with monthly_data as(
SELECT
    FORMAT(order_month, 'yyyy-MM') AS order_month,
    monthly_revenue
FROM (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(order_total) AS monthly_revenue
    FROM fact_orders
    WHERE order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)sub

)
select 
order_month,
sum(monthly_revenue) over(order by order_month rows between unbounded preceding and current row) as running_total,
ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        * 100.0
        / LAG(monthly_revenue) OVER (ORDER BY order_month),
        2
    ) AS mom_pct_change
from monthly_data
order by order_month;