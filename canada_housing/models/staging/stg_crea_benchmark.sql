SELECT
    Cast(Date AS DATE) AS month_date,
    City AS city,
    Composite_Benchmark AS composite_benchmark
FROM {{ source('raw', 'CREA_MONTHLY') }}