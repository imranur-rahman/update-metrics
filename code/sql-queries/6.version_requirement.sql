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
-- (169 rows)


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









-- Function to classify version specifications
-- This function classifies version specifications into different categories
-- CREATE OR REPLACE FUNCTION get_spec_type(spec text)
-- RETURNS text AS $$
-- DECLARE
--     req text := lower(trim(spec));
-- BEGIN

--     -- Handle null input
--     IF req IS NULL THEN
--         RETURN 'null';
--     END IF;

--     -- OR-combination: prioritize early
--     IF req LIKE '%||%' THEN
--         RETURN 'or-expression';
--     END IF;

--     -- Floating-major
--     IF req IN ('*', 'latest', 'x', 'x.x', 'x.x.x') OR req ~ '^\*\.\*\.\*$' OR
--           (req LIKE '>=%' AND substring(req from 3) !~ '[<>=!*~^]') OR
--           (req LIKE '>%' AND substring(req from 2) !~ '[<>=!*~^]') THEN
--         RETURN 'floating-major';
--     END IF;

--     -- Floating-patch
--     IF req ~ '^=?=?\d+\.\d+\.x$' OR req ~ '^=?=?\d+\.\d+\.\*$' OR req ~ '^\d+\.\d+\.x$' OR
--           (req LIKE '~%' AND req NOT LIKE '%,%') OR
--           (req LIKE '~=%' AND req !~ '[><^*]') THEN
--         RETURN 'floating-patch';
--     END IF;

--     -- Floating-minor
--     IF req ~ '^=?=?\d+\.x(\.x)?$' OR req ~ '^=?=?\d+\.\*(\.\*)?$' OR req ~ '^x\.\*$' OR req LIKE '^%' THEN
--         RETURN 'floating-minor';
--     END IF;

--     -- Range
--     IF req ~ '^[<>]=?\s*\d+(\.\d+){0,2}(\s*,\s*|\s+)[<>]=?\s*\d+(\.\d+){0,2}$' OR
--           req ~ '^\d+(\.\d+)?(\.\w+)?\s*-\s*\d+(\.\d+)?(\.\w+)?$' OR
--           (req LIKE '%<%' AND req LIKE '%>%' AND req !~ '[!*~^]') OR
--           (req LIKE '% - %' AND req !~ '[!*~^<>]') THEN
--         RETURN 'fixed-ranging';
--     END IF;

--     -- Unclassified
--     IF req LIKE '%github%' OR req LIKE '%gitlab%' OR req LIKE '%git%' OR
--           req LIKE '%npm:%' THEN
--         RETURN 'unclassified';
--     END IF;

--     -- Pinning: simple versions with no operators
--     IF req ~ '^[\w\.\-\+]+' AND req !~ '[<>=!*~^]' AND NOT req LIKE '%.x%' THEN
--         RETURN 'pinning';
--     END IF;

--     -- At-most
--     IF req ~ '^<=?\s*\d+(\.\d+){0,2}(-[a-z0-9]+)?$' OR
--           (req LIKE '<%' AND substring(req from 2) !~ '[=>!*~^]') OR
--           (req LIKE '<=%' AND substring(req from 3) !~ '[>!*~^]') THEN
--         RETURN 'at-most';
--     END IF;

--     -- Not
--     IF req ~ '^!?=?\d+(\.\d+){0,2}$' AND req LIKE '!%' THEN
--         RETURN 'not-expression';
--     END IF;

--     -- Pinning with metadata or pre-release
--     IF req ~ '^\d+(\.\d+){0,2}(-[\w\.-]+)?(\+[\w\.-]+)?$' OR
--           ((req LIKE '=%' OR req LIKE '==%') AND req !~ '[<>\*!~^]') THEN
--         RETURN 'pinning';
--     END IF;

--     -- Complex expression
--     IF req ~ '[<>=!~^]' THEN
--         RETURN 'complex-expression';
--     END IF;

--     -- Final fallback pinning (e.g., bare version with optional metadata)
--     IF req ~ '^\d+(\.\d+){0,2}(-[\w\.-]+)?(\+[\w\.-]+)?$' THEN
--         RETURN 'pinning';
--     END IF;

