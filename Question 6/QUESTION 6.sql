--QUESTION 6
USE Voltkart;
WITH CategoryTree AS
(
    SELECT category_id, category_name,
    1 AS depth_level,
    CAST(category_name AS VARCHAR(MAX)) AS category_path
    FROM dim_category
    WHERE category_name = 'Computers'

    UNION ALL

    SELECT 
        c.category_id, c.category_name,
        cte.depth_level + 1, 
        CAST(cte.category_path + ' -> ' + c.category_name AS VARCHAR(MAX))
    FROM dim_category c
    INNER JOIN CategoryTree cte 
        ON c.parent_category_id = cte.category_id

)
SELECT 
category_id,category_name,depth_level,category_path
from CategoryTree
order by category_path;