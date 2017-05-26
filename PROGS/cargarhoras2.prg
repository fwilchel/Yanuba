 SELECT horas
 DELETE ALL FOR desde=m.desde .AND. hasta=m.hasta
 &&PACK
 SELECT 0
 USE vendedores
&& SELECT 0
&& USE vistaVendedores
 SELECT 0
 USE vistaHoras
 SCAN FOR horas<>0
    SCATTER MEMO MEMVAR
    m.codalmacen = almacen
    SELECT vistavendedores
    LOCATE ALL FOR ALLTRIM(numssocial)==ALLTRIM(TRANSFORM(INT(m.cedula))) .AND. descatalogado='F'
    IF FOUND()
       m.codvendedor = codvendedor
    ELSE
       LOCATE ALL FOR ALLTRIM(numssocial)==ALLTRIM(TRANSFORM(INT(m.cedula))) .AND. (ISNULL(descatalogado) .OR. descatalogado='T')
       IF FOUND()
          m.codvendedor = codvendedor
       ELSE
          WAIT WINDOW "No se encuentra la cédula "+ALLTRIM(TRANSFORM(INT(m.cedula)))
          m.codvendedor = 0
       ENDIF
    ENDIF
    INSERT INTO horas FROM MEMVAR
    SELECT vistahoras
 ENDSCAN
 SELECT horas
 SET ORDER TO vendedor
 SET FILTER TO desde=m.desde .AND. hasta=m.hasta
 REPLACE rol WITH 0 ALL FOR desde=m.desde .AND. hasta=m.hasta
 SELECT vendedores
 SCAN FOR rol<>0 .AND. rol2=0 .AND. rol3=0
    m.codvendedor = id
    m.rol = rol
    SELECT horas
    REPLACE rol WITH m.rol ALL FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
    SELECT vendedores
 ENDSCAN
 SELECT vendedores
 SCAN FOR rol<>0 .AND. rol2<>0 .AND. rol3=0
    m.codvendedor = id
    m.rol1 = rol
    m.rol2 = rol2
    cual = 1
    SELECT horas
    SCAN FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
       DO CASE
          CASE cual=1
             REPLACE rol WITH m.rol1
          CASE cual=2
             REPLACE rol WITH m.rol2
          OTHERWISE
       ENDCASE
       cual = cual+1
       SCATTER MEMVAR
    ENDSCAN
    IF cual=2
       WAIT WINDOW "Falta un registro de hrs para el codvendedor "+ALLTRIM(STR(m.codvendedor))+" se corrige duplicando"
       m.rol = m.rol2
       INSERT INTO horas FROM MEMVAR
    ENDIF
    SELECT vendedores
 ENDSCAN
 SCAN FOR rol<>0 .AND. rol2<>0 .AND. rol3<>0
    m.codvendedor = id
    m.rol1 = rol
    m.rol2 = rol2
    m.rol3 = rol3
    cual = 1
    SELECT horas
    SCAN FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
       DO CASE
          CASE cual=1
             REPLACE rol WITH m.rol1
          CASE cual=2
             REPLACE rol WITH m.rol2
          CASE cual=3
             REPLACE rol WITH m.rol3
          OTHERWISE
       ENDCASE
       cual = cual+1
       SCATTER MEMVAR
    ENDSCAN
    IF cual=2
       WAIT WINDOW "Falta un registro de hrs para el codvendedor "+ALLTRIM(STR(m.codvendedor))+" se corrige duplicando"
       m.rol = m.rol2
       INSERT INTO horas FROM MEMVAR
       m.rol = m.rol3
       INSERT INTO horas FROM MEMVAR
    ENDIF
    IF cual=3
       m.rol = m.rol3
       INSERT INTO horas FROM MEMVAR
    ENDIF
    SELECT vendedores
 ENDSCAN
 SELECT horas
 REPLACE rol WITH IIF(codalmacen='A1', 29, 22) FOR rol=0 .AND. cedula<2000 .AND. desde=m.desde .AND. hasta=m.hasta
SELECT vendedores
USE
&&SELECT vistavendedores
&&USE
SELECT vistahoras
use 
**

SELECT horas
