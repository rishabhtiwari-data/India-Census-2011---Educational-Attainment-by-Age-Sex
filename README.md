# Indian Census 2011 — Educational Attainment by Age and Sex

A reproducible data-analysis project based on **Census of India 2011, Table C-08: Educational Level by Age and Sex for Population Age 7 and Above**.

The project cleans the Census table, reshapes it into an analysis-ready fact table, runs SQL-based analytical queries, and presents the results through an interactive dashboard concept and a Power BI implementation plan.

> **Terminology:** Census C-08 reports **sex categories (Males/Females)**. This project uses *gender gap* only when interpreting differences between those sex-disaggregated measures. It does not claim that the dataset captures gender identity.

## Objectives

- Examine educational attainment across age groups from 7 years onward.
- Compare literacy outcomes for males and females.
- Compare rural and urban literacy.
- Rank States/UTs on literacy and educational attainment.
- Examine graduate-and-above attainment.
- Identify age-group patterns in illiteracy and higher educational attainment.
- Build a reproducible workflow from cleaning → transformation → SQL analysis → dashboard.

## Data source

**Office of the Registrar General & Census Commissioner, India (ORGI), Population Census 2011, Table C-08.**

Official catalog: https://censusindia.gov.in/nada/index.php/catalog/44790

The official metadata describes C-08 as educational level by age and sex for population age 7 and above, with Total/Rural/Urban residence and age groups including single years 7–19, grouped ages thereafter, and an `0–6` row treated as illiterate.

## Repository structure

```text
.
├── README.md
├── PROJECT_REPORT.md
├── C08_clean.csv
├── Fact_Education_Long.csv
├── Data_cleaning.ipynb
├── census c08 queries.sql
├── CensusDashboard.tsx
├── PowerBI Build Guide.pdf
└── report-assets/
    ├── chart_gender.png
    ├── chart_top_bottom.png
    ├── chart_rural_urban.png
    └── chart_age.png
```

## File guide

| File | Purpose |
|---|---|
| `C08_clean.csv` | Cleaned wide-format Census table; useful for Excel/SQL/reference work. |
| `Fact_Education_Long.csv` | Long-format fact table designed for Power BI and interactive filtering; 122,148 rows. |
| `Data_cleaning.ipynb` | Auditable Python/Pandas cleaning pipeline. |
| `census c08 queries.sql` | SQLite-compatible schema and 10 analytical SQL queries. |
| `CensusDashboard.tsx` | Interactive React/TypeScript preview of the dashboard. |
| `PowerBI Build Guide.pdf` | Power BI import instructions, DAX measures, page layouts and interaction guidance. |
| `PROJECT_REPORT.md` | Detailed methodology, findings, limitations and recommendations. |

## Data model

The cleaned wide table contains:

- **36 geographic units**: India + States/UTs represented in the source.
- **3 residence categories**: Total / Rural / Urban.
- **29 age groups**: All ages, 0–6, single years 7–19, grouped ages 20–24 through 80+, and Age not stated.
- **13 education categories**, represented for Persons, Males and Females.

The long table contains one observation per:

**State/UT × residence × age group × education level × sex category**

with fields:

`State_Code`, `State`, `Area_Type`, `Age_Group`, `Education_Level`, `Gender`, `Population`.

## Cleaning workflow

The notebook documents and fixes:

1. Multi-row merged Excel header.
2. Title/header rows and a stray artifact row.
3. Mixed numeric/text age labels.
4. Inconsistent `Area_Name` prefixes.
5. Constant metadata columns.
6. Empty trailing column.
7. Mixed/object population types.

It then runs sanity checks and saves the cleaned dataset.

**Reproducibility note:** the notebook expects the original `DDW-0000C-08.xlsx`. That raw workbook is referenced by the notebook but is not included in this project bundle. The supplied cleaned CSVs can therefore be used directly, while full raw-to-clean reproduction requires obtaining the original Census workbook.

## Main analytical definition

For this project:

```text
7+ Population = All-age Population − 0–6 Population

C-08 Derived Literacy Rate =
Literate Population / 7+ Population × 100
```

For India, the supplied C-08 data give:

