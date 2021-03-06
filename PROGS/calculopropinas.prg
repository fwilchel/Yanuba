 SET SAFETY OFF







 use horas
 SET ORDER TO vendedor
 SET FILTER TO desde=m.desde .AND. hasta=m.hasta
 REPLACE rol WITH 0 ALL FOR desde=m.desde .AND. hasta=m.hasta
 SELECT 0
 USE vendedores
 SCAN FOR rol<>0 .AND. rol2=0 .AND. rol3=0
    m.codvendedor = id
    m.rol = rol
    SELECT horas
    REPLACE rol WITH m.rol ALL FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
    SELECT vendedores
 ENDSCAN
 SELECT vendedores
 SCAN FOR rol<>0 .AND. rol2<>0 .AND. rol3=0
    m.codvendedor = id
    m.rol1 = rol
    m.rol2 = rol2
    cual = 1
    SELECT horas
    SCAN FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
       DO CASE
          CASE cual=1
             REPLACE rol WITH m.rol1
          CASE cual=2
             REPLACE rol WITH m.rol2
          OTHERWISE
       ENDCASE
       cual = cual+1
       SCATTER MEMVAR
    ENDSCAN
    IF cual=2
       WAIT WINDOW "Falta un registro de hrs para el codvendedor "+ALLTRIM(STR(m.codvendedor))+" se corrige duplicando"
       m.rol = m.rol2
       INSERT INTO horas FROM MEMVAR
    ENDIF
    SELECT vendedores
 ENDSCAN
 SCAN FOR rol<>0 .AND. rol2<>0 .AND. rol3<>0
    m.codvendedor = id
    m.rol1 = rol
    m.rol2 = rol2
    m.rol3 = rol3
    cual = 1
    SELECT horas
    SCAN FOR m.codvendedor=codvendedor .AND. desde=m.desde .AND. hasta=m.hasta
       DO CASE
          CASE cual=1
             REPLACE rol WITH m.rol1
          CASE cual=2
             REPLACE rol WITH m.rol2
          CASE cual=3
             REPLACE rol WITH m.rol3
          OTHERWISE
       ENDCASE
       cual = cual+1
       SCATTER MEMVAR
    ENDSCAN
    IF cual=2
       WAIT WINDOW "Falta un registro de hrs para el codvendedor "+ALLTRIM(STR(m.codvendedor))+" se corrige duplicando"
       m.rol = m.rol2
       INSERT INTO horas FROM MEMVAR
       m.rol = m.rol3
       INSERT INTO horas FROM MEMVAR
    ENDIF
    IF cual=3
       m.rol = m.rol3
       INSERT INTO horas FROM MEMVAR
    ENDIF
    SELECT vendedores
 ENDSCAN
 SELECT horas
 REPLACE rol WITH IIF(codalmacen='A1', 29, 22) FOR rol=0 .AND. cedula<2000 .AND. desde=m.desde .AND. hasta=m.hasta
