DROP VIEW IF EXISTS v_tomas_mourek_wages_trend CASCADE;

CREATE VIEW v_tomas_mourek_wages_trend AS
WITH base AS (
    SELECT DISTINCT
        year,
        industry_branch_name,
        avg_wage_per_industry
    FROM t_tomas_mourek_project_sql_primary_final
    WHERE industry_branch_name IS NOT NULL
),
lagged AS (
    SELECT
        year,
        industry_branch_name,
        avg_wage_per_industry,
        LAG(avg_wage_per_industry) OVER (
            PARTITION BY industry_branch_name
            ORDER BY year
        ) AS prev_wage
    FROM base
)
SELECT
    industry_branch_name AS industry,
    year,
    avg_wage_per_industry AS avg_wage,
    ROUND(
        100.0 * (avg_wage_per_industry - prev_wage) / NULLIF(prev_wage, 0),
        2
    ) AS yoy_wage_growth_pct,
    CASE
        WHEN prev_wage IS NULL THEN NULL
        WHEN avg_wage_per_industry < prev_wage THEN TRUE
        ELSE FALSE
    END AS wage_decrease
FROM lagged
ORDER BY
    industry,
    year;
