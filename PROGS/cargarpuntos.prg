CLOSE TABLES all

USE puntos EXCLUSIVE
ZAP

SELECT 0
USE puntosAplicados EXCLUSIVE
zap

SELECT 0
USE vistaPuntosPromociones
GO bottom

SCAN FOR puntos>0
	SCATTER MEMVAR memo
	INSERT INTO puntos FROM memvar
	
	WAIT WINDOW "Procesando..." nowait	

ENDSCAN

SCAN FOR puntos<0
	WAIT WINDOW "Procesando..." nowait	
	SCATTER MEMVAR memo
	m.idlinea1=idlinea
	m.puntos=-m.puntos
	SELECT puntos
	
	SCAN FOR idtarjeta=m.idtarjeta AND puntos-gastados>0
		m.idlinea2=idlinea
		m.caja=caja
		m.aplicables = MIN(m.puntos, puntos-gastados)
		replace gastados with gastados + m.aplicables
		m.puntos=m.puntos-m.aplicables
		m.puntosAplicados=m.aplicables
		INSERT INTO puntosAplicados FROM memvar
		IF m.puntos=0
			exit
		endif
	ENDSCAN
	IF m.puntos>0
		? m.idtarjeta
		? m.puntos
	ENDIF
	
	
	
	

ENDSCAN

SELECT puntos 
BROWSE
COPY TO puntos.xls TYPE xls


SELECT puntosAplicados
BROWSE
COPY TO puntosAplicados.xls TYPE xls

CLOSE TABLES all

	WAIT WINDOW "Archivos generados: puntos.xls y puntosAplicados.xls ..." nowait	