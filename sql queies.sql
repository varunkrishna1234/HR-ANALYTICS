-- What is the overall attrition rate

SELECT 
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct
FROM hremployeeattrition;


-- Which departments have the highest attrition

SELECT 
  Department,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct
FROM hremployeeattrition
GROUP BY Department
ORDER BY AttritionRatePct DESC;


-- Which job roles are leaking talent the most

SELECT 
  JobRole,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct
FROM hremployeeattrition
GROUP BY JobRole
ORDER BY AttritionRatePct DESC, Leavers DESC;

-- Is low salary correlated with higher attrition by SalaryBand

SELECT 
  SalaryBand,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS AttritionRatePct,
  ROUND(AVG(MonthlyIncome), 0) AS AvgIncome
FROM hremployeesclean
GROUP BY SalaryBand
ORDER BY AttritionRatePct DESC;

-- Are early-tenure employees quitting more by TenureBand

SELECT 
  TenureBand,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct,
  ROUND(AVG(YearsAtCompany),2) AS AvgTenure
FROM hremployeesclean
GROUP BY TenureBand
ORDER BY 
  CASE TenureBand 
    WHEN '<1 yr' THEN 1 WHEN '1-3 yrs' THEN 2 WHEN '3-5 yrs' THEN 3 
    WHEN '5-10 yrs' THEN 4 ELSE 5 END;

-- What’s the impact of overtime on attrition 

SELECT 
  OverTime,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct,
  ROUND(AVG(MonthlyIncome),0) AS AvgIncome
FROM hremployeesclean
GROUP BY OverTime
ORDER BY AttritionRatePct DESC;


-- Do job/environment satisfaction scores differ for leavers

SELECT 
  Attrition,
  ROUND(AVG(JobSatisfaction),2) AS AvgJobSatisfaction,
  ROUND(AVG(EnvironmentSatisfaction),2) AS AvgEnvSatisfaction
FROM hremployeesclean
GROUP BY Attrition;


-- Is “stagnation” a driver by YearsSinceLastPromotion

SELECT 
  CASE 
    WHEN YearsSinceLastPromotion <= 1 THEN '≤1 yr'
    WHEN YearsSinceLastPromotion BETWEEN 2 AND 3 THEN '2-3 yrs'
    WHEN YearsSinceLastPromotion BETWEEN 4 AND 5 THEN '4-5 yrs'
    ELSE '5+ yrs'
  END AS PromoStaleness,
  COUNT(*) AS Headcount,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Leavers,
  100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) AS AttritionRatePct
FROM hremployeesclean
GROUP BY PromoStaleness
ORDER BY AttritionRatePct DESC;

-- Who are the high-risk cohorts right now by rule-based score
-- Simple risk score: low salary band + overtime + early tenure + low satisfaction + promotion staleness

SELECT 
  EmployeeNumber, Department, JobRole, SalaryBand, TenureBand, OverTime,
  JobSatisfaction, YearsSinceLastPromotion, MonthlyIncome,
  (
    CASE WHEN SalaryBand IN ('<3k','3-5k') THEN 1 ELSE 0 END +
    CASE WHEN OverTime='Yes' THEN 1 ELSE 0 END +
    CASE WHEN TenureBand IN ('<1 yr','1-3 yrs') THEN 1 ELSE 0 END +
    CASE WHEN JobSatisfaction <= 2 THEN 1 ELSE 0 END +
    CASE WHEN YearsSinceLastPromotion >= 4 THEN 1 ELSE 0 END
  ) AS RiskScore
FROM hremployeesclean
WHERE Attrition='No'
ORDER BY RiskScore DESC, MonthlyIncome ASC
LIMIT 50;