--     RETURN 'unclassified';
-- END;
-- $$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION get_spec_type(spec text)
RETURNS text AS $$
DECLARE
    req text;
BEGIN
    -- Early return for NULL
    IF spec IS NULL THEN
        RETURN 'null';
    END IF;

    -- Pre-process once
    req := lower(trim(spec));

    RETURN CASE
        -- Quick checks first (no regex)
        WHEN req LIKE '%||%' THEN 'or-expression'
        WHEN req IN ('*', 'latest', 'x', 'x.x', 'x.x.x') THEN 'floating-major'
        WHEN req LIKE '%github%' OR req LIKE '%gitlab%' OR req LIKE '%git%' OR
             req LIKE '%npm:%' THEN 'unclassified'
        
        -- Pinned version with equals and post/dev/alpha/beta suffixes
        WHEN req ~ '^=?=?\d+(\.\d+)*((\.?post\d*)|(-\w+))?$' THEN 'pinning'
        
        -- Rest of the patterns...
        
        -- Floating-minor
        WHEN req ~ '^=?=?\d+\.x(\.x)?$' OR req ~ '^=?=?\d+\.\*(\.\*)?$' OR req ~ '^x\.\*$' OR req LIKE '^%' THEN
             'floating-minor'

        -- Floating-major
        WHEN req ~ '^\*\.\*\.\*$' OR
             (req LIKE '>=%' AND substring(req from 3) !~ '[<>=!*~^]') OR
             (req LIKE '>%' AND substring(req from 2) !~ '[<>=!*~^]') 
             THEN 'floating-major'
        
        -- Floating-patch
        WHEN req ~ '^=?=?\d+\.\d+\.x$' OR req ~ '^=?=?\d+\.\d+\.\*$' OR req ~ '^\d+\.\d+\.x$' OR
             (req LIKE '~%' AND req NOT LIKE '%,%') OR
             (req LIKE '~=%' AND req !~ '[><^*]') THEN
             'floating-patch'
        
        -- Range
        WHEN req ~ '^[<>]=?\s*\d+(\.\d+){0,2}(\s*,\s*|\s+)[<>]=?\s*\d+(\.\d+){0,2}$' OR
             req ~ '^\d+(\.\d+)?(\.\w+)?\s*-\s*\d+(\.\d+)?(\.\w+)?$' OR
             (req LIKE '%<%' AND req LIKE '%>%' AND req !~ '[!*~^]') OR
             (req LIKE '% - %' AND req !~ '[!*~^<>]') THEN
             'fixed-ranging'
        
        -- Unclassified
        WHEN req LIKE '%github%' OR req LIKE '%gitlab%' OR req LIKE '%git%' OR
             req LIKE '%npm:%' THEN 'unclassified'
        
        -- Pinning: simple versions with no operators
        WHEN req ~ '^[\w\.\-\+]+' AND req !~ '[<>=!*~^]' AND NOT req LIKE '%.x%' THEN
             'pinning'
        
        -- At-most
        WHEN req ~ '^<=?\s*\d+(\.\d+){0,2}(-[a-z0-9]+)?$' OR
             (req LIKE '<%' AND substring(req from 2) !~ '[=>!*~^]') OR
             (req LIKE '<=%' AND substring(req from 3) !~ '[>!*~^]') THEN
             'at-most'
        
        -- Not
        WHEN req ~ '^!?=?\d+(\.\d+){0,2}$' AND req LIKE '!%' THEN
             'not-expression'
        
        -- Pinning with metadata or pre-release
        WHEN req ~ '^\d+(\.\d+){0,2}(-[\w\.-]+)?(\+[\w\.-]+)?$' OR
             ((req LIKE '=%' OR req LIKE '==%') AND req !~ '[<>\*!~^]') THEN
             'pinning'
        
        -- Complex expression
        WHEN req ~ '[<>=!~^,]' THEN 'complex-expression'
        
        ELSE 'unclassified'
    END;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
