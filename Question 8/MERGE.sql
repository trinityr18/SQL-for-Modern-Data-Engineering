--QUESTION 8
USE Voltkart;
select count(*) from stg_orders_incr;
select count(*) from fact_orders;

merge into fact_orders as tgt
using stg_orders_incr as src
on tgt.order_id=src.order_id

when matched and(
isnull(tgt.order_status,'')<>isnull(src.order_status,'')
or isnull(tgt.order_total,'')<>isnull(src.order_total,'')
)
then update set 
    tgt.order_status=src.order_status,
    tgt.order_total=src.order_total
    
when not matched by TARGET THEN
INSERT(order_id,order_date,customer_id,sales_rep_id,order_status,order_total)
values(src.order_id,src.order_date,src.customer_id,src.sales_rep_id,src.order_status,src.order_total);
select count(*) from fact_orders;