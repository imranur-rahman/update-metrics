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