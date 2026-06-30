--QUESTION 2
USE Voltkart;
select 
c.customer_id, 
c.customer_name, 
c.signup_date
from dim_customer c
where not exists(

select 1 from fact_orders o where o.customer_id=c.customer_id

);