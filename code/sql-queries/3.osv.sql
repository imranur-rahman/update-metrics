-- SELECT * from osv;

-- For the post-fix exposure time
-- 1. convert osv columns to semver

-- rows at this point: 14721



-- 2. find the fixed version release date and add it to the table.
create table osv_extended as
select o.vul_id, o.system_name, o.package_name, o.vul_introduced, o.vul_fixed, v.release_date as fixed_version_release_date
from osv o
inner join versioninfo v
on o.system_name = v.system_name and o.package_name = v.package_name and o.vul_fixed = v.version_name;
-- total rows: 11368

-- select count(*) from osv_extended;
-- rows in osv_extended: 11368


-- change the data type of 'vul_introduced' and 'vul_fixed' column
alter table osv_extended alter column vul_introduced type semver using 
   case when is_semver(vul_introduced) then semver(vul_introduced) end;
   
alter table osv_extended alter column vul_fixed type semver using 
   case when is_semver(vul_fixed) then semver(vul_fixed) end;
-- time needed: < 1 sec
-- it didn't delete any rows.

-- now delete it.
-- use with caution.
delete from osv_extended
where not (osv_extended is not null);
-- 424 rows deleted
-- total rows: 10944


-- indexing for faster data retrieval
CREATE INDEX osv_extended_index
ON osv_extended (system_name, package_name, vul_introduced, vul_fixed, fixed_version_release_date);

-- drop index osv_extended_index;


-- CREATE INDEX relations_index
-- ON relations (system_name,
--                 from_package_name,
-- 				from_version,
-- 				to_package_name,
-- 				to_version);
CREATE INDEX relations_index_2
ON relations (system_name,
				to_package_name,
				to_version,
				interval_start);

CREATE INDEX relations_index_3
ON relations (system_name,
				from_package_name,
				to_package_name,
				to_version,
				interval_start);


CREATE TABLE selected_packages AS
(
	SELECT system_name, package_name, x.lifetime, x.last_release_date, x.num_versions
	FROM (
		SELECT system_name, package_name, MAX(release_date) - MIN(release_date) as lifetime, MAX(release_date) AS last_release_date, COUNT(version_name) as num_versions
		FROM versioninfo_extended
		GROUP BY system_name, package_name
	) AS x
	WHERE EXTRACT(DAY FROM lifetime) > 730  -- from courtney paper (2+ years of regular maintanance)
		AND last_release_date > '2022-08-17 00:00:00'  -- only packages that had a version release within the last 2 years
		-- AND num_versions > 5  -- probably don't need it anymore
);
-- rows: 232514

CREATE INDEX selected_packages_index
ON selected_packages (system_name, package_name, lifetime, last_release_date, num_versions);

CREATE TABLE relations_minified AS
SELECT r.system_name,
		r.from_package_name,
		r.from_version,
		r.to_package_name,
		r.actual_requirement,
		r.to_version,
		r.to_package_highest_available_release,
		r.interval_start,
		r.interval_end,
		r.is_out_of_date,
		r.is_regular
FROM relations r
INNER JOIN selected_packages s1
ON r.system_name = s1.system_name AND r.from_package_name = s1.package_name
INNER JOIN selected_packages s2
ON r.system_name = s2.system_name AND r.to_package_name = s2.package_name;
-- rows: 274237470

CREATE INDEX relations_minified_index
ON relations_minified (system_name,
				to_package_name,
				to_version,
				interval_start);

-- alter table relations drop column is_exposed;
alter table relations_minified add column is_exposed boolean default false;

-- Update the rows for is_exposed = true
UPDATE relations_minified r
SET is_exposed = true
FROM osv_extended o
WHERE r.system_name = o.system_name
	AND r.to_package_name = o.package_name
	AND o.fixed_version_release_date <= r.interval_start
	AND o.vul_introduced <= r.to_version
	AND r.to_version < o.vul_fixed;
-- updated rows: 2315112

CREATE INDEX relations_minified_index_2
ON relations_minified (system_name,
				from_package_name,
				to_package_name,
				is_out_of_date,
				is_regular,
				is_exposed);

CREATE INDEX relations_minified_index_3
ON relations_minified (actual_requirement);


-- update relations_minified r
-- set is_exposed = exists(
-- 	select 1
-- 	from osv_extended o
-- 	where o.system_name = r.system_name and o.package_name = r.to_package_name and
-- 		o.fixed_version_release_date <= r.interval_start and o.vul_introduced <= r.to_version and r.to_version < o.vul_fixed
-- );
-- -- took 3h 51m

-- -- running this instead of the above query
-- UPDATE relations r
-- SET is_exposed = CASE
--     WHEN o.system_name IS NOT NULL THEN TRUE
--     ELSE FALSE
-- END
-- FROM osv_extended o
-- WHERE r.system_name = o.system_name
--   AND r.to_package_name = o.package_name
--   AND o.fixed_version_release_date <= r.interval_start
--   AND o.vul_introduced <= r.to_version
--   AND r.to_version < o.vul_fixed;


-- -- for each row in relations table check if vul_introduced <= to_version < vul_fixed
-- -- AND fixed_version_release_date <= interval_start
-- -- create table relations_exposed as
-- -- select r.system_name, r.from_package_name, r.from_version, r.to_package_name, r.actual_requirement, r.to_version, r.to_package_highest_available_release, r.interval_start, r.interval_end, r.is_out_of_date, r.is_regular,
-- -- case
-- -- 	when exists (
-- -- 		select *
-- -- 		from osv_extended o
-- -- 		where o.system_name = r.system_name and o.package_name = r.to_package_name and
-- -- 			o.fixed_version_release_date <= r.interval_start and o.vul_introduced <= r.to_version and r.to_version < o.vul_fixed
-- -- 	)
-- -- 		then 1
-- -- 	else NULL
-- -- end as is_exposed
-- -- from relations_test r;


-- testing
select count(*)
from relations_minified
where is_exposed = true;


-- osv stats

-- total number of vulnerabilities
SELECT COUNT(DISTINCT vul_id)
FROM osv_extended;
-- 6929


-- number of vulnerabilities in each ecosystem
SELECT system_name, COUNT(DISTINCT vul_id) as unique_vuln_count
FROM osv_extended
GROUP BY system_name
ORDER BY unique_vuln_count DESC;

--  system_name | unique_vuln_count 
-- -------------+-------------------
--  PYPI        |              3767
--  NPM         |              2192
--  CARGO       |               989
-- (3 rows)

-- number of vulnerabilities that have multiple vulnerable ranges
SELECT COUNT(DISTINCT vul_id)
FROM osv_extended
WHERE vul_id IN (
	SELECT vul_id
	FROM osv_extended
	GROUP BY vul_id
	HAVING COUNT(*) > 1
);
-- 1610 total


-- number of vulnerabilities that have multiple vulnerable ranges by ecosystem
SELECT system_name, COUNT(DISTINCT vul_id) as multiple_range_vuln_count
FROM osv_extended
WHERE vul_id IN (
	SELECT vul_id
	FROM osv_extended
	GROUP BY vul_id
	HAVING COUNT(*) > 1
)
GROUP BY system_name
ORDER BY multiple_range_vuln_count DESC;

--  system_name | multiple_range_vuln_count 
-- -------------+---------------------------
--  PYPI        |                      1101
--  NPM         |                       366
--  CARGO       |                       162
-- (3 rows)


-- number of unique vulnerabilities that has vulnerable ranges spanning more than one major version
SELECT COUNT(DISTINCT vul_id) 
FROM osv_extended 
WHERE get_semver_major(vul_introduced) != get_semver_major(vul_fixed);
-- 4208

SELECT system_name, COUNT(DISTINCT vul_id) as unique_vuln_count, COUNT(DISTINCT (system_name, package_name)) as unique_pkg_count
FROM osv_extended 
WHERE get_semver_major(vul_introduced) != get_semver_major(vul_fixed)
GROUP BY system_name;
--  system_name | unique_vuln_count | unique_pkg_count 
-- -------------+-------------------+------------------
--  CARGO       |               194 |               79
--  NPM         |              1560 |             1001
--  PYPI        |              2465 |              473
-- (3 rows)
-- Summing up: 4219 vul, 1553 packages

-- number of unique packages that have vulnerabilities
SELECT COUNT(DISTINCT (system_name, package_name)) as unique_pkg_with_vuln_count
FROM osv_extended;
--  unique_pkg_with_vuln_count 
-- ----------------------------
--                        2440
-- (1 row)

-- breakdown by ecosystem
SELECT system_name, COUNT(DISTINCT package_name) as unique_pkg_with_vuln_count
FROM osv_extended
GROUP BY system_name
ORDER BY unique_pkg_with_vuln_count DESC;
--  system_name | unique_pkg_with_vuln_count 
-- -------------+----------------------------
--  NPM         |                       1363
--  PYPI        |                        694
--  CARGO       |                        383
-- (3 rows)