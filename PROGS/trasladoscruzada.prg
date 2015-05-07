 CLOSE TABLE ALL
 USE traslados
 SELECT 0
 USE vistaAlmacenes ALIAS destinos
 SELECT 0
 USE vistaAlmacenes ALIAS origenes
 SCAN
    m.almacenorigen = codalmacen
    SELECT destinos
    SCAN
       m.almacendestino = codalmacen
       SELECT traslados
       LOCATE ALL FOR almacenorigen=m.almacenorigen .AND. almacendestino=m.almacendestino
       IF  .NOT. FOUND()
          INSERT INTO traslados FROM MEMVAR
       ELSE
          RECALL
       ENDIF
       SELECT destinos
    ENDSCAN
    SELECT origenes
 ENDSCAN
 SELECT traslados
 BROWSE
 
**
