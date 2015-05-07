 CLOSE TABLE ALL
 DROP TABLE plano
 CREATE TABLE data\plano (c1 C (1))
 SELECT 0
 USE vistaCampos
 SCAN
    SCATTER MEMO MEMVAR
    m.campo2 = STRTRAN(SUBSTR(m.campo, 9), '-', '_')
    ALTER TABLE plano ADD COLUMN '&campo2' c(m.FINAL-m.inicial+1)
    SELECT vistacampos
 ENDSCAN
 SELECT plano
 ALTER TABLE plano DROP COLUMN c1
 BROWSE
 
**
