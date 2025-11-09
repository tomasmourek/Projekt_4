DROP TABLE IF EXISTS t_tomas_mourek_project_SQL_primary_final;

CREATE TABLE t_tomas_mourek_project_SQL_primary_final AS
WITH years_intersection AS (
    SELECT y FROM (
        SELECT DISTINCT payroll_year AS y
        FROM czechia_payroll
        WHERE value_type_code = 5958
          AND calculation_code = 200
          AND value IS NOT NULL
    ) p
    INNER JOIN (
        SELECT DISTINCT EXTRACT(YEAR FROM date_from)::int AS y
        FROM czechia_price
        WHERE value IS NOT NULL
    ) pr USING (y)
),
payroll_prep AS (
    SELECT
        cpib.name                                   AS industry_branch,
        cp.payroll_year                             AS year,
        ROUND(AVG(cp.value)::numeric, 2)            AS avg_salary
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib
      ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
      AND cp.calculation_code = 200
      AND cp.value IS NOT NULL
      AND cpib.name IS NOT NULL
      AND cp.payroll_year IN (SELECT y FROM years_intersection)
    GROUP BY cpib.name, cp.payroll_year
),
price_prep AS (
    SELECT
        cpc.name                                    AS food_category,
        EXTRACT(YEAR FROM cp.date_from)::int        AS year,
        ROUND(AVG(cp.value)::numeric, 2)            AS avg_price,
        cpc.price_value                             AS quantity,
        cpc.price_unit                              AS unit
    FROM czechia_price cp
    JOIN czechia_price_category cpc
      ON cp.category_code = cpc.code
    WHERE cp.value IS NOT NULL
      AND EXTRACT(YEAR FROM cp.date_from)::int IN (SELECT y FROM years_intersection)
    GROUP BY cpc.name, EXTRACT(YEAR FROM cp.date_from), cpc.price_value, cpc.price_unit
)
SELECT
    p.year,
    p.industry_branch,
    p.avg_salary,
    pr.food_category,
    pr.avg_price,
    pr.quantity,
    pr.unit
FROM payroll_prep p
JOIN price_prep pr USING (year)
ORDER BY p.year, p.industry_branch, pr.food_category;
