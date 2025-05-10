SELECT 
    system_name,
    from_package_name,
    from_version,
    to_package_name,
    actual_requirement 
FROM relations_minified 
WHERE is_regular = true 
    AND actual_requirement LIKE '%>%' 
    AND actual_requirement LIKE '%<%' 
    AND system_name = 'NPM'
LIMIT 5;

-- system_name | from_package_name | from_version | to_package_name | actual_requirement 
-- -------------+-------------------+--------------+-----------------+--------------------
--  PYPI        | sdv               | 0.3.3        | sdmetrics       | <0.0.2,>=0.0.1
--  PYPI        | sdmetrics         |              | scikit-learn    | <1,>=0.20
--  PYPI        | sdv               |              | faker           | <10,>=3.0.0
--  PYPI        | sdv               |              | pandas          | <2,>=1.1.3
--  PYPI        | sdgym             |              | boto3           | <2,>=1.15.0

--  system_name |       from_package_name       | from_version |       to_package_name       | actual_requirement 
-- -------------+-------------------------------+--------------+-----------------------------+--------------------
--  NPM         | strato-db                     | 3.8.0        | uuid                        | >=8 <10
--  NPM         | @financial-times/o-footer     | 6.1.4        | @financial-times/o-viewport | >=2.2.0 <4
--  NPM         | @financial-times/o-typography | 5.11.1       | @financial-times/o-icons    | >=4.4.2 <6
--  NPM         | @financial-times/o-teaser     | 3.5.6        | @financial-times/o-icons    | >=4.4.2 <6
--  NPM         | @financial-times/o-footer     | 6.1.1        | @financial-times/o-icons    | >=4.4.2 <6

--  system_name | from_package_name | from_version | to_package_name | actual_requirement 
-- -------------+-------------------+--------------+-----------------+--------------------
--  CARGO       | actix-files       | 0.4.1        | actix-web       | >=3.0.0, <4.0.0
--  CARGO       | actix-files       | 0.4.1        | actix-web       | >=3.0.0, <4.0.0
--  CARGO       | actix-files       | 0.4.1        | actix-web       | >=3.0.0, <4.0.0
--  CARGO       | actix-files       | 0.4.1        | actix-web       | >=3.0.0, <4.0.0
--  CARGO       | actix-files       | 0.4.1        | futures-core    | >=0.3.7, <0.4.0


SELECT 
    system_name,
    from_package_name,
    from_version,
    to_package_name,
    actual_requirement 
FROM relations_minified 
WHERE is_regular = true 
    AND actual_requirement LIKE '%x%' 
    AND actual_requirement NOT LIKE '%^%' 
    AND system_name = 'NPM'
LIMIT 5;

--  system_name |    from_package_name     | from_version |   to_package_name   | actual_requirement 
-- -------------+--------------------------+--------------+---------------------+--------------------
--  NPM         | @firebase/database-types | 0.4.3        | @firebase/app-types | 0.x
--  NPM         | @fitbit/sdk              | 2.0.1        | gulp-zip            | 2.x
--  NPM         | @fitbit/sdk              | 1.0.0        | gulp-zip            | 2.x
--  NPM         | @fitbit/sdk              | 2.0.3        | gulp-zip            | 2.x
--  NPM         | @fitbit/sdk              | 2.0.0        | gulp-zip            | 2.x



SELECT 
    system_name,
    COALESCE(LEFT(actual_requirement, 1), 'NULL') AS starting_character,
    COUNT(*) AS occurrences
FROM 
    relations_minified
GROUP BY 
    system_name, 
    COALESCE(LEFT(actual_requirement, 1), 'NULL')
ORDER BY 
    system_name, 
    starting_character;
-- should have used is_regular

--  system_name | starting_character | occurrences 
-- -------------+--------------------+-------------
--  CARGO       | *                  |        9352
--  CARGO       | 0                  |       10958
--  CARGO       | 1                  |        5248
--  CARGO       | 2                  |        1303
--  CARGO       | 3                  |         561
--  CARGO       | 4                  |         552
--  CARGO       | 5                  |           5
--  CARGO       | 6                  |          96
--  CARGO       | 7                  |          23
--  CARGO       | 8                  |          12
--  CARGO       | <                  |        1906
--  CARGO       | =                  |      311042
--  CARGO       | >                  |       51584
--  CARGO       | ^                  |     7591673
--  CARGO       | ~                  |       86042
--  NPM         |                    |        5153
--  NPM         | *                  |     3379615
--  NPM         | 0                  |     5661534
--  NPM         | 1                  |    14284423
--  NPM         | 2                  |     7649568
--  NPM         | 3                  |     7657966
--  NPM         | 4                  |     4332036
--  NPM         | 5                  |     2965671
--  NPM         | 6                  |     2230665
--  NPM         | 7                  |     3615537
--  NPM         | 8                  |     1987645
--  NPM         | 9                  |      975485
--  NPM         | <                  |       47054
--  NPM         | =                  |       67084
--  NPM         | >                  |     3748739
--  NPM         | ^                  |   181623454
--  NPM         | v                  |       10194
--  NPM         | x                  |        7237
--  NPM         | ~                  |     5058313
--  PYPI        | !                  |      113075
--  PYPI        | <                  |     2578238
--  PYPI        | =                  |     3477315
--  PYPI        | >                  |     6086415
--  PYPI        | NULL               |     8000645
--  PYPI        | ~                  |      604052
-- (40 rows)



SELECT 
    system_name,
    CASE
        WHEN actual_requirement ~ '^[0-9]' THEN 'Digit'
        WHEN actual_requirement IS NULL THEN 'NULL'
        ELSE LEFT(actual_requirement, 2)
    END AS starting_characters,
    COUNT(*) AS occurrences
FROM 
    relations_minified
GROUP BY 
    system_name, 
    CASE
        WHEN actual_requirement ~ '^[0-9]' THEN 'Digit'
        WHEN actual_requirement IS NULL THEN 'NULL'
        ELSE LEFT(actual_requirement, 2)
    END
ORDER BY 
    system_name, 
    starting_characters;



