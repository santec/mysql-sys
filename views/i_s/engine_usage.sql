--
-- View: engine_usage
--
-- Storage engines usage statistics.
--
-- mysql> SELECT * FROM sys.engine_usage;
--          +--------------------+--------------+
--          | engine             | tables_count |
--          +--------------------+--------------+
--          | ARCHIVE            |            0 |
--          | BLACKHOLE          |            0 |
--          | CSV                |            2 |
--          | InnoDB             |          306 |
-- ...
--          +--------------------+--------------+
--          8 rows in set (0.01 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW engine_usage (
  engine,
  tables_count
) AS
  SELECT e.ENGINE, COUNT(t.ENGINE) AS tables_count
    FROM INFORMATION_SCHEMA.ENGINES e
    LEFT JOIN INFORMATION_SCHEMA.TABLES t
      ON e.ENGINE = t.ENGINE
    WHERE e.SUPPORT IN ('YES', 'DEFAULT')
    GROUP BY e.ENGINE
    ORDER BY e.ENGINE;
