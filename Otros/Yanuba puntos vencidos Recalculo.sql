select IDTARJETA, CAJA, SUM(puntos) 
from EXTRACTOPROMOCIONESTARJETA 
group by IDTARJETA, caja






select * from REM_FRONTS

select * from TARJETASCONTPROMOCIONES


select sq2.idtarjeta, SUM(puntos) as puntos, idfront from (
select sq1.*, isnull(REM_CAJASFRONT.idfront,0) as idfront from (select IDTARJETA, CAJA, SUM(puntos) as puntos
from EXTRACTOPROMOCIONESTARJETA 
group by IDTARJETA, caja) sq1 left outer join REM_CAJASFRONT on CAJA=REM_CAJASFRONT.CAJAMANAGER
) sq2 group by IDTARJETA, idfront

**** 
SIGUIENTE QUERY
[23:13, 29/12/2016] +57 300 2146240: Esta consulta tiene 6 columnas                        
[23:14, 29/12/2016] +57 300 2146240: Las 3 primeras muestran los datos de la tabla de acumulados por tarjeta y idfront                        
[23:14, 29/12/2016] +57 300 2146240: las 3 ultimas sería con los valores que quedarían al aplicar el recálculo



select tcp.idtarjeta, tcp.idfront, tcp.puntosacumulados, sq3.* from TARJETASCONTPROMOCIONES tcp
full outer join (select sq2.idtarjeta, SUM(puntos) as puntos, idfront from (
select sq1.*, isnull(REM_CAJASFRONT.idfront,0) as idfront from (select IDTARJETA, CAJA, SUM(puntos) as puntos
from EXTRACTOPROMOCIONESTARJETA 
group by IDTARJETA, caja) sq1 left outer join REM_CAJASFRONT on CAJA=REM_CAJASFRONT.CAJAMANAGER
) sq2 group by IDTARJETA, idfront) sq3 on tcp.idtarjeta=sq3.idtarjeta and tcp.IDFRONT = sq3.idfront
order by isnull(tcp.idtarjeta,sq3.idtarjeta), isnull(tcp.idfront, sq3.idfront)


***** 
LOS TRES SIGUIENTES QUERIES DEBEN SUMAR LO MISMO

select SUM(puntos) from EXTRACTOPROMOCIONESTARJETA where idtarjeta>0

select SUM(sq6.puntos) from (select tcp.idtarjeta as idtar, tcp.idfront as idf, tcp.puntosacumulados, sq3.* from TARJETASCONTPROMOCIONES tcp
full outer join (select sq2.idtarjeta, SUM(puntos) as puntos, idfront from (
select sq1.*, isnull(REM_CAJASFRONT.idfront,0) as idfront from (select IDTARJETA, CAJA, SUM(puntos) as puntos
from EXTRACTOPROMOCIONESTARJETA 
group by IDTARJETA, caja) sq1 left outer join REM_CAJASFRONT on CAJA=REM_CAJASFRONT.CAJAMANAGER
) sq2 group by IDTARJETA, idfront) sq3 on tcp.idtarjeta=sq3.idtarjeta and tcp.IDFRONT = sq3.idfront
) sq6 where idtarjeta>0


select SUM(puntosacumulados) from TARJETASCONTPROMOCIONES where idtarjeta>0

********************

update [TARJETASCONTPROMOCIONES] set PUNTOSACUMULADOS=0

  MERGE INTO [TARJETASCONTPROMOCIONES]
  USING (
  
  select sq2.idtarjeta, SUM(puntos) as puntos, idfront from (
select sq1.*, isnull(REM_CAJASFRONT.idfront,0) as idfront from (select IDTARJETA, CAJA, SUM(puntos) as puntos
from EXTRACTOPROMOCIONESTARJETA 
group by IDTARJETA, caja) sq1 left outer join REM_CAJASFRONT on CAJA=REM_CAJASFRONT.CAJAMANAGER
) sq2 where idtarjeta>0 group by IDTARJETA, idfront 
  
  )
  AS PUNTOS
  ON PUNTOS.idtarjeta=[TARJETASCONTPROMOCIONES].idtarjeta and [TARJETASCONTPROMOCIONES].idfront=puntos.idfront
  WHEN MATCHED THEN
  UPDATE SET [TARJETASCONTPROMOCIONES].puntosacumulados = puntos.puntos
  WHEN NOT MATCHED THEN
  INSERT (IDTARJETA, IDFRONT, puntosacumulados)
  VALUES (PUNTOS.idtarjeta, puntos.idfront, PUNTOS.PUNTOS);