COMMENT ON FUNCTION get_spec_type(text) IS 'Determines the type of version specification (pinned, floating patch/minor/major)';


-- testing
-- Step 1: Create a temporary table to store test inputs
DROP TABLE IF EXISTS test_spec_types;
CREATE TEMP TABLE test_spec_types (
    case_id INTEGER,
    spec TEXT,
    detected_type TEXT,
    expected_type TEXT
);


-- Step 2: Insert all test cases and capture output
INSERT INTO test_spec_types (case_id, spec, detected_type, expected_type)
VALUES
(1, '*', get_spec_type('*'), 'floating-major'),
(2, 'latest', get_spec_type('latest'), 'floating-major'),
(3, '~1.2.3', get_spec_type('~1.2.3'), 'floating-patch'),
(4,  '^1.2.3',               get_spec_type('^1.2.3'), 'floating-minor'),
(5,  '1.2.3',                get_spec_type('1.2.3'), 'pinning'),
(6,  '1.x.x',                get_spec_type('1.x.x'), 'floating-minor'),
(7,  '1.2.x',                get_spec_type('1.2.x'), 'floating-patch'),
(8,  '>=1.2.3',              get_spec_type('>=1.2.3'), 'floating-major'),
(9,  '<1.2.3',               get_spec_type('<1.2.3'), 'at-most'),
(10, '>=1.2.3 <2.0.0',       get_spec_type('>=1.2.3 <2.0.0'), 'fixed-ranging'),
(11, '>=1.2.3 <1.3.0',       get_spec_type('>=1.2.3 <1.3.0'), 'fixed-ranging'),
(12, '>1.0.0 <6',            get_spec_type('> 1.0.0 < 6'), 'fixed-ranging'),
(13, '>1.0.0 <6.0',          get_spec_type('>1.0.0 <6.0'), 'fixed-ranging'),
(14, '>=1.2.3 <5.0.0',       get_spec_type('>=1.2.3 <5.0.0'), 'fixed-ranging'),
(15, '>2.0.0 <6.0.0',        get_spec_type('> 2.0.0 < 6.0.0'), 'fixed-ranging'),
(16, '^1.2.0 || ^2.0.0',     get_spec_type('^1.2.0 || ^2.0.0'), 'or-expression'),
(17, '>= 1.2.3 || <= 1.2.4', get_spec_type('>= 1.2.3 || <= 1.2.4'), 'or-expression'),
(18, '>= 1.2.3 <= 1.2.4',    get_spec_type('>= 1.2.3 <= 1.2.4'), 'fixed-ranging'),
(19, '<2.0.0 || >=1.2.3',    get_spec_type('<2.0.0 || >=1.2.3'), 'or-expression'),
(20, 'npm:eslint-plugin-i@2.27.5-4', get_spec_type('npm:eslint-plugin-i@2.27.5-4'), 'unclassified'),
(21, '<2.8,>=2.4',           get_spec_type('<2.8,>=2.4'), 'fixed-ranging'),
(22, '<2.16.0,>=2.6',        get_spec_type('<2.16.0,>=2.6'), 'fixed-ranging'),
(23, '<=2.18.2',             get_spec_type('<=2.18.2'), 'at-most'),
(24, '==2.10.*',             get_spec_type('==2.10.*'), 'floating-patch'),
(25, '==1.1.post2',          get_spec_type('==1.1.post2'), 'pinning'),
(26, '>= 5.0.0 < 9.0.0',     get_spec_type('>= 5.0.0 < 9.0.0'), 'fixed-ranging'),
(27, '13.0.x || > 13.1.0 < 14.0.0', get_spec_type('13.0.x || > 13.1.0 < 14.0.0'), 'or-expression'),
(28, '=0.8.x',               get_spec_type('=0.8.x'), 'floating-patch'),
(29, '>= 6.x.x',             get_spec_type('>= 6.x.x'), 'floating-major'),
(30, '0.18 - 0.26 || ^0.26.0', get_spec_type('0.18 - 0.26 || ^0.26.0'), 'or-expression'),
(31, '7.*',                  get_spec_type('7.*'), 'floating-minor'),
(32, '7.x',                  get_spec_type('7.x'), 'floating-minor'),
(33, '>=10 <= 11',           get_spec_type('>=10 <= 11'), 'fixed-ranging'),
(34, 'v3.6.0-upgrade-to-lit.1', get_spec_type('v3.6.0-upgrade-to-lit.1'), 'pinning'),
(35, '11 || 12 || 13',       get_spec_type('11 || 12 || 13'), 'or-expression'),
(36, '>= 1.2.3 < 2.0.0',     get_spec_type('>= 1.2.3 < 2.0.0'), 'fixed-ranging'),
(37, '>=3 || >=3.0.0-beta',  get_spec_type('>=3 || >=3.0.0-beta'), 'or-expression'),
(38, 'v1.0.0',               get_spec_type('v1.0.0'), 'pinning'),
(39, '>1.1.2-dev <1.1.2-ropsten', get_spec_type('>1.1.2-dev <1.1.2-ropsten'), 'fixed-ranging'),
(40, '0.6.X',                get_spec_type('0.6.X'), 'floating-patch'),
(41, '==1.0.0.dev11',        get_spec_type('==1.0.0.dev11'), 'pinning'),
(42, '~=1.0.0.dev20',        get_spec_type('~=1.0.0.dev20'), 'floating-patch'),
(43, '>=1.3.0,~=1.3',        get_spec_type('>=1.3.0,~=1.3'), 'complex-expression'),
(44, '~=1.3,>=1.3.0',        get_spec_type('~=1.3,>=1.3.0'), 'complex-expression'),
(45, '~=1.3',                get_spec_type('~=1.3'), 'floating-patch'),
(46, '1.0.6-alpha.18494658a.0', get_spec_type('1.0.6-alpha.18494658a.0'), 'pinning'),
(47, '6.2.9-alpha-aa43054d.0',  get_spec_type('6.2.9-alpha-aa43054d.0'), 'pinning'),
(48, '>=0.12', get_spec_type('>=0.12'), 'floating-major'),
(49, '>= 0.9, ^0.10.0', get_spec_type('>= 0.9, ^0.10.0'), 'complex-expression'),
(50, '19.1.4 - 21', get_spec_type('19.1.4 - 21'), 'fixed-ranging'),
(51, '5.1.2 - 6.7.0', get_spec_type('5.1.2 - 6.7.0'), 'fixed-ranging'),
(52, '2 - 4', get_spec_type('2 - 4'), 'fixed-ranging');


