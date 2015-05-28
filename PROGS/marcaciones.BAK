 IF FILE("data\extras.dbf")
    DROP TABLE extras
 ENDIF
 SELECT 0
 USE festivos
 SELECT * FROM vistaMarcaciones INTO CURSOR vm1
 m.hastabk = m.hasta
 m.hasta = m.hasta+1
 SELECT * FROM vistaMarcaciones WHERE (HOUR(horain)=0 AND MINUTE(horain)=0 AND SEC(horain)=0) INTO CURSOR vm2
 m.hasta = m.hastabk
 SELECT vm1.fo, vm1.codempleado, vm1.nomvendedor, vm1.dia, vm1.horain, vm2.horaout, vm1.horas+vm2.horas, vm1.caja, vm1.codalmacen FROM vm1 LEFT JOIN vm2 ON vm1.codempleado=vm2.codempleado AND vm1.caja=vm2.caja AND TTOD(vm1.horaout)+1=TTOD(vm2.horain) WHERE (HOUR(vm1.horaout)=23 AND MINUTE(vm1.horaout)=59) AND  NOT (HOUR(vm1.horain)=0 AND MINUTE(vm1.horain)=0) INTO CURSOR cortados
 SET FILTER TO ISNULL(horaout)
 BROWSE NOAPPEND NOEDIT NODELETE NORMAL TITLE "Marcaciones sin salida"
 SET FILTER TO
 SELECT * FROM vm1 WHERE  NOT (HOUR(horaout)=23 AND MINUTE(horaout)=59) AND  NOT (HOUR(horain)=0 AND MINUTE(horain)=0) UNION ALL SELECT * FROM cortados WHERE horaout IS NOT NULL  INTO CURSOR marcaciones
 SELECT vm.*, calcularhoraentrada(horain) AS entrada, calcularhorasalida(horaout) AS salida, (calcularhorasalida(horaout)-calcularhoraentrada(horain))/3600 AS tiempo FROM Marcaciones AS vm INTO CURSOR paso1
 SELECT paso1.*, IIF(salida<entrada+IIF(caja='B5' AND DOW(entrada)>=2 AND DOW(entrada)<=5, 10, 8)*3600, salida, entrada+IIF(caja='B5' AND DOW(entrada)>=2 AND DOW(entrada)<=5, 10, 8)*3600) AS finturno FROM paso1 ORDER BY caja, nomvendedor, entrada INTO CURSOR paso2
 COPY TO data\extras DATABASE interfaz
 ALTER TABLE extras ADD COLUMN rn N (10, 3)
 ALTER TABLE extras ADD COLUMN rnf N (10, 3)
 ALTER TABLE extras ADD COLUMN hed N (10, 3)
 ALTER TABLE extras ADD COLUMN hen N (10, 3)
 ALTER TABLE extras ADD COLUMN hf N (10, 3)
 ALTER TABLE extras ADD COLUMN hefd N (10, 3)
 ALTER TABLE extras ADD COLUMN hefn N (10, 3)
 ALTER TABLE extras ADD COLUMN retardos N (10, 3)
 SELECT extras
 SCAN
    rn(entrada, finturno)
    hf(entrada, salida)
    he(entrada, salida, finturno, SUBSTR(caja, 1, 2))
    retardos()
 ENDSCAN
 BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 COPY TO extras.xls TYPE XLS
 SELECT codempleado, nomvendedor, codalmacen, SUM(rn), SUM(rnf), SUM(hed), SUM(hen), SUM(hf), SUM(hefd), SUM(hefn), SUM(retardos), SUM(hed)-redondear2(SUM(retardos)/60) AS sum_hed_retardos FROM extras GROUP BY 1, 2, 3 ORDER BY 3, 2 INTO CURSOR ResumenExtras
 COPY TO ResumenExtras.xls TYPE XLS
 SELECT extras
 REPLACE rn WITH redondear2(rn) ALL
 REPLACE rnf WITH redondear2(rnf) ALL
 REPLACE hed WITH redondear2(hed) ALL
 REPLACE hen WITH redondear2(hen) ALL
 REPLACE hf WITH redondear2(hf) ALL
 REPLACE hefd WITH redondear2(hefd) ALL
 REPLACE hefn WITH redondear2(hefn) ALL
 COPY TO extras2.xls TYPE XLS
 SELECT codempleado, nomvendedor, codalmacen, SUM(rn), SUM(rnf), SUM(hed), SUM(hen), SUM(hf), SUM(hefd), SUM(hefn), SUM(retardos), SUM(hed)-redondear2(SUM(retardos)/60) AS sum_hed_retardos FROM extras GROUP BY 1, 2, 3 ORDER BY 3, 2 INTO CURSOR ResumenExtras2
 COPY TO ResumenExtras2.xls TYPE XLS
 CLOSE TABLE ALL
 RETURN
 
**
PROCEDURE retardos
 IF horain>entrada
    REPLACE retardos WITH ROUND((horain-entrada)/60, 0)
 ENDIF
ENDPROC
**
PROCEDURE he
 PARAMETER entrada, salida, finturno, m.caja
 IF (m.salida-m.entrada)/3600>8
    IF TTOD(m.entrada)<>TTOD(m.salida)
       IF (MINUTE(m.salida)=0 .OR. MINUTE(m.salida)=15 .OR. MINUTE(m.salida)=30 .OR. MINUTE(m.salida)=45 .OR. m.caja='B5')
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefd WITH hefd+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.entrada))
          ELSE
             REPLACE hed WITH hed+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.entrada))
          ENDIF
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.entrada))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.entrada))
          ENDIF
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.entrada))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.entrada))
          ENDIF
          IF esfestivo(TTOD(m.salida))
             REPLACE hefd WITH hefd+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.salida))
          ELSE
             REPLACE hed WITH hed+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.salida))
          ENDIF
          IF esfestivo(TTOD(m.salida))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.salida))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.salida))
          ENDIF
          IF esfestivo(TTOD(m.salida))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.salida))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.salida))
          ENDIF
       ENDIF
    ELSE
       IF (MINUTE(m.salida)=0 .OR. MINUTE(m.salida)=15 .OR. MINUTE(m.salida)=30 .OR. MINUTE(m.salida)=45 .OR. m.caja='B5')
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefd WITH hefd+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.entrada))
          ELSE
             REPLACE hed WITH hed+tiempointerseccion(m.finturno, m.salida, 6, 22, TTOD(m.entrada))
          ENDIF
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.entrada))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 0, 6, TTOD(m.entrada))
          ENDIF
          IF esfestivo(TTOD(m.entrada))
             REPLACE hefn WITH hefn+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.entrada))
          ELSE
             REPLACE hen WITH hen+tiempointerseccion(m.finturno, m.salida, 22, 24, TTOD(m.entrada))
          ENDIF
       ENDIF
    ENDIF
 ENDIF
 RETURN
ENDPROC
**
PROCEDURE hf
 PARAMETER entrada, salida
 m.tiempo = 0
 IF TTOD(m.entrada)<>TTOD(m.salida)
    IF esfestivo(TTOD(m.entrada))
       REPLACE hf WITH tiempointerseccion(m.entrada, m.salida, 6, 22, TTOD(m.entrada))
    ENDIF
    IF esfestivo(TTOD(m.salida))
       REPLACE hf WITH hf+tiempointerseccion(m.entrada, m.salida, 6, 22, TTOD(m.salida))
    ENDIF
 ELSE
    IF esfestivo(TTOD(m.entrada))
       REPLACE hf WITH tiempointerseccion(m.entrada, m.salida, 6, 22, TTOD(m.entrada))
    ENDIF
 ENDIF
 IF hf>8
    REPLACE hf WITH 8
 ENDIF
ENDPROC
**
PROCEDURE rn
 PARAMETER entrada, salida
 m.tiempo = 0
 IF TTOD(m.entrada)<>TTOD(m.salida)
    IF (MINUTE(m.salida)=0 .OR. MINUTE(m.salida)=15 .OR. MINUTE(m.salida)=30 .OR. MINUTE(m.salida)=45)
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 22, 24, TTOD(m.entrada))
       IF esfestivo(TTOD(m.entrada))
          REPLACE rnf WITH m.tiempo
       ELSE
          REPLACE rn WITH m.tiempo
       ENDIF
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 0, 6, TTOD(m.entrada))
       IF esfestivo(TTOD(m.entrada))
          REPLACE rnf WITH rnf+m.tiempo
       ELSE
          REPLACE rn WITH rn+m.tiempo
       ENDIF
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 0, 6, TTOD(m.salida))
       IF esfestivo(TTOD(m.salida))
          REPLACE rnf WITH rnf+m.tiempo
       ELSE
          REPLACE rn WITH rn+m.tiempo
       ENDIF
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 22, 24, TTOD(m.salida))
       IF esfestivo(TTOD(m.salida))
          REPLACE rnf WITH rnf+m.tiempo
       ELSE
          REPLACE rn WITH rn+m.tiempo
       ENDIF
    ENDIF
 ELSE
    IF (MINUTE(m.salida)=0 .OR. MINUTE(m.salida)=15 .OR. MINUTE(m.salida)=30 .OR. MINUTE(m.salida)=45)
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 0, 6, TTOD(m.entrada))
       IF esfestivo(TTOD(m.entrada))
          REPLACE rnf WITH m.tiempo
       ELSE
          REPLACE rn WITH m.tiempo
       ENDIF
       m.tiempo = tiempointerseccion(m.entrada, m.salida, 22, 24, TTOD(m.entrada))
       IF esfestivo(TTOD(m.entrada))
          REPLACE rnf WITH rnf+m.tiempo
       ELSE
          REPLACE rn WITH rn+m.tiempo
       ENDIF
    ENDIF
 ENDIF
 RETURN
ENDPROC
**
FUNCTION tiempointerseccion
 PARAMETER entrada, salida, hini, hfin, m.fecha
 m.dia = DAY(m.fecha)
 m.mes = MONTH(m.fecha)
 m.ano = YEAR(m.fecha)
 m.ini = CTOT(ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano))+" "+ALLTRIM(STR(hini))+":00:00")
 IF hfin=24
    m.fin = DTOT(CTOD(ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano)))+1)
 ELSE
    m.fin = CTOT(ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano))+" "+ALLTRIM(STR(hfin))+":00:00")
 ENDIF
 m.tiempo = 0
 IF m.salida<=ini .OR. m.entrada>=fin
    RETURN 0
 ENDIF
 IF m.entrada<=ini .AND. m.salida>ini .AND. m.salida<fin
    m.tiempo = tiempo(ini, m.salida)
 ENDIF
 IF m.entrada>=ini .AND. m.entrada<=fin .AND. m.salida>=ini .AND. m.salida<=fin
    m.tiempo = tiempo(m.entrada, m.salida)
 ENDIF
 IF m.entrada>=ini .AND. m.entrada<=fin .AND. m.salida>=fin
    m.tiempo = tiempo(m.entrada, fin)
 ENDIF
 IF m.entrada<=ini .AND. m.salida>=fin
    m.tiempo = tiempo(ini, fin)
 ENDIF
 RETURN m.tiempo
ENDFUNC
**
FUNCTION tiempo
 PARAMETER f1, f2
 RETURN (f2-f1)/3600
ENDFUNC
**
FUNCTION esfestivo
 PARAMETER m.fecha
 IF DOW(m.fecha)=1
    RETURN .T.
 ELSE
    zona = SELECT()
    SELECT festivos
    LOCATE ALL FOR fecha=m.fecha
    encontro = FOUND()
    SELECT (zona)
    RETURN encontro
 ENDIF
ENDFUNC
**
FUNCTION calcularhoraentrada
 PARAMETER ingreso
 m.dia = DAY(ingreso)
 m.mes = MONTH(ingreso)
 m.ano = YEAR(ingreso)
 m.hora = HOUR(ingreso)
 m.minuto = MINUTE(ingreso)
 IF minuto>=54
    m.minuto = 0
    m.hora = hora+1
 ELSE
    IF m.minuto>=24 .AND. minuto<=30
       m.minuto = 30
    ELSE
       IF minuto>=0 .AND. minuto<24
          minuto = 0
       ELSE
          m.minuto = 30
       ENDIF
    ENDIF
 ENDIF
 m.fecha = ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano))+" "+ALLTRIM(STR(hora))+":"+ALLTRIM(STR(minuto))+":00"
 RETURN CTOT(m.fecha)
ENDFUNC
**
FUNCTION calcularhorasalida
 PARAMETER m.ingreso
 m.dia = DAY(m.ingreso)
 m.mes = MONTH(m.ingreso)
 m.ano = YEAR(m.ingreso)
 m.hora = HOUR(m.ingreso)
 m.minuto = MINUTE(m.ingreso)
 m.fecha = ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano))+" "+ALLTRIM(STR(hora))+":"+ALLTRIM(STR(minuto))+":00"
 RETURN CTOT(m.fecha)
ENDFUNC
**
FUNCTION redondear
 PARAMETER m.tiempo
 horase = INT(m.tiempo)-8
 decimales = m.tiempo-INT(m.tiempo)
 IF decimales>=(11/12)
    m.horase = m.horase+1
 ELSE
    IF decimales>=(41/60)
       horase = horase+0.75 
    ELSE
       IF decimales>=(09/20)
          horase = horase+0.5 
       ELSE
          IF decimales>=(13/60)
             horase = horase+0.25 
          ENDIF
       ENDIF
    ENDIF
 ENDIF
 RETURN horase
ENDFUNC
**
FUNCTION redondear2
 PARAMETER m.tiempo
 signo = IIF(m.tiempo<0, -1, 1)
 m.tiempo = ABS(m.tiempo)
 horase = INT(m.tiempo)*1.00000 
 decimales = m.tiempo-INT(m.tiempo)
 IF decimales>=(11/12)
    m.horase = m.horase+1
 ELSE
    IF decimales>=(41/60)
       horase = horase+0.75 
    ELSE
       IF decimales>=(09/20)
          horase = horase+0.5 
       ELSE
          IF decimales>=(13/60)
             horase = horase+0.25 
          ENDIF
       ENDIF
    ENDIF
 ENDIF
 RETURN horase*signo
ENDFUNC
**
FUNCTION calcularrn
 PARAMETER m.entrada, m.finturno
 m.dia = DAY(entrada)
 m.mes = MONTH(entrada)
 m.ano = YEAR(entrada)
 m.hora = HOUR(entrada)
 m.minuto = MINUTE(entrada)
 m.inicio = CTOT(ALLTRIM(STR(m.dia))+"/"+ALLTRIM(STR(m.mes))+"/"+ALLTRIM(STR(m.ano))+" 22:00:00")
 m.fin = m.inicio+028800
 IF (m.finturno>m.inicio .AND. m.finturno<=m.fin) .OR. (m.entrada>=m.inicio .AND. m.entrada<m.fin)
    IF m.entrada<m.inicio .AND. m.finturno>m.inicio
       RETURN redondear2((m.finturno-m.inicio)/3600)
    ELSE
       IF m.entrada>=m.inicio .AND. m.finturno<=m.fin
          RETURN redondear2((m.finturno-m.entrada)/3600)
       ELSE
          RETURN redondear2((m.fin-m.entrada)/3600)
       ENDIF
    ENDIF
 ELSE
    RETURN 00.0000 
 ENDIF
ENDFUNC
**