SELECT vendedores
USE









 CLOSE TABLE ALL
 todos = .T.
 
 
 && Consulta de las propinas recibidas, por vendedor y almacen del vendedor y de la propina, y se quita el 4/1000
 USE vistapropinas2
 SELECT 0
 USE vistaVendedores
 SELECT 0
 USE vendedores

 SELECT SUBSTR(caja, 1, 2) AS caja, vp2.codvendedor, vv.nomvendedor, v.codalmacen, SUM(propina), SUM(propina-propina*4/1000) AS propina_4_mil ;
 FROM vistapropinas2 AS vp2 LEFT JOIN vistavendedores AS vv ON vp2.codvendedor=vv.codvendedor LEFT JOIN vendedores AS v ON vp2.codvendedor=v.id ;
 GROUP BY 1,2,3,4 ORDER BY 1, 3 INTO CURSOR ps

  
 
 && Propinas de otras calles. caja<>codalmacen
 
 SELECT caja, codalmacen, SUM(sum_propina), SUM(propina_4_mil) AS propina4mil ;
 FROM ps WHERE caja<>codalmacen AND propina_4_mil<>0 ;
 GROUP BY 1, 2 INTO CURSOR otrascalles
 
 
 && Lo que hay que sumar y restar de otras calles
 SELECT ALLTRIM(caja) AS codalmacen, 00000000000000.00  AS mas, SUM(propina4mil*.4) AS menos;
  FROM otrascalles GROUP BY caja ;
  UNION ALL ;
 SELECT ALLTRIM(codalmacen), SUM(propina4mil*.4), 000000000000000.00 ;
  FROM Otrascalles GROUP BY codalmacen INTO CURSOR otrascalles2
  
  
  && Lo mismo anterior pero en un solo registro
 SELECT codalmacen, SUM(mas) AS mas, SUM(menos) AS menos;
  FROM otrascalles2 GROUP BY 1 INTO CURSOR otrascalles3
 
 
 && Lo que queda de propinas en cada almac�n luego de quitar 4/100 y sumando y restando de otras calles
 SELECT caja, SUM(sum_propina), SUM(propina_4_mil) AS propina4mil, mas, menos;
  FROM ps LEFT JOIN otrascalles3 AS oc ON ALLTRIM(ps.caja)=ALLTRIM(oc.codalmacen) ;
   GROUP BY 1 INTO CURSOR propinasPoralmacen
   
   
 BROWSE NOAPPEND NODELETE NORMAL
 COPY TO paso0.xls TYPE XLS
 
 
 && Cargar las horas trabajadas, el rol, y nombre
 SELECT * FROM horas AS h1 WHERE h1.desde=m.desde AND h1.hasta=m.hasta;
  INTO CURSOR horasC

  
  
  && Vendedor, almacen base, rol, y horas
  
  &&   AND h.codalmacen=v.codalmacen ; Para Rol 3
  
  
 SELECT v.id, IIF(ISNULL(v.nombre),SPACE(254), v.nombre) as nombre, v.rol AS codrol, r.rol AS nombrerol, v.codalmacen AS codalmacenbase, a.nombrealmacen AS nombrealmacenbase, vv.numssocial AS cedula, h.horas AS horas, h.codalmacen AS codalm, a2.nombrealmacen, cc;
  FROM vendedores AS v INNER JOIN vistavendedores AS vv ON v.id=vv.codvendedor INNER JOIN roles AS r ON v.rol=r.id INNER JOIN horasC AS h ON h.codvendedor=v.id AND h.rol=v.rol ;
  LEFT JOIN almacenes AS a ON v.codalmacen=a.codalmacen LEFT JOIN almacenes AS a2 ON h.codalmacen=a2.codalmacen ;
 UNION ALL;
 SELECT v.id, IIF(ISNULL(v.nombre),SPACE(254), v.nombre) as nombre, v.rol2 AS codrol, r.rol AS nombrerol, v.codalmacen AS codalmacenbase, a.nombrealmacen AS nombrealmacenbase, vv.numssocial AS cedula, h.horas AS horas, h.codalmacen AS codalm, a2.nombrealmacen, cc;
  FROM vendedores AS v INNER JOIN vistavendedores AS vv ON v.id=vv.codvendedor INNER JOIN roles AS r ON v.rol2=r.id INNER JOIN horasC AS h ON h.codvendedor=v.id AND h.rol=v.rol2 ;
  LEFT JOIN almacenes AS a ON v.codalmacen=a.codalmacen LEFT JOIN almacenes AS a2 ON h.codalmacen=a2.codalmacen;
 UNION ALL ;
 SELECT v.id, IIF(ISNULL(v.nombre),SPACE(254), v.nombre) as nombre, v.rol3 AS codrol, r.rol AS nombrerol, v.codalmacen AS codalmacenbase, a.nombrealmacen AS nombrealmacenbase, vv.numssocial AS cedula, h.horas AS horas, h.codalmacen AS codalm, a2.nombrealmacen, cc ;
  FROM vendedores AS v INNER JOIN vistavendedores AS vv ON v.id=vv.codvendedor INNER JOIN roles AS r ON v.rol3=r.id INNER JOIN horasC AS h ON h.codvendedor=v.id AND h.rol=v.rol3 ;
  LEFT JOIN almacenes AS a ON v.codalmacen=a.codalmacen LEFT JOIN almacenes AS a2 ON h.codalmacen=a2.codalmacen ;
 UNION ALL ;
 SELECT -cedula AS id, IIF(ISNULL(nombre),SPACE(100),nombre)+SPACE(154) AS nombre, horas.rol AS codrol, r.rol AS nombrerol, horas.codalmacen AS codalmacenbase, a.nombrealmacen AS nombrealmacenbase, ALLTRIM(STR(horas.cedula))+SPACE(8) AS cedula, horas.horas, horas.codalmacen AS codalm, a.nombrealmacen AS nombrealmacen, cc;
  FROM horas LEFT JOIN roles AS r ON horas.rol=r.id LEFT JOIN almacenes AS a ON horas.codalmacen=a.codalmacen;
  WHERE cedula<2000 ORDER BY 2 INTO CURSOR paso1previo

 && eliminaci�n de repetidos, Horas por empleado
 SELECT DISTINCT * FROM paso1previo INTO CURSOR paso1
 COPY TO paso1.xls TYPE XLS
 
 && Para Incentivo Mostrador, calculo de horas y conteo (N�mero de personas por rol)
 SELECT IIF(codrol=21, codalmacenbase, codalm) AS codalmacen, IIF(codrol=21, nombrealmacenbase, nombrealmacen) AS nombrealmacen, codrol, nombrerol, SUM(horas) AS horas, COUNT(1) AS cuantos;
  FROM paso1 GROUP BY 1, 2, 3, 4 INTO CURSOR paso2
  
 COPY TO paso2.xls TYPE XLS
 
 