-- Step 3: Display results
SELECT case_id, spec, detected_type, expected_type,
       detected_type = expected_type AS pass
FROM test_spec_types
ORDER BY case_id;



-- drop column if needed and then add the new column
ALTER TABLE relations_minified DROP COLUMN IF EXISTS requirement_type;
-- Adding a new column to the relations_minified table
-- to store the constraint type
ALTER TABLE relations_minified
ADD COLUMN requirement_type TEXT DEFAULT 'unclassified';

-- update cost for parallel execution
-- ALTER FUNCTION get_spec_type(text) SET parallel_worker_cost = 0;
ALTER FUNCTION get_spec_type(text) SET parallel_tuple_cost = 0;

UPDATE relations_minified
SET requirement_type = get_spec_type(actual_requirement)
WHERE actual_requirement IS NOT NULL
AND is_regular = true;
-- UPDATE 88031972

DROP INDEX IF EXISTS relations_index_4;
CREATE INDEX relations_index_4 ON relations_minified (requirement_type);


-- Occurance of each requirement type
SELECT 
    requirement_type,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM 
    relations_minified
WHERE
    is_regular = true
    AND actual_requirement IS NOT NULL
GROUP BY 
    requirement_type
ORDER BY 
    count DESC;

--   requirement_type  |  count   | percentage 
-- --------------------+----------+------------
--  floating-minor     | 52756242 |      59.93
--  pinning            | 24803391 |      28.18
--  floating-major     |  5071604 |       5.76
--  fixed-ranging      |  2761388 |       3.14
--  floating-patch     |  2292972 |       2.60
--  at-most            |   143890 |       0.16
--  complex-expression |   107146 |       0.12
--  or-expression      |    86235 |       0.10
--  not-expression     |     9104 |       0.01
-- (9 rows)



