-- ============================================================
-- Census 2011 (India) Table C-08 — Educational Level by Age and Sex
-- SQL analysis queries
-- Source data: C08_clean.csv / C08_clean.xlsx
-- Tested against SQLite; for MySQL replace double-quoted
-- identifiers with backticks.
-- ============================================================

-- ------------------------------------------------------------
-- Schema (load C08_clean.csv into this table before running
-- the queries below, e.g. in SQLite:
--   sqlite3 census.db
--   .mode csv
--   .import C08_clean.csv education
-- or, since the CSV already has a header row, use pandas'
-- df.to_sql('education', conn, index=False) instead.)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS education;

CREATE TABLE education (
  "State_Code"                                                              INTEGER,
  "Area_Name_Clean"                                                         TEXT,
  "Total_Rural_Urban"                                                       TEXT,
  "Age_Group"                                                               TEXT,
  "Total_Persons"                                                           INTEGER,
  "Total_Males"                                                             INTEGER,
  "Total_Females"                                                           INTEGER,
  "Illiterate_Persons"                                                      INTEGER,
  "Illiterate_Males"                                                        INTEGER,
  "Illiterate_Females"                                                      INTEGER,
  "Literate_Persons"                                                        INTEGER,
  "Literate_Males"                                                          INTEGER,
  "Literate_Females"                                                        INTEGER,
  "Literate_without_educational_level_Persons"                              INTEGER,
  "Literate_without_educational_level_Males"                                INTEGER,
  "Literate_without_educational_level_Females"                              INTEGER,
  "Below_primary_Persons"                                                   INTEGER,
  "Below_primary_Males"                                                     INTEGER,
  "Below_primary_Females"                                                   INTEGER,
  "Primary_Persons"                                                         INTEGER,
  "Primary_Males"                                                           INTEGER,
  "Primary_Females"                                                         INTEGER,
  "Middle_Persons"                                                          INTEGER,
  "Middle_Males"                                                            INTEGER,
  "Middle_Females"                                                          INTEGER,
  "Matric_Secondary_Persons"                                                INTEGER,
  "Matric_Secondary_Males"                                                  INTEGER,
  "Matric_Secondary_Females"                                                INTEGER,
  "Higher_secondary_Intermediate_Pre-University_Senior_secondary_Persons"   INTEGER,
  "Higher_secondary_Intermediate_Pre-University_Senior_secondary_Males"     INTEGER,
  "Higher_secondary_Intermediate_Pre-University_Senior_secondary_Females"   INTEGER,
  "Non-technical_diploma_or_certificate_not_equal_to_degree_Persons"        INTEGER,
  "Non-technical_diploma_or_certificate_not_equal_to_degree_Males"          INTEGER,
  "Non-technical_diploma_or_certificate_not_equal_to_degree_Females"        INTEGER,
  "Technical_diploma_or_certificate_not_equal_to_degree_Persons"            INTEGER,
  "Technical_diploma_or_certificate_not_equal_to_degree_Males"              INTEGER,
  "Technical_diploma_or_certificate_not_equal_to_degree_Females"            INTEGER,
  "Graduate_&_above_Persons"                                                INTEGER,
  "Graduate_&_above_Males"                                                  INTEGER,
  "Graduate_&_above_Females"                                                INTEGER,
  "Unclassified_Persons"                                                    INTEGER,
  "Unclassified_Males"                                                      INTEGER,
  "Unclassified_Females"                                                    INTEGER
);


-- ------------------------------------------------------------
-- Q1. Which states have the highest illiteracy rate (Total, All ages)?
-- ------------------------------------------------------------
SELECT Area_Name_Clean,
       ROUND(100.0 * Illiterate_Persons / Total_Persons, 2) AS illiteracy_pct
FROM education
WHERE Total_Rural_Urban = 'Total' AND Age_Group = 'All ages' AND Area_Name_Clean <> 'INDIA'
ORDER BY illiteracy_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q2. How does literacy rate differ between rural and urban areas nationally?
-- ------------------------------------------------------------
SELECT Total_Rural_Urban,
       ROUND(100.0 * SUM(Literate_Persons) / SUM(Total_Persons), 2) AS literacy_pct
FROM education
WHERE Area_Name_Clean = 'INDIA' AND Age_Group = 'All ages'
GROUP BY Total_Rural_Urban;


-- ------------------------------------------------------------
-- Q3. What is the gender gap in literacy (Males vs Females) by state?
-- ------------------------------------------------------------
SELECT Area_Name_Clean,
       ROUND(100.0 * Literate_Males / Total_Males, 2) AS male_literacy_pct,
       ROUND(100.0 * Literate_Females / Total_Females, 2) AS female_literacy_pct
