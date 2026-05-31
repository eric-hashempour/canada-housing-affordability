SELECT
month_date,
city,
composite_benchmark,
composite_benchmark - LAG(composite_benchmark) OVER (PARTITION BY city ORDER BY month_date) AS composite_benchmark_change,
mortgage_arrears,
loan_to_income_ratio,
debt_service_ratio,
mortgage_rate_5yrs_fixed,
mortgage_rate_5yrs_variable,
policy_rate,
policy_rate - LAG(policy_rate) OVER (PARTITION BY city ORDER BY month_date) AS policy_rate_change, 
composite_benchmark/policy_rate AS benchmark_to_rate_ratio 
FROM {{ref ('int_housing_joined')}}
ORDER BY month_date, city