 OPEN DATABASE data\interfaz
 SET EXCLUSIVE ON

ALTER TABLE horas ADD COLUMN cc c(5)



 
 
 CLOSE TABLE ALL
 RETURN

ALTER TABLE almacenes ADD COLUMN co c(3)
REPLACE co WITH "017" FOR ALLTRIM(codalmacen)=="B1"
REPLACE co WITH "022" FOR ALLTRIM(codalmacen)=="B4"
REPLACE co WITH "019" FOR ALLTRIM(codalmacen)=="B6"
REPLACE co WITH "010" FOR ALLTRIM(codalmacen)=="B5"
REPLACE co WITH "029" FOR ALLTRIM(codalmacen)=="B7"




USE horas EXCLUSIVE
INDEX ON nombre TAG nombre
INDEX ON codalmacen TAG almacen


 m.desde = DATE()
 m.hasta = DATE()

 = DBSETPROP("VistaVendedores.nomvendedor", "Field", "DataType", "c(100)")
 = DBSETPROP("VistaPuntos.nombrecliente", "Field", "DataType", "c(100)")



CREATE SQL VIEW VistaTarjetas REMOTE CONNECTION ConexionICG as SELECT clientes.codcliente, nif20, idtarjeta from tarjetas inner join clientes on tarjetas.codcliente=clientes.codcliente

CREATE SQL VIEW VistaPuntosPromociones REMOTE CONNECTION ConexionICG as select * from EXTRACTOPROMOCIONESTARJETA  order by idtarjeta, fecha
CREATE TABLE puntos (idlinea i(4), idtarjeta i(4), caja c(3), fecha datetime, descripcion c(50), puntos i(4), gastados i(4))
CREATE TABLE puntosAplicados (idlinea1 i(4), idlinea2 i(4), idtarjeta i(4), caja c(3), fecha datetime, descripcion c(50), puntosAplicados i(4))



 CREATE SQL VIEW VistaConceptosPago REMOTE CONNECTION ConexionICG AS select id, descripcion from conceptospago where movcaja='T'
 CREATE SQL VIEW VistaConceptosDto REMOTE CONNECTION ConexionICG AS SELECT * from cargosDtos
 CREATE SQL VIEW VistaAlmacenes REMOTE CONNECTION ConexionICG AS SELECT * from almacen
  CREATE SQL VIEW VistaPagosCaja REMOTE CONNECTION conexionICG AS select caja, numero, fecha, importe, comentario, codmediopago, codconceptopago, tipomovcaja, z from pagos where fecha>=?m.desde AND fecha<=?m.hasta
   CREATE SQL VIEW VistaAnticiposReservadas REMOTE CONNECTION conexionICG AS Select fecha as fechadocumento, importe, z as zsaldado, cajaorigen as cajasaldado from cobrospagos where tipo=5 AND fecha>=?m.desde AND fecha<=?m.hasta
   CREATE SQL VIEW vistaCobros REMOTE CONNECTION ConexionICG as select * from Tesoreria where fechaSaldado>=?m.desde AND fechaSaldado<=?m.hasta AND comentario<>'' AND origen='C' AND tipodocumento='F'
 


ALTER TABLE config ADD COLUMN porcentaje_domicilios n(10,2)
REPLACE porcentaje_domicilios WITH 10

ALTER TABLE config ADD COLUMN cuenta_domicilios c(8)
REPLACE cuenta_domicilios WITH '28150505'




 CREATE SQL VIEW VistaVentas REMOTE CONNECTION ConexionICG AS SELECT Albventacab.NUMSERIE, Albventacab.NUMALBARAN, Albventacab.N, Albventacab.FECHA, precio, unidadespagadas, dto, total, iva, precioIva, tipoimpuesto, albVentaLin.codArticulo, caja, Albventacab.TOTALBRUTO, Albventacab.TOTALIMPUESTOS, albventalin.coste,  Albventacab.TOTALNETO, coste as precioDefecto, Albventacab.totDtoComercial, Albventacab.dtoComercial, ultimoCoste, unidadesTotal, fvsr.numeroFiscal, codCliente, codAlmacen, puntosacum, numlin ;
 FROM dbo.ALBVENTACAB Albventacab left outer join dbo.ALBVENTALIN Albventalin  ON Albventalin.NUMSERIE = Albventacab.NUMSERIE AND Albventalin.NUMALBARAN = Albventacab.NUMALBARAN   left outer join dbo.ARTICULOSLIN ON AlbVentaLin.codArticulo=ArticulosLin.codArticulo AND AlbVentaLin.talla=ArticulosLin.talla AND AlbVentaLin.color=ArticulosLin.color left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 