FROM education
WHERE Total_Rural_Urban = 'Total' AND Age_Group = 'All ages' AND Area_Name_Clean <> 'INDIA'
ORDER BY (male_literacy_pct - female_literacy_pct) DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q4. Which states have the highest share of graduates among literates?
-- ------------------------------------------------------------
SELECT Area_Name_Clean,
       ROUND(100.0 * "Graduate_&_above_Persons" / Literate_Persons, 2) AS graduate_share_pct
FROM education
WHERE Total_Rural_Urban = 'Total' AND Age_Group = 'All ages' AND Area_Name_Clean <> 'INDIA'
ORDER BY graduate_share_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q5. How does educational attainment change across age groups nationally?
-- ------------------------------------------------------------
SELECT Age_Group,
       ROUND(100.0 * Illiterate_Persons / Total_Persons, 2) AS illiteracy_pct,
       ROUND(100.0 * "Graduate_&_above_Persons" / Total_Persons, 2) AS graduate_pct
FROM education
WHERE Area_Name_Clean = 'INDIA' AND Total_Rural_Urban = 'Total'
  AND Age_Group NOT IN ('All ages', 'Age not stated', '0-6')
ORDER BY Age_Group;


-- ------------------------------------------------------------
-- Q6. Which states show the widest rural-urban literacy gap?
-- ------------------------------------------------------------
SELECT r.Area_Name_Clean,
       ROUND(100.0*u.Literate_Persons/u.Total_Persons,2) AS urban_literacy_pct,
       ROUND(100.0*r.Literate_Persons/r.Total_Persons,2) AS rural_literacy_pct,
       ROUND(100.0*u.Literate_Persons/u.Total_Persons - 100.0*r.Literate_Persons/r.Total_Persons,2) AS gap_pct
FROM education r
JOIN education u
  ON r.Area_Name_Clean = u.Area_Name_Clean AND r.Age_Group = u.Age_Group
WHERE r.Total_Rural_Urban = 'Rural' AND u.Total_Rural_Urban = 'Urban'
  AND r.Age_Group = 'All ages' AND r.Area_Name_Clean <> 'INDIA'
ORDER BY gap_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q7. What proportion of technical/vocational qualification holders are
--     female, by state?
-- ------------------------------------------------------------
SELECT Area_Name_Clean,
       ROUND(100.0 * "Technical_diploma_or_certificate_not_equal_to_degree_Females"
             / "Technical_diploma_or_certificate_not_equal_to_degree_Persons", 2) AS female_share_pct
FROM education
WHERE Total_Rural_Urban = 'Total' AND Age_Group = 'All ages'
  AND "Technical_diploma_or_certificate_not_equal_to_degree_Persons" > 0
  AND Area_Name_Clean <> 'INDIA'
ORDER BY female_share_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q8. Which age group has the largest absolute population still
--     classified as "Below primary" education?
-- ------------------------------------------------------------
SELECT Age_Group, SUM(Below_primary_Persons) AS total_below_primary
FROM education
WHERE Area_Name_Clean = 'INDIA' AND Total_Rural_Urban = 'Total'
  AND Age_Group NOT IN ('All ages', 'Age not stated', '0-6')
GROUP BY Age_Group
ORDER BY total_below_primary DESC
LIMIT 5;


-- ------------------------------------------------------------
-- Q9. Rank states by literacy rate for the working-age population
--     (20-59) only.
-- ------------------------------------------------------------
SELECT Area_Name_Clean,
       ROUND(100.0 * SUM(Literate_Persons) / SUM(Total_Persons), 2) AS literacy_pct
FROM education
WHERE Total_Rural_Urban = 'Total'
  AND Age_Group IN ('20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59')
  AND Area_Name_Clean <> 'INDIA'
GROUP BY Area_Name_Clean
ORDER BY literacy_pct DESC;


-- ------------------------------------------------------------
-- Q10. Which states have Higher Secondary+ attainment far below
--      the national average ("higher education attainment gap")?
-- ------------------------------------------------------------
WITH national AS (
  SELECT ROUND(100.0 * SUM("Higher_secondary_Intermediate_Pre-University_Senior_secondary_Persons"
                + "Graduate_&_above_Persons") / SUM(Total_Persons), 2) AS national_pct
  FROM education
  WHERE Area_Name_Clean = 'INDIA' AND Total_Rural_Urban = 'Total' AND Age_Group = 'All ages'
)
SELECT e.Area_Name_Clean,
       ROUND(100.0 * (e."Higher_secondary_Intermediate_Pre-University_Senior_secondary_Persons"
             + e."Graduate_&_above_Persons") / e.Total_Persons, 2) AS state_pct,
       national.national_pct
FROM education e, national
WHERE e.Total_Rural_Urban = 'Total' AND e.Age_Group = 'All ages' AND e.Area_Name_Clean <> 'INDIA'
ORDER BY state_pct ASC
LIMIT 10;
