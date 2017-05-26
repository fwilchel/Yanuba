CLOSE TABLES all
USE config
SCATTER MEMVAR memo


SELECT DISTINCT co FROM almacenes WHERE LEN(ALLTRIM(co))>0 INTO CURSOR grupos


SELECT cedula, planilla.codalmacen, INT(sum(propina)) as propina, co, cc ;
FROM planilla ;
LEFT OUTER JOIN almacenes ON ALLTRIM(planilla.codalmacen)==ALLTRIM(almacenes.codalmacen) ;
WHERE propina<>0 AND codrol<>8 ;
GROUP BY 1,2,4,5 ORDER BY 2,1,4,5 ;
INTO CURSOR datos

BROWSE NORMAL noedit NODELETE noapp

m.ano=YEAR(m.hasta)
m.mes=Month(m.hasta)

m.mes = m.mes+1
IF m.mes>12
	m.mes=1
	m.ano=m.ano+1
ENDIF

 
SELECT grupos

SCAN
	m.co=co
	
	



	 archivosalida = ALLTRIM(m.destino)+"NMBATCHNMBATCH"+transform(int(val(m.co)))+".DAT"
	 punteroarchivo = FCREATE(archivosalida, 0)
	 
	SELECT datos
	 
	SCAN FOR co=m.co

	       FWRITE(punteroarchivo, completarespacios(ALLTRIM(cedula), 13, .F.))
	       FWRITE(punteroarchivo, "00076")
	       FWRITE(punteroarchivo, co) 	&& completarCeros(idfront,3,.t.)	3
	       FWRITE(punteroarchivo, cc) 	&& Centro de costo					5
	       FWRITE(punteroarchivo, SPACE(3))  
	       FWRITE(punteroarchivo, completarCeros(m.ano,4,.t.))
	       FWRITE(punteroarchivo, completarCeros(m.mes,2,.t.))
	       FWRITE(punteroarchivo, "15")
	       FWRITE(punteroarchivo, SPACE(8))  && fecha inicio
	       FWRITE(punteroarchivo, SPACE(8))  && fecha fin
	       FWRITE(punteroarchivo, "000")
	       FWRITE(punteroarchivo, SPACE(8))  && cantidad
	       FWRITE(punteroarchivo, SPACE(8))  && ubicacion
	       FWRITE(punteroarchivo, "000000+")  && horas
	       FWRITE(punteroarchivo, completarCeros(ABS(INT(IIF(ISNULL(propina),0,propina)*100)), 13, .t.))  && propina
	       FWRITE(punteroarchivo, IIF(propina>0,"+","-"))  && 
	       FWRITE(punteroarchivo, "        000        ")
	       FWRITE(punteroarchivo, completarCeros(INT(VAL(cedula)), 13, .t.))
	       FWRITE(punteroarchivo, SPACE(10))  && proyecto
	       FWRITE(punteroarchivo, "00000000")  && ubicacion
	       
	       
		   FWRITE(punteroarchivo, "+000")
	       FWRITE(punteroarchivo, cc) 	&& Centro de costo					5
	       FWRITE(punteroarchivo, "00000")  && 
	       
	       FPUTS(punteroarchivo, "")       
	ENDSCAN
	 FCLOSE(punteroarchivo)
	 
	 WAIT WINDOW NOWAIT "Archivo generado "+archivosalida
	 
	 
	SELECT grupos
ENDSCAN


 CLOSE TABLE ALL
 RETURN

RETURN

FUNCTION completarceros
 PARAMETER numero, tamano, izquierda
 m.numero = ALLTRIM(STR(numero))
 DO WHILE LEN(numero)<tamano
    IF izquierda
       m.numero = "0"+m.numero
    ELSE
       m.numero = m.numero+"0"
    ENDIF
 ENDDO
 RETURN m.numero
ENDFUNC
**
FUNCTION completarespacios
 PARAMETER texto, tamano, izquierda
 DO WHILE LEN(texto)<tamano
    IF izquierda
       m.texto = " "+m.texto
    ELSE
       m.texto = m.texto+" "
    ENDIF
 ENDDO
 RETURN m.texto
ENDFUNC
