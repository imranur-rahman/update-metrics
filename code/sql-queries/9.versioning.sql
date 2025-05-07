SELECT COUNT(*)
FROM (
    SELECT system_name, package_name
    FROM (
        SELECT system_name, package_name, rank,
               ROW_NUMBER() OVER (PARTITION BY system_name ORDER BY rank DESC) as rn
        FROM libraries
        WHERE system_name IN ('NPM', 'PYPI', 'CARGO')
    ) ranked
    WHERE rn <= 1000
) ranked;
-- reutrned 3000

-- Create a new table with top 1000 projects from each system and their relations
CREATE TABLE relations_minified_versioning AS
WITH top_packages AS (
    SELECT system_name, package_name
    FROM (
        SELECT system_name, package_name, rank,
               ROW_NUMBER() OVER (PARTITION BY system_name ORDER BY rank DESC) as rn
        FROM libraries
        WHERE system_name IN ('NPM', 'PYPI', 'CARGO')
    ) ranked
    WHERE rn <= 1000
)
SELECT r.*
FROM relations_minified r
INNER JOIN top_packages t 
    ON r.system_name = t.system_name 
    AND r.from_package_name = t.package_name
WHERE r.is_regular = true
    AND r.actual_requirement IS NOT NULL;
-- SELECT 1559743

-- Adding a new column to the relations_minified_versioning table
-- to store the constraint type
ALTER TABLE relations_minified_versioning
ADD COLUMN requirement_type VARCHAR(50);

-- probably don't need this since relations_minified already has the column
UPDATE relations_minified_versioning
SET requirement_type = CASE
    -- WHEN actual_requirement IS NULL THEN 'null' -- this is case won't occur
    WHEN get_spec_type(actual_requirement) = 'pinned' THEN 'pinned'
    WHEN get_spec_type(actual_requirement) = 'floating - major' THEN 'floating - major'
    WHEN get_spec_type(actual_requirement) = 'floating - major - restrictive' THEN 'floating - major - restrictive'
    WHEN get_spec_type(actual_requirement) = 'floating - minor' THEN 'floating - minor'
    WHEN get_spec_type(actual_requirement) = 'floating - patch' THEN 'floating - patch'
    ELSE 'other'
END;
-- UPDATE 1559743

-- not needed anymore
-- UPDATE relations_minified_versioning
-- SET requirement_type = 'NULL'
-- WHERE actual_requirement IS NULL;
-- -- UPDATE 91321


-- Convert the interval start time and interval end time to zero based indexing for each package dependency relationship
-- Also add an id for each system_name, from_package_name, to_package_name.
ALTER TABLE relations_minified_versioning 
ADD COLUMN interval_start_days INTEGER,
ADD COLUMN interval_end_days INTEGER;

WITH min_dates AS (
    SELECT system_name, from_package_name, to_package_name,
           MIN(interval_start) as min_start
    FROM relations_minified_versioning
    GROUP BY system_name, from_package_name, to_package_name
),
dependency_ids AS (
    SELECT DISTINCT system_name, from_package_name, to_package_name,
           ROW_NUMBER() OVER () as dependency_id
    FROM relations_minified_versioning
)
UPDATE relations_minified_versioning r
SET 
    interval_start_days = EXTRACT(EPOCH FROM (r.interval_start - m.min_start)) / 86400,
    interval_end_days = EXTRACT(EPOCH FROM (r.interval_end - m.min_start)) / 86400
FROM min_dates m, dependency_ids d
WHERE r.system_name = m.system_name 
    AND r.from_package_name = m.from_package_name 
    AND r.to_package_name = m.to_package_name
    AND r.system_name = d.system_name
    AND r.from_package_name = d.from_package_name
    AND r.to_package_name = d.to_package_name;
-- UPDATE 1559743

-- Store the dependency_id for each system_name, from_package_name, to_package_name
ALTER TABLE relations_minified_versioning 
ADD COLUMN dependency_id INTEGER;

ALTER TABLE relations_minified_versioning 
ADD COLUMN dependency_key TEXT;

WITH dependency_ids AS (
    SELECT DISTINCT system_name, from_package_name, to_package_name,
            ROW_NUMBER() OVER () as dependency_id
    FROM relations_minified_versioning
)
UPDATE relations_minified_versioning r
SET 
    dependency_id = d.dependency_id,
    dependency_key = CONCAT_WS('|', r.system_name, r.from_package_name, r.to_package_name)
FROM dependency_ids d
WHERE r.system_name = d.system_name
    AND r.from_package_name = d.from_package_name
    AND r.to_package_name = d.to_package_name;
-- UPDATE 1559743