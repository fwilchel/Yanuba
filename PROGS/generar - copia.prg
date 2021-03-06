 SET TALK OFF
 SET SAFETY OFF
*!*	 IF m.desde>{^2015-03-10} .OR. m.hasta>{^2015-03-10}
*!*	    WAIT WINDOW "Software sin licencia..."
*!*	    RETURN
*!*	 ENDIF
 IF USED("config")
    SELECT config
 ELSE
    SELECT 0
    USE config
 ENDIF
 SCATTER MEMO MEMVAR
 USE
 IF USED("consecutivo")
    SELECT consecutivo
 ELSE
    SELECT 0
    USE consecutivo
 ENDIF
 m.cc = ""
 IF USED("salida")
    SELECT salida
    USE
 ENDIF
 IF USED("temporal")
    SELECT temporal
    USE
 ENDIF
 USE salida EXCLUSIVE
 ZAP
 USE
 USE temporal EXCLUSIVE
 ZAP
 IF m.ventas
    SELECT DISTINCT fecha, numserie, numalbaran, caja, SUM(precio*unidadespagadas-(precio*unidadespagadas*(1-dto/100)*(1-dtocomercial/100))) AS totdtocomercial FROM vistaVentas GROUP BY 1, 2, 3, 4 INTO CURSOR descuentosComerciales
    
    SELECT fecha, serie, numero, LTRIM(STR(MAX(INT(VAL(codformapago))))) AS codformapago, COUNT(1) AS cuantos FROM vistapagos GROUP BY 1, 2, 3 INTO CURSOR pagoUnico
    
    SELECT DISTINCT numserie, numalbaran, n, fecha, caja, totalbruto FROM vistaventas INTO CURSOR vencabezado
    
    SELECT vistaventas.fecha, marcas.cuenta, almacenes.idfront AS sucursal, 000000000000000.00 AS debito, precio*unidadespagadas+dto*precio*unidadespagadas/100 AS credito, nit_varios AS tercero, 01, 2 AS naturaleza, 000000000000000.00  AS base, marcas.cc, "INTERFAZ ICG - VALOR ANTES DE IMPUESTOS" AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE tipoimpuesto<>3 AND SUBSTR(vistaventas.numserie, 4, 1)<>'I' AND precio*unidadespagadas<>0 AND vistaventas.codarticulo>0 AND vistaventas.codarticulo<>3240;
	UNION ALL SELECT vistaventas.fecha, m.cta_puntos_dto, almacenes.idfront AS sucursal, -precio*unidadespagadas+dto*precio*unidadespagadas/100 AS debito, 000000000000000.00 AS credito, nit_varios AS tercero, 12, 1 AS naturaleza, 000000000000000.00  AS base, '30080   ' as cc, "INTERFAZ ICG - DESCUENTO PUNTOS        " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE vistaventas.codarticulo=3240 ;
    UNION ALL SELECT vistaventas.fecha, impuestos.cuenta_ventas AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS debito, (total-total*dtocomercial/100)*vistaventas.iva/100 AS credito, nit_varios AS tercero, 2, 2 AS naturaleza, total-total*dtocomercial/100 AS base, "        " AS cc, "INTERFAZ ICG - IMPUESTOS               " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 02 as orden, "" as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN impuestos ON vistaventas.tipoimpuesto=impuestos.tipoiva ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero ;
    	WHERE tipoimpuesto<>3 AND SUBSTR(vistaventas.numserie, 4, 1)<>'I' AND LEN(ALLTRIM(caja))>0 ;
    UNION ALL SELECT vistapagos.fecha, formaspago.cuenta, almacenes.idfront AS sucursal, importe AS debito, 000000000000000.00  AS credito, IIF(LEN(ALLTRIM(formaspago.nit))>0, formaspago.nit, IIF(formaspago.credito, ALLTRIM(IIF(ISNULL(cif), "", cif)), nit_varios)) AS tercero, 3, 1 AS naturaleza, 000000000000000.00  AS base, formaspago.cc AS cc, "INTERFAZ ICG - PAGOS                   " AS descripcio, formaspago.credito AS vtacredito, IIF(formaspago.credito, IIF(formaspago.numerofiscal, vistapagos.numerofiscal, getconsecutivo2(vistapagos.fecha)), 000000) AS numfac, IIF((pu.codformapago='19' AND cuantos=1) OR (pu.codformapago='19' AND cuantos>1 AND importe>0), 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 03 as orden, formasPago.descripcion as descripci2, vistaPagos.serie, vistaPagos.numero ;
    	FROM vistaPagos LEFT JOIN formasPago ON vistapagos.codformapago=formaspago.codformapago ;
    	LEFT JOIN vistaSucursales ON vistapagos.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistapagos.fecha=pu.fecha AND vistapagos.serie=pu.serie AND vistapagos.numero=pu.numero ;
    	WHERE SUBSTR(vistapagos.serie, 4, 1)<>'I' AND LEN(ALLTRIM(caja))>0 AND vistapagos.codtipopago IS NOT NULL  ;
    UNION ALL SELECT vistaventas.fecha, m.cuenta_exentas AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS debito, precio*unidadespagadas AS credito, nit_varios AS tercero, 4, 2 AS naturaleza, 000000000000000.00  AS base, marcas.cc, "INTERFAZ ICG - EXENTOS                 " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 04 as orden, "" as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero ;
    	WHERE tipoimpuesto=3 AND SUBSTR(vistaventas.numserie, 4, 1)<>'I' AND precio*unidadespagadas<>0 AND vistaventas.codarticulo<>3240 ;
    UNION ALL SELECT vistaventas.fecha, m.cuenta_descuentos AS cuenta, almacenes.idfront AS sucursal, dto*precio*unidadespagadas/100 AS debito, 000000000000000.00  AS credito, nit_varios AS tercero, 5, 1 AS naturaleza, 000000000000000.00  AS base, marcas.cc, "INTERFAZ ICG - DESCUENTOS              " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 05 as orden, "" as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero ;
    	WHERE dto<>0 AND SUBSTR(vistaventas.numserie, 4, 1)<>'I' ;
    UNION ALL SELECT descuentoscomerciales.fecha, m.cuenta_descuentos AS cuenta, almacenes.idfront AS sucursal, SUM(totdtocomercial) AS debito, 000000000000000.00  AS credito, nit_varios AS tercero, 6, 1 AS naturaleza, 000000000000000.00  AS base, "30080   " AS cc, "INTERFAZ ICG - DESCUENTOS              " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 06 as orden, "" as descripci2, descuentosComerciales.numserie, descuentosComerciales.numalbaran ;
    	FROM descuentosComerciales LEFT JOIN vistaSucursales ON descuentoscomerciales.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON descuentoscomerciales.fecha=pu.fecha AND descuentoscomerciales.numserie=pu.serie AND descuentoscomerciales.numalbaran=pu.numero ;
    	WHERE SUBSTR(descuentoscomerciales.numserie, 4, 1)<>'I' AND totdtocomercial<>0 GROUP BY descuentoscomerciales.fecha, almacenes.idfront, sucursale, pu.codformapago ;
   	INTO CURSOR ventas1

	SELECT vistaventas.fecha, m.cta_puntos_cr, almacenes.idfront AS sucursal, -precio*unidadespagadas+dto*precio*unidadespagadas/100 AS debito, 000000000000000.00 AS credito, nit_varios AS tercero, 13, 1 AS naturaleza, 000000000000000.00  AS base, SPACE(8) as cc, "INTERFAZ ICG - REDENCION PUNTOS        " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE vistaventas.codarticulo=3240 ;
    UNION ALL SELECT vistaventas.fecha, m.cta_puntos_db, almacenes.idfront AS sucursal, 000000000000000.00 AS debito, -precio*unidadespagadas+dto*precio*unidadespagadas/100 AS credito, nit_varios AS tercero, 14, 2 AS naturaleza, 000000000000000.00  AS base, SPACE(8) as cc, "INTERFAZ ICG - REDENCION PUNTOS        " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE vistaventas.codarticulo=3240 ;
    UNION ALL SELECT vistapropinas.fecha, m.cuenta_credito_propinas AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS debito, propina AS credito, nit_varios AS tercero, 7, 2 AS naturaleza, 000000000000000.00  AS base, "        " AS cc, "INTERFAZ ICG - PROPINAS                " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 07 as orden, "" as descripci2, vistaPropinas.numserie, vistaPropinas.numfactura ;
    	FROM vistaPropinas LEFT JOIN almacenes ON SUBSTR(vistapropinas.caja, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistapropinas.fecha=pu.fecha AND vistapropinas.numserie=pu.serie AND vistapropinas.numfactura=pu.numero ;
    	WHERE propina<>0 ;
    UNION ALL SELECT vistapropinas.fecha, m.cuenta_debito_propinas AS cuenta, almacenes.idfront AS sucursal, propina AS debito, 000000000000000.00  AS credito, nit_varios AS tercero, 7, 1 AS naturaleza, 000000000000000.00  AS base, "        " AS cc, "INTERFAZ ICG - PROPINAS                " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19' AND cuantos=1, 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 08 as orden, "" as descripci2, vistaPropinas.numserie, vistaPropinas.numfactura ;
    	FROM vistaPropinas LEFT JOIN almacenes ON SUBSTR(vistapropinas.caja, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistapropinas.fecha=pu.fecha AND vistapropinas.numserie=pu.serie AND vistapropinas.numfactura=pu.numero ;
    	WHERE propina<>0 ;
    UNION ALL SELECT vistaventas.fecha, m.cuenta_costos_debito AS cuenta, almacenes.idfront AS sucursal, SUM(unidadespagadas*ROUND(coste, 0)) AS debito, 000000000000000.00  AS credito, nit_varios AS tercero, 8, 1 AS naturaleza, 000000000000000.00  AS base, marcas.cc, "INTERFAZ ICG - COSTOS                  " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 09 as orden, "" as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero ;
    	WHERE vistaventas.codarticulo<>3240 AND unidadespagadas*coste<>0;
    	GROUP BY vistaventas.fecha, almacenes.idfront, sucursale, pu.codformapago ;
    UNION ALL SELECT vistaventas.fecha, m.cuenta_costos_credito AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS dedito, SUM(unidadespagadas*ROUND(coste, 0)) AS crebito, nit_varios AS tercero, 9, 2 AS naturaleza, 000000000000000.00  AS base, marcas.cc, "INTERFAZ ICG - COSTOS                  " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 10 as orden, "" as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero ;
    	WHERE vistaventas.codarticulo<>3240 AND unidadespagadas*coste<>0 ;
    	GROUP BY vistaventas.fecha, almacenes.idfront, sucursale, pu.codformapago ;
    UNION ALL SELECT vencabezado.fecha, m.cuenta_db_cree AS cuenta, almacenes.idfront AS sucursal, m.tasa_cree*totalbruto/100 AS debito, 000000000000000.00  AS credito, nit_varios AS tercero, 10, 1 AS naturaleza, 000000000000000.00  AS base, "        " AS cc, "INTERFAZ ICG - AUTORETENCION CREE" AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 11 as orden, "" as descripci2, vencabezado.numserie, vencabezado.numalbaran ;
    	FROM vencabezado LEFT JOIN vistaSucursales ON vencabezado.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vencabezado.fecha=pu.fecha AND vencabezado.numserie=pu.serie AND vencabezado.numalbaran=pu.numero ;
    UNION ALL SELECT vencabezado.fecha, m.cuenta_cr_cree AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS debito, m.tasa_cree*totalbruto/100 AS credito, nit_varios AS tercero, 11, 2 AS naturaleza, 000000000000000.00  AS base, "        " AS cc, "INTERFAZ ICG - AUTORETENCION CREE" AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 12 as orden, "" as descripci2, vencabezado.numserie, vencabezado.numalbaran ;
    	FROM vencabezado LEFT JOIN vistaSucursales ON vencabezado.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vencabezado.fecha=pu.fecha AND vencabezado.numserie=pu.serie AND vencabezado.numalbaran=pu.numero INTO CURSOR ventas2
    	
    SELECT * from ventas1 UNION ALL select* from ventas2 ;
    UNION ALL SELECT vistaventas.fecha, m.cta_puntos_db, almacenes.idfront AS sucursal, puntosacum AS debito, 000000000000000.00 AS credito, nit_varios AS tercero, 13, 1 AS naturaleza, 000000000000000.00  AS base, SPACE(8) as cc, "INTERFAZ ICG - PUNTOS ACUMULADOS       " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE SUBSTR(vistaventas.numserie, 4, 1)<>'I' AND puntosacum<>0 AND numlin=1 ;
    UNION ALL SELECT vistaventas.fecha, m.cta_puntos_cr, almacenes.idfront AS sucursal, 000000000000000.00 AS debito, puntosacum AS credito, nit_varios AS tercero, 14, 2 AS naturaleza, 000000000000000.00  AS base, SPACE(8) as cc, "INTERFAZ ICG - PUNTOS ACUMULADOS       " AS descripcio, .F. AS vtacredito, 000000 AS numfac, IIF(pu.codformapago='19', 010, almacenes.idfront) AS sucursale, pu.codformapago, cuantos, 01 as orden, SPACE(30) as descripci2, vistaVentas.numserie, vistaventas.numalbaran ;
    	FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo ;
    	LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    	LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager ;
    	LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen ;
    	LEFT JOIN pagoUnico AS pu ON vistaventas.fecha=pu.fecha AND vistaventas.numserie=pu.serie AND vistaventas.numalbaran=pu.numero;
    	WHERE SUBSTR(vistaventas.numserie, 4, 1)<>'I' AND puntosacum<>0 AND numlin=1 ;
    INTO CURSOR ventas

    COPY TO ventas.xls TYPE XLS
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 SET DECIMALS TO 3
 IF m.compras
    SELECT DISTINCT seriefact, numfact, nfact FROM vistacompras INNER JOIN almacenes ON vistacompras.codalmacen=almacenes.codalmacen WHERE destino=1 INTO CURSOR filtro
    SELECT fecha AS fecha, marcas.cuenta_compras, almacenes.idfront AS sucursal, 000000000000000.00  AS base, total AS debito, 000000000000000.00  AS credito, proveedores.nit AS tercero, 1 AS naturaleza, esdevolucion, sufactura, 01, "INTERFAZ ICG - COMPRAS                 " AS descripcio, marcas.cc, vpc.codtipopago, 00.0000  AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursale FROM vistaCompras LEFT JOIN vistaArticulos ON vistacompras.codarticulo=vistaarticulos.codarticulo LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca INNER JOIN almacenes ON ALLTRIM(vistacompras.codalmacen)==ALLTRIM(almacenes.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE destino=1 UNION ALL SELECT fecha, m.cuenta_impuestos_compras AS cuenta, almacenes.idfront AS sucursal, total*(100-dtocomercial)/100 AS base, (total*(100-dtocomercial)/100)*iva/100 AS debito, 000000000000000.00  AS credito, proveedores.nit AS tercero, 1 AS naturaleza, esdevolucion, sufactura, 2, "INTERFAZ ICG - IVA                     " AS descripcio, "        " AS cc, vpc.codtipopago, iva AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursale FROM vistaCompras INNER JOIN almacenes ON vistacompras.codalmacen=almacenes.codalmacen LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE destino=1 AND iva>0 UNION ALL SELECT DISTINCT fecha, IIF(vpc.codtipopago="1", m.cuenta_debito_propinas, proveedores.cuenta) AS cuenta, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursal, 000000000000000.00  AS base, 000000000000000.00  AS debito, totalneto AS credito, proveedores.nit AS tercero, 2 AS naturaleza, esdevolucion, sufactura, 3, "INTERFAZ ICG - NETOS                   " AS descripcio, "        " AS cc, vpc.codtipopago, 00.0000  AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursale FROM vistaCompras LEFT JOIN vistaArticulos ON vistacompras.codarticulo=vistaarticulos.codarticulo INNER JOIN almacenes ON vistacompras.codalmacen=almacenes.codalmacen LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE destino=1 UNION ALL SELECT vistadescuentoscompras.fecha, conceptosdtos.cuenta_compras AS cuenta, IIF(vpc.codtipopago="1", buscar(filtro.seriefact, filtro.numfact, filtro.nfact), 010) AS sucursal, ABS(vistadescuentoscompras.importe)*100/VAL(SUBSTR(ALLTRIM(conceptosdtos.nombre), AT(" ", ALLTRIM(conceptosdtos.nombre))+1)) AS base, IIF(conceptosdtos.naturaleza="D", ABS(vistadescuentoscompras.importe), 000000000000000.00 ) AS debito, IIF(conceptosdtos.naturaleza="C", ABS(vistadescuentoscompras.importe), 000000000000000.00 ) AS credito, proveedores.nit AS tercero, IIF(conceptosdtos.naturaleza="D", 1, 2) AS naturaleza, esdevolucion, sufactura, conceptosdtos.codigo+3, "INTERFAZ ICG - "+UPPER(conceptosdtos.nombre) AS descripcio, "        " AS cc, vpc.codtipopago, VAL(SUBSTR(ALLTRIM(conceptosdtos.nombre), AT(" ", ALLTRIM(conceptosdtos.nombre))+1)) AS tasa, conceptosdtos.factortasa, IIF(vpc.codtipopago="1", buscar(filtro.seriefact, filtro.numfact, filtro.nfact), 010) AS sucursale FROM filtro INNER JOIN VistaDescuentosCompras ON filtro.seriefact=vistadescuentoscompras.numserie AND filtro.numfact=vistadescuentoscompras.numfactura LEFT JOIN vistaPagosCompras AS vpc ON vistadescuentoscompras.numserie=vpc.serie AND vistadescuentoscompras.numfactura=vpc.numero LEFT JOIN proveedores ON vpc.codproveedor=proveedores.codproveedor LEFT JOIN conceptosDtos ON vistadescuentoscompras.coddto=conceptosdtos.codigo WHERE vistadescuentoscompras.importe<>0 UNION ALL SELECT fecha AS fecha, m.cuenta_compras_dtos, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursal, 000000000000000.00  AS base, 000000000000000.00  AS debito, totdtocomercial AS credito, proveedores.nit AS tercero, 2 AS naturaleza, esdevolucion, sufactura, 20, "INTERFAZ ICG - DESCUENTO               " AS descripcio, "        " AS cc, vpc.codtipopago, dtocomercial AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", almacenes.idfront, 010) AS sucursale FROM vistaCompras INNER JOIN almacenes ON vistacompras.codalmacen=almacenes.codalmacen LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE destino=1 AND totdtocomercial<>0 INTO CURSOR compras
    COPY TO compras.xls TYPE XLS
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.gastos
    SELECT DISTINCT seriefact, numfact, nfact FROM vistacompras INNER JOIN almacenes ON vistacompras.codalmacen=almacenes.codalmacen WHERE destino<>1 INTO CURSOR filtro
    SELECT fecha AS fecha, IIF(almacenes.destino=2, cuenta_ventas, cuenta_produccion) AS cuenta, alm2.idfront AS sucursal, 000000000000000.00  AS base, total AS debito, 000000000000000.00  AS credito, proveedores.nit AS tercero, 1 AS naturaleza, esdevolucion, sufactura, 01, "INTERFAZ ICG - GASTOS                  " AS descripcio, IIF(almacenes.destino=2, articulos.cc, articulos.cc2) AS cc, vpc.codtipopago, 00.0000  AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", alm2.idfront, 010) AS sucursale FROM vistaCompras LEFT JOIN vistaArticulos ON vistacompras.codarticulo=vistaarticulos.codarticulo LEFT JOIN Articulos ON vistacompras.codarticulo=articulos.codarticulo LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca INNER JOIN almacenes ON ALLTRIM(vistacompras.codalmacen)==ALLTRIM(almacenes.codalmacen) LEFT JOIN almacenes AS alm2 ON SUBSTR(vistacompras.numserie, 1, 2)==ALLTRIM(alm2.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE (almacenes.destino=2 OR almacenes.destino=3) UNION ALL SELECT fecha, m.cuenta_compras_gastos AS cuenta, alm2.idfront AS sucursal, total*(100-dtocomercial)/100 AS base, (total*(100-dtocomercial)/100)*iva/100 AS debito, 000000000000000.00  AS credito, proveedores.nit AS tercero, 1 AS naturaleza, esdevolucion, sufactura, 02, "INTERFAZ ICG - IVA                     " AS descripcio, "        " AS cc, vpc.codtipopago, iva AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", alm2.idfront, 010) AS sucursale FROM vistaCompras INNER JOIN almacenes ON ALLTRIM(vistacompras.codalmacen)==ALLTRIM(almacenes.codalmacen) LEFT JOIN almacenes AS alm2 ON SUBSTR(vistacompras.numserie, 1, 2)==ALLTRIM(alm2.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE (almacenes.destino=2 OR almacenes.destino=3) AND iva>0 UNION ALL SELECT DISTINCT fecha, IIF(vpc.codtipopago="1", m.cuenta_debito_propinas, proveedores.cuenta) AS cuenta, alm2.idfront AS sucursal, 000000000000000.00  AS base, 000000000000000.00  AS debito, totalneto AS credito, proveedores.nit AS tercero, 2 AS naturaleza, esdevolucion, sufactura, 03, "INTERFAZ ICG - NETOS                   " AS descripcio, "        " AS cc, vpc.codtipopago, 00.0000  AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", alm2.idfront, 010) AS sucursale FROM vistaCompras LEFT JOIN vistaArticulos ON vistacompras.codarticulo=vistaarticulos.codarticulo INNER JOIN almacenes ON ALLTRIM(vistacompras.codalmacen)==ALLTRIM(almacenes.codalmacen) LEFT JOIN almacenes AS alm2 ON SUBSTR(vistacompras.numserie, 1, 2)==ALLTRIM(alm2.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE (almacenes.destino=2 OR almacenes.destino=3) UNION ALL SELECT vistadescuentoscompras.fecha, conceptosdtos.cuenta_gastos AS cuenta, alm2.idfront AS sucursal, ABS(vistadescuentoscompras.importe)*100/VAL(SUBSTR(ALLTRIM(conceptosdtos.nombre), AT(" ", ALLTRIM(conceptosdtos.nombre))+1)) AS base, IIF(conceptosdtos.naturaleza="D", ABS(vistadescuentoscompras.importe), 000000000000000.00 ) AS debito, IIF(conceptosdtos.naturaleza="C", ABS(vistadescuentoscompras.importe), 000000000000000.00 ) AS credito, proveedores.nit AS tercero, IIF(conceptosdtos.naturaleza="D", 1, 2) AS naturaleza, esdevolucion, sufactura, conceptosdtos.codigo+3, "INTERFAZ ICG - "+UPPER(conceptosdtos.nombre) AS descripcio, "        " AS cc, vpc.codtipopago, VAL(SUBSTR(ALLTRIM(conceptosdtos.nombre), AT(" ", ALLTRIM(conceptosdtos.nombre))+1)) AS tasa, conceptosdtos.factortasa, IIF(vpc.codtipopago="1", buscar2(filtro.seriefact, filtro.numfact, filtro.nfact), 010) AS sucursale FROM filtro INNER JOIN VistaDescuentosCompras ON filtro.seriefact=vistadescuentoscompras.numserie AND filtro.numfact=vistadescuentoscompras.numfactura AND filtro.nfact=vistadescuentoscompras.n LEFT JOIN almacenes AS alm2 ON SUBSTR(vistacompras.numserie, 1, 2)==ALLTRIM(alm2.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistadescuentoscompras.numserie=vpc.serie AND vistadescuentoscompras.numfactura=vpc.numero AND vistadescuentoscompras.n=vpc.n LEFT JOIN proveedores ON vpc.codproveedor=proveedores.codproveedor LEFT JOIN conceptosDtos ON vistadescuentoscompras.coddto=conceptosdtos.codigo UNION ALL SELECT fecha AS fecha, m.cuenta_compras_dtos, alm2.idfront AS sucursal, 000000000000000.00  AS base, 000000000000000.00  AS debito, totdtocomercial AS credito, proveedores.nit AS tercero, 2 AS naturaleza, esdevolucion, sufactura, 20, "INTERFAZ ICG - DESCUENTO               " AS descripcio, "        " AS cc, vpc.codtipopago, dtocomercial AS tasa, 00 AS factortasa, IIF(vpc.codtipopago="1", alm2.idfront, 010) AS sucursale FROM vistaCompras INNER JOIN almacenes ON ALLTRIM(vistacompras.codalmacen)==ALLTRIM(almacenes.codalmacen) LEFT JOIN almacenes AS alm2 ON SUBSTR(vistacompras.numserie, 1, 2)==ALLTRIM(alm2.codalmacen) LEFT JOIN vistaPagosCompras AS vpc ON vistacompras.seriefact=vpc.serie AND vistacompras.numfact=vpc.numero AND vistacompras.nfact=vpc.n LEFT JOIN proveedores ON vistacompras.codproveedor=proveedores.codproveedor WHERE (almacenes.destino=2 OR almacenes.destino=3) AND totdtocomercial<>0 INTO CURSOR gastos
    COPY TO gastos.xls TYPE XLS
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 SET DECIMALS TO 2
 IF m.cortesias
    SELECT fecha, m.cuenta_cortesias AS cuenta, almacenes.idfront AS sucursal, preciodefecto AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza FROM vistaVentas LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen WHERE SUBSTR(vistaventas.numserie, 4, 1)=='I' UNION ALL SELECT fecha, marcas.cuenta AS cuenta, almacenes.idfront AS sucursal, 000000000000000.00  AS debito, preciodefecto AS credito, m.nit AS tercero, 2 AS naturaleza FROM vistaVentas LEFT JOIN vistaArticulos ON vistaventas.codarticulo=vistaarticulos.codarticulo LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca LEFT JOIN vistaSucursales ON vistaventas.caja=vistasucursales.cajamanager LEFT JOIN almacenes ON SUBSTR(vistasucursales.cajamanager, 1, 2)==almacenes.codalmacen WHERE SUBSTR(vistaventas.numserie, 4, 1)=='I' INTO CURSOR cortesias
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.traslados
    SELECT fecha, IIF(a2.idfront=0, a1.idfront, a2.idfront) AS sucursale, IIF(a1.idfront=0, a2.idfront, a1.idfront) AS sucursal, unidades*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza, codalmacenorigen, codalmacendestino, codmarca, a1.nombrealmacen ;
    FROM vistaTraslados LEFT JOIN vistaArticulos ON vistatraslados.codarticulo=vistaarticulos.codarticulo ;
    LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca ;
    LEFT JOIN almacenes AS a1 ON vistatraslados.codalmacendestino=a1.codalmacen ;
    LEFT JOIN almacenes AS a2 ON vistatraslados.codalmacenorigen=a2.codalmacen ;
    UNION ALL SELECT fecha, IIF(a1.idfront=0, a2.idfront, a1.idfront) AS sucursale, IIF(a1.idfront=0, a2.idfront, a1.idfront) AS sucursal, 000000000000000.00  AS debito, unidades*precio AS credito, m.nit AS tercero, 2 AS naturaleza, codalmacenorigen, codalmacendestino, codmarca, a2.nombrealmacen ;
    FROM vistaTraslados LEFT JOIN vistaArticulos ON vistatraslados.codarticulo=vistaarticulos.codarticulo ;
    LEFT JOIN marcas ON vistaarticulos.marca=marcas.codmarca LEFT JOIN almacenes AS a1 ON vistatraslados.codalmacenorigen=a1.codalmacen ;
    LEFT JOIN almacenes AS a2 ON vistatraslados.codalmacendestino=a2.codalmacen ;
    UNION ALL SELECT fecha, IIF(vv.codalmacen="A1", 029, 030) AS sucursale, almacenes.idfront AS sucursal, unidadestotal*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza, vv.codalmacen AS codalmacenorigen, almacenes.codalmacen AS codalmacendestino, marca AS codmarca, almacenes.nombrealmacen ;
    FROM VistaVentas AS vv LEFT JOIN almacenes ON vv.codcliente=almacenes.codcliente ;
    LEFT JOIN vistaArticulos ON vv.codarticulo=vistaarticulos.codarticulo ;
    WHERE unidadestotal*precio<>0 AND unidadespagadas=0 ;
    UNION ALL SELECT fecha, IIF(vv.codalmacen="A1", 029, 030) AS sucursale, IIF(vv.codalmacen="A1", 029, 030) AS sucursal, 000000000000000.00  AS debito, unidadestotal*precio AS credito, m.nit AS tercero, 2 AS naturaleza, vv.codalmacen AS codalmacenorigen, almacenes.codalmacen AS codalmacendestino, marca AS codmarca, almacenes.nombrealmacen ;
    FROM VistaVentas AS vv LEFT JOIN almacenes ON vv.codcliente=almacenes.codcliente ;
    LEFT JOIN vistaArticulos ON vv.codarticulo=vistaarticulos.codarticulo ;
    WHERE unidadestotal*precio<>0 AND unidadespagadas=0 INTO CURSOR trasladosA
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.inventarios
    SELECT fecha, almacenes.idfront AS sucursal, almacenes.idfront AS sucursale, m.cuenta_inventarios AS cuenta, 000000000000000.00  AS debito, (stock-unidades)*precio AS credito, m.nit AS tercero, 2 AS naturaleza, marcas.cc AS cc ;
    FROM vistaInventarios AS inven LEFT JOIN almacenes ON inven.codalmacenorigen=almacenes.codalmacen ;
    LEFT JOIN marcas ON inven.marca=marcas.codmarca ;
    WHERE unidades<stock AND ((codalmacenorigen='A1' AND codmarca=4) OR codmarca<>4) ;
    UNION ALL ;
    SELECT fecha, almacenes.idfront AS sucursal, almacenes.idfront AS sucursale, m.cuenta_costo_ventas AS cuenta, (stock-unidades)*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza, marcas.cc AS cc ;
    FROM vistaInventarios AS inven LEFT JOIN almacenes ON inven.codalmacenorigen=almacenes.codalmacen ;
    LEFT JOIN marcas ON inven.marca=marcas.codmarca WHERE unidades<stock AND ((codalmacenorigen='A1' AND codmarca=4) OR codmarca<>4) ;
    UNION ALL ;
    SELECT fecha, almacenes.idfront AS sucursal, almacenes.idfront AS sucursale, m.cuenta_inventarios AS cuenta, (unidades-IIF(stock>=0, stock, 0))*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza, marcas.cc AS cc ;
    FROM vistaInventarios AS inven LEFT JOIN almacenes ON inven.codalmacenorigen=almacenes.codalmacen ;
    LEFT JOIN marcas ON inven.marca=marcas.codmarca WHERE unidades>stock AND ((codalmacenorigen='A1' AND codmarca=4) OR codmarca<>4) ;
    UNION ALL SELECT fecha, almacenes.idfront AS sucursal, almacenes.idfront AS sucursale, m.cuenta_costo_ventas AS cuenta, 000000000000000.00  AS debito, (unidades-IIF(stock>=0, stock, 0))*precio AS credito, m.nit AS tercero, 2 AS naturaleza, marcas.cc AS cc ;
    FROM vistaInventarios AS inven LEFT JOIN almacenes ON inven.codalmacenorigen=almacenes.codalmacen ;
    LEFT JOIN marcas ON inven.marca=marcas.codmarca WHERE unidades>stock AND ((codalmacenorigen='A1' AND codmarca=4) OR codmarca<>4) INTO CURSOR inventarios
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.bajas
    SELECT m.cuenta_bajas AS cuenta, a1.idfront AS sucursal, unidades*precio AS debito, 000000000000000.00  AS credito, m.nit AS tercero, 1 AS naturaleza FROM vistaTraslados LEFT JOIN vistaArticulos ON vistatraslados.codarticulo=vistaarticulos.codarticulo LEFT JOIN secciones ON vistaarticulos.seccion=secciones.numseccion LEFT JOIN almacenes AS a1 ON vistatraslados.codalmacenorigen=a1.codalmacen LEFT JOIN almacenes AS a2 ON vistatraslados.codalmacendestino=a2.codalmacen WHERE a1.exportar AND a2.exportar AND vistatraslados.codalmacendestino=m.almacen_bajas UNION ALL SELECT secciones.cuenta AS cuenta, a1.idfront AS sucursal, 000000000000000.00  AS debito, unidades*precio AS credito, m.nit AS tercero, 2 AS naturaleza FROM vistaTraslados LEFT JOIN vistaArticulos ON vistatraslados.codarticulo=vistaarticulos.codarticulo LEFT JOIN secciones ON vistaarticulos.seccion=secciones.numseccion LEFT JOIN almacenes AS a1 ON vistatraslados.codalmacenorigen=a1.codalmacen LEFT JOIN almacenes AS a2 ON vistatraslados.codalmacendestino=a2.codalmacen WHERE a1.exportar AND a2.exportar AND vistatraslados.codalmacendestino=m.almacen_bajas INTO CURSOR bajas
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.movscaja
 
 
    SELECT vpc.fecha, cp.cuenta, a.idfront AS sucursal, IIF(vpc.tipomovcaja=2, importe, 000000000000000.00 ) AS debito, IIF(vpc.tipomovcaja=1, -importe, 000000000000000.00 ) AS credito, nit_varios AS tercero, 1, IIF(vpc.tipomovcaja=1, 2, 1) AS naturaleza, 000000000000000.00  AS base, "30080" AS cc, "INTERFAZ ICG - "+ALLTRIM(cp.descripcion)+" "+ALLTRIM(STR(vpc.z)) AS descripcio, .F. AS vtacredito, 000000 AS numfac ;
    FROM vistaPagosCaja AS vpc INNER JOIN ConceptosPago AS cp ON cp.id=vpc.codconceptopago ;
    LEFT JOIN vistaSucursales AS vs ON vpc.caja=vs.cajamanager ;
    LEFT JOIN almacenes AS a ON SUBSTR(vs.cajamanager, 1, 2)==a.codalmacen ;
    WHERE cp.importar ;
    UNION ALL ;
    SELECT vpc.fecha, m.cuenta_caja AS cuenta, a.idfront AS sucursal, IIF(vpc.tipomovcaja=1, -importe, 000000000000000.00 ) AS debito, IIF(vpc.tipomovcaja=2, importe, 000000000000000.00 ) AS credito, nit_varios AS tercero, 1, IIF(vpc.tipomovcaja=1, 1, 2) AS naturaleza, 000000000000000.00  AS base, "30080" AS cc, "INTERFAZ ICG - "+ALLTRIM(cp.descripcion)+" "+ALLTRIM(STR(vpc.z)) AS descripcio, .F. AS vtacredito, 000000 AS numfac ;
    FROM vistaPagosCaja AS vpc INNER JOIN ConceptosPago AS cp ON cp.id=vpc.codconceptopago ;
    LEFT JOIN vistaSucursales AS vs ON vpc.caja=vs.cajamanager ;
    LEFT JOIN almacenes AS a ON SUBSTR(vs.cajamanager, 1, 2)==a.codalmacen ;
    WHERE cp.importar INTO CURSOR MOVSCAJA
    COPY TO movscaja.xls TYPE XLS
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.anticipos
 
    SELECT vpc.fechadocumento AS fecha, m.cuenta_anticipos AS cuenta, a.idfront AS sucursal, IIF(importe<0,importe,000000000000000.00) AS debito, IIF(importe>=0,importe,000000000000000.00) AS credito, nit_varios AS tercero, 1, IIF(importe>0,2,1) AS naturaleza, 000000000000000.00  AS base, "30080" AS cc, "INTERFAZ ICG - ANTICIPOS "+ALLTRIM(STR(vpc.zsaldado)) AS descripcio, .F. AS vtacredito, 000000 AS numfac ;
    FROM vistaAnticiposReservadas AS vpc LEFT JOIN vistaSucursales AS vs ON vpc.cajasaldado=vs.cajamanager ;
    LEFT JOIN almacenes AS a ON SUBSTR(vs.cajamanager, 1, 2)==a.codalmacen ;
    UNION ALL ;
    SELECT vpc.fechadocumento AS fecha, m.cuenta_caja AS cuenta, a.idfront AS sucursal, IIF(importe>=0,importe,000000000000000.00) AS debito, IIF(importe<0,importe,000000000000000.00) AS credito, nit_varios AS tercero, 1, IIF(importe>0,1,2) AS naturaleza, 000000000000000.00  AS base, "30080" AS cc, "INTERFAZ ICG - ANTICIPOS "+ALLTRIM(STR(vpc.zsaldado)) AS descripcio, .F. AS vtacredito, 000000 AS numfac ;
    FROM vistaAnticiposReservadas AS vpc LEFT JOIN vistaSucursales AS vs ON vpc.cajasaldado=vs.cajamanager ;
    LEFT JOIN almacenes AS a ON SUBSTR(vs.cajamanager, 1, 2)==a.codalmacen INTO CURSOR ANTICIPOS
    COPY TO anticipos.xls TYPE XLS
    BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 ENDIF
 IF m.ventas
    SELECT ventas
    IF RECCOUNT()>0
       SELECT DISTINCT fecha, ventas.sucursal FROM ventas INTO TABLE consecutivos
       ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
       SCAN
          REPLACE consecutiv WITH getconsecutivo("consecutivo")
       ENDSCAN
       SELECT "RV" AS tipodocumento, consecutiv AS numerodoc, ventas.fecha, ventas.cuenta, ventas.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(SUM(base), 0) AS base, tercero, cc, descripcio, vtacredito, numfac, ventas.sucursale, orden ;
       	FROM ventas LEFT JOIN consecutivos ON ventas.fecha=consecutivos.fecha AND ventas.sucursal=consecutivos.sucursal ;
       	WHERE debito<>0 OR credito<>0 GROUP BY ventas.fecha, tipodocumento, cuenta, descripcio, tercero, ventas.sucursal, naturaleza, cc, numfac, ventas.sucursale, orden ;
       	ORDER BY ventas.fecha, tipodocumento, numerodoc INTO CURSOR c1
       copiar3("c1")
       SELECT consecutivos
       USE
       
       
       IF m.cuadreCaja
       
       SELECT * from almacenes WHERE LEN(ALLTRIM(codalmacen))=2 INTO CURSOR alma2
       
       SELECT ventas.fecha, ventas.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, IIF(orden=3,"INTERFAZ ICG - "+descripci2, descripcio) as descripcio, orden, Alma2.nombrealmacen, IIF(orden=5 OR orden=6,4,IIF(debito<>0,2,1)) AS natu ;
	       	FROM ventas inner join alma2 on ventas.sucursal = alma2.idfront;
	       	WHERE (debito<>0 OR credito<>0) AND orden NOT in (9,10, 11, 12) GROUP BY 1,2,5,6,7,8 ;
       UNION ALL ;
	    SELECT vpc.fecha, a.idfront AS sucursal, sum(IIF(vpc.tipomovcaja=2, importe, 000000000000000.00)) AS debito, sum(IIF(vpc.tipomovcaja=1, -importe, 000000000000000.00)) AS credito, "INTERFAZ ICG - "+ALLTRIM(cp.descripcion) AS descripcio, 15, a.nombrealmacen, 3 AS natu ;
		    FROM vistaPagosCaja AS vpc INNER JOIN ConceptosPago AS cp ON cp.id=vpc.codconceptopago ;
		    LEFT JOIN alma2 as a ON SUBSTR(vpc.caja, 1, 2)==a.codalmacen ;
		     GROUP BY 1,2,5,6,7,8 ;   &&&& WHERE cp.importar OR cp.id=5
		UNION ALL ;
			SELECT vpc.fechadocumento AS fecha, a.idfront AS sucursal, 000000000000000.00 AS debito, sum(importe) AS credito, "INTERFAZ ICG - ANTICIPOS " AS descripcio, 16, a.nombrealmacen, 3 AS natu ;
		    FROM vistaAnticiposReservadas AS vpc LEFT JOIN vistaSucursales AS vs ON vpc.cajasaldado=vs.cajamanager ;
		    LEFT JOIN alma2 AS a ON SUBSTR(vs.cajamanager, 1, 2)==a.codalmacen GROUP BY 1,2,5,6,7,8 ;
		UNION ALL ;
			select fecha, alma2.idfront as sucursal, sum(importe) as debito, 000000000000000.00 as credito, "INTERFAZ ICG - PLANILLA"+SPACE(16) as descripcio, 17 as orden, alma2.nombrealmacen, 3 as natu ;
				FROM vistaPlanilla LEFT JOIN alma2 ON SUBSTR(vistaPlanilla.caja,1,2)=alma2.codalmacen GROUP BY 1,2,5,6,7,8 ;
		UNION ALL ;
			select fechaSaldado as fecha, alma2.idfront as sucursal, 000000000000000.00 as debito, sum(importe) as credito, "INTERFAZ ICG - COBRO"+SPACE(19) as descripcio, 18 as orden, alma2.nombrealmacen, 4 as natu ;
				FROM vistaCobros LEFT JOIN alma2 ON SUBSTR(vistaCobros.serie,1,2)=alma2.codalmacen GROUP BY 1,2,5,6,7,8 ;
		ORDER BY 1,2,8,6,5 ;
       	INTO CURSOR cuadreCaja

&&	       	order by fecha, sucursal, natu, orden, descripcio 

       	REPORT FORM reports/CuadreCaja preview
       	
       	USE
       	SELECT alma2
       	use
       		
       ENDIF
       
       
       
       
    ENDIF
 ENDIF
 IF m.compras
    SELECT DISTINCT fecha, tercero, sufactura, codtipopago FROM compras WHERE esdevolucion='F' INTO TABLE consecutivos
    ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
    SCAN
       REPLACE consecutiv WITH getconsecutivo("consecutivo"+IIF(codtipopag="1", "CP", "CC"))
    ENDSCAN
    SELECT IIF(codtipopago="1", "CP", "CC") AS tipodocumento, consecutiv AS numerodoc, compras.fecha, compras.cuenta_compras AS cuenta, compras.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(SUM(base), 0) AS base, compras.tercero, cc, descripcio, compras.sufactura, compras.sucursale, tasa*factortasa AS tasaimpues FROM compras LEFT JOIN consecutivos ON compras.fecha=consecutivos.fecha AND compras.tercero=consecutivos.tercero AND compras.sufactura=consecutivos.sufactura AND compras.codtipopago=consecutivos.codtipopag WHERE esdevolucion='F' GROUP BY tipodocumento, numerodoc, cuenta, compras.tercero, compras.sucursal, naturaleza, cc, tasaimpues, sucursale INTO CURSOR c2
    copiar2("c2")
    SELECT consecutivos
    USE
    SELECT DISTINCT fecha, tercero, sufactura FROM compras WHERE esdevolucion='T' INTO TABLE consecutivos
    ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
    SCAN
       REPLACE consecutiv WITH getconsecutivo("consecutivoNC")
    ENDSCAN
    SELECT "NC" AS tipodocumento, consecutiv AS numerodoc, compras.fecha, compras.cuenta_compras AS cuenta, compras.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, compras.tercero, cc, descripcio, compras.sufactura, compras.sucursale, tasa*factortasa AS tasaimpues FROM compras LEFT JOIN consecutivos ON compras.fecha=consecutivos.fecha AND compras.tercero=consecutivos.tercero AND compras.sufactura=consecutivos.sufactura WHERE esdevolucion='T' GROUP BY tipodocumento, numerodoc, cuenta, compras.tercero, sucursal, naturaleza, cc, tasaimpues, sucursale INTO CURSOR c3
    copiar2("c3")
    SELECT consecutivos
    USE
 ENDIF
 IF m.gastos
    SELECT DISTINCT fecha, tercero, sufactura, codtipopago FROM gastos INTO TABLE consecutivos
    ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
    SCAN
       REPLACE consecutiv WITH getconsecutivo("consecutivo"+IIF(codtipopag="1", "CP", "CC"))
    ENDSCAN
    SELECT IIF(codtipopago="1", "CP", "CC") AS tipodocumento, consecutiv AS numerodoc, gastos.fecha, gastos.cuenta AS cuenta, gastos.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(SUM(base), 0) AS base, gastos.tercero, cc, descripcio, gastos.sufactura, gastos.sucursale AS sucursale, tasa*factortasa AS tasaimpues FROM gastos LEFT JOIN consecutivos ON gastos.fecha=consecutivos.fecha AND gastos.tercero=consecutivos.tercero AND gastos.sufactura=consecutivos.sufactura AND gastos.codtipopago=consecutivos.codtipopag GROUP BY tipodocumento, numerodoc, cuenta, gastos.tercero, sucursal, naturaleza, cc, tasaimpues, sucursale INTO CURSOR c7
    copiar2("c7")
    SELECT consecutivos
    USE
 ENDIF
 IF m.cortesias
    SELECT cortesias
    IF RECCOUNT()>0
       m.consecutivo = getconsecutivo("consecutivo_cortesias")
       SELECT "COR" AS tipodocumento, m.consecutivo AS numerodoc, m.fecha AS fecha, cortesias.cuenta, cortesias.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, tercero, m.cc AS cc FROM cortesias GROUP BY tipodocumento, cuenta, tercero, sucursal, naturaleza INTO CURSOR c4
       copiar("c4")
    ENDIF
 ENDIF
 IF m.traslados
    SELECT trasladosa
    IF RECCOUNT()>0
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
       copiar("c5")
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
       copiar("c6")
    ENDIF
 ENDIF
 IF m.inventarios
    SELECT DISTINCT fecha AS fecha, sucursale FROM inventarios INTO TABLE consecutivos
    ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
    SCAN
       REPLACE consecutiv WITH getconsecutivo("consecutivo_inventarios")
    ENDSCAN
    SELECT "MA" AS tipodocumento, consecutiv AS numerodoc, inventarios.fecha-1 AS fecha, cuenta, sucursal, inventarios.sucursale, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, tercero, cc, "INTERFAZ ICG - REGULARIZACION" AS descripcio FROM inventarios LEFT JOIN consecutivos ON inventarios.fecha=consecutivos.fecha AND inventarios.sucursale=consecutivos.sucursale GROUP BY inventarios.fecha, tipodocumento, cuenta, tercero, inventarios.sucursale, sucursal, naturaleza INTO CURSOR c5
    copiar("c5")
 ENDIF
 IF m.bajas
    SELECT bajas
    IF RECCOUNT()>0
       m.consecutivo = getconsecutivo("consecutivo_bajas")
       SELECT "BAJ" AS tipodocumento, m.consecutivo AS numerodoc, m.fecha AS fecha, cuenta, sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(000000000000000.00 , 0) AS base, tercero, m.cc AS cc FROM bajas GROUP BY tipodocumento, cuenta, tercero, sucursal, naturaleza INTO CURSOR c6
       copiar("c6")
    ENDIF
 ENDIF
 IF m.movscaja
    SELECT movscaja
    IF RECCOUNT()>0
       SELECT DISTINCT fecha, movscaja.sucursal FROM movscaja INTO TABLE consecutivos
       ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
       SCAN
          REPLACE consecutiv WITH getconsecutivo("consecutivo")
       ENDSCAN
       SELECT "RV" AS tipodocumento, consecutiv AS numerodoc, mc.fecha, mc.cuenta, mc.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(SUM(base), 0) AS base, tercero, cc, descripcio, vtacredito, numfac, mc.sucursal AS sucursale FROM movscaja AS mc LEFT JOIN consecutivos ON mc.sucursal=consecutivos.sucursal AND mc.fecha=consecutivos.fecha WHERE debito<>0 OR credito<>0 GROUP BY mc.fecha, tipodocumento, cuenta, descripcio, tercero, mc.sucursal, naturaleza, cc, numfac ORDER BY mc.fecha, tipodocumento, numerodoc INTO CURSOR c1
       copiar("c1")
       SELECT consecutivos
       USE
    ENDIF
 ENDIF
 IF m.anticipos
    SELECT anticipos
    IF RECCOUNT()>0
       SELECT DISTINCT fecha, anticipos.sucursal FROM anticipos INTO TABLE consecutivos
       ALTER TABLE consecutivos ADD COLUMN consecutiv N (10)
       SCAN
          REPLACE consecutiv WITH getconsecutivo("consecutivo")
       ENDSCAN
       SELECT "RV" AS tipodocumento, consecutiv AS numerodoc, mc.fecha, mc.cuenta, mc.sucursal, ROUND(SUM(debito), 0) AS debito, ROUND(SUM(credito), 0) AS credito, ROUND(SUM(base), 0) AS base, tercero, cc, descripcio, vtacredito, numfac, mc.sucursal AS sucursale FROM anticipos AS mc LEFT JOIN consecutivos ON mc.sucursal=consecutivos.sucursal AND mc.fecha=consecutivos.fecha WHERE debito<>0 OR credito<>0 GROUP BY mc.fecha, tipodocumento, cuenta, descripcio, tercero, mc.sucursal, naturaleza, cc, numfac ORDER BY mc.fecha, tipodocumento, numerodoc INTO CURSOR c1
       copiar("c1")
       SELECT consecutivos
       USE
    ENDIF
 ENDIF
 SELECT temporal
 BROWSE NOAPPEND NODELETE NORMAL
 COPY TO salida.xls TYPE XLS
 archivosalida = ALLTRIM(m.destino)+"CGBATCH.DAT"
 punteroarchivo = FCREATE(archivosalida, 0)
 SELECT temporal
 SELECT tipodocume, numerodoc, fecha, SUM(debito) AS total, tercero FROM temporal GROUP BY 1, 2, 3, 5 INTO CURSOR encabezado
 m.renglon = 1
 SCAN
    SCATTER MEMO MEMVAR
    SELECT temporal
    SCAN FOR tipodocume=m.tipodocume .AND. numerodoc=m.numerodoc .AND. fecha=m.fecha .AND. tercero=m.tercero .AND. (credito<>0 .OR. debito<>0)
       FWRITE(punteroarchivo, completarceros(m.renglon, 9, .T.))
       m.renglon = m.renglon+1
       FWRITE(punteroarchivo, "ML")
       FWRITE(punteroarchivo, completarceros(sucursale, 3, .T.))
       FWRITE(punteroarchivo, SUBSTR(tipodocume, 1, 2))
       FWRITE(punteroarchivo, completarceros(numerodoc, 6, .T.))
       FWRITE(punteroarchivo, completarespacios("", 13))
       FWRITE(punteroarchivo, completarceros(1, 2, .T.))
       FWRITE(punteroarchivo, DTOS(fecha))
       FWRITE(punteroarchivo, SUBSTR(DTOS(fecha), 1, 6))
       FWRITE(punteroarchivo, completarespacios(" ", 16))
       FWRITE(punteroarchivo, completarespacios(" ", 40))
       FWRITE(punteroarchivo, completarespacios(" ", 13))
       FWRITE(punteroarchivo, completarceros(IIF(m.total>0, m.total, -m.total)*100, 17, .T.)+IIF(m.total>0, "+", "-"))
       FWRITE(punteroarchivo, completarespacios(" ", 23))
       FWRITE(punteroarchivo, completarespacios(ALLTRIM(cuenta), 8))
       FWRITE(punteroarchivo, completarespacios(ALLTRIM(tercero), 13, .F.))
       FWRITE(punteroarchivo, completarceros(0, 2, .T.))
       FWRITE(punteroarchivo, completarceros(sucursal, 3, .T.))
       FWRITE(punteroarchivo, IIF(debito<>0, "D", "C"))
       FWRITE(punteroarchivo, completarceros(IIF(debito+credito>0, debito+credito, -(debito+credito))*100, 17, .T.)+IIF(debito+credito>0, "+", "-"))
       FWRITE(punteroarchivo, completarceros(0, 17, .T.)+"+")
       FWRITE(punteroarchivo, completarceros(0, 11, .T.)+"+")
       FWRITE(punteroarchivo, completarceros(0, 11, .T.)+"+")
       FWRITE(punteroarchivo, completarceros((base)*100, 17, .T.)+"+")
       FWRITE(punteroarchivo, completarceros(INT(tasaimpues*1000), 6, .T.))
       FWRITE(punteroarchivo, completarceros((tasareteiv)*100, 6, .T.))
       FWRITE(punteroarchivo, completarceros(0, 13, .T.)+"+")
       FWRITE(punteroarchivo, completarespacios(descripcio, 80, .F.))
       FWRITE(punteroarchivo, completarespacios(cc, 8, .F.))
       FWRITE(punteroarchivo, completarespacios(" ", 98))
       FWRITE(punteroarchivo, completarespacios(" ", 2))
       FWRITE(punteroarchivo, completarceros(0, 6, .T.))
       FWRITE(punteroarchivo, completarespacios(" ", 4, .T.))
       FWRITE(punteroarchivo, completarceros(doctoterce, 12, .T.))
       FWRITE(punteroarchivo, completarespacios(" ", 30))
       FWRITE(punteroarchivo, IIF(vtacredito, "FC", IIF(SUBSTR(tipodocume, 1, 2)="CC" .OR. SUBSTR(tipodocume, 1, 2)="CP", SUBSTR(tipodocume, 1, 2), "  ")))
       FWRITE(punteroarchivo, completarceros(IIF(vtacredito, numfac, IIF(SUBSTR(tipodocume, 1, 2)="CC" .OR. SUBSTR(tipodocume, 1, 2)="CP", doctoterce, 0)), 6, .T.))
       FWRITE(punteroarchivo, "00")
       FWRITE(punteroarchivo, IIF(vtacredito .OR. SUBSTR(tipodocume, 1, 2)="CC" .OR. SUBSTR(tipodocume, 1, 2)="CP", DTOS(fecha), "00000000"))
       FWRITE(punteroarchivo, "                            0           000000000000000000000000+0000000000000+00000000            ")
       FWRITE(punteroarchivo, "            000000000000000000                                                                                    0000000000000000                    ")
       FWRITE(punteroarchivo, IIF(.T., completarceros(IIF(sucursale=29, 22, sucursale), 3, .T.), "   "))
       FWRITE(punteroarchivo, "   ")
       FWRITE(punteroarchivo, IIF(.T., "E", " "))
       FWRITE(punteroarchivo, "00000000 ")
       FWRITE(punteroarchivo, IIF(.T., "0", " "))
       FWRITE(punteroarchivo, IIF(.T., "1", " "))
       FWRITE(punteroarchivo, "       000000   000000                                                                 00000000                    ")
       FWRITE(punteroarchivo, "0000000000000000                                                                                                                       ")
       FWRITE(punteroarchivo, "                                000000000         00000000                                                                                                                        0000000")
       FWRITE(punteroarchivo, "                                                                                   0                              0                                                                ")
       FWRITE(punteroarchivo, "      000                                                     000                                          00000000000000            00 00     00000 000")
       FWRITE(punteroarchivo, "                                                                                     00000000                0000                                        0000000000000000    ")
       FWRITE(punteroarchivo, "0000                                          0   0000000000000000                                           0            00000000")
       FWRITE(punteroarchivo, "                    000000000000000000000000   000                                                      ")
       FPUTS(punteroarchivo, "")
    ENDSCAN
    SELECT encabezado
 ENDSCAN
 FCLOSE(punteroarchivo)
 WAIT WINDOW NOWAIT "Archivo generado "+archivosalida
 CLOSE TABLE ALL
 RETURN
 
**
PROCEDURE copiar
 PARAMETER cursorname
 SELECT &cursorname
 SELECT tipodocumento, numerodoc, SUM(debito) AS debitos, SUM(credito) AS creditos FROM &cursorname GROUP BY tipodocumento, numerodoc INTO CURSOR acumulados
 SELECT acumulados
 SCAN
    m.tipodocume = tipodocumento
    m.numerodoc = numerodoc
    m.debitos = debitos
    m.creditos = creditos
    SELECT &cursorname
    entro = .F.
    SCAN FOR tipodocumento=m.tipodocume .AND. numerodoc=m.numerodoc
       entro = .T.
       SCATTER MEMVAR
       INSERT INTO temporal FROM MEMVAR
    ENDSCAN
    SELECT temporal
    IF entro
       IF ABS(m.debitos-m.creditos)>m.error
          WAIT WINDOW "La diferencia entre d�bitos y cr�ditos excede error permitido "+TRANSFORM(m.debitos-m.creditos, "999,999,999.99")+" en el documento "+ALLTRIM(m.tipodocumento)+"-"+ALLTRIM(STR(m.numerodoc))
          BROWSE NOAPPEND NOEDIT NODELETE NORMAL
       ELSE
          IF ABS(m.debitos-m.creditos)>0
             IF m.debitos>m.creditos
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. credito<>0 .AND. numerodoc=m.numerodoc
                REPLACE credito WITH credito+(m.debitos-m.creditos)
             ELSE
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. debito<>0 .AND. numerodoc=m.numerodoc
                REPLACE debito WITH debito+(m.creditos-m.debitos)
             ENDIF
          ENDIF
       ENDIF
    ENDIF
    SELECT acumulados
 ENDSCAN
 USE
 RETURN
ENDPROC
**
PROCEDURE copiar2
 PARAMETER cursorname
 SELECT &cursorname
 SELECT tipodocumento, numerodoc, sufactura, SUM(debito) AS debitos, SUM(credito) AS creditos FROM &cursorname GROUP BY tipodocumento, numerodoc INTO CURSOR acumulados
 SELECT acumulados
 SCAN
    m.tipodocume = tipodocumento
    m.numerodoc = numerodoc
    m.debitos = debitos
    m.creditos = creditos
    m.doctoterce = INT(VAL(ALLTRIM(sufactura)))
    SELECT &cursorname
    entro = .F.
    SCAN FOR tipodocumento=m.tipodocume .AND. numerodoc=m.numerodoc
       entro = .T.
       SCATTER MEMVAR
       INSERT INTO temporal FROM MEMVAR
    ENDSCAN
    SELECT temporal
    IF entro
       IF ABS(m.debitos-m.creditos)>m.error
          WAIT WINDOW "La diferencia entre d�bitos y cr�ditos excede error permitido "+TRANSFORM(m.debitos-m.creditos, "999,999,999.99")+" en el documento "+ALLTRIM(m.tipodocumento)+"-"+ALLTRIM(STR(m.numerodoc))
          BROWSE NOAPPEND NOEDIT NODELETE NORMAL
       ELSE
          IF ABS(m.debitos-m.creditos)>0
             IF m.debitos>m.creditos
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. credito>0 .AND. numerodoc=m.numerodoc
                REPLACE credito WITH credito+(m.debitos-m.creditos)
             ELSE
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. debito>0 .AND. numerodoc=m.numerodoc
                REPLACE debito WITH debito+(m.creditos-m.debitos)
             ENDIF
          ENDIF
       ENDIF
    ENDIF
    SELECT acumulados
 ENDSCAN
 USE
 RETURN
ENDPROC
**
PROCEDURE copiar3
 PARAMETER cursorname
 SELECT &cursorname
 SELECT tipodocumento, numerodoc, sucursale, SUM(debito) AS debitos, SUM(credito) AS creditos FROM &cursorname GROUP BY tipodocumento, numerodoc, sucursale INTO CURSOR acumulados
 SELECT acumulados
 SCAN
    m.tipodocume = tipodocumento
    m.numerodoc = numerodoc
    m.debitos = debitos
    m.creditos = creditos
    m.sucursale = sucursale
    SELECT &cursorname
    entro = .F.
    SCAN FOR tipodocumento=m.tipodocume .AND. numerodoc=m.numerodoc .AND. sucursale=m.sucursale
       entro = .T.
       SCATTER MEMVAR
       INSERT INTO temporal FROM MEMVAR
    ENDSCAN
    SELECT temporal
    IF entro
       IF ABS(m.debitos-m.creditos)>m.error
          WAIT WINDOW "La diferencia entre d�bitos y cr�ditos excede error permitido "+TRANSFORM(m.debitos-m.creditos, "999,999,999.99")+" en el documento "+ALLTRIM(m.tipodocumento)+"-"+ALLTRIM(STR(m.numerodoc))
          BROWSE NOAPPEND NOEDIT NODELETE NORMAL
       ELSE
          IF ABS(m.debitos-m.creditos)>0
             IF m.debitos>m.creditos
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. credito<>0 .AND. numerodoc=m.numerodoc .AND. sucursale=m.sucursale AND AT("PUNTOS", descripcio)=0
                REPLACE credito WITH credito+(m.debitos-m.creditos)
             ELSE
                LOCATE ALL FOR ALLTRIM(m.tipodocume)==ALLTRIM(tipodocume) .AND. debito<>0 .AND. numerodoc=m.numerodoc .AND. sucursale=m.sucursale AND AT("PUNTOS", descripcio)=0
                REPLACE debito WITH debito+(m.creditos-m.debitos)
             ENDIF
          ENDIF
       ENDIF
    ENDIF
    SELECT acumulados
 ENDSCAN
 USE
 RETURN
 CALCULATE SUM(unidadespagadas*precioiva) TO ventas 
 CALCULATE SUM(totalneto) TO ventas2 
 CALCULATE SUM(importe) TO pagos 
 CALCULATE SUM(importe) TO descuentos FOR importe<0
 SET FILTER TO totalbruto+totalimpuestos<>totalneto
 SELECT totalneto, SUM(importe) FROM vistaPagos GROUP BY serie, numero, n
 SET FILTER TO totalneto<>sum_importe
 SELECT vistaventas
 SELECT numserie, numalbaran, n, SUM(precioiva*unidadespagadas) AS detalle, totalneto AS encabezado FROM vistaVentas GROUP BY numserie, numalbaran, n INTO CURSOR ventas
 SELECT serie, numero, n, SUM(importe) AS pago FROM vistaPagos GROUP BY serie, numero, n INTO CURSOR pagos
 SELECT ventas.*, pagos.pago FROM ventas LEFT JOIN pagos ON numserie=serie AND numero=numalbaran AND pagos.n=ventas.n
 SET FILTER TO pago<>encabezado
 SET FILTER TO pago<>detalle
ENDPROC
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
**
FUNCTION buscar
 PARAMETER ser, num, n
 zona = SELECT()
 SELECT vistacompras
 reg = RECNO()
 LOCATE ALL FOR seriefact=ser .AND. numfact=num .AND. nfact=n
 m.codal = codalmacen
 GOTO reg
 SELECT almacenes
 reg = RECNO()
 LOCATE ALL FOR codalmacen=m.codal
 m.idf = idfront
 GOTO reg
 SELECT (zona)
 RETURN idf
ENDFUNC
**
FUNCTION buscar2
 PARAMETER ser, num, n
 zona = SELECT()
 SELECT vistacompras
 reg = RECNO()
 LOCATE ALL FOR seriefact=ser .AND. numfact=num .AND. nfact=n
 m.codal = SUBSTR(vistacompras.numserie, 1, 2)
 GOTO reg
 SELECT almacenes
 reg = RECNO()
 LOCATE ALL FOR codalmacen=m.codal
 m.idf = idfront
 GOTO reg
 SELECT (zona)
 RETURN idf
ENDFUNC
**
FUNCTION getconsecutivo2
 PARAMETER m.fecha
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
 RETURN m.numero
ENDFUNC
**
