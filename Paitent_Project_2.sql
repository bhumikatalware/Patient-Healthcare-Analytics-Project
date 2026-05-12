create database Paitent_Healthcare;
-- ============================================================
-- PATIENT HEALTHCARE PROJECT — STEP 2: SQL ANALYSIS
-- ============================================================
-- Dialect : SQLite (runs via Python). All logic is ANSI-compatible
-- and can be adapted to PostgreSQL / MySQL / SQL Server.
-- Inputs  : Clean CSVs from Step 1 (output_clean/)
-- ============================================================

-- ══════════════════════════════════════════════════════════════
-- SECTION A: TABLE DEFINITIONS  (auto-created from CSVs below)
-- ══════════════════════════════════════════════════════════════
-- patient   (Patient ID, Gender, Age, Age_Group, Blood Type,
--            State, City, Insurance Provider, Chronic Conditions,
--            Allergies, Full_Name, ...)
-- doctor    (Doctor ID, Doctor Name, Specialty,
--            Years Of Experience, Hospital/Clinic, ...)
-- visit     (Visit ID, Patient ID, Doctor ID, Visit Date,
--            Diagnosis, Follow Up Required, Visit Type,
--            Visit Status, Visit Year, Visit Month, ...)
-- treatment (Treatment ID, Visit ID, Treatment Type,
--            Treatment Name, Treatment Cost, Cost, Status, Outcome)
-- labtest   (Lab Result ID, Visit ID, Test Name, Test Date,
--            Test Result, Reference Range, Units)


-- ══════════════════════════════════════════════════════════════
-- SECTION B: KPI QUERIES
-- ══════════════════════════════════════════════════════════════

-- B-1  Core Counts
SELECT
    (SELECT COUNT(*) FROM patient)   AS Total_Patients,
    (SELECT COUNT(*) FROM doctor)    AS Total_Doctors,
    (SELECT COUNT(*) FROM visit)     AS Total_Visits,
    (SELECT COUNT(*) FROM treatment) AS Total_Treatments,
    (SELECT COUNT(*) FROM labtest)   AS Total_Lab_Tests;

-- B-2  Average Patient Age
SELECT
    ROUND(AVG(CAST(Age AS REAL)), 1)  AS Avg_Age,
    MIN(Age)                           AS Min_Age,
    MAX(Age)                           AS Max_Age
FROM patient;

-- B-3  Follow-Up Rate
SELECT
    COUNT(*)                                                      AS Total_Visits,
    SUM(CASE WHEN `Follow Up Required` = 'Yes' THEN 1 ELSE 0 END) AS FollowUp_Yes,
    ROUND(
        100.0 * SUM(CASE WHEN `Follow Up Required` = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    )                                                             AS FollowUp_Rate_Pct
FROM visit;

-- B-4  Avg Treatment Cost
SELECT
    ROUND(AVG(`Treatment Cost`), 2)  AS Avg_Treatment_Cost,
    ROUND(MIN(`Treatment Cost`), 2)  AS Min_Cost,
    ROUND(MAX(`Treatment Cost`), 2)  AS Max_Cost,
    ROUND(SUM(`Treatment Cost`), 2)  AS Total_Cost
FROM treatment;

-- B-5  Abnormal Lab Result Rate
SELECT
    COUNT(*)                                                        AS Total_Tests,
    SUM(CASE WHEN `Test Result` = 'Abnormal' THEN 1 ELSE 0 END)    AS Abnormal_Count,
    ROUND(
        100.0 * SUM(CASE WHEN `Test Result` = 'Abnormal' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    )                                                               AS Abnormal_Rate_Pct
FROM labtest ;

-- B-6  Doctor Workload (avg visits per doctor)
SELECT
    ROUND(
        COUNT(v.`ï»¿Visit ID`) * 1.0 / COUNT(DISTINCT v.`Doctor ID`),
        2
    ) AS Avg_Visits_Per_Doctor
FROM visit v;


-- ══════════════════════════════════════════════════════════════
-- SECTION C: PATIENT ANALYSIS
-- ══════════════════════════════════════════════════════════════

-- C-1  Gender Distribution
SELECT
    Gender,
    COUNT(*)                                   AS Patient_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM patient), 1) AS Pct
FROM patient
GROUP BY Gender
ORDER BY Patient_Count DESC;

-- C-2  Age Group Distribution
SELECT
    Age,
    COUNT(*)  AS Count,
    ROUND(AVG(CAST(Age AS REAL)), 1) AS Avg_Age
FROM patient
GROUP BY Age
ORDER BY Age;

-- C-3  Blood Type Distribution
SELECT
    `Blood_Type`,
    COUNT(*) AS Count
