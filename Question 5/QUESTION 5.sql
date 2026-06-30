--QUESTION 5
USE Voltkart;
with customer_cte as (
select customer_id,
sum(order_total) as lifetime_spend
from fact_orders
group by customer_id
),
quartile_cte as(
select lifetime_spend,ntile(4) over(order by lifetime_spend) as spend_quartile
from customer_cte
)
select spend_quartile,count(*) as customer_count,AVG(lifetime_spend) as avg_lifetime_spend
from quartile_cte
group by spend_quartile
ORDER BY spend_quartile;