-- outdated dependencies: general overview
-- result to RQ1
-- 1. Materialize common calculations first
WITH RECURSIVE highest AS (
    SELECT MAX(interval_start) as db_creation_date
    FROM relations_minified
),
-- 2. Pre-filter and index the base data
filtered_requirements AS (
    SELECT 
        requirement_type,
        from_package_name,
        from_version,
        to_package_name,
        interval_start,
        interval_end,
        (SELECT db_creation_date FROM highest) as db_creation_date
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND is_out_of_date = true
        AND actual_requirement IS NOT NULL
),
-- 3. Pre-calculate days for each record
days_calculated AS (
    SELECT 
        *,
        EXTRACT(EPOCH FROM (COALESCE(interval_end, db_creation_date) - interval_start))/86400 as days
    FROM filtered_requirements
),
-- 4. Calculate total days once
total_days AS (
    SELECT SUM(days) as sum_total_days
    FROM days_calculated
)
-- 5. Final aggregation with pre-calculated values
SELECT 
    requirement_type,
    COUNT(*) as total_count,
    COUNT(DISTINCT CONCAT_WS('|', from_package_name, from_version, to_package_name)) as unique_pkg_pkgver_dep_count,
    COUNT(DISTINCT CONCAT_WS('|', from_package_name, to_package_name)) as unique_pkg_dep_count,
    COUNT(DISTINCT from_package_name) as unique_pkg_count,
    SUM(days) as total_days,
    ROUND(100.0 * SUM(days) / NULLIF((SELECT sum_total_days FROM total_days), 0), 2) as days_percentage
FROM 
    days_calculated
GROUP BY 
    requirement_type
ORDER BY 
    total_days DESC;


--   requirement_type  | total_count | unique_pkg_pkgver_dep_count | unique_pkg_dep_count | unique_pkg_count |             total_days             | days_percentage 
-- --------------------+-------------+-----------------------------+----------------------+------------------+------------------------------------+-----------------
--  floating-minor     |    13966739 |                     7730545 |               354678 |            87637 | 175385311.691874999999644045047490 |           60.46
--  pinning            |    13117575 |                     9687426 |               204360 |            47733 |  89310500.392418981481491993189862 |           30.79
--  floating-patch     |     1119255 |                      562445 |                30680 |            11096 |  13592325.692407407407335987992373 |            4.69
--  fixed-ranging      |      866900 |                      316645 |                27111 |            10659 |   9545365.392731481481735041427075 |            3.29
--  at-most            |       96102 |                       47131 |                 4995 |             3172 |   1489122.457870370370373962771840 |            0.51
--  floating-major     |       57769 |                        9548 |                 1963 |             1728 |    299634.096655092592587597180987 |            0.10
--  or-expression      |       30923 |                       14117 |                  946 |              645 |    262043.914444444444436025375186 |            0.09
--  complex-expression |       12209 |                        5282 |                 1061 |              837 |    189263.339097222222225907641077 |            0.07
--  not-expression     |        1534 |                         276 |                  106 |              100 |      7346.784328703703702848268148 |            0.00
-- (9 rows)


