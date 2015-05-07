 SELECT fecha, 029 AS sucursale, almacenes.idfront AS sucursal, unidadestotal*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza, vv.codalmacen AS codalmacenorigen, almacenes.codalmacen AS codalmacendestino, marca AS codmarca, almacenes.nombrealmacen FROM VistaVentas AS vv LEFT JOIN almacenes ON vv.codcliente=almacenes.codcliente LEFT JOIN vistaArticulos ON vv.codarticulo=vistaarticulos.codarticulo WHERE unidadestotal*precio<>0 AND unidadespagadas=0 UNION ALL SELECT fecha, 029 AS sucursale, 029 AS sucursal, 000000000000000.00  AS debito, unidadestotal*precio AS credito, m.nit AS tercero, 2 AS naturaleza, vv.codalmacen AS codalmacenorigen, almacenes.codalmacen AS codalmacendestino, marca AS codmarca, almacenes.nombrealmacen FROM VistaVentas AS vv LEFT JOIN almacenes ON vv.codcliente=almacenes.codcliente LEFT JOIN vistaArticulos ON vv.codarticulo=vistaarticulos.codarticulo WHERE unidadestotal*precio<>0 AND unidadespagadas=0 INTO CURSOR trasladosA
 SELECT DISTINCT fecha, sucursale, traslados.tipodocumento FROM traslados, trasladosA WHERE trasladosa.codalmacenorigen=traslados.almacenorigen AND trasladosa.codalmacendestino=traslados.almacendestino AND exportar INTO TABLE consecutivos
 ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
 SCAN
    IF tipodocume="TR"
       REPLACE consecutiv WITH getconsecutivo("consecutivo_traslados")
    ENDIF
    IF tipodocume="TM"
       REPLACE consecutiv WITH getconsecutivo("traslado_terminado")
    ENDIF
    IF tipodocume="SA"
       REPLACE consecutiv WITH getconsecutivo("traslado_gastos")
    ENDIF
 ENDSCAN
 SELECT traslados.tipodocumento, consecutiv AS numerodoc, trasladosa.fecha, IIF(naturaleza=1, traslados.debito, traslados.credito) AS cuenta, sucursal, trasladosa.sucursale, ROUND(SUM(trasladosa.debito), 0) AS debito, ROUND(SUM(trasladosa.credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, tercero, traslados.cc, traslados.descripcion AS descripcio FROM traslados, trasladosA, consecutivos WHERE trasladosa.codalmacenorigen=traslados.almacenorigen AND trasladosa.codalmacendestino=traslados.almacendestino AND exportar AND trasladosa.fecha=consecutivos.fecha AND trasladosa.sucursale=consecutivos.sucursale AND traslados.tipodocumento=consecutivos.tipodocume AND codmarca<>4 GROUP BY trasladosa.fecha, tipodocumento, cuenta, tercero, trasladosa.sucursale, sucursal, naturaleza, descripcio, cc INTO CURSOR c5
 SELECT DISTINCT fecha, sucursale, traslados.tipodocumento2 AS tipodocum FROM traslados, trasladosA WHERE trasladosa.codalmacenorigen=traslados.almacenorigen AND trasladosa.codalmacendestino=traslados.almacendestino AND exportar2 INTO TABLE consecutivos
 ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
 SCAN
    IF tipodocum="TR"
       REPLACE consecutiv WITH getconsecutivo("consecutivo_traslados")
    ENDIF
    IF tipodocum="TM"
       REPLACE consecutiv WITH getconsecutivo("traslado_terminado")
    ENDIF
    IF tipodocum="SA"
       REPLACE consecutiv WITH getconsecutivo("traslado_gastos")
    ENDIF
 ENDSCAN
 SELECT traslados.tipodocumento2 AS tipodocumento, consecutiv AS numerodoc, trasladosa.fecha, IIF(naturaleza=1, traslados.debito2, traslados.credito2) AS cuenta, sucursal, trasladosa.sucursale, ROUND(SUM(trasladosa.debito), 0) AS debito, ROUND(SUM(trasladosa.credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, tercero, traslados.cc2 AS cc, traslados.descripcion2 AS descripcio FROM traslados, trasladosA, consecutivos WHERE trasladosa.codalmacenorigen=traslados.almacenorigen AND trasladosa.codalmacendestino=traslados.almacendestino AND exportar2 AND trasladosa.fecha=consecutivos.fecha AND trasladosa.sucursale=consecutivos.sucursale AND traslados.tipodocumento2=consecutivos.tipodocum AND codmarca=4 GROUP BY trasladosa.fecha, tipodocumento, cuenta, tercero, trasladosa.sucursale, sucursal, naturaleza, descripcio, cc INTO CURSOR c6
 
**
FUNCTION getconsecutivo
 PARAMETER campo
 zona = SELECT()
 usado = .F.
 IF USED("config")
    usado = .T.
    SELECT config
 ELSE
    SELECT 0
    USE config
 ENDIF
 m.consecutivo=&campo
 m.consecutivo = m.consecutivo+1
 REPLACE &campo WITH m.consecutivo
 IF  .NOT. usado
    USE
 ENDIF
 SELECT (zona)
 RETURN m.consecutivo
ENDFUNC
**