--  system_name | starting_characters | occurrences 
-- -------------+---------------------+-------------
--  CARGO       | *                   |        9352
--  CARGO       | <                   |         108
--  CARGO       | <0                  |          53
--  CARGO       | <1                  |        1226
--  CARGO       | <2                  |          20
--  CARGO       | <3                  |           3
--  CARGO       | <4                  |           2
--  CARGO       | <=                  |         494
--  CARGO       | =                   |       10298
--  CARGO       | =0                  |      139172
--  CARGO       | =1                  |      136176
--  CARGO       | =2                  |       10189
--  CARGO       | =3                  |        7539
--  CARGO       | =4                  |        5569
--  CARGO       | =5                  |         910
--  CARGO       | =6                  |         437
--  CARGO       | =7                  |         243
--  CARGO       | =8                  |         144
--  CARGO       | =9                  |         365
--  CARGO       | >                   |         207
--  CARGO       | >0                  |         103
--  CARGO       | >1                  |         172
--  CARGO       | >2                  |           4
--  CARGO       | >=                  |       51098
--  CARGO       | Digit               |       18758
--  CARGO       | ^0                  |     3876138
--  CARGO       | ^1                  |     2851518
--  CARGO       | ^2                  |      377156
--  CARGO       | ^3                  |      254273
--  CARGO       | ^4                  |      154239
--  CARGO       | ^5                  |       37406
--  CARGO       | ^6                  |       16817
--  CARGO       | ^7                  |       13305
--  CARGO       | ^8                  |        6251
--  CARGO       | ^9                  |        4570
--  CARGO       | ~0                  |       50356
--  CARGO       | ~1                  |       22705
--  CARGO       | ~2                  |        7194
--  CARGO       | ~3                  |        3392
--  CARGO       | ~4                  |        1919
--  CARGO       | ~5                  |         122
--  CARGO       | ~6                  |         155
--  CARGO       | ~7                  |          72
--  CARGO       | ~8                  |          67
--  CARGO       | ~9                  |          60
--  NPM         |                     |           1
--  NPM         |  *                  |         440
--  NPM         |  0                  |          68
--  NPM         |  1                  |         182
--  NPM         |  2                  |         857
--  NPM         |  3                  |         143
--  NPM         |  4                  |          81
--  NPM         |  5                  |          66
--  NPM         |  7                  |         159
--  NPM         |  8                  |          65
--  NPM         |  <                  |          98
--  NPM         |  >                  |         693
--  NPM         |  ^                  |        2104
--  NPM         |  ~                  |         196
--  NPM         | *                   |     3379182
--  NPM         | *                   |         282
--  NPM         | *.                  |         151
--  NPM         | <                   |       13478
--  NPM         | <0                  |        1038
--  NPM         | <1                  |        6173
--  NPM         | <2                  |        4224
--  NPM         | <3                  |        2204
--  NPM         | <4                  |        2062
--  NPM         | <5                  |        1115
--  NPM         | <6                  |        2631
--  NPM         | <7                  |        1289
--  NPM         | <8                  |        1603
--  NPM         | <9                  |        1042
--  NPM         | <=                  |       10195
--  NPM         | =                   |        3619
--  NPM         | =0                  |        6271
--  NPM         | =1                  |       15533
--  NPM         | =2                  |        9179
--  NPM         | =3                  |        6825
--  NPM         | =4                  |        4651
--  NPM         | =5                  |        4002
--  NPM         | =6                  |        2520
--  NPM         | =7                  |        5702
--  NPM         | =8                  |        8062
--  NPM         | =9                  |         702
--  NPM         | =v                  |          18
--  NPM         | >                   |        6924
--  NPM         | >0                  |       19443
--  NPM         | >1                  |       19822
--  NPM         | >2                  |       26004
--  NPM         | >3                  |        4921
--  NPM         | >4                  |        2511
--  NPM         | >5                  |        3387
--  NPM         | >6                  |        5403
--  NPM         | >7                  |        2549
--  NPM         | >8                  |        3352
--  NPM         | >9                  |        1728
--  NPM         | >=                  |     3652695
--  NPM         | >5                  |        3387
--  NPM         | >6                  |        5403
--  NPM         | >7                  |        2549
--  NPM         | >8                  |        3352
--  NPM         | >9                  |        1728
--  NPM         | >=                  |     3652695
--  NPM         | Digit               |    51360530
--  NPM         | ^                   |        7089
--  NPM         | ^*                  |        1164
--  NPM         | ^0                  |    14352734
--  NPM         | ^1                  |    47051590
--  NPM         | ^2                  |    31590793
--  NPM         | ^3                  |    17833587
--  NPM         | ^4                  |    18528539
--  NPM         | ^5                  |    12545827
--  NPM         | ^6                  |     9878775
--  NPM         | ^7                  |    18470591
--  NPM         | ^8                  |     8073317
--  NPM         | ^9                  |     3281713
--  NPM         | ^v                  |        7046
--  NPM         | ^x                  |         689
--  NPM         | v0                  |        1784
--  NPM         | v1                  |        2873
--  NPM         | v2                  |        1660
--  NPM         | v3                  |         571
--  NPM         | v4                  |        1573
--  NPM         | v5                  |          80
--  NPM         | v6                  |        1051
--  NPM         | v7                  |         349
--  NPM         | v8                  |         182
--  NPM         | v9                  |          71
--  NPM         | x                   |        4539
--  NPM         | x.                  |        2698
--  NPM         | ~                   |         332
--  NPM         | ~0                  |      516542
--  NPM         | ~1                  |     1331934
--  NPM         | ~2                  |      782915
--  NPM         | ~3                  |      539221
--  NPM         | ~4                  |      608260
--  NPM         | ~5                  |      303979
--  NPM         | ~6                  |      208162
--  NPM         | ~7                  |      314646
--  NPM         | ~8                  |      293794
--  NPM         | ~9                  |      154764
--  NPM         | ~>                  |        3502
--  NPM         | ~v                  |         110
--  NPM         | ~x                  |         152
--  PYPI        | !=                  |      113075
--  PYPI        | <                   |         234
--  PYPI        | <0                  |      139116
--  PYPI        | <1                  |      779078
--  PYPI        | <2                  |      625372
--  PYPI        | <3                  |      238368
--  PYPI        | <4                  |      421790
--  PYPI        | <5                  |      103988
--  PYPI        | <6                  |       67673
--  PYPI        | <7                  |       52392
--  PYPI        | <8                  |       26037
--  PYPI        | <9                  |       13071
--  PYPI        | <=                  |      111110
--  PYPI        | <v                  |           9
--  PYPI        | ==                  |     3477315
--  PYPI        | >                   |          25
--  PYPI        | >0                  |        9490
--  PYPI        | >1                  |       13857
--  PYPI        | >2                  |       10593
--  PYPI        | >3                  |        7138
--  PYPI        | >4                  |        3679
--  PYPI        | >5                  |        2660
--  PYPI        | >6                  |        1078
--  PYPI        | >7                  |        1607
--  PYPI        | >8                  |         476
--  PYPI        | >9                  |         171
--  PYPI        | >=                  |     6035604
--  PYPI        | >v                  |          37
--  PYPI        | NULL                |     8000645
--  PYPI        | ~=                  |      604052
-- (169 rows)


