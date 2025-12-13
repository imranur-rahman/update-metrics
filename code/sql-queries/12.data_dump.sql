pg_dump -h localhost -U metricsuser -d metrics --schema-only --table public.relations_minified > schema-relations.sql

Change the column name in the schema

pg_dump -h localhost -U metricsuser -d metrics --data-only --column-inserts --table public.relations_minified > data-relations.sql


pg_dump -h localhost -U metricsuser -d metrics --schema-only --table public.osv_extended > schema-osv-extended.sql

Change the column name in the schema

pg_dump -h localhost -U metricsuser -d metrics --data-only --column-inserts --table public.osv_extended > data-osv-extended.sql
