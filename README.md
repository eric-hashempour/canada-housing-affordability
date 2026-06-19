# Canada Housing Affordability Analysis

**Research Question:** How did Bank of Canada rate hikes between 2022 and 2024 affect housing affordability across Canadian cities?

## Key Findings
- Following the Bank of Canada's rate hikes beginning March 2022, the national Debt Service Ratio rose from 16.3% to a peak of 20.6% by early 2024 — the highest level in the study period.
- Only **Calgary, Vancouver, and Halifax** showed a statistically significant relationship between policy rate and benchmark prices (p < 0.05).
- **Vancouver** showed the highest price sensitivity with a coefficient of 31,133 — meaning each 1% rate increase was associated with a $31,133 rise in benchmark prices.
- **Calgary** had the strongest model fit (R² = 0.55).
- Eastern cities like Toronto, Montreal, and Ottawa were not statistically significant, suggesting other factors dominate their price movements.
- Benchmark price growth peaked at over 20% YOY in early 2022, then turned sharply negative in 2023 as rate hikes took effect.
- Halifax and Toronto experienced the most dramatic price swings — Halifax surged nearly 40% YOY at peak before falling to -10%, with Toronto going from 32% to -18%.

## Overview
This project analyzes the relationship between Bank of Canada monetary policy and housing affordability across 8 major Canadian cities from 2018 to 2024. It demonstrates a complete end-to-end data engineering and analysis pipeline — from API ingestion through cloud warehousing, transformation, machine learning, and interactive visualization.

## Tech Stack
| Layer | Tool | Purpose |
|-------|------|---------|
| Data Collection | Python (pandas, requests) | BoC API ingestion and CREA data processing |
| Cloud Warehouse | Snowflake | RAW → STAGING → MARTS schema architecture |
| Transformation | dbt | Staging views, intermediate joins, mart models with window functions |
| Modeling | scikit-learn + statsmodels | Per-city OLS regression and significance testing |
| Visualization | Power BI | Interactive 4-page dashboard |
| CI/CD | GitHub Actions | Automated dbt test runs on every push |

## Project Structure

```
canada-housing-affordability/
├── data/
│   ├── raw/                          # Original source files
│   └── processed/                    # Cleaned CSVs and Snowflake mart exports
├── notebooks/
│   └── canada_housing.ipynb          # Data collection, EDA, modeling, Snowflake loading
├── dbt/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_boc_rates.sql
│   │   │   └── stg_crea_benchmark.sql
│   │   ├── intermediate/
│   │   │   └── int_housing_joined.sql
│   │   └── marts/
│   │       └── mart_affordability.sql
│   ├── macros/
│   │   └── generate_schema_name.sql  # Custom schema naming macro
│   ├── schema.yml                    # Tests and documentation
│   └── dbt_project.yml
├── .github/
│   └── workflows/
│       └── dbt_test.yml              # GitHub Actions CI/CD pipeline
├── .env.example                      # Environment variable template
└── requirements.txt                  # Python dependencies
```

## Data Sources
| Source | Data | Reason Chosen |
|--------|------|---------------|
| Bank of Canada Valet API | Policy rate, prime rate, 5yr fixed/variable mortgage rates, debt service ratio, loan-to-income ratio, mortgage arrears | Official source for Canadian monetary policy data |
| CREA MLS Benchmark HPI | Composite benchmark prices by city (2018–present) | Provides actual dollar values vs index-only sources like StatCan NHPI |

### Data Notes
- **DSR Series Splice:** The Debt Service Ratio series was spliced between the discontinued RESL1 and newer RESL2 at 2024 Q2 to extend coverage through 2025.
- **DSR is a national series** replicated across cities — it captures aggregate debt burden, not city-specific affordability. City-level price variation is captured through CREA composite benchmark prices.
- **City-level household income data** was unavailable at monthly granularity. Price-to-income ratio analysis is identified as a future enhancement.

## Cities Covered
Greater Toronto, Greater Vancouver, Calgary, Edmonton, Montreal CMA, Ottawa, Winnipeg, Halifax-Dartmouth

