WITH db_status AS (
	SELECT MAX(interval_start) as max_start, MIN(interval_start) as min_start, MAX(interval_end) as max_end, MIN(interval_end) as min_end
	FROM relations_minified
)
SELECT *
FROM db_status;
-- output:
--   db_creation_date   
-- ---------------------
--  2024-08-20 18:41:11
-- (1 row)

-- Add columns to relations_minified table
ALTER TABLE relations_minified 
ADD COLUMN age_of_interval NUMERIC,
ADD COLUMN expo_weight NUMERIC,
ADD COLUMN inverse_weight NUMERIC;

-- Update the new columns
WITH db_status AS (
	SELECT MAX(interval_start) as db_creation_date
	FROM relations_minified
)
UPDATE relations_minified 
SET age_of_interval = EXTRACT(DAYS FROM (SELECT db_creation_date FROM db_status) - COALESCE(interval_end, (SELECT db_creation_date FROM db_status)))
WHERE is_out_of_date = true
AND is_regular = true;

CREATE INDEX idx_relations_minified_age_of_interval ON relations_minified(age_of_interval);

UPDATE relations_minified
SET expo_weight = EXP(-(LN(2)/730.0) * age_of_interval),
	inverse_weight = 1.0 / (age_of_interval + 0.01)
WHERE is_out_of_date = true
AND is_regular = true;

CREATE INDEX idx_relations_minified_expo_weight ON relations_minified(expo_weight);
CREATE INDEX idx_relations_minified_inverse_weight ON relations_minified(inverse_weight);

CREATE TABLE weighted_mttu AS
WITH highest AS (
	SELECT MAX(interval_start) as db_creation_date
	FROM relations_minified
),
weighted_ttu AS (
	SELECT system_name,
			from_package_name,
			to_package_name,
			SUM(
				expo_weight * EXTRACT(DAYS FROM COALESCE(interval_end, (select db_creation_date from highest)) - interval_start)
			) / NULLIF(SUM(expo_weight), 0) AS ttu_expo_weighted,
			SUM(
				inverse_weight * EXTRACT(DAYS FROM COALESCE(interval_end, (select db_creation_date from highest)) - interval_start)
			) / NULLIF(SUM(inverse_weight), 0) AS ttu_inverse_weighted
	  FROM relations_minified
	 WHERE is_out_of_date = true -- Only when the requirement was out of date
	   AND is_regular = true -- Don't count dev dependencies (maybe you want to?)
	 GROUP BY system_name,
			  from_package_name,
			  to_package_name
)
SELECT system_name,
	   from_package_name,
	   AVG(ttu_expo_weighted) AS mttu_expo_weighted,
	   AVG(ttu_inverse_weighted) AS mttu_inverse_weighted
FROM weighted_ttu
GROUP BY system_name,
		 from_package_name;
-- SELECT 123318

CREATE TABLE weighted_mttr AS
WITH highest AS (
	SELECT MAX(interval_start) as db_creation_date
	FROM relations_minified
),
weighted_ttr AS (
	SELECT system_name,
			from_package_name,
			to_package_name,
			SUM(
				expo_weight * EXTRACT(DAYS FROM COALESCE(interval_end, (select db_creation_date from highest)) - interval_start)
			) / NULLIF(SUM(expo_weight), 0) AS ttr_expo_weighted,
			SUM(
				inverse_weight * EXTRACT(DAYS FROM COALESCE(interval_end, (select db_creation_date from highest)) - interval_start)
			) / NULLIF(SUM(inverse_weight), 0) AS ttr_inverse_weighted
	  FROM relations_minified
	 WHERE is_exposed = true -- Only when the requirement was out of date
	   AND is_regular = true -- Don't count dev dependencies (maybe you want to?)
	 GROUP BY system_name,
			  from_package_name,
			  to_package_name
)
SELECT system_name,
	   from_package_name,
	   AVG(ttr_expo_weighted) AS mttr_expo_weighted,
	   AVG(ttr_inverse_weighted) AS mttr_inverse_weighted
FROM weighted_ttr
GROUP BY system_name,
		 from_package_name;
-- SELECT 23132