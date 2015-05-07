 CLOSE TABLE ALL
 USE c:\basura\data\traslados ALIAS origen
 SELECT 0
 USE traslados ALIAS destino
 SELECT origen
 SCAN
    SCATTER MEMVAR
    INSERT INTO destino FROM MEMVAR
 ENDSCAN
 
**
