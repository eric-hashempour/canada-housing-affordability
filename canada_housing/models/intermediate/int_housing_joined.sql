SELECT 
    c.month_date,
    c.city,
    c.composite_benchmark,
    b.mortgage_arrears,
    b.loan_to_income_ratio,
    b.debt_service_ratio,
    b.mortgage_rate_5yrs_fixed,
    b.mortgage_rate_5yrs_variable,
    b.policy_rate,
    b.prime_rate  
FROM {{ ref('stg_crea_benchmark') }} c
LEFT JOIN {{ ref('stg_boc_rates') }} b
    ON c.month_date = DATE_TRUNC('month', b.month_date)