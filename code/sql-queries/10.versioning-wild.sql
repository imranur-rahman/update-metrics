ALTER TABLE relations_minified DROP COLUMN IF EXISTS requirement_type;


-- Adding a new column to the relations_minified table
-- to store the constraint type
ALTER TABLE relations_minified
ADD COLUMN requirement_type TEXT;

UPDATE relations_minified
SET requirement_type = CASE
    WHEN actual_requirement IS NULL THEN 'other'
    WHEN get_spec_type(actual_requirement) = 'pinned' THEN 'pinned'
    WHEN get_spec_type(actual_requirement) = 'floating - major' THEN 'floating - major'
    WHEN get_spec_type(actual_requirement) = 'floating - major - restrictive' THEN 'floating - major - restrictive'
    WHEN get_spec_type(actual_requirement) = 'floating - minor' THEN 'floating - minor'
    WHEN get_spec_type(actual_requirement) = 'floating - patch' THEN 'floating - patch'
    ELSE 'other'
END;

UPDATE relations_minified
SET requirement_type = 'null'
WHERE actual_requirement IS NULL
    AND is_regular = true;
-- UPDATE 8000645

CREATE INDEX relations_minified_index_4
ON relations_minified (requirement_type);


-- group by system_name, from_package_name, from_version, to_package_name
-- and from each group take the first row to get the requirement_type
-- and count the types of requirements used overall
WITH FirstRequirementInGroup AS (
    SELECT
        system_name,
        requirement_type,
        -- Use ROW_NUMBER to pick one requirement type per unique dependency relation
        ROW_NUMBER() OVER(PARTITION BY system_name, from_package_name, from_version, to_package_name ORDER BY (SELECT NULL)) as rn
    FROM relations_minified
    WHERE is_regular = TRUE
        AND actual_requirement IS NOT NULL
)
SELECT
    system_name,
    requirement_type,
    COUNT(*) AS usage_count
FROM FirstRequirementInGroup
WHERE rn = 1 -- Filter to get only one row per group
GROUP BY system_name, requirement_type
ORDER BY system_name;
-- system_name |        requirement_type        | usage_count 
-- -------------+--------------------------------+-------------
--  CARGO       | floating - major               |         106
--  CARGO       | floating - major - restrictive |          98
--  CARGO       | floating - minor               |       99970
--  CARGO       | floating - patch               |        1335
--  CARGO       | other                          |        3182
--  CARGO       | pinned                         |         126
--  NPM         | floating - major               |      389961
--  NPM         | floating - major - restrictive |        1944
--  NPM         | floating - minor               |    34148963
--  NPM         | floating - patch               |     1094980
--  NPM         | other                          |       84392
--  NPM         | pinned                         |    15380765
--  PYPI        | floating - major               |     1465062
--  PYPI        | floating - major - restrictive |       56926
--  PYPI        | floating - minor               |      919946
--  PYPI        | floating - patch               |      431793
--  PYPI        | other                          |     1496250
--  PYPI        | pinned                         |        2867
-- (18 rows)




WITH categorized_requirements AS (
    SELECT 
        system_name,
        from_package_name,
        from_version,
        to_package_name,
        requirement_type,
        interval_start,
        interval_end
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND actual_requirement IS NOT NULL
)
SELECT 
    system_name,
    requirement_type,
    COUNT(*) as total_count,
    -- Use CONCAT_WS for better readability and performance
    COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name, from_version, to_package_name)) as unique_pkg_pkgver_dep_count,
    COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name, to_package_name)) as unique_pkg_dep_count,
    COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name)) as unique_pkg_count
FROM 
    categorized_requirements
GROUP BY 
    system_name, requirement_type
ORDER BY
    system_name, requirement_type;
-- system_name |        requirement_type        | total_count | unique_pkg_pkgver_dep_count | unique_pkg_dep_count | unique_pkg_count 
-- -------------+--------------------------------+-------------+-----------------------------+----------------------+------------------
--  CARGO       | floating - major               |         200 |                         106 |                   17 |               17
--  CARGO       | floating - major - restrictive |         150 |                          98 |                    8 |                8
--  CARGO       | floating - minor               |      188983 |                       99970 |                 6678 |             3271
--  CARGO       | floating - patch               |        2675 |                        1335 |                  239 |              158
--  CARGO       | other                          |        5468 |                        3182 |                  234 |              177
--  CARGO       | pinned                         |         227 |                         126 |                   18 |               17
--  NPM         | floating - major               |     1776125 |                      389961 |                18116 |             9901
--  NPM         | floating - major - restrictive |        4626 |                        1944 |                  179 |              137
--  NPM         | floating - minor               |    52652254 |                    34148964 |               614394 |           105755
--  NPM         | floating - patch               |     1833562 |                     1094988 |                27358 |             8701
--  NPM         | other                          |      146373 |                       84392 |                 4711 |             2772
--  NPM         | pinned                         |    22560270 |                    15380765 |               180979 |            41262
--  PYPI        | floating - major               |     3266606 |                     1466024 |                76742 |            22218
--  PYPI        | floating - major - restrictive |      113305 |                       57039 |                 4199 |             2790
--  PYPI        | floating - minor               |     1960065 |                      920345 |                33501 |             9924
--  PYPI        | floating - patch               |      832580 |                      432192 |                22108 |             7737
--  PYPI        | other                          |     2682283 |                     1497272 |                59339 |            13492
--  PYPI        | pinned                         |        6220 |                        2868 |                  317 |              138
-- (18 rows)



WITH dependency_stats AS (
    SELECT 
        system_name,
        from_package_name,
        from_version,
        to_package_name
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND actual_requirement IS NOT NULL
)
SELECT 
    system_name,
    COUNT(*) as total_count,
    -- Count unique package version dependencies
    COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name, from_version, to_package_name)) as unique_pkg_version_deps,
    -- Count unique package dependencies (ignoring versions)
    COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name, to_package_name)) as unique_pkg_deps,
    -- Count unique packages
    COUNT(DISTINCT from_package_name) as unique_packages,
    -- Calculate average dependencies per package
    ROUND(COUNT(DISTINCT CONCAT_WS('|', system_name, from_package_name, to_package_name))::numeric / 
          NULLIF(COUNT(DISTINCT from_package_name), 0)::numeric, 2) as avg_deps_per_package
FROM 
    dependency_stats
GROUP BY 
    system_name
ORDER BY
    total_count DESC;

--  system_name | total_count | unique_pkg_version_deps | unique_pkg_deps | unique_packages | avg_deps_per_package 
-- -------------+-------------+-------------------------+-----------------+-----------------+----------------------
--  NPM         |    78973210 |                51101005 |          741250 |          118035 |                 6.28
--  PYPI        |     8861059 |                 4372844 |          155574 |           31135 |                 5.00
--  CARGO       |      197703 |                  104817 |            6854 |            3323 |                 2.06
-- (3 rows)