&& IIF(p.rol=1 OR p.rol=2 OR p.rol=21 OR p.rol=27 OR p.rol=29, porcentaje, horas*porcentaje/240)*IIF(p.rol=1, propina4mil+mas-menos, propina4mil)/100/p2.horas AS valor_hora 
 && C�lculo de valor hora por almacen
 SELECT p.codalmacen, a.nombrealmacen, p.rol AS codrol, r.rol, porcentaje, p2.horas, ;
 IIF(p.rol=1 OR p.rol=2, porcentaje, IIF(p.rol=21 OR p.rol=27 OR p.rol=29, horas*100/(cuantos*240)*porcentaje/100, horas*porcentaje/240)) AS porcentaje2, ;
 porcentaje/horas * IIF(p.rol=1, propina4mil+mas-menos, propina4mil)/100 AS valor_hora, ;
 IIF(p.rol=1 OR p.rol=2 OR p.rol=21 OR p.rol=27 OR p.rol=29, porcentaje, horas*porcentaje/240)*IIF(p.rol=1, propina4mil+mas-menos, propina4mil)/100/p2.horas AS valor_hora2;
  FROM porcentajes AS p LEFT JOIN roles AS r ON r.id=p.rol LEFT JOIN almacenes AS a ON a.codalmacen=p.codalmacen ;
  LEFT JOIN paso2 AS p2 ON p2.codalmacen=p.codalmacen AND p2.codrol=p.rol;
   LEFT JOIN propinasPoralmacen AS ppa ON p.codalmacen=ppa.caja;
  WHERE horas>0 OR p.rol=2 ;
  GROUP BY p.codalmacen, p.rol;
  ORDER BY p.codalmacen, codrol;
  INTO CURSOR paso3
 
 
 COPY TO paso3.xls TYPE XLS
 BROWSE NOAPPEND NODELETE NORMAL TITLE 'Rec�lculo de porcentajes seg�n horas laboradas'
 SELECT paso2
 BROWSE NOAPPEND NODELETE NORMAL TITLE 'Horas y n�mero de personas por rol'
 SELECT paso1
 BROWSE NOAPPEND NODELETE NORMAL TITLE 'Horas por empleado'
 
 && Validaci�n porcentajes almacen
 SELECT codalmacen, nombrealmacen, SUM(porcentaje2) AS porcacum, 100-SUM(porcentaje2) AS restante FROM paso3 GROUP BY 1, 2 INTO CURSOR paso4
 BROWSE NOAPPEND NODELETE NORMAL TITLE 'Validaci�n porcentajes almacen'
 COPY TO paso4.xls TYPE XLS
 
 
 
 
 
 
 SELECT p1.codalm AS codalmacen, SUM(IIF(codrol=22 OR codrol=8, horas, horas/2)) AS sum_horas;
  FROM paso1 AS p1 WHERE (p1.codrol=22 OR p1.codrol=30 OR p1.codrol=8) AND codalmacenbase=codalm ;
   GROUP BY 1 INTO CURSOR personalBase
 
 SELECT pb.codalmacen, pb.sum_horas, pa.propina4mil, p4.restante, propina4mil*restante/100/sum_horas AS valor_hora;
  FROM personalbase AS pb LEFT JOIN propinasporalmacen AS pa ON pa.caja=pb.codalmacen LEFT JOIN paso4 AS p4 ON p4.codalmacen=pb.codalmacen;
   INTO CURSOR vlrHoraRol22
 COPY TO paso5.xls TYPE XLS
 
 
 SELECT paso3.*, IIF(codrol=22 OR codrol=8, 1, paso3.valor_hora/vlrhorarol22.valor_hora) AS factor;
  FROM paso3 LEFT JOIN vlrHoraRol22 ON paso3.codalmacen=vlrhorarol22.codalmacen;
   WHERE paso3.codalmacen='B1' AND vlrhorarol22.codalmacen='B1';
    INTO CURSOR factores
 COPY TO factores.xls TYPE XLS
 
 
 SELECT SUM(propina4mil*p.porcentaje/100) AS vlrplantapro;
  FROM propinasPoralmacen AS ppa LEFT JOIN porcentajes AS p ON ppa.caja=p.codalmacen;
   WHERE p.rol=2 INTO CURSOR vlrPlantaProduccion
   
 m.vlrplantaproduccion = vlrplantapro
 
 SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, p3.valor_hora, p1.horas*p3.valor_hora AS propina, factor;
  FROM paso1 AS p1 LEFT JOIN vlrHoraRol22 AS p3 ON p1.codalm=p3.codalmacen LEFT JOIN factores ON p1.codrol=factores.codrol;
   WHERE p1.codalm<>'B5' AND p1.codalmacenbase<>'B5' AND p1.codalm<>'B7' AND p1.codalmacenbase<>'B7' AND p1.codalm<>'B8' AND p1.codalmacenbase<>'B8' AND codalmacenbase<>codalm AND p1.codrol<>4 AND p1.codrol<>3 AND p1.codrol<>1 AND p1.codrol<>39 AND p1.codrol<>38 AND p1.codrol<>12 AND p1.codrol<>18;
    INTO CURSOR factores1

 COPY TO factores1.xls TYPE XLS
 
 
 SELECT codalm, SUM(horas*factor) AS nuevashoras ;
  FROM factores1 GROUP BY 1 INTO CURSOR factores2
 COPY TO factores2.xls TYPE XLS
 
 
 && Rol 18 corresponde Fines de semana, calculo del valor hora para los Fines semana que se trabajan en la B4 y B6. Personas que vienen de la B1
 SELECT codalmacen, propina4mil*porcentaje/100 AS valor, nuevashoras, propina4mil*porcentaje/100/nuevashoras AS valorhora;
  FROM propinasporalmacen AS ppa INNER JOIN porcentajes AS p ON p.codalmacen=ppa.caja INNER JOIN factores2 AS f ON f.codalm=ppa.caja;
   WHERE INLIST(codalmacen, 'B4', 'B6') AND rol=18 INTO CURSOR factores3
 COPY TO factores3.xls TYPE XLS
 
 && p1.codrol<>22 AND p1.codrol<>8 AND p1.codrol<>30 AND 
 &&
 
 SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, p3.valor_hora, p1.horas*p3.valor_hora AS propina, 1, cc;
  FROM paso1 AS p1 LEFT JOIN paso3 AS p3 ON p1.codalm=p3.codalmacen AND p1.codrol=p3.codrol;
   WHERE p1.codrol<>21 AND p1.codalm<>'B5' AND p1.codalm<>'B7' AND p1.codalm<>'B8' AND NOT ((p1.codalmacenbase<>'B5' OR p1.codalmacenbase<>'B7' OR p1.codalmacenbase<>'B8') AND codalmacenbase<>codalm AND p1.codrol<>4 AND p1.codrol<>12 AND p1.codrol<>3 AND p1.codrol<>1 AND p1.codrol<>39 AND p1.codrol<>18);
 UNION ALL;
   SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, p3.valor_hora, p1.horas*p3.valor_hora AS propina, 2, cc;
    FROM paso1 AS p1 LEFT JOIN paso3 AS p3 ON p1.codalmacenbase=p3.codalmacen AND p1.codrol=p3.codrol;
     WHERE p1.codrol=21 AND p1.codalm<>'B5' AND p1.codalm<>'B7' AND p1.codalm<>'B8' ;
 UNION ALL;
  SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, IIF(ISNULL(p1.horas*factores.factor),0,p1.horas*factores.factor) AS horas, p3.valorhora, p1.horas*factores.factor*p3.valorhora AS propina, 3, cc ;
  FROM paso1 AS p1 LEFT JOIN factores3 AS p3 ON p1.codalm=p3.codalmacen LEFT JOIN factores ON p1.codrol=factores.codrol ;
  WHERE p1.codalm<>'B5' AND p1.codalmacenbase<>'B5' AND p1.codalm<>'B7' AND p1.codalmacenbase<>'B7' AND p1.codalm<>'B8' AND p1.codalmacenbase<>'B8' AND codalmacenbase<>codalm AND p1.codrol<>4 AND p1.codrol<>12 AND p1.codrol<>3 AND p1.codrol<>1 AND p1.codrol<>39 AND p1.codrol<>18 AND p1.codrol<>0 AND IIF(ISNULL(p1.horas*factores.factor),0,p1.horas*factores.factor)<>0;
 UNION ALL ;
 SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, m.vlrplantaproduccion*p3.porcentaje/100/p2.horas, m.vlrplantaproduccion*p3.porcentaje/100/p2.horas*p1.horas, 4,cc ;
 FROM paso1 AS p1 LEFT JOIN paso3 AS p3 ON p1.codalm=p3.codalmacen AND p1.codrol=p3.codrol LEFT JOIN paso2 AS p2 ON p2.codalmacen=p1.codalm AND p2.codrol=p1.codrol ;
 WHERE (p3.codalmacen='B5' AND p1.codalm='B5') OR (p3.codalmacen='B7' AND p1.codalm='B7') OR (p3.codalmacen='B8' AND p1.codalm='B8') ORDER BY 5, 2 INTO CURSOR planilla