## Snowflake Architecture
### RAW
| Table | Description |
|-------|-------------|
| BOC_RATES_MONTHLY | Monthly Bank of Canada rate and affordability metrics |
| CREA_MONTHLY | Monthly composite benchmark prices by city |

### STAGING
| View | Description |
|------|-------------|
| STG_BOC_RATES | Cleaned and typed BoC rates |
| STG_CREA_BENCHMARK | Cleaned and typed CREA benchmark prices |
| INT_HOUSING_JOINED | Joined staging views on month date |

### MARTS
| Table | Description |
|-------|-------------|
| MART_AFFORDABILITY | Full enriched time series with LAG window functions, YOY change, and derived ratios |
| MART_MODEL_SKTLEARN | Per-city regression results: policy coefficient, R², RMSE, p-value, predicted benchmark |

## Methodology
- **Model:** Per-city OLS linear regression — `COMPOSITE_BENCHMARK ~ POLICY_RATE`
- **Date range:** 2019–2024 (restricted to last common available data point across all variables)
- **Libraries:** scikit-learn for coefficient extraction; statsmodels for p-value significance testing
- **Modeling note:** `BENCHMARK_YOY_PERCENTAGE_CHANGE` was excluded as a predictor due to multicollinearity with the target variable. `DEBT_SERVICE_RATIO` was excluded as a predictor as it is a national series with no city-level variation.

### Known Limitations
- DSR is a national aggregate — city-level debt burden data was unavailable
- Low R² values for some cities (Toronto, Montreal, Ottawa) indicate policy rate alone does not fully explain price movements in those markets
- Toronto and Vancouver show the highest RMSE, reflecting their larger absolute price levels and greater price volatility beyond policy rate movements
- Annual income data at CMA level exists (StatCan Table 11-10-0239-01) but monthly interpolation would introduce artifacts — documented as future enhancement

## Dashboard
[Add screenshot here]

Built in Power BI with 4 pages:
| Page | Description |
|------|-------------|
| Overview | Project context, research question, data sources, tools |
| National Affordability | Policy Rate vs DSR dual-axis, mortgage rates and loan-to-income ratio trends |
| City Trends | Multi-city benchmark comparison, city slicer, YOY bar chart |
| Reaction to Policy Changes | Map with per-city model metrics, methodology and findings callouts |

## Setup
1. Clone the repository
   ```bash
   git clone https://github.com/eric-hashempour/canada-housing-affordability.git
   ```
2. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```
3. Copy `.env.example` to `.env` and fill in your Snowflake credentials
   ```
   SNOWFLAKE_USER=
   SNOWFLAKE_PASSWORD=
   SNOWFLAKE_ACCOUNT=
   SNOWFLAKE_WAREHOUSE=
   SNOWFLAKE_DATABASE=
   SNOWFLAKE_SCHEMA=
   ```
4. Run the notebook — `canada_housing.ipynb`
5. Set up dbt profile and run
   ```bash
   dbt run
   dbt test
   ```

> **Note:** The Snowflake free trial has expired. The Power BI dashboard runs on exported CSVs in `data/processed/`. To fully reproduce the Snowflake pipeline, a new Snowflake account would be required.

## Design Decisions
- **CREA over CMHC/StatCan:** CMHC provides housing starts (supply-side) and StatCan NHPI is index-based without dollar values. CREA benchmark prices are actual dollar figures suitable for affordability analysis.
- **Full refresh over incremental loading:** Dataset is small (~800 rows total). Full refresh is simpler and appropriate at this scale.
- **Custom dbt schema macro:** `generate_schema_name.sql` required to prevent dbt from prepending the default schema name to custom schema names in Snowflake.
- **2018 baseline:** Provides pre-pandemic context for the 2022–2024 rate hike analysis.
- **scikit-learn + statsmodels:** scikit-learn used for per-city coefficient extraction; statsmodels added for p-value significance testing which scikit-learn does not natively provide.