FROM patient
GROUP BY `Blood_Type`
ORDER BY Count DESC;

-- C-4  Top 10 States by Patient Count
SELECT
    State,
    COUNT(*) AS Patient_Count
FROM patient
GROUP BY State
ORDER BY Patient_Count DESC
LIMIT 10;

-- C-5  Top Insurance Providers
SELECT
    `Insurance_Provider`,
    COUNT(*) AS Patient_Count
FROM patient
GROUP BY `Insurance_Provider`
ORDER BY Patient_Count DESC
LIMIT 10;

-- C-6  Most Common Chronic Conditions
SELECT
    `Chronic_Conditions`,
    COUNT(*) AS Count
FROM patient
WHERE `Chronic_Conditions` != 'None'
GROUP BY `Chronic_Conditions`
ORDER BY Count DESC
LIMIT 10;


-- ══════════════════════════════════════════════════════════════
-- SECTION D: VISIT ANALYSIS
-- ══════════════════════════════════════════════════════════════

-- D-1  Visits by Type
SELECT
    `Visit Type`,
    COUNT(*) AS Visit_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM visit), 1) AS Pct
FROM visit
GROUP BY `Visit Type`
ORDER BY Visit_Count DESC;

-- D-2  Visits by Status
SELECT
    `Visit Status`,
    COUNT(*) AS Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM visit), 1) AS Pct
FROM visit
GROUP BY `Visit Status`
ORDER BY Count DESC;

-- D-3  Top 10 Diagnoses
SELECT
    Diagnosis,
    COUNT(*) AS Count
FROM visit
WHERE Diagnosis IS NOT NULL
GROUP BY Diagnosis
ORDER BY Count DESC
LIMIT 10;

-- D-4  Top 10 Reasons for Visit
SELECT
    `Reason for Visit`,
    COUNT(*) AS Count
FROM visit
GROUP BY `Reason for Visit`
ORDER BY Count DESC
LIMIT 10;


-- ══════════════════════════════════════════════════════════════
-- SECTION E: TREATMENT ANALYSIS
-- ══════════════════════════════════════════════════════════════

-- E-1  Treatment Type Distribution
SELECT
    `Treatment Type`,
    COUNT(*)                                   AS Count,
    ROUND(AVG(`Treatment Cost`), 2)            AS Avg_Cost,
    ROUND(SUM(`Treatment Cost`), 2)            AS Total_Cost
FROM treatment
GROUP BY `Treatment Type`
ORDER BY Count DESC;

-- E-2  Treatment Status Breakdown
SELECT
    Status,
    COUNT(*) AS Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM treatment), 1) AS Pct
FROM treatment
GROUP BY Status
ORDER BY Count DESC;

-- E-3  Treatment Outcomes
SELECT
    Outcome,
    COUNT(*) AS Count
FROM treatment
GROUP BY Outcome
ORDER BY Count DESC;

-- E-4  Most Expensive Treatments (avg cost)
SELECT
    `Treatment Name`,
    COUNT(*)                        AS Occurrences,
    ROUND(AVG(`Treatment Cost`), 2) AS Avg_Cost,
    ROUND(MAX(`Treatment Cost`), 2) AS Max_Cost
FROM treatment
GROUP BY `Treatment Name`
ORDER BY Avg_Cost DESC
LIMIT 10;


-- ══════════════════════════════════════════════════════════════
-- SECTION F: LAB TEST ANALYSIS
-- ══════════════════════════════════════════════════════════════

-- F-1  Test Result Distribution
SELECT
    `Test Result`,
    COUNT(*) AS Count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM labtest),
        1
    ) AS Pct
FROM labtest
GROUP BY `Test Result`
ORDER BY Count DESC;

-- F-2  Reference Range Distribution
SELECT
    `Reference Range`,
    COUNT(*) AS Count
FROM labtest
GROUP BY `Reference Range`
ORDER BY Count DESC;

-- F-3  Most Common Lab Tests
SELECT
    `Test Name`,
    COUNT(*) AS Count
FROM labtest
GROUP BY `Test Name`
ORDER BY Count DESC
LIMIT 10;

-- F-4  Abnormal Results by Test Name
SELECT
		`Test Name`,
    COUNT(*)                                                        AS Total,
    SUM(CASE WHEN `Test Result` = 'Abnormal' THEN 1 ELSE 0 END)    AS Abnormal,
    ROUND(
        100.0 * SUM(CASE WHEN `Test Result` = 'Abnormal' THEN 1 ELSE 0 END)
        / COUNT(*), 1
    )                                                               AS Abnormal_Pct
FROM labtest
GROUP BY `Test Name`
ORDER BY Abnormal_Pct DESC;