*!*	  SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, p3.valor_hora, p1.horas*p3.valor_hora AS propina ;
*!*	  FROM paso1 AS p1 LEFT JOIN vlrHoraRol22 AS p3 ON p1.codalm=p3.codalmacen ;
*!*	  WHERE (p1.codrol=22 OR p1.codrol=8) AND p1.codalm<>'B7' AND  NOT (p1.codalmacenbase<>'B7' AND codalmacenbase<>codalm AND p1.codrol<>4 AND p1.codrol<>3 AND p1.codrol<>1);
*!*	 UNION ALL;
*!*	  SELECT p1.cedula, p1.nombre, p1.codrol, p1.nombrerol, p1.codalmacenbase, p1.nombrealmacenbase, p1.codalm, p1.nombrealmacen, p1.horas, p3.valor_hora/2, p1.horas*p3.valor_hora/2 AS propina ;
*!*	  FROM paso1 AS p1 LEFT JOIN vlrHoraRol22 AS p3 ON p1.codalm=p3.codalmacen ;
*!*	  WHERE p1.codrol=30 AND p1.codalm<>'B7';
*!*	 UNION ALL;
&&
 
 SELECT planilla
 BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 
 COPY TO data\planilla
 
 
 CALCULATE SUM(propina) TO total1 
 COPY TO planilla.xls TYPE XLS
 SELECT propinasporalmacen
 CALCULATE SUM(propina4mil) TO total2 
 WAIT WINDOW "Recogido: "+TRANSFORM(m.total2, "99,999,999.99")+" Planilla: "+TRANSFORM(m.total1, "999,999,999.99")+" Diferencia: "+TRANSFORM(m.total2-m.total1, "999,999,999.99")
 
 SELECT codalmacenbase, nombre, SUM(propina) FROM planilla GROUP BY 1, 2 ORDER BY 1, 2 INTO CURSOR resumen
 COPY TO resumen.xls TYPE XLS
 
 
 DO generarPlanoPropinas
 
 &&CLOSE TABLE ALL
 RETURN
 
 
 
 
 
 
 SELECT vp.codvendedor, SUM(vp.propina) AS propina FROM vistapropinas2 AS vp INNER JOIN vistavendedores AS vv ON vp.codvendedor=vv.codvendedor WHERE SUBSTR(caja, 1, 2)<>vv.codalmacen GROUP BY 1 INTO CURSOR vpo
 SELECT LEFT(vv.nomvendedor, 50) AS vendedor, vv.codalmacen AS codalmacenbasevendedor, r.id, r.rol, p.porcentaje, SUM(vp.propina) AS propinatotal, SUM(IIF(vp.codvendedor=vv.codvendedor AND v.genera_propina, vp.propina, 00000000000000000.00 )) AS propinavendedor, vpo.propina AS propinavendedorotros, h.horas, SUM(IIF(vp.codvendedor=vv.codvendedor AND  NOT v.genera_propina, vp.propina, 00000000000000000.00 )) AS propinasparamundo FROM vistavendedores AS vv LEFT JOIN Vendedores AS v ON vv.codvendedor=v.id LEFT JOIN roles AS r ON v.rol=r.id LEFT JOIN porcentajes AS p ON ALLTRIM(p.codalmacen)==ALLTRIM(vv.codalmacen) AND p.rol=v.rol LEFT JOIN vistaPropinas2 AS vp ON SUBSTR(caja, 1, 2)=vv.codalmacen LEFT JOIN vpo ON vpo.codvendedor=vv.codvendedor LEFT JOIN horas AS h ON h.codvendedor=vv.codvendedor WHERE vv.descatalogado='F' AND h.desde=m.desde AND h.hasta=m.hasta AND vv.codvendedor<>197 GROUP BY 1, 2, 3, 4, 5 UNION ALL SELECT LEFT(vv.nomvendedor, 50) AS vendedor, SUBSTR(vp.caja, 1, 2) AS codalmacenbasevendedor, r.id, r.rol, 000.00  AS porcentaje, SUM(vp.propina) AS propinatotal, SUM(IIF(vp.codvendedor=vv.codvendedor, vp.propina, 00000000000000000.00 )) AS propinavendedor, 00000000000000000.00  AS propinavendedorotros, 240 AS horas, 00000000000000000.00  AS propinasparamundo FROM vistaPropinas2 AS vp LEFT JOIN vistavendedores AS vv ON 1=1 LEFT JOIN roles AS r ON 1=1 WHERE vv.codvendedor=197 AND r.id=1 GROUP BY 1, 2, 3, 4, 5 ORDER BY 2, 1 INTO CURSOR p1
 SELECT p1.*, porcentaje*propinavendedor/100 AS propina1, porcentaje*propinavendedorotros/100 AS propina2, IIF(id<>1, porcentaje*propinatotal/100, 0000000000000.00 ) AS basepropina3, IIF(id<>1, porcentaje*propinatotal*horas/24000, 0000000000000.00 ) AS propina3 FROM p1 ORDER BY 2, 1 INTO CURSOR p2
 BROWSE NORMAL
 SELECT vv.codvendedor AS codvendedor2, vv.nomvendedor AS nombre, vv.codalmacen AS codalmacenbasevendedor, r.id, r.rol, p.porcentaje, SUM(vp.propina) AS propinatotal FROM vistavendedores AS vv LEFT JOIN Vendedores AS v ON vv.codvendedor=v.id INNER JOIN roles AS r ON v.rol=r.id LEFT JOIN porcentajes AS p ON ALLTRIM(p.codalmacen)==ALLTRIM(vv.codalmacen) AND p.rol=v.rol LEFT JOIN vistaPropinas2 AS vp ON SUBSTR(vp.caja, 1, 2)=vv.codalmacen WHERE vv.descatalogado='F' AND vv.codvendedor<>197 GROUP BY 1, 2, 3, 4, 5, 6 UNION ALL SELECT vv.codvendedor AS codvendedor2, vv.nomvendedor AS nombre, vv.codalmacen AS codalmacenbasevendedor, r.id, r.rol, p.porcentaje, SUM(vp.propina) AS propinatotal FROM vistavendedores AS vv LEFT JOIN Vendedores AS v ON vv.codvendedor=v.id INNER JOIN roles AS r ON v.rol2=r.id LEFT JOIN porcentajes AS p ON ALLTRIM(p.codalmacen)==ALLTRIM(vv.codalmacen) AND p.rol=v.rol2 LEFT JOIN vistaPropinas2 AS vp ON SUBSTR(vp.caja, 1, 2)=vv.codalmacen WHERE vv.descatalogado='F' AND vv.codvendedor<>197 GROUP BY 1, 2, 3, 4, 5, 6 ORDER BY codalmacenbasevendedor, codvendedor2 INTO CURSOR sq1
 SELECT sq1.codalmacenbasevendedor, sq1.id, sq1.rol, sq1.porcentaje, sq1.propinatotal, COUNT(1) AS cuantos, SUM(h.horas) AS horas, sq1.propinatotal*sq1.porcentaje/(100*SUM(h.horas)) AS valor_hora_con_sobrante, (sq1.propinatotal*sq1.porcentaje/(24000*COUNT(1))) AS valor_hora, sq1.porcentaje*sq1.propinatotal/100-(sq1.propinatotal*sq1.porcentaje/(24000*COUNT(1)))*SUM(h.horas) AS sobrante FROM sq1 LEFT JOIN horas AS h ON h.codvendedor=sq1.codvendedor WHERE h.desde=m.desde AND h.hasta=m.hasta GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3 INTO CURSOR sueldosHoras
 RETURN
 SELECT a.nombrealmacen FROM almacenes AS a WHERE a.destino=1 INTO CURSOR a1
 SELECT LEFT(vv.nomvendedor, 100) AS nomvendedor, vv.codalmacen AS codalmacenvendedor, LEFT(vp.caja, 2) AS codalmacenventa, p.rol, p.porcentaje, SUM(propina) AS propinas FROM vistaVendedores AS vv LEFT JOIN VistaPropinas2 AS vp ON vv.codvendedor=vp.codvendedor LEFT JOIN vendedores AS v ON vv.codvendedor=v.id INNER JOIN porcentajes AS p ON p.codalmacen=vv.codalmacen WHERE vv.activo='T' AND (vv.codalmacen='B1' OR todos) AND p.porcentaje<>0 GROUP BY vv.codvendedor, vv.codalmacen, p.rol, p.porcentaje, caja HAVING propinas<>0 INTO CURSOR parte1
 SELECT nomvendedor, codalmacenvendedor, codalmacenventa, p1.rol, r.rol, porcentaje, propinas, porcentaje*propinas/100 FROM parte1 AS p1 LEFT JOIN roles AS r ON p1.rol=r.id ORDER BY codalmacenvendedor, nomvendedor, p1.rol INTO CURSOR parte2
 BROWSE
 
**