- Total population: **1,210,854,977**
- 0–6 population: **164,515,253**
- Derived 7+ population: **1,046,339,724**
- Literate population: **763,638,812**
- C-08 derived literacy rate: **72.98%**
- Male literacy: **80.88%**
- Female literacy: **64.63%**

### Important rate-reconciliation note

The widely published Census 2011 headline literacy rate is **74.04%**, with male literacy at **82.14%** and female literacy at **65.46%**. The supplied C-08 file produces 72.98% when its `All ages` row is reduced by the `0–6` row.

This is a denominator/source-reconciliation issue. The project therefore labels its calculation **C-08 Derived Literacy Rate** rather than silently replacing it with the headline figure.

## Headline findings from the supplied data

### Highest C-08-derived literacy

1. Kerala — 94.00%
2. Lakshadweep — 91.85%
3. Mizoram — 91.33%
4. Goa — 88.70%
5. Tripura — 87.22%

### Lowest

1. Bihar — 61.80%
2. Arunachal Pradesh — 65.38%
3. Rajasthan — 66.11%
4. Jharkhand — 66.41%
5. Andhra Pradesh — 67.02%

### Largest male–female gaps

- Rajasthan — 27.07 percentage points
- Jharkhand — 21.42
- Dadra & Nagar Haveli — 20.86
- Jammu & Kashmir — 20.32
- Uttar Pradesh — 20.10

### Largest rural–urban gaps

- Dadra & Nagar Haveli — 25.66 percentage points
- Arunachal Pradesh — 22.99
- Jharkhand — 21.14
- Meghalaya — 20.87
- Andhra Pradesh — 19.64

### Educational attainment mix

Among literates nationally:

- Primary — 24.12%
- Below Primary — 19.24%
- Middle — 17.53%
- Matric/Secondary — 13.87%
- Higher Secondary — 10.21%
- Graduate & Above — 8.94%

## SQL analysis

The SQL file contains ten questions covering illiteracy, rural/urban literacy, sex-based gaps, graduate share, age patterns, residence gaps, technical qualifications, below-primary attainment, working-age literacy and higher-education gaps.

### SQL improvement required

Several supplied queries use `Total_Persons` as the denominator for `All ages`. If the intended statistic is an effective 7+ rate, those queries should instead use a denominator that excludes the corresponding 0–6 population.

Keep the original SQL for transparency, but add corrected versions/comments rather than silently changing it.

## Dashboard

The React/TypeScript preview contains:

1. **Overview**
2. **Gender Gap**
3. **Rural vs Urban**
4. **Age & Attainment**
5. **Education Mix**

The Power BI guide mirrors this five-page structure and provides DAX measures, slicers and cross-filtering guidance.

A key modelling recommendation is to separate aggregate levels (`Total`, `Illiterate`, `Literate`) from detailed attainment levels so that the same population is not counted twice.

## Recommended improvements

1. Standardise the 7+ denominator across Python, SQL, Power BI and React.
2. Add a `Level_Type` field separating aggregate and attainment categories.
3. Add automated validation checks.
4. Add a numeric age sort key.
5. Add a methodology page/card to the dashboard.
6. Add a short insight box to each dashboard page.
7. Add screenshots to the README.
8. Add a `DATA_DICTIONARY.md`.
9. Keep the denominator discrepancy visible and explained.
10. Avoid causal claims from descriptive Census data.

> **AI assistance:** Generative AI was used selectively for documentation, formatting and code-review support. The underlying Census files, calculations and final analytical decisions were reviewed against the project data and source documentation.

## Reproduction checklist

1. Obtain the official C-08 workbook referenced by the notebook.
2. Run `Data_cleaning.ipynb`.
3. Verify `C08_clean.csv`.
4. Refresh `Fact_Education_Long.csv`.
5. Load the fact table into Power BI.
6. Use consistent 7+ measures.
7. Build the five report pages.
8. Run the SQL analysis.
9. Compare SQL, Python and dashboard outputs.
10. Document any intentional difference between C-08-derived rates and headline Census rates.

## Detailed report

See [`PROJECT_REPORT.pdf`](PROJECT_REPORT.pdf).
