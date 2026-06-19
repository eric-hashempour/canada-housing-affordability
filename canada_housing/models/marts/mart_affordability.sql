SELECT
month_date,
city,
composite_benchmark,
composite_benchmark - LAG(composite_benchmark) OVER (PARTITION BY city ORDER BY month_date) AS composite_benchmark_change,
mortgage_arrears * 100 AS mortgage_arrears,
loan_to_income_ratio,
debt_service_ratio,
mortgage_rate_5yrs_fixed,
mortgage_rate_5yrs_variable,
policy_rate,
policy_rate - LAG(policy_rate) OVER (PARTITION BY city ORDER BY month_date) AS policy_rate_change, 
ROUND(composite_benchmark/policy_rate, 2) AS benchmark_to_rate_ratio,
CAST(ROUND(((composite_benchmark - LAG(composite_benchmark, 12) OVER (PARTITION BY city ORDER BY month_date))/ LAG(composite_benchmark, 12) OVER (PARTITION BY city ORDER BY month_date) * 100), 2) AS FLOAT) AS benchmark_yoy_percentage_change 
FROM {{ref ('int_housing_joined')}}
ORDER BY city, month_date