-- vulnerable dependencies: general overview
-- result to RQ1
-- 1. Materialize common calculations first
WITH RECURSIVE highest AS (
    SELECT MAX(interval_start) as db_creation_date
    FROM relations_minified
),
-- 2. Pre-filter and index the base data
filtered_requirements AS (
    SELECT 
        requirement_type,
        from_package_name,
        from_version,
        to_package_name,
        interval_start,
        interval_end,
        (SELECT db_creation_date FROM highest) as db_creation_date
    FROM 
        relations_minified
    WHERE 
        is_regular = true
        AND is_exposed = true
        AND actual_requirement IS NOT NULL
),
-- 3. Pre-calculate days for each record
days_calculated AS (
    SELECT 
        *,
        EXTRACT(EPOCH FROM (COALESCE(interval_end, db_creation_date) - interval_start))/86400 as days
    FROM filtered_requirements
),
-- 4. Calculate total days once
total_days AS (
    SELECT SUM(days) as sum_total_days
    FROM days_calculated
)
-- 5. Final aggregation with pre-calculated values
SELECT 
    requirement_type,
    COUNT(*) as total_count,
    COUNT(DISTINCT CONCAT_WS('|', from_package_name, from_version, to_package_name)) as unique_pkg_pkgver_dep_count,
    COUNT(DISTINCT CONCAT_WS('|', from_package_name, to_package_name)) as unique_pkg_dep_count,
    COUNT(DISTINCT from_package_name) as unique_pkg_count,
    SUM(days) as total_days,
    ROUND(100.0 * SUM(days) / NULLIF((SELECT sum_total_days FROM total_days), 0), 2) as days_percentage
FROM 
    days_calculated
GROUP BY 
    requirement_type
ORDER BY 
    total_days DESC;

--   requirement_type  | total_count | unique_pkg_pkgver_dep_count | unique_pkg_dep_count | unique_pkg_count |            total_days            | days_percentage 
-- --------------------+-------------+-----------------------------+----------------------+------------------+----------------------------------+-----------------
--  floating-minor     |      377834 |                      197476 |                13907 |            11398 | 6224998.702025462963002667354452 |           44.12
--  pinning            |      415409 |                      214675 |                17385 |             9926 | 6173429.745300925925929769586645 |           43.75
--  floating-patch     |       48703 |                       18311 |                 2293 |             1647 |  879357.045787037037026527816297 |            6.23
--  fixed-ranging      |       33019 |                       15803 |                 2765 |             2144 |  701206.349305555555542307777404 |            4.97
--  at-most            |        6041 |                        2433 |                  470 |              427 |      114057.76657407407406752969 |            0.81
--  complex-expression |        1479 |                         287 |                   63 |               56 |       13960.67704861111110971104 |            0.10
--  or-expression      |         177 |                          62 |                   16 |               16 |        3065.95626157407407372590 |            0.02
--  not-expression     |          10 |                           8 |                    6 |                6 |         149.02063657407407408889 |            0.00
--  floating-major     |           3 |                           3 |                    3 |                3 |      29.946840277777777800000000 |            0.00
-- (9 rows)



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
--                       235 |                                                1023 |                                                  47168 |                                                     23018 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - major -> pinned, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - major, pinned -> floating - major - restrictive, pinned -> floating - minor, pinned -> floating - patch, pinned -> other


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
-- --------------------------+-----------------------------------------------------+--------------------------------------------------------+-----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                      5657 |                                                  75 |                                                5219238 |                                                     71190 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - major, pinned -> floating - major - restrictive, pinned -> floating - minor, pinned -> floating - patch, pinned -> other


-- outdated -> updated, trending constraint type change
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
--  floating - major -> other                          |             7219
--  floating - patch -> floating - minor               |             5597
--  floating - minor -> floating - major               |             3082
--  floating - patch -> floating - major               |             1875
--  pinned -> floating - patch                         |             1728
--  other -> floating - patch                          |             1718
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
--                        29 |                                                1267 |                                                    558 |                                                      1138 | floating - major - restrictive -> floating - major, floating - major - restrictive -> floating - minor, floating - major - restrictive -> floating - patch, floating - major - restrictive -> other, floating - major -> floating - major - restrictive, floating - major -> floating - minor, floating - major -> floating - patch, floating - major -> other, floating - minor -> floating - major, floating - minor -> floating - major - restrictive, floating - minor -> floating - patch, floating - minor -> other, floating - minor -> pinned, floating - patch -> floating - major - restrictive, floating - patch -> floating - minor, floating - patch -> other, floating - patch -> pinned, other -> floating - major, other -> floating - major - restrictive, other -> floating - minor, other -> floating - patch, other -> pinned, pinned -> floating - minor



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