USE config
REPLACE all cta_puntos_db with '13809510'
REPLACE all cta_puntos_cr with '23809510'



ALTER TABLE config ADD cta_puntos_db c(8)
ALTER TABLE config ADD cta_puntos_cr c(8)
ALTER TABLE config ADD cta_puntos_dto c(8)


REPLACE all cta_puntos_db with '13809510'
REPLACE all cta_puntos_db with '23809510'
REPLACE all cta_puntos_dto with '41751010'


CREATE SQL VIEW VistaPlanilla REMOTE CONNECTION ConexionICG as select * from pagos where fecha>=?m.desde and fecha<=?m.hasta AND (codconceptopago=2 OR codconceptopago=3)
CREATE SQL VIEW vistaCobros REMOTE CONNECTION ConexionICG as select * from Tesoreria where fechaSaldado>=?m.desde AND fechaSaldado<=?m.hasta AND comentario<>'' AND origen='C' AND tipodocumento='F'
CREATE SQL VIEW VistaCuadreCaja as select Temporal.fecha, Temporal.sucursal, sum(Temporal.debito) as debito,;
  sum(Temporal.credito) as credito, Temporal.descripcio, Temporal.orden,;
  Almacenes.nombrealmacen, Almacenes.idfront,;
  IIF(debito#0,1,2) AS naturaleza from temporal left outer join almacenes on temporal.sucursal = almacenes.idfront where LEN(ALLTRIM(almacenes.codalmacen))=2 group by 1,2,5,6,7,8,9 order by fecha, sucursal, naturaleza, orden, descripcio
 CREATE SQL VIEW VistaPagosCaja REMOTE CONNECTION conexionICG AS select caja, numero, fecha, importe, comentario, codmediopago, codconceptopago, tipomovcaja, z from pagos where fecha>=?m.desde AND fecha<=?m.hasta


CREATE SQL VIEW vistaCobros REMOTE CONNECTION ConexionICG as select * from Tesoreria where fechaSaldado>=?m.desde AND fechaSaldado<=?m.hasta AND comentario<>'' AND origen='C' AND tipodocumento='F'
CREATE SQL VIEW VistaPlanilla REMOTE CONNECTION ConexionICG as select * from pagos where fecha>=?m.desde and fecha<=?m.hasta AND codconceptopago=2

ALTER TABLE temporal ADD COLUMN orden i
ALTER TABLE temporal ADD COLUMN descripci2 c(30)

CREATE SQL VIEW vistaCobros REMOTE CONNECTION ConexionICG as select * from Tesoreria where fechaSaldado>=?m.desde AND fechaSaldado<=?m.hasta AND comentario<>'' AND origen='C' AND tipodocumento='F'
CREATE SQL VIEW VistaPlanilla REMOTE CONNECTION ConexionICG as select * from pagos where fecha>=?m.desde and fecha<=?m.hasta AND codconceptopago=2

CREATE SQL VIEW VistaCuadreCaja as select Temporal.fecha, Temporal.sucursal, sum(Temporal.debito) as debito,;
  sum(Temporal.credito) as credito, Temporal.descripcio, Temporal.orden,;
  Almacenes.nombrealmacen, Almacenes.idfront,;
  IIF(debito#0,1,2) AS naturaleza from temporal left outer join almacenes on temporal.sucursal = almacenes.idfront where LEN(ALLTRIM(almacenes.codalmacen))=2 group by 1,2,5,6,7,8,9 order by fecha, sucursal, naturaleza, orden, descripcio


 = DBSETPROP("VistaVendedores.nomvendedor", "Field", "DataType", "c(100)")
 CREATE SQL VIEW VistaMarcaciones REMOTE CONNECTION conexionICG AS SELECT Registroempleados.FO, Registroempleados.CODEMPLEADO, Vendedores.NOMVENDEDOR, Registroempleados.DIA, Registroempleados.HORAIN, Registroempleados.HORAOUT, Registroempleados.HORAS, Registroempleados.CAJA, vendedores.codalmacen FROM dbo.REGISTROEMPLEADOS Registroempleados, dbo.VENDEDORES Vendedores WHERE Vendedores.CODVENDEDOR = Registroempleados.CODEMPLEADO AND (Registroempleados.DIA >= ?m.desde AND Registroempleados.DIA <= ?m.hasta) ORDER BY Registroempleados.CODEMPLEADO, Registroempleados.HORAIN
 = DBSETPROP("VistaMarcaciones.nomvendedor", "Field", "DataType", "c(100)")
 CREATE TABLE data\festivos (fecha D)
 INDEX ON fecha TAG fecha
 ALTER TABLE vendedores ALTER COLUMN rol3 N (10)
 ALTER TABLE horas ADD COLUMN rol INT (10)
 INDEX ON codvendedor TAG vendedor
 ALTER TABLE vendedores ADD COLUMN rol3 INT (10)
 CREATE SQL VIEW VistaVentas REMOTE CONNECTION ConexionICG AS SELECT Albventacab.NUMSERIE, Albventacab.NUMALBARAN, Albventacab.N, Albventacab.FECHA, precio, unidadespagadas, dto, total, iva, precioIva, tipoimpuesto, albVentaLin.codArticulo, caja, Albventacab.TOTALBRUTO, Albventacab.TOTALIMPUESTOS, albventalin.coste,  Albventacab.TOTALNETO, coste as precioDefecto, Albventacab.totDtoComercial, Albventacab.dtoComercial, ultimoCoste, unidadesTotal, fvsr.numeroFiscal, codCliente, codAlmacen  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.ALBVENTALIN Albventalin  ON Albventalin.NUMSERIE = Albventacab.NUMSERIE AND Albventalin.NUMALBARAN = Albventacab.NUMALBARAN   left outer join dbo.ARTICULOSLIN ON AlbVentaLin.codArticulo=ArticulosLin.codArticulo AND AlbVentaLin.talla=ArticulosLin.talla AND AlbVentaLin.color=ArticulosLin.color left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 USE horas
 INDEX ON codalmacen+STR(cedula) TAG horas
 ALTER TABLE horas ADD COLUMN codalmacen C (3)
 USE horas
 ZAP
 ALTER TABLE horas ALTER COLUMN horas N (15, 2)
 ALTER TABLE horas ALTER COLUMN cedula N (15)
 CREATE SQL VIEW VistaPropinas2 REMOTE CONNECTION conexionicg AS select caja, fecha, numserie, numfactura, propina, codvendedor from facturasventa where fecha>=?m.desde AND fecha<=?m.hasta 
 ALTER TABLE config ADD COLUMN cuenta_db_cree C (8)
 ALTER TABLE config ADD COLUMN cuenta_cr_cree C (8)
 ALTER TABLE config ADD COLUMN base_cree N (10)
 ALTER TABLE config ADD COLUMN tasa_cree N (10, 2)
 ALTER TABLE vendedores ADD COLUMN rol2 N
 CREATE TABLE data\distReservadas (caja C (3), fecha D, numfactura I, codvendedor I)
 ALTER TABLE vendedores ADD COLUMN genera_propina L
 CREATE SQL VIEW VistaPropinas2 REMOTE CONNECTION conexionicg AS select caja, fecha, numserie, numfactura, propina, codvendedor from facturasventa where fecha>=?m.desde AND fecha<=?m.hasta AND propina>0
 CREATE SQL VIEW VistaVendedores REMOTE CONNECTION conexionICG AS SELECT codVendedor, nomvendedor, activo, codalmacen, descatalogado, numssocial from vendedores
 CREATE CONNECTION ConexionYanubaHoras DATASOURCE YanubaHoras
 CREATE TABLE data\horas (codvendedor N, desde D, hasta D, cedula N, horas N)
 CREATE TABLE data\roles (id N PRIMARY KEY, rol C (50))
 USE roles EXCLUSIVE
 INSERT INTO roles VALUES (1, 'Mesero')
 INSERT INTO roles VALUES (2, 'Planta')
 INSERT INTO roles VALUES (3, 'Admon principal')
 INSERT INTO roles VALUES (4, 'Asistente 1 Admon')
 INSERT INTO roles VALUES (5, 'Asistente 2 Admon')
 INSERT INTO roles VALUES (6, 'Maitre principal')
 INSERT INTO roles VALUES (7, 'Maitre n 2')
 INSERT INTO roles VALUES (8, 'Cajera')
 INSERT INTO roles VALUES (9, 'Jefe cocina')
 INSERT INTO roles VALUES (10, 'Primera cocina')
 INSERT INTO roles VALUES (11, 'Segunda cocina')
 INSERT INTO roles VALUES (12, 'Jefe fuente')
 INSERT INTO roles VALUES (13, 'Primera fuente')
 INSERT INTO roles VALUES (14, 'Jefes bizcochería')
 INSERT INTO roles VALUES (15, 'Jefes mostrador')
 INSERT INTO roles VALUES (16, 'Chocolatería')
 INSERT INTO roles VALUES (17, 'Incentivo mostrador')
 INSERT INTO roles VALUES (18, 'Taquillera')
 INSERT INTO roles VALUES (19, 'Almacenista')
 CREATE TABLE data\vendedores (id N, nombre C (254), rol N, activo L, codalmacen C (3) NULL)
 USE vendedores EXCLUSIVE
 INDEX ON id TAG id
 INDEX ON rol TAG rol
 INDEX ON codalmacen TAG sede
 INDEX ON SUBSTR(nombre, 1, 100) TAG nombre
 INDEX ON activo TAG activo
 CREATE SQL VIEW VistaVendedores REMOTE CONNECTION conexionICG AS SELECT codVendedor, nomvendedor, activo, codalmacen from vendedores
 CREATE TABLE data\porcentajes (codalmacen C (3), rol N, porcentaje N (7, 2))
 CLOSE TABLE ALL
 WAIT WINDOW "Cambio realizado!!!"
 RETURN
 ALTER TABLE formasPago ADD COLUMN cc C (8)
 CREATE SQL VIEW VistaPagos REMOTE CONNECTION ConexionICG AS SELECT fecha, tesoreria.serie, numero, tesoreria.n, totalbruto, totalimpuestos, totalneto, totalcoste, ivaincluido, totalcosteiva, codformapago, importe, codtipopago, base, caja, clientes.cif, clientes.codCliente, numfac, nombrecliente, fvsr.numeroFiscal  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.TESORERIA TESORERIA  ON TESORERIA.SERIE = Albventacab.NUMSERIE AND TESORERIA.NUMERO = Albventacab.NUMALBARAN  left outer join dbo.clientes on albVentaCab.codCliente=clientes.codCliente  left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 CREATE SQL VIEW vistaPropinas REMOTE CONNECTION ConexionICG AS SELECT Facturasventa.CAJA, facturasventa.fecha, numserie, numfactura, Facturasventa.PROPINA FROM dbo.FACTURASVENTA Facturasventa WHERE Facturasventa.FECHA >= ?m.desde AND Facturasventa.FECHA <=?m.hasta 
 CREATE SQL VIEW VistaVentas REMOTE CONNECTION ConexionICG AS SELECT Albventacab.NUMSERIE, Albventacab.NUMALBARAN, Albventacab.N, Albventacab.FECHA, precio, unidadespagadas, dto, total, iva, precioIva, tipoimpuesto, albVentaLin.codArticulo, caja, Albventacab.TOTALBRUTO, Albventacab.TOTALIMPUESTOS, Albventacab.TOTALNETO, coste as precioDefecto, Albventacab.totDtoComercial, Albventacab.dtoComercial, ultimoCoste, unidadesTotal, fvsr.numeroFiscal, codCliente, codAlmacen  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.ALBVENTALIN Albventalin  ON Albventalin.NUMSERIE = Albventacab.NUMSERIE AND Albventalin.NUMALBARAN = Albventacab.NUMALBARAN   left outer join dbo.ARTICULOSLIN ON AlbVentaLin.codArticulo=ArticulosLin.codArticulo AND AlbVentaLin.talla=ArticulosLin.talla AND AlbVentaLin.color=ArticulosLin.color left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 CREATE SQL VIEW VistaPagos REMOTE CONNECTION ConexionICG AS SELECT fecha, tesoreria.serie, numero, tesoreria.n, totalbruto, totalimpuestos, totalneto, totalcoste, ivaincluido, totalcosteiva, codformapago, importe, codtipopago, base, caja, clientes.cif, clientes.codCliente, numfac, nombrecliente, fvsr.numeroFiscal  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.TESORERIA TESORERIA  ON TESORERIA.SERIE = Albventacab.NUMSERIE AND TESORERIA.NUMERO = Albventacab.NUMALBARAN  left outer join dbo.clientes on albVentaCab.codCliente=clientes.codCliente  left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura AND Albventacab.nfac=fvsr.n  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 CREATE SQL VIEW VistaAnticiposReservadas REMOTE CONNECTION conexionICG AS Select fecha as fechadocumento, importe, z as zsaldado, cajaorigen as cajasaldado from cobrospagos where tipo=5 AND fecha>=?m.desde AND fecha<=?m.hasta
 ALTER TABLE config ADD COLUMN cuenta_anticipos C (8)
 ALTER TABLE config ADD COLUMN cuenta_compras_gastos C (8)
 CREATE SQL VIEW VistaMarcas REMOTE CONNECTION conexionICG AS select * from marca
 CREATE SQL VIEW VistaPagosCaja REMOTE CONNECTION conexionICG AS select caja, numero, fecha, importe, comentario, codmediopago, codconceptopago, tipomovcaja,z from pagos where fecha>=?m.desde AND fecha<=?m.hasta
 CREATE SQL VIEW VistaConceptosPago REMOTE CONNECTION ConexionICG AS select id, descripcion from conceptospago where movcaja='T'
 CREATE TABLE data\conceptosPago (id I PRIMARY KEY, descripcion C (100), cuenta C (8), importar L)
 ? DBSETPROP('VistaConceptosPago', "VIEW", 'SendUpdates', .T.)
 UPDATE conceptosPago SET cuenta = '28109503', importar = .T. WHERE id=7
 UPDATE conceptosPago SET cuenta = '23809509', importar = .T. WHERE id=8
 UPDATE conceptosPago SET cuenta = '28109501', importar = .T. WHERE id=9
 ALTER TABLE config ADD COLUMN cuenta_caja C (8)
 USE
 RETURN
 CREATE TABLE data\consecutivo (fecha D, numero I)
 m.fecha = DATE()-10
 m.numero = 1300
 INSERT INTO consecutivo FROM MEMVAR
 CREATE SQL VIEW VistaPuntos REMOTE CONNECTION ConexionICG AS SELECT Clientes.CODCLIENTE, Clientes.NOMBRECLIENTE FROM dbo.CLIENTES Clientes WHERE Clientes.NOMBRECLIENTE LIKE 'PUNTO%'
 ALTER TABLE almacenes ADD COLUMN codcliente N (4)
 USE
 RETURN
 ALTER TABLE config ADD COLUMN cuentasacortesiasdb C (8)
 ALTER TABLE config ADD COLUMN cuentasacortesiascr C (8)
 REPLACE cuentasacortesiasdb WITH "61401501"
 REPLACE cuentasacortesiascr WITH "14052031"
 USE
 RETURN
 CREATE SQL VIEW VistaDescuentosCompras REMOTE CONNECTION ConexionICG AS select albcompracab.numserie, numalbaran, albcompracab.n, coddto, tipo, dtocargo, importe, sufactura, FACTURASCOMPRA.fecha, esdevolucion, base  from albcompradtos left outer join albcompracab  on albcompracab.numserie = albcompradtos.numserie AND albcompracab.numAlbaran = albcompradtos.numero AND albcompracab.N = albcompradtos.n  LEFT OUTER JOIN FACTURASCOMPRA  ON albcompracab.numseriefac=FACTURASCOMPRA.numSerie and albcompracab.numfac=FACTURASCOMPRA.numFactura and albcompracab.nFac=FACTURASCOMPRA.n where fecha=?m.fecha
 ALTER TABLE config ADD cuenta_descuentos C (13)
 ALTER TABLE config ADD COLUMN error N (5)
 ALTER TABLE config ADD COLUMN consecutivo_cortesias N
 ALTER TABLE config ADD COLUMN cuenta_compras_reteica C (13)
 ALTER TABLE config ADD COLUMN cuenta_compras_reteiva C (13)
 ALTER TABLE config ADD COLUMN cuenta_compras_retefuente C (13)
 SELECT config
 REPLACE error WITH 100
 USE
 CREATE SQL VIEW VistaTraslados REMOTE CONNECTION ConexionICG AS SELECT serie, numero, TRASPASOSCAB.caja, TRASPASOSCAB.codalmacendestino, total, precio, TRASPASOSCAB.fecha, codarticulo, unidades FROM TRASPASOSCAB left JOIN MOVIMENTS ON TRASPASOSCAB.CAJA = MOVIMENTS.CAJA AND TRASPASOSCAB.SERIE = MOVIMENTS.SERIEDOC AND TRASPASOSCAB.NUMERO = MOVIMENTS.NUMDOC where tipo='ENV'
 
**
