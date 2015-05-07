 CLOSE TABLE
 USE vendedores
 SELECT 0
 USE vistaVendedores
 SCAN
    m.id = codvendedor
    m.nombre = nomvendedor
    m.activo = IIF(activo='F', .F., .T.)
    SELECT vendedores
    LOCATE ALL FOR id=m.id
    IF FOUND()
       GATHER MEMO MEMVAR
    ELSE
       INSERT INTO vendedores FROM MEMVAR
    ENDIF
    SELECT vistavendedores
 ENDSCAN
 
**
