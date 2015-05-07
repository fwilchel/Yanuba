 zona = SELECT()
 IF USED("consecutivo")
    SELECT consecutivo
    usado = .T.
 ELSE
    SELECT 0
    USE consecutivo
    usado = .F.
 ENDIF
 LOCATE ALL FOR fecha=TTOD(m.fecha)
 IF FOUND()
    m.numero = numero
 ELSE
    CALCULATE MAX(numero) TO m.numero 
    m.numero = m.numero+1
    INSERT INTO consecutivo FROM MEMVAR
 ENDIF
 IF  .NOT. usado
    USE
 ENDIF
 SELECT (zona)
 
**
