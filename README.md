
# Canada Housing Affordability Analysis

**Research Question:** How did Bank of Canada rate hikes between 2022 and 2024 affect housing affordability across Canadian cities?

## Overview
This project analyzes the relationship between Bank of Canada monetary policy and housing affordability across major Canadian cities from 2018 to present. It demonstrates an end-to-end data engineering and analysis pipeline.

## Tech Stack
- **Python** (pandas, matplotlib, requests) — data collection and processing
- **Snowflake** — cloud data warehouse
- **dbt** — data transformations
- **scikit-learn** — regression modeling
- **Power BI** — dashboard and visualization

## Project Structure

canada_housing_project/
├── data/
│   ├── raw/          # Source files (excluded from git)
│   └── processed/    # Cleaned CSVs (excluded from git)
├── notebooks/
│   ├── 01_canada_housing.ipynb      # Data collection and EDA
│   └── 02_load_to_snowflake.ipynb   # Snowflake loading
├── sql/              # SQL scripts
├── docs/             # Documentation
├── .env.example      # Environment variable template
└── requirements.txt  # Python dependencies

## Data Sources
| Source | Data | Reason Chosen |
|--------|------|---------------|
| Bank of Canada Valet API | Policy rate, prime rate, fixed/variable mortgage rates, debt service ratio, loan-to-income ratio, mortgage arrears | Official source for Canadian monetary policy data |
| CREA MLS Benchmark HPI | Composite benchmark prices by city (2018–present) | Provides actual dollar values vs index-only sources like StatCan NHPI |

## Cities Covered
Greater Toronto, Greater Vancouver, Calgary, Edmonton, Montreal CMA, Ottawa, Winnipeg, Halifax-Dartmouth

## Snowflake Schema
### RAW
| Table | Description |
|-------|-------------|
| BOC_RATES | Monthly Bank of Canada rate and affordability metrics |
| CREA_MONTHLY | Monthly composite benchmark prices by city |

### STAGING
*In progress — dbt transformations*

### MARTS
*In progress — final analytical tables*

## Design Decisions
- **CREA over CMHC/StatCan:** CMHC provides housing starts (supply-side) and StatCan NHPI is index-based without dollar values. CREA benchmark prices are actual dollar figures suitable for affordability analysis.
- **Full refresh over incremental loading:** Dataset is small (~900 rows total). Full refresh is simpler and appropriate at this scale. Incremental loading would be the production approach for larger datasets.
- **2018 baseline:** Provides pre-pandemic context for the 2022–2024 rate hike analysis.

## Setup
1. Clone the repository
2. Copy `.env.example` to `.env` and fill in your Snowflake credentials
3. Install dependencies: `pip install -r requirements.txt`
4. Run notebooks in order