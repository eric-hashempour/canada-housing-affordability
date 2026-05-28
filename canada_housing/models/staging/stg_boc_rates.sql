SELECT
    CAST(date AS DATE) AS month_date,
    mortgage_arrears,
    loan_to_income_ratio,
    debt_service_ratio,
    mortgage_rate_5yrs_fixed,
    mortgage_rate_5yrs_variable,
    policy_rate,
    prime_rate   
FROM {{ source('raw', 'BOC_RATES') }}