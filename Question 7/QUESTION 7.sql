--QUESTION 7
USE Voltkart;

WITH EmployeeSubtree AS
(
    -- each employee is in their own subtree
    SELECT
        employee_id AS root_employee,
        employee_id AS descendant_employee
    FROM dim_employee

    UNION ALL

    -- add descendants
    SELECT
        es.root_employee,
        e.employee_id
    FROM EmployeeSubtree es
    JOIN dim_employee e
        ON e.manager_id = es.descendant_employee
)

SELECT
    e.employee_id,
    e.employee_name,
    e.role,
    SUM(f.order_total) AS team_total_revenue
FROM EmployeeSubtree es
JOIN dim_employee e
    ON e.employee_id = es.root_employee
LEFT JOIN fact_orders f
    ON es.descendant_employee = f.sales_rep_id
GROUP BY
    e.employee_id,
    e.employee_name,
    e.role
order by e.employee_id;
