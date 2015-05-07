 m.fecha = {^2008-08-07}
 m.desde = DATE()-30
 m.hasta = DATE()-30
 CREATE SQL VIEW VistaVendedores REMOTE CONNECTION conexionICG AS SELECT codVendedor, nomvendedor, activo, codalmacen, descatalogado, numssocial from vendedores
 CREATE SQL VIEW VistaPropinas2 REMOTE CONNECTION conexionicg AS select caja, fecha, numserie, numfactura, propina, codvendedor from facturasventa where fecha>=?m.desde AND fecha<=?m.hasta 
 CREATE SQL VIEW vistaPropinas REMOTE CONNECTION ConexionICG AS SELECT Facturasventa.CAJA, facturasventa.fecha, numserie, numfactura, Facturasventa.PROPINA FROM dbo.FACTURASVENTA Facturasventa WHERE Facturasventa.FECHA >= ?m.desde AND Facturasventa.FECHA <=?m.hasta 
 CREATE SQL VIEW VistaAnticiposReservadas REMOTE CONNECTION conexionICG AS Select fecha as fechadocumento, importe, z as zsaldado, cajaorigen as cajasaldado from cobrospagos where tipo=5 AND fecha>=?m.desde AND fecha<=?m.hasta
 CREATE SQL VIEW VistaMarcas REMOTE CONNECTION conexionICG AS select * from marca
 CREATE SQL VIEW VistaPagosCaja REMOTE CONNECTION conexionICG AS select caja, numero, fecha, importe, comentario, codmediopago, codconceptopago, tipomovcaja, z from pagos where fecha>=?m.desde AND fecha<=?m.hasta
 CREATE SQL VIEW VistaConceptosPago REMOTE CONNECTION ConexionICG AS select id, descripcion from conceptospago where movcaja='T'
 CREATE SQL VIEW VistaConceptosDto REMOTE CONNECTION ConexionICG AS SELECT * from cargosDtos
 CREATE SQL VIEW VistaArticulos REMOTE CONNECTION ConexionICG AS SELECT codArticulo, marca, dpto, seccion, descripcion from articulos
 CREATE SQL VIEW VistaVentas REMOTE CONNECTION ConexionICG AS SELECT Albventacab.NUMSERIE, Albventacab.NUMALBARAN, Albventacab.N, Albventacab.FECHA, precio, unidadespagadas, dto, total, iva, precioIva, tipoimpuesto, albVentaLin.codArticulo, caja, Albventacab.TOTALBRUTO, Albventacab.TOTALIMPUESTOS, albventalin.coste,  Albventacab.TOTALNETO, coste as precioDefecto, Albventacab.totDtoComercial, Albventacab.dtoComercial, ultimoCoste, unidadesTotal, fvsr.numeroFiscal, codCliente, codAlmacen  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.ALBVENTALIN Albventalin  ON Albventalin.NUMSERIE = Albventacab.NUMSERIE AND Albventalin.NUMALBARAN = Albventacab.NUMALBARAN   left outer join dbo.ARTICULOSLIN ON AlbVentaLin.codArticulo=ArticulosLin.codArticulo AND AlbVentaLin.talla=ArticulosLin.talla AND AlbVentaLin.color=ArticulosLin.color left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 CREATE SQL VIEW VistaPagos REMOTE CONNECTION ConexionICG AS SELECT fecha, tesoreria.serie, numero, tesoreria.n, totalbruto, totalimpuestos, totalneto, totalcoste, ivaincluido, totalcosteiva, codformapago, importe, codtipopago, base, caja, clientes.cif, clientes.codCliente, numfac, nombrecliente, fvsr.numeroFiscal  FROM dbo.ALBVENTACAB Albventacab left outer join dbo.TESORERIA TESORERIA  ON TESORERIA.SERIE = Albventacab.NUMSERIE AND TESORERIA.NUMERO = Albventacab.NUMALBARAN  left outer join dbo.clientes on albVentaCab.codCliente=clientes.codCliente  left outer join dbo.facturasVentaSeriesResol fvsr on Albventacab.numseriefac=fvsr.numSerie AND Albventacab.numfac=fvsr.numfactura  WHERE Albventacab.fecha >= ?m.desde AND Albventacab.fecha <= ?m.hasta 
 CREATE SQL VIEW VistaCompras REMOTE CONNECTION ConexionICG AS SELECT fecha, ALBCOMPRACAB.numserie, ALBCOMPRACAB.numalbaran, ALBCOMPRACAB.n, sufactura, ALBCOMPRALIN.unidadesTotal, ALBCOMPRALIN.precio, ALBCOMPRALIN.dto, ALBCOMPRALIN.total, ALBCOMPRALIN.tipoImpuesto, ALBCOMPRALIN.iva, ALBCOMPRALIN.codArticulo, ALBCOMPRALIN.codAlmacen, facturascompra.codProveedor, albcompracab.esdevolucion, FACTURASCOMPRA.numSerie as serieFact, FACTURASCOMPRA.numFactura as numFact, FACTURASCOMPRA.n as nFact, facturasCompra.totalneto, facturascompra.dtocomercial, facturasCompra.totDtoComercial FROM ALBCOMPRACAB LEFT OUTER JOIN FACTURASCOMPRA  ON ALBCOMPRACAB.numseriefac=FACTURASCOMPRA.numSerie and ALBCOMPRACAB.numFac=FACTURASCOMPRA.numFactura and ALBCOMPRACAB.nfac=FACTURASCOMPRA.n  left outer join ALBCOMPRALIN  ON ALBCOMPRALIN.numSerie=ALBCOMPRACAB.numSerie and ALBCOMPRALIN.numAlbaran=ALBCOMPRACAB.numAlbaran and ALBCOMPRALIN.n=ALBCOMPRACAB.n  where ALBCOMPRACAB.FACTURADO='T' AND facturasCompra.fecha>=?m.desde AND facturasCompra.fecha<=?m.hasta
 CREATE SQL VIEW VistaDescuentosCompras REMOTE CONNECTION ConexionICG AS select facturascompra.numserie, numfactura, facturascompra.n, coddto, tipo, dtocargo, importe, sufactura, FACTURASCOMPRA.fecha, 'F' as esdevolucion, base as baseError, totalBruto  from facturasCompraDtos LEFT OUTER JOIN FACTURASCOMPRA  on FACTURASCOMPRA.numserie = facturasCompraDtos.numserie AND FACTURASCOMPRA.numFactura = facturasCompraDtos.numero AND FACTURASCOMPRA.N = facturasCompraDtos.n  where FACTURASCOMPRA.fecha>=?m.desde AND FACTURASCOMPRA.fecha<=?m.hasta
 CREATE SQL VIEW VistaPagosCompras REMOTE CONNECTION ConexionICG AS SELECT DISTINCT serie, numero, tesoreria.n, codtipopago, codProveedor  FROM TESORERIA TESORERIA  LEFT OUTER JOIN FACTURASCOMPRA  ON tesoreria.serie=FACTURASCOMPRA.numSerie and tesoreria.numero=FACTURASCOMPRA.numFactura and tesoreria.n=FACTURASCOMPRA.n  WHERE facturasCompra.fecha>=?m.desde AND facturasCompra.fecha<=?m.hasta AND origen='P' 
 CREATE SQL VIEW VistaTraslados REMOTE CONNECTION ConexionICG AS SELECT serie, numero, TRASPASOSCAB.caja, TRASPASOSCAB.codAlmacenOrigen, TRASPASOSCAB.codalmacendestino, total, precio, TRASPASOSCAB.fecha, codarticulo, unidades  FROM TRASPASOSCAB left JOIN MOVIMENTS ON TRASPASOSCAB.CAJA = MOVIMENTS.CAJA AND TRASPASOSCAB.SERIE = MOVIMENTS.SERIEDOC AND TRASPASOSCAB.NUMERO = MOVIMENTS.NUMDOC  where tipo='ENV' AND moviments.fecha>=?m.desde AND moviments.fecha<=?m.hasta
 CREATE SQL VIEW VistaInventarios REMOTE CONNECTION ConexionICG AS SELECT Moviments.CODALMACENORIGEN, Moviments.CODALMACENDESTINO, Moviments.CODARTICULO, Moviments.FECHA, Moviments.UNIDADES, Moviments.STOCK, Moviments.PRECIO, marca FROM  MOVIMENTS Moviments LEFT OUTER JOIN ARTICULOS Articulos  ON  Moviments.CODARTICULO = Articulos.CODARTICULO  WHERE Moviments.TIPO = 'REG' AND Moviments.FECHA >= ?m.desde AND Moviments.FECHA <= ?m.hasta
 RETURN
 CREATE SQL VIEW VistaPagosCompras REMOTE CONNECTION ConexionICG AS SELECT DISTINCT ALBCOMPRACAB.numserie, numalbaran, ALBCompraCAB.n, codtipopago  FROM dbo.ALBCompraCAB AlbCompracab left outer join dbo.TESORERIA TESORERIA  ON TESORERIA.SERIE = AlbCompracab.NUMSERIEfac AND TESORERIA.NUMERO = AlbCompracab.NUMFAC  AND TESORERIA.N = AlbCompracab.NFac  left outer join dbo.clientes on albCompraCab.codCliente=clientes.codCliente  LEFT OUTER JOIN FACTURASCOMPRA  ON ALBCOMPRACAB.numseriefac=FACTURASCOMPRA.numSerie and ALBCOMPRACAB.numFac=FACTURASCOMPRA.numFactura and ALBCOMPRACAB.nfac=FACTURASCOMPRA.n  WHERE facturasCompra.fecha>=?m.desde AND facturasCompra.fecha<=?m.hasta AND origen='P' AND facturado='T'
 CREATE SQL VIEW VistaFacturasComprasTot REMOTE CONNECTION ConexionICG AS SELECT serie, numero, fct.n, sum(bruto) as bruto, dtocomerc, sum(totDtocomerc) as totDtoComerc, sum(totIva) as totiva from FacturasCompraTot fct left outer join facturasCompra on facturasCompra.numSerie=fct.serie AND facturasCompra.numFactura=fct.numero AND facturasCompra.n=fct.n  where facturasCompra.fecha>=?m.desde AND facturasCompra.fecha<=?m.hasta group by serie, numero, fct.n, dtocomerc
 CREATE SQL VIEW VistaCompras REMOTE CONNECTION ConexionICG AS SELECT fecha, ALBCOMPRACAB.numserie, ALBCOMPRACAB.numalbaran, ALBCOMPRACAB.n, sufactura, ALBCOMPRALIN.unidadesTotal, ALBCOMPRALIN.precio, ALBCOMPRALIN.dto, ALBCOMPRALIN.total, ALBCOMPRALIN.tipoImpuesto, ALBCOMPRALIN.iva, ALBCOMPRALIN.codArticulo, ALBCOMPRALIN.codAlmacen, facturascompra.codProveedor, albcompracab.esdevolucion, FACTURASCOMPRA.totalNeto, FACTURASCOMPRA.totdtocomercial FROM ALBCOMPRACAB LEFT OUTER JOIN FACTURASCOMPRA  ON ALBCOMPRACAB.numseriefac=FACTURASCOMPRA.numSerie and ALBCOMPRACAB.numFac=FACTURASCOMPRA.numFactura and ALBCOMPRACAB.nfac=FACTURASCOMPRA.n  left outer join ALBCOMPRALIN  ON ALBCOMPRALIN.numSerie=ALBCOMPRACAB.numSerie and ALBCOMPRALIN.numAlbaran=ALBCOMPRACAB.numAlbaran and ALBCOMPRALIN.n=ALBCOMPRACAB.n  where ALBCOMPRACAB.FACTURADO='T' AND facturasCompra.fecha>=?m.desde AND facturasCompra.fecha<=?m.hasta
 CREATE SQL VIEW VistaDescuentosCompras REMOTE CONNECTION ConexionICG AS select albcompracab.numserie, numalbaran, albcompracab.n, coddto, tipo, dtocargo, importe, sufactura, FACTURASCOMPRA.fecha, esdevolucion, base  from albcompradtos left outer join albcompracab  on albcompracab.numserie = albcompradtos.numserie AND albcompracab.numAlbaran = albcompradtos.numero AND albcompracab.N = albcompradtos.n  LEFT OUTER JOIN FACTURASCOMPRA  ON albcompracab.numseriefac=FACTURASCOMPRA.numSerie and albcompracab.numfac=FACTURASCOMPRA.numFactura and albcompracab.nFac=FACTURASCOMPRA.n  where fecha>=?m.desde AND fecha<=?m.hasta
 
**
