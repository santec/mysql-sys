--
-- View: innodb_foreign_key
--
-- Information about foreign keys in InnoDB tables.
--
-- mysql> SELECT * FROM innodb_foreign_key LIMIT 2 \G
--          *************************** 1. row ***************************
--           foreign_key_schema: test
--            foreign_key_table: post
--          foreign_key_columns: blog_id
--            referenced_schema: test
--             referenced_table: blog
--           referenced_columns: id
--                columns_count: 1
--                    on_delete: RESTRICT
--                    on_update: RESTRICT
--          *************************** 2. row ***************************
--           foreign_key_schema: test
--            foreign_key_table: post
--          foreign_key_columns: user_id
--            referenced_schema: test
--             referenced_table: user
--           referenced_columns: id
--                columns_count: 1
--                    on_delete: CASCADE
--                    on_update: CASCADE
--          2 rows in set (0.00 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW innodb_foreign_key (
  foreign_key_schema,
  foreign_key_table,
  foreign_key_columns,
  referenced_schema,
  referenced_table,
  referenced_columns,
  columns_count,
  on_delete,
  on_update
) AS
  SELECT
      -- InnoDB format: 'db_name/tab_name'
      SUBSTRING_INDEX(fk.FOR_NAME, '/', 1) AS foreign_key_schema,
      SUBSTRING(fk.FOR_NAME FROM LOCATE('/', fk.FOR_NAME) + 1) AS foreign_key_table,
      c.foreign_key_columns,
      SUBSTRING_INDEX(fk.REF_NAME, '/', 1) AS referenced_schema,
      SUBSTRING(fk.REF_NAME FROM LOCATE('/', fk.REF_NAME) + 1) AS referenced_table,
      c.referenced_columns,
      -- tools can find out cols number without parsing a list
      c.columns_count,
      -- 0   ON DELETE/UPDATE RESTRICT (default)
      -- 1   ON DELETE CASCADE,
      -- 2   ON DELETE SET NULL,
      -- 4   ON UPDATE CASCADE,
      -- 8   ON UPDATE SET NULL,
      -- 16  ON DELETE NO ACTION,
      -- 32  ON UPDATE NO ACTION
      IF(fk.TYPE & 1, 'CASCADE', IF(fk.TYPE & 2, 'SET NULL', IF(fk.TYPE & 16, 'NO ACTION', 'RESTRICT'))) AS on_delete,
      IF(fk.TYPE & 4, 'CASCADE', IF(fk.TYPE & 8, 'SET NULL', IF(fk.TYPE & 32, 'NO ACTION', 'RESTRICT'))) AS on_update
    FROM (
      SELECT
          id,
          COUNT(FOR_COL_NAME) AS columns_count,
          GROUP_CONCAT(FOR_COL_NAME ORDER BY POS SEPARATOR ', ') AS foreign_key_columns,
          GROUP_CONCAT(REF_COL_NAME ORDER BY POS SEPARATOR ', ') AS referenced_columns
        FROM information_schema.INNODB_SYS_FOREIGN_COLS
        GROUP BY ID
    ) c
    INNER JOIN information_schema.INNODB_SYS_FOREIGN fk
      ON c.id = fk.ID;
