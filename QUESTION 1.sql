create database Voltkart;
USE Voltkart;

SELECT 'dim_category'        AS table_name, COUNT(*) AS rows FROM dim_category
UNION ALL SELECT 'dim_employee',        COUNT(*) FROM dim_employee
UNION ALL SELECT 'dim_customer',        COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product',         COUNT(*) FROM dim_product
UNION ALL SELECT 'fact_orders',         COUNT(*) FROM fact_orders
UNION ALL SELECT 'fact_order_items',    COUNT(*) FROM fact_order_items
UNION ALL SELECT 'stg_orders_incr',     COUNT(*) FROM stg_orders_incr
UNION ALL SELECT 'cdc_product_changes', COUNT(*) FROM cdc_product_changes;

-----------
--QUESTION 1

select top 20
o.order_id, 
o.order_date, 
c.customer_name, 
o.sales_rep_id, 
o.order_total
from dbo.fact_orders as o
inner join dbo.dim_customer as c
on o.customer_id=c.customer_id
where order_status='Completed'
order by o.order_total desc;