SELECT 
    system_name,
    CASE
        WHEN ltrim(actual_requirement) ~ '^[0-9]' THEN 'Digit'
        WHEN actual_requirement IS NULL THEN 'NULL'
        ELSE LEFT(ltrim(actual_requirement), 2)
    END AS starting_characters,
    COUNT(*) AS occurrences
FROM 
    relations_minified
GROUP BY 
    system_name, 
    CASE
        WHEN ltrim(actual_requirement) ~ '^[0-9]' THEN 'Digit'
        WHEN actual_requirement IS NULL THEN 'NULL'
        ELSE LEFT(ltrim(actual_requirement), 2)
    END
ORDER BY 
    system_name, 
    starting_characters;


-- system_name | starting_characters | occurrences 
-- -------------+---------------------+-------------
--  CARGO       | *                   |        9352
--  CARGO       | <                   |         108
--  CARGO       | <0                  |          53
--  CARGO       | <1                  |        1226
--  CARGO       | <2                  |          20
--  CARGO       | <3                  |           3
--  CARGO       | <4                  |           2
--  CARGO       | <=                  |         494
--  CARGO       | =                   |       10298
--  CARGO       | =0                  |      139172
--  CARGO       | =1                  |      136176
--  CARGO       | =2                  |       10189
--  CARGO       | =3                  |        7539
--  CARGO       | =4                  |        5569
--  CARGO       | =5                  |         910
--  CARGO       | =6                  |         437
--  CARGO       | =7                  |         243
--  CARGO       | =8                  |         144
--  CARGO       | =9                  |         365
--  CARGO       | >                   |         207
--  CARGO       | >0                  |         103
--  CARGO       | >1                  |         172
--  CARGO       | >2                  |           4
--  CARGO       | >=                  |       51098
--  CARGO       | Digit               |       18758
--  CARGO       | ^0                  |     3876138
--  CARGO       | ^1                  |     2851518
--  CARGO       | ^2                  |      377156
--  CARGO       | ^3                  |      254273
--  CARGO       | ^4                  |      154239
--  CARGO       | ^5                  |       37406
--  CARGO       | ^6                  |       16817
--  CARGO       | ^7                  |       13305
--  CARGO       | ^8                  |        6251
--  CARGO       | ^9                  |        4570
--  CARGO       | ~0                  |       50356
--  CARGO       | ~1                  |       22705
--  CARGO       | ~2                  |        7194
--  CARGO       | ~3                  |        3392
--  CARGO       | ~4                  |        1919
--  CARGO       | ~5                  |         122
--  CARGO       | ~6                  |         155
--  CARGO       | ~7                  |          72
--  CARGO       | ~8                  |          67
--  CARGO       | ~9                  |          60
--  NPM         | *                   |     3379622
--  NPM         | *                   |         282
--  NPM         | *.                  |         151
--  NPM         | <                   |       13576
--  NPM         | <0                  |        1038
--  NPM         | <1                  |        6173
--  NPM         | <2                  |        4224
--  NPM         | <3                  |        2204
--  NPM         | <4                  |        2062
--  NPM         | <5                  |        1115
--  NPM         | <6                  |        2631
--  NPM         | <7                  |        1289
--  NPM         | <8                  |        1603
--  NPM         | <9                  |        1042
--  NPM         | <=                  |       10195
--  NPM         | =                   |        3619
--  NPM         | =0                  |        6271
--  NPM         | =1                  |       15533
--  NPM         | =2                  |        9179
--  NPM         | =3                  |        6825
--  NPM         | =4                  |        4651
--  NPM         | =5                  |        4002
--  NPM         | =6                  |        2520
--  NPM         | =7                  |        5702
--  NPM         | =8                  |        8062
--  NPM         | =9                  |         702
--  NPM         | =v                  |          18
--  NPM         | >                   |        6924
--  NPM         | >0                  |       19443
--  NPM         | >1                  |       19822
--  NPM         | >2                  |       26004
--  NPM         | >3                  |        4921
--  NPM         | >4                  |        2511
--  NPM         | >5                  |        3387
--  NPM         | >6                  |        5403
--  NPM         | >7                  |        2549
--  NPM         | >8                  |        3352
--  NPM         | >9                  |        1728
--  NPM         | >=                  |     3653388
--  NPM         | Digit               |    51362152
--  NPM         | ^                   |        7089
--  NPM         | ^*                  |        1164
--  NPM         | ^0                  |    14352840
--  NPM         | ^1                  |    47052436
--  NPM         | ^2                  |    31590873
--  NPM         | ^3                  |    17833845
--  NPM         | ^4                  |    18528648
--  NPM         | ^5                  |    12545848
--  NPM         | ^6                  |     9879215
--  NPM         | ^7                  |    18470662
--  NPM         | ^8                  |     8073461
--  NPM         | ^9                  |     3281742
--  NPM         | ^v                  |        7046
--  NPM         | ^x                  |         689
--  NPM         | v0                  |        1784
--  NPM         | v1                  |        2873
--  NPM         | v2                  |        1660
--  NPM         | v3                  |         571
--  NPM         | v4                  |        1573
--  NPM         | v5                  |          80
--  NPM         | v6                  |        1051
--  NPM         | v7                  |         349
--  NPM         | v8                  |         182
--  NPM         | v9                  |          71
--  NPM         | x                   |        4539
--  NPM         | x.                  |        2698
--  NPM         | ~                   |         332
--  NPM         | ~0                  |      516542
--  NPM         | ~1                  |     1332130
--  NPM         | ~2                  |      782915
--  NPM         | ~3                  |      539221
--  NPM         | ~4                  |      608260
--  NPM         | ~5                  |      303979
--  NPM         | ~6                  |      208162
--  NPM         | ~7                  |      314646
--  NPM         | ~8                  |      293794
--  NPM         | ~9                  |      154764
--  NPM         | ~>                  |        3502
--  NPM         | ~v                  |         110
--  NPM         | ~x                  |         152
--  PYPI        | !=                  |      113075
--  PYPI        | <                   |         234
--  PYPI        | <0                  |      139116
--  PYPI        | <1                  |      779078
--  PYPI        | <2                  |      625372
--  PYPI        | <3                  |      238368
--  PYPI        | <4                  |      421790
--  PYPI        | <5                  |      103988
--  PYPI        | <6                  |       67673
--  PYPI        | <7                  |       52392
--  PYPI        | <8                  |       26037
--  PYPI        | <9                  |       13071
--  PYPI        | <=                  |      111110
--  PYPI        | <v                  |           9
--  PYPI        | ==                  |     3477315
--  PYPI        | >                   |          25
--  PYPI        | >0                  |        9490
--  PYPI        | >1                  |       13857
--  PYPI        | >2                  |       10593
--  PYPI        | >3                  |        7138
--  PYPI        | >4                  |        3679
--  PYPI        | >5                  |        2660
--  PYPI        | >6                  |        1078
--  PYPI        | >7                  |        1607
--  PYPI        | >8                  |         476
--  PYPI        | >9                  |         171
--  PYPI        | >=                  |     6035604
--  PYPI        | >v                  |          37
--  PYPI        | NULL                |     8000645
--  PYPI        | ~=                  |      604052
-- (155 rows)


CREATE TABLE aggregated_dependency_status AS
WITH dependency_classification AS (
    SELECT 
        from_package_name,
        system_name,
        CASE
            WHEN actual_requirement IS NULL THEN 'NULL'
            WHEN ltrim(actual_requirement) ~ '^[*<>^~!x]' THEN 'floating'
            ELSE 'pinned'
        END AS dependency_type
    FROM 
        relations_minified
),
excluded_packages AS (
    SELECT DISTINCT 
        from_package_name,
        system_name
    FROM 
        dependency_classification
    WHERE 
        dependency_type = 'NULL'
),
aggregated_dependencies AS (
    SELECT 
        system_name,
        from_package_name,
        COUNT(*) AS total_rows_with_dependencies,
        SUM(CASE WHEN dependency_type = 'floating' THEN 1 ELSE 0 END) AS floating_count,
        SUM(CASE WHEN dependency_type = 'pinned' THEN 1 ELSE 0 END) AS pinned_count
    FROM 
        dependency_classification
    WHERE 
        (from_package_name, system_name) NOT IN 
        (SELECT from_package_name, system_name FROM excluded_packages)
    GROUP BY 
        system_name, 
        from_package_name
)
SELECT 
    system_name,
    from_package_name,
    CASE
        WHEN floating_count = total_rows_with_dependencies THEN 'all_floating'
        WHEN pinned_count = total_rows_with_dependencies THEN 'all_pinned'
        ELSE 'mixed'
    END AS dependency_status,
    total_rows_with_dependencies,
    floating_count,
    pinned_count
FROM 
    aggregated_dependencies
ORDER BY 
    system_name, 
    from_package_name;
-- SELECT 169670


`\copy (select * from aggregated_dependency_status) to '/home/imranur/security-metrics/data/dep_status/dep_status.csv' with header delimiter as ','`


-- Find the number of time a package updates its pinned dependencies
CREATE TABLE pinned_dependency_updates AS
WITH distinct_pinned_deps AS (
    SELECT DISTINCT
        system_name,
        from_package_name,
        from_version,
        to_package_name,
        actual_requirement
    FROM relations_minified
    WHERE 
        -- Only consider pinned versions
        ltrim(actual_requirement) !~ '^[*<>^~!x]'
        AND actual_requirement IS NOT NULL
        AND is_regular = true
    ORDER BY 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement
),
version_changes AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        CASE 
            WHEN LAG(actual_requirement) OVER (
                PARTITION BY system_name, from_package_name, to_package_name 
                ORDER BY from_version
            ) != actual_requirement THEN 1
            ELSE 0
        END as version_changed
    FROM distinct_pinned_deps
)
SELECT 
    system_name,
    from_package_name,
    to_package_name,
    SUM(version_changed) as requirement_changes
FROM version_changes
GROUP BY 
    system_name,
    from_package_name,
    to_package_name
HAVING SUM(version_changed) > 0
ORDER BY requirement_changes DESC;
-- SELECT 134390

`\copy (select * from pinned_dependency_updates) to '/home/imranur/security-metrics/data/dep_status/pinned_dependency_updates.csv' with header delimiter as ','`







-- with fine grained version specifying strategy

-- First create custom type for version components
CREATE TYPE version_component AS (
    operator text,
    version semver
);

-- Create helper functions for semver components
CREATE OR REPLACE FUNCTION semver_major(ver semver) 
RETURNS integer AS $$
BEGIN
    RETURN (regexp_split_to_array(ver::text, '\.'))[1]::integer;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION semver_minor(ver semver) 
RETURNS integer AS $$
BEGIN
    RETURN (regexp_split_to_array(ver::text, '\.'))[2]::integer;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION semver_patch(ver semver) 
RETURNS integer AS $$
BEGIN
    RETURN (regexp_split_to_array(ver::text, '\.'))[3]::integer;
END;
$$ LANGUAGE plpgsql;

-- Create function to parse version specs
CREATE OR REPLACE FUNCTION parse_version_spec(spec text) 
RETURNS version_component[] AS $$
DECLARE
    parts text[];
    result version_component[];
    part text;
    ver_str text;
    comp version_component;
BEGIN
    -- Split on both spaces and other delimiters, normalize all delimiters to ||
    parts := string_to_array(
        regexp_replace(
            regexp_replace(
                regexp_replace(spec, '\s+(?=[<>])', '||', 'g'),  -- Space before operator
                '[,\s]+', '||', 'g'                              -- Commas and other spaces
            ),
            '\|\|\|+', '||', 'g'                                -- Clean up multiple ||
        ),
        '||'
    );
    
    -- Process each part and sort them
    FOR part IN 
        SELECT p FROM unnest(parts) p 
        WHERE p != ''
        ORDER BY 
            CASE 
                WHEN p ~ '^>' THEN 1  -- Make > come before <
                WHEN p ~ '^<' THEN 2
                ELSE 3
            END 
    LOOP
        -- Extract operator and version
        IF part ~ '^[><]=?' THEN
            comp.operator := substring(part from '^[><]=?');
            ver_str := substring(part from '[0-9].*');
        ELSE
            comp.operator := '=';
            ver_str := part;
        END IF;
        
        -- Clean version string and handle different formats
        ver_str := regexp_replace(ver_str, '[^0-9.].*$', '');
        IF ver_str ~ '^[0-9]+$' THEN
            ver_str := ver_str || '.0.0';
        ELSIF ver_str ~ '^[0-9]+\.[0-9]+$' THEN
            ver_str := ver_str || '.0';
        END IF;
        
        IF ver_str ~ '^[0-9]+\.[0-9]+\.[0-9]+$' THEN
            BEGIN
                comp.version := ver_str::semver;
                result := array_append(result, comp);
            EXCEPTION 
                WHEN OTHERS THEN
                    NULL;
            END;
        END IF;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Main function to determine spec type
CREATE OR REPLACE FUNCTION get_spec_type(spec text)
RETURNS text AS $$
DECLARE
    comps version_component[];
    comp1 version_component;
    comp2 version_component;
BEGIN
    -- Handle simple cases first
    IF spec = '*' OR spec = 'latest' THEN
        RETURN 'floating - major';
    END IF;
    
    IF spec LIKE '~%' THEN
        RETURN 'floating - patch';
    END IF;
    
    IF spec LIKE '^%' THEN
        RETURN 'floating - minor';
    END IF;

    -- Handle x-based patterns
    IF spec ~ '^[0-9]+\.x\.x$' THEN
        RETURN 'floating - minor';
    END IF;

    IF spec ~ '^[0-9]+\.[0-9]+\.x$' THEN
        RETURN 'floating - patch';
    END IF;

    -- Parse version spec
    comps := parse_version_spec(spec);
    
    -- Handle single version component
    IF array_length(comps, 1) = 1 THEN
        IF comps[1].operator = '=' THEN
            RETURN 'pinned';
        ELSIF comps[1].operator LIKE '>' OR comps[1].operator = '>=' THEN
            RETURN 'floating - major';
        ELSIF comps[1].operator LIKE '<' OR comps[1].operator = '<=' THEN
            RETURN 'other';
        END IF;
    END IF;

    -- Handle version ranges
    IF array_length(comps, 1) = 2 THEN
        comp1 := comps[1];
        comp2 := comps[2];
        
        -- Check for floating - minor pattern FIRST
        IF (comp1.operator LIKE '>%' AND comp2.operator LIKE '<%') AND
           (semver_major(comp2.version) = semver_major(comp1.version) + 1 OR 
            semver_major(comp2.version) = semver_major(comp1.version)) AND
           (semver_minor(comp2.version) = 0) AND
           (semver_patch(comp2.version) = 0) THEN
            RETURN 'floating - minor';
        END IF;

        -- Check for floating - patch pattern
        IF (comp1.operator LIKE '>%' AND comp2.operator LIKE '<%') AND
           (semver_major(comp2.version) = semver_major(comp1.version)) AND
           (semver_minor(comp2.version) = semver_minor(comp1.version) + 1) AND
           (semver_minor(comp2.version) != 0) AND
           (semver_patch(comp2.version) = 0) THEN
            RETURN 'floating - patch';
        END IF;

        -- Check for floating - major - restrictive pattern
        IF (comp1.operator LIKE '>%' AND comp2.operator LIKE '<%') AND
           (semver_major(comp2.version) > semver_major(comp1.version) + 1) THEN
            RETURN 'floating - major - restrictive';
        END IF;
    END IF;

    RETURN 'other';
EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'other';
END;
$$ LANGUAGE plpgsql;


-- Test cases
SELECT get_spec_type('*');                    -- 'floating - major'
SELECT get_spec_type('latest');               -- 'floating - major'
SELECT get_spec_type('~1.2.3');               -- 'floating - patch'
SELECT get_spec_type('^1.2.3');               -- 'floating - minor'
SELECT get_spec_type('1.2.3');                -- 'pinned'
SELECT get_spec_type('1.x.x');                -- 'floating - minor'
SELECT get_spec_type('1.2.x');                -- 'floating - patch'      
SELECT get_spec_type('>=1.2.3');              -- 'floating - major'
SELECT get_spec_type('<1.2.3');               -- 'other'
SELECT parse_version_spec('>=1.2.3 <2.0.0');  -- {"(>=,1.2.3)","(<,2.0.0)"}
SELECT get_spec_type('>=1.2.3 <2.0.0');       -- 'floating - minor'
SELECT get_spec_type('>=1.2.3 <1.3.0');       -- 'floating - patch'
SELECT get_spec_type('>1.0.0 <6');            -- 'floating - major - restrictive'
SELECT get_spec_type('>1.0.0 <6.0');        -- 'floating - major - restrictive'
SELECT get_spec_type('>=1.2.3 <5.0.0');       -- 'floating - major - restrictive'
SELECT get_spec_type('>2.0.0 <6.0.0');        -- 'floating - major - restrictive'
SELECT get_spec_type('^1.2.0 || ^2.0.0');     -- it should be 'other', but the current version is returning 'floating - minor'
SELECT get_spec_type('>= 1.2.3 || <= 1.2.4'); -- "other"
SELECT get_spec_type('>= 1.2.3 <= 1.2.4');    -- "other"
SELECT get_spec_type('<2.0.0 || >=1.2.3');    -- "floating - minor"
SELECT get_spec_type('npm:eslint-plugin-i@2.27.5-4'); -- "other"

-- Example usage:
COMMENT ON FUNCTION get_spec_type(text) IS 'Determines the type of version specification (pinned, floating patch/minor/major)';



-- outdated dependencies: general overview
-- result to RQ1
WITH highest AS (
    SELECT MAX(interval_start) as db_creation_date
    FROM relations_minified
),
categorized_requirements AS (
    SELECT 
        -- we don't care about system_name for now
        requirement_type,
        from_package_name,
        from_version,
        to_package_name,
        interval_start,
        interval_end
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND is_out_of_date = true
        AND actual_requirement IS NOT NULL
),
total_days_cte AS (
    SELECT SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) as sum_total_days
    FROM categorized_requirements
)
SELECT 
    requirement_type,
    COUNT(*) as total_count,
    COUNT(DISTINCT from_package_name || '|' || from_version || '|' || to_package_name) as unique_pkg_pkgver_dep_count,
    COUNT(DISTINCT from_package_name || '|' || to_package_name) as unique_pkg_dep_count,
    COUNT(DISTINCT from_package_name) as unique_pkg_count,
    SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) as total_days,
    ROUND(100.0 * SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) / 
        (SELECT sum_total_days FROM total_days_cte), 2) as days_percentage
FROM 
    categorized_requirements
GROUP BY 
    requirement_type
ORDER BY 
    total_days DESC;


--         requirement_type        | total_count | unique_pkg_pkgver_dep_count | unique_pkg_dep_count | unique_pkg_count |             total_days             | days_percentage 
-- --------------------------------+-------------+-----------------------------+----------------------+------------------+------------------------------------+-----------------
--  floating - minor               |    14493894 |                     7882374 |               367848 |            94217 | 179692596.289594907407245699343349 |           61.95
--  pinned                         |    11705617 |                     8924119 |               163975 |            39056 |  71395294.055914351851741317448968 |           24.61
--  other                          |     1687818 |                      888391 |                51914 |            13681 |  22005715.599745370370561369146618 |            7.59
--  floating - patch               |     1286413 |                      644474 |                38573 |            14477 |  16030421.686435185185072258513853 |            5.53
--  floating - major - restrictive |       33393 |                       13824 |                 2045 |             1648 |    576225.945335648148179789256192 |            0.20
--  floating - major               |       61871 |                       11425 |                 2427 |             2026 |    380660.184803240740732975185058 |            0.13
-- (6 rows)


-- vulnerable dependencies: general overview
-- result to RQ1
WITH highest AS (
    SELECT MAX(interval_start) as db_creation_date
    FROM relations_minified
),
categorized_requirements AS (
    SELECT 
        requirement_type,
        from_package_name,
        from_version,
        to_package_name,
        interval_start,
        interval_end
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND is_exposed = true
        AND actual_requirement IS NOT NULL
),
total_days_cte AS (
    SELECT SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) as sum_total_days
    FROM categorized_requirements
)
SELECT 
    requirement_type,
        COUNT(*) as total_count,
        COUNT(DISTINCT from_package_name || '|' || from_version || '|' || to_package_name) as unique_pkg_pkgver_dep_count,
        COUNT(DISTINCT from_package_name || '|' || to_package_name) as unique_pkg_dep_count,
        COUNT(DISTINCT from_package_name) as unique_pkg_count,
        SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) as total_days,
        ROUND(100.0 * SUM(EXTRACT(EPOCH FROM (COALESCE(interval_end, (select db_creation_date from highest)) - interval_start))/86400) / 
        (SELECT sum_total_days FROM total_days_cte), 2) as days_percentage
FROM 
    categorized_requirements
GROUP BY 
    requirement_type
ORDER BY 
--     total_days DESC;        requirement_type        | total_count | unique_pkg_pkgver_dep_count | unique_pkg_dep_count | unique_pkg_count |            total_days            | days_percentage 
-- --------------------------------+-------------+-----------------------------+----------------------+------------------+----------------------------------+-----------------
--  floating - minor               |      387721 |                      202024 |                14790 |            12187 | 6432441.756400462962990126123338 |           45.59
--  pinned                         |      313195 |                      167490 |                10898 |             6921 | 4149005.904143518518514018771848 |           29.40
--  other                          |      122868 |                       55418 |                 7938 |             4006 | 2403922.457939814814819980831093 |           17.04
--  floating - patch               |       56301 |                       21923 |                 3024 |             2276 | 1076921.145821759259244772748519 |            7.63
--  floating - major - restrictive |        2421 |                        1165 |                  231 |              228 |       43628.55542824074073929994 |            0.31
--  floating - major               |         169 |                          53 |                   27 |               23 |    4335.390046296296295929640000 |            0.03
-- (6 rows)



-- updated -> outdated, count the four ways
-- why a package goes into outdated dependency version
-- from is_out_of_date = false to is_out_of_date = true


WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_out_of_date,
        LAG(is_out_of_date) OVER w as prev_is_out_of_date,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    COUNT(CASE 
        WHEN is_out_of_date = true 
        AND prev_is_out_of_date = false 
        AND from_version = prev_from_version
        AND to_version != prev_to_version
        THEN 1 
    END) as dep_releases_new_version,
    COUNT(CASE 
        WHEN is_out_of_date = true 
        AND prev_is_out_of_date = false 
        AND from_version != prev_from_version 
        AND actual_requirement = prev_actual_requirement
        THEN 1 
    END) as pkg_releases_new_version_same_requirement_same_spec,
    COUNT(CASE 
        WHEN is_out_of_date = true 
        AND prev_is_out_of_date = false 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type = prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_same_spec,
    COUNT(CASE 
        WHEN is_out_of_date = true 
        AND prev_is_out_of_date = false 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type != prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_changed_spec,
    STRING_AGG(DISTINCT CASE 
        WHEN is_out_of_date = true 
        AND prev_is_out_of_date = false 
        AND from_version != prev_from_version 
        AND current_spec_type != prev_spec_type
        THEN prev_spec_type || ' -> ' || current_spec_type 
    END, ', ')
FROM version_transitions
WHERE prev_is_out_of_date IS NOT NULL;
-- possible ways to improve when the first time dep was introduced and 
-- checking whether it was outdated or not.

-- dep_releases_new_version | pkg_releases_new_version_same_requirement_same_spec | pkg_releases_new_version_changed_req
-- uirement_same_spec | pkg_releases_new_version_changed_requirement_changed_spec |                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
--                                                         string_agg                                                    
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                          
-- --------------------------+-----------------------------------------------------+--------------------------------------------------------+-----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                       235 |                                                1023 |                                                  47168 |                                                     23018 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - major -> pinned, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - minor, pinned -> floating - patch, pinned -> other


-- updated -> outdated, trending constraint type change
-- pkg_releases_new_version_changed_requirement_changed_spec
WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_out_of_date,
        LAG(is_out_of_date) OVER w as prev_is_out_of_date,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    prev_spec_type || ' -> ' || current_spec_type as spec_type_transition,
    COUNT(*) as transition_count
FROM version_transitions
WHERE 
    is_out_of_date = true 
    AND prev_is_out_of_date = false 
    AND from_version != prev_from_version 
    AND actual_requirement != prev_actual_requirement
    AND current_spec_type != prev_spec_type
GROUP BY 
    prev_spec_type, current_spec_type
ORDER BY 
    transition_count DESC;

--                 spec_type_transition                | transition_count 
-- ----------------------------------------------------+------------------
--  floating - minor -> pinned                         |            12716
--  floating - major -> other                          |             3521
--  floating - minor -> floating - patch               |             1808
--  floating - major -> floating - minor               |             1500
--  floating - minor -> other                          |             1112
--  floating - major -> floating - patch               |              701
--  floating - major -> pinned                         |              349
--  floating - patch -> pinned                         |              288
--  floating - major -> floating - major - restrictive |              283
--  pinned -> floating - minor                         |              243
--  floating - patch -> other                          |              202
--  floating - patch -> floating - minor               |               55
--  floating - major - restrictive -> other            |               44
--  other -> floating - minor                          |               39
--  other -> floating - patch                          |               37
--  pinned -> floating - patch                         |               34
--  other -> pinned                                    |               33
--  floating - major - restrictive -> floating - minor |               31
--  pinned -> other                                    |               15
--  floating - major - restrictive -> floating - patch |                7
--  floating - minor -> floating - major               |                4
--  other -> floating - major                          |                4
--  floating - minor -> floating - major - restrictive |                2
--  floating - patch -> floating - major               |                1
--  other -> floating - major - restrictive            |                1
--  floating - major - restrictive -> floating - major |                1
-- (26 rows)






 -- outdated -> updated, count the four ways
-- from is_out_of_date = true to is_out_of_date = false

WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_out_of_date,
        LAG(is_out_of_date) OVER w as prev_is_out_of_date,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    COUNT(CASE 
        WHEN is_out_of_date = false 
        AND prev_is_out_of_date = true
        AND from_version = prev_from_version
        AND to_version != prev_to_version
        THEN 1 
    END) as dep_releases_new_version,
    COUNT(CASE 
        WHEN is_out_of_date = false 
        AND prev_is_out_of_date = true 
        AND from_version != prev_from_version 
        AND actual_requirement = prev_actual_requirement
        THEN 1 
    END) as pkg_releases_new_version_same_requirement_same_spec,
    COUNT(CASE 
        WHEN is_out_of_date = false 
        AND prev_is_out_of_date = true 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type = prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_same_spec,
    COUNT(CASE 
        WHEN is_out_of_date = false 
        AND prev_is_out_of_date = true 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type != prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_changed_spec,
    STRING_AGG(DISTINCT CASE 
        WHEN is_out_of_date = false 
        AND prev_is_out_of_date = true 
        AND from_version != prev_from_version 
        AND current_spec_type != prev_spec_type
        THEN prev_spec_type || ' -> ' || current_spec_type 
    END, ', ')
FROM version_transitions
WHERE prev_is_out_of_date IS NOT NULL;

--  dep_releases_new_version | pkg_releases_new_version_same_requirement_same_spec | pkg_releases_new_version_changed_requirement_same_spec | pkg_releases_new_version_changed_requirement_changed_spec |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    string_agg                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
-- --------------------------+-----------------------------------------------------+--------------------------------------------------------+-----------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                      5657 |                                                  75 |                                                5219238 |                                                     71190 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major - restrictive -> pinned, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - major, pinned -> floating - major - restrictive, pinned -> floating - minor, pinned -> floating - patch, pinned -> other


-- updated -> outdated, trending constraint type change
WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_out_of_date,
        LAG(is_out_of_date) OVER w as prev_is_out_of_date,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    prev_spec_type || ' -> ' || current_spec_type as spec_type_transition,
    COUNT(*) as transition_count
FROM version_transitions
WHERE 
    is_out_of_date = false 
    AND prev_is_out_of_date = true 
    AND from_version != prev_from_version 
    AND actual_requirement != prev_actual_requirement
    AND current_spec_type != prev_spec_type
GROUP BY 
    prev_spec_type, current_spec_type
ORDER BY 
    transition_count DESC;

--                 spec_type_transition                | transition_count 
-- ----------------------------------------------------+------------------
--  pinned -> floating - minor                         |            28338
--  floating - minor -> pinned                         |             9482
--  other -> floating - major                          |             7219
--  floating - patch -> floating - minor               |             5597
--  floating - minor -> floating - major               |             3082
--  other -> floating - minor                          |             2959
--  floating - patch -> floating - major               |             1875
--  pinned -> floating - patch                         |             1728
--  other -> floating - patch                          |             1718
--  floating - minor -> floating - major - restrictive |             1697
--  floating - patch -> other                          |             1665
--  floating - minor -> floating - patch               |             1315
--  floating - patch -> pinned                         |             1154
--  floating - minor -> other                          |              958
--  pinned -> floating - major                         |              531
--  other -> floating - major - restrictive            |              385
--  pinned -> other                                    |              341
--  floating - major - restrictive -> floating - major |              339
--  other -> pinned                                    |              271
--  floating - patch -> floating - major - restrictive |              223
--  floating - major - restrictive -> floating - minor |              150
--  floating - major - restrictive -> other            |               51
--  floating - major -> other                          |               42
--  floating - major - restrictive -> floating - patch |               20
--  floating - major -> floating - patch               |               13
--  floating - major -> floating - major - restrictive |               11
--  floating - major -> floating - minor               |                9
--  pinned -> floating - major - restrictive           |                6
--  floating - major - restrictive -> pinned           |                5
-- (29 rows)














-- nonvulnerable -> vulnerable, count the four ways
-- why a package goes into exposed
-- from is_exposed = false to is_exposed = true


WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_exposed,
        LAG(is_exposed) OVER w as prev_is_exposed,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    COUNT(CASE 
        WHEN is_exposed = true 
        AND prev_is_exposed = false 
        AND from_version = prev_from_version
        AND to_version != prev_to_version
        THEN 1 
    END) as dep_releases_new_version,
    COUNT(CASE 
        WHEN is_exposed = true 
        AND prev_is_exposed = false 
        AND from_version != prev_from_version 
        AND actual_requirement = prev_actual_requirement
        THEN 1 
    END) as pkg_releases_new_version_same_requirement_same_spec,
    COUNT(CASE 
        WHEN is_exposed = true 
        AND prev_is_exposed = false 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type = prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_same_spec,
    COUNT(CASE 
        WHEN is_exposed = true 
        AND prev_is_exposed = false 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type != prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_changed_spec,
    STRING_AGG(DISTINCT CASE 
        WHEN is_exposed = true 
        AND prev_is_exposed = false 
        AND from_version != prev_from_version 
        AND current_spec_type != prev_spec_type
        THEN prev_spec_type || ' -> ' || current_spec_type 
    END, ', ')
FROM version_transitions
WHERE prev_is_exposed IS NOT NULL;
-- possible ways to improve when the first time dep was introduced and 
-- checking whether it was exposed or not.


--  dep_releases_new_version | pkg_releases_new_version_same_requirement_same_spec | pkg_releases_new_version_changed_requirement_same_spec | pkg_releases_new_version_changed_requirement_changed_spec |                                                                                                                                                                                                                                                                                                                                                            string_agg                                                                                                                                                                                                                                                                                                                                                            
-- --------------------------+-----------------------------------------------------+--------------------------------------------------------+-----------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                        29 |                                                1267 |                                                    558 |                                                      1138 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - major -> pinned, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - minor



-- nonvulnerable -> vulnerable, trending constraint type change
WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_exposed,
        LAG(is_exposed) OVER w as prev_is_exposed,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    prev_spec_type || ' -> ' || current_spec_type as spec_type_transition,
    COUNT(*) as transition_count
FROM version_transitions
WHERE 
    is_exposed = true 
    AND prev_is_exposed = false 
    AND from_version != prev_from_version 
    AND actual_requirement != prev_actual_requirement
    AND current_spec_type != prev_spec_type
GROUP BY 
    prev_spec_type, current_spec_type
ORDER BY 
    transition_count DESC;

--                 spec_type_transition                | transition_count 
-- ----------------------------------------------------+------------------
--  floating - minor -> pinned                         |              536
--  floating - major -> other                          |              274
--  floating - minor -> other                          |               84
--  floating - minor -> floating - patch               |               60
--  floating - major -> floating - patch               |               40
--  pinned -> floating - minor                         |               26
--  floating - patch -> pinned                         |               26
--  floating - major -> floating - minor               |               23
--  floating - patch -> other                          |               20
--  floating - major -> floating - major - restrictive |               19
--  floating - major -> pinned                         |                9
--  other -> pinned                                    |                8
--  other -> floating - patch                          |                7
--  floating - major - restrictive -> other            |                6
--  other -> floating - minor                          |                6
--  other -> floating - major - restrictive            |                2
--  floating - patch -> floating - minor               |                2
--  floating - major - restrictive -> floating - minor |                1
--  floating - patch -> floating - major - restrictive |                1
--  floating - major - restrictive -> floating - major |                1
-- (20 rows)



-- vulnerable -> nonvulnerable, count the four ways
-- from is_exposed = true to is_exposed = false

WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_exposed,
        LAG(is_exposed) OVER w as prev_is_exposed,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    COUNT(CASE 
        WHEN is_exposed = false 
        AND prev_is_exposed = true 
        AND from_version = prev_from_version
        AND to_version != prev_to_version
        THEN 1 
    END) as dep_releases_new_version,
    COUNT(CASE 
        WHEN is_exposed = false 
        AND prev_is_exposed = true 
        AND from_version != prev_from_version 
        AND actual_requirement = prev_actual_requirement
        THEN 1 
    END) as pkg_releases_new_version_same_requirement_same_spec,
    COUNT(CASE 
        WHEN is_exposed = false 
        AND prev_is_exposed = true 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type = prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_same_spec,
    COUNT(CASE 
        WHEN is_exposed = false 
        AND prev_is_exposed = true 
        AND from_version != prev_from_version 
        AND actual_requirement != prev_actual_requirement
        AND current_spec_type != prev_spec_type
        THEN 1 
    END) as pkg_releases_new_version_changed_requirement_changed_spec,
    STRING_AGG(DISTINCT CASE 
        WHEN is_exposed = false 
        AND prev_is_exposed = true 
        AND from_version != prev_from_version 
        AND current_spec_type != prev_spec_type
        THEN prev_spec_type || ' -> ' || current_spec_type 
    END, ', ')
FROM version_transitions
WHERE prev_is_exposed IS NOT NULL;

--  dep_releases_new_version | pkg_releases_new_version_same_requirement_same_spec | pkg_releases_new_version_changed_requirement_same_spec | pkg_releases_new_version_changed_requirement_changed_spec |                                                                                                                                                                                                                                                                                                                                                                                                                                                    string_agg                                                                                                                                                                                                                                                                                                                                                                                                                                                    
-- --------------------------+-----------------------------------------------------+--------------------------------------------------------+-----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                        49 |                                                   0 |                                                  19275 |                                                      4103 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> other, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - major, pinned -> floating - minor, pinned -> floating - patch, pinned -> other
-- (1 row)


-- vulnerable -> nonvulnerable, trending constraint type change
WITH version_transitions AS (
    SELECT 
        system_name,
        from_package_name,
        to_package_name,
        from_version,
        actual_requirement,
        to_version,
        interval_start,
        is_exposed,
        LAG(is_exposed) OVER w as prev_is_exposed,
        LAG(from_version) OVER w as prev_from_version,
        LAG(to_version) OVER w as prev_to_version,
        LAG(actual_requirement) OVER w as prev_actual_requirement,
        requirement_type as current_spec_type,
        LAG(requirement_type) OVER w as prev_spec_type
    FROM relations_minified
    WHERE is_regular = true
        AND actual_requirement IS NOT NULL
    WINDOW w AS (
        PARTITION BY system_name, from_package_name, to_package_name 
        ORDER BY interval_start
    )
)
SELECT 
    prev_spec_type || ' -> ' || current_spec_type as spec_type_transition,
    COUNT(*) as transition_count
FROM version_transitions
WHERE 
    is_exposed = false 
    AND prev_is_exposed = true 
    AND from_version != prev_from_version 
    AND actual_requirement != prev_actual_requirement
    AND current_spec_type != prev_spec_type
GROUP BY 
    prev_spec_type, current_spec_type
ORDER BY 
    transition_count DESC;


--                 spec_type_transition                | transition_count 
-- ----------------------------------------------------+------------------
--  pinned -> floating - minor                         |             1140
--  other -> floating - major                          |              845
--  other -> floating - minor                          |              359
--  floating - patch -> floating - minor               |              307
--  floating - minor -> pinned                         |              277
--  other -> floating - patch                          |              202
--  floating - minor -> floating - major               |              163
--  floating - patch -> floating - major               |              162
--  floating - patch -> other                          |              148
--  floating - minor -> floating - major - restrictive |              110
--  pinned -> floating - patch                         |               69
--  floating - patch -> pinned                         |               66
--  other -> floating - major - restrictive            |               49
--  floating - minor -> floating - patch               |               46
--  floating - major - restrictive -> floating - major |               35
--  floating - minor -> other                          |               34
--  pinned -> floating - major                         |               30
--  floating - major - restrictive -> floating - minor |               21
--  floating - patch -> floating - major - restrictive |               12
--  other -> pinned                                    |                8
--  floating - major - restrictive -> other            |                7
--  pinned -> other                                    |                5
--  floating - major - restrictive -> floating - patch |                4
--  floating - major -> other                          |                3
--  floating - major -> floating - major - restrictive |                1
-- (25 rows)
