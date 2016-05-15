-- Copyright (c) 2014, 2015, Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

--
-- View: schema_object
-- 
-- A list of all objects contained in each database: tables, views, triggers, procedures, functions, events.
-- Objects that are not contained in a database are not included.
--
-- 
-- mysql> SELECT * FROM schema_object LIMIT 5;
-- +--------------------+-------------+---------------------------------------+
-- | object_schema      | object_type | object_name                           |
-- +--------------------+-------------+---------------------------------------+
-- | information_schema | VIEW        | CHARACTER_SETS                        |
-- | information_schema | VIEW        | COLLATIONS                            |
-- | information_schema | VIEW        | COLLATION_CHARACTER_SET_APPLICABILITY |
-- | information_schema | VIEW        | COLUMNS                               |
-- | information_schema | VIEW        | COLUMN_PRIVILEGES                     |
-- +--------------------+-------------+---------------------------------------+
-- 5 rows in set (0.02 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW schema_object (
  object_schema,
  object_type,
  object_name
) AS
(SELECT
    TABLE_SCHEMA AS object_schema,
    IF(TABLE_TYPE IN ('VIEW', 'SYSTEM VIEW'), 'VIEW', 'TABLE') AS object_type,
    TABLE_NAME AS object_name
  FROM information_schema.TABLES)
UNION
(SELECT
    TRIGGER_SCHEMA AS object_schema,
    'TRIGGER' AS object_type,
    TRIGGER_NAME AS object_name
  FROM information_schema.TRIGGERS)
UNION
(SELECT
    ROUTINE_SCHEMA AS object_schema,
    ROUTINE_TYPE AS object_type,
    ROUTINE_NAME AS object_name
  FROM information_schema.ROUTINES)
UNION
(SELECT
    EVENT_SCHEMA AS object_schema,
    'EVENT' AS object_type,
    EVENT_NAME AS object_name
  FROM information_schema.EVENTS)
ORDER BY object_schema, object_type, object_name;

