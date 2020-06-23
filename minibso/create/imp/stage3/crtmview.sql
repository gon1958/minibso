CREATE MATERIALIZED VIEW LOG ON CLASS_PARTS
  TABLESPACE T_USR
  WITH ROWID EXCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON CLASSES
  TABLESPACE T_USR 
  WITH ROWID EXCLUDING NEW VALUES;


CREATE MATERIALIZED VIEW MV_UK_CLASSES_CLASSPARTS (CRID, ERID)
  TABLESPACE T_USR 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FAST ON COMMIT
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS select c.rowid crid, e.rowid erid
  from classes c, class_parts e
  where c.id = e.id;

EXIT