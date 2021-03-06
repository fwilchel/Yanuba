/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [IDTARJETA]
      ,[IDFRONT]
      ,[PUNTOSACUMULADOS]
      ,[CONSACUMULADAS]
      ,[IMPORTEACUMULADO]
      ,[TICKETSACUMULADOS]
  FROM [Yanuba].[dbo].[TARJETASCONTPROMOCIONES]
  
  select distinct idtarjeta from [TARJETASCONTPROMOCIONES]
  select distinct idtarjeta from [EXTRACTOPROMOCIONESTARJETA]
  
  select q1.*, q2.* from (select distinct idtarjeta as tarjeta from [TARJETASCONTPROMOCIONES]) as q1 full outer join
  (select distinct idtarjeta as tarjeta_extracto from [EXTRACTOPROMOCIONESTARJETA]) as q2 on q1.tarjeta=q2.tarjeta_extracto where TARJETA is null or tarjeta_extracto is null
  
  select idtarjeta, SUM(puntosAcumulados) from [TARJETASCONTPROMOCIONES] group by idtarjeta order by idtarjeta
  select idtarjeta, SUM(puntos) from [EXTRACTOPROMOCIONESTARJETA] group by idtarjeta order by idtarjeta
  
  
 select q1.*, q2.* from (select idtarjeta, SUM(puntosAcumulados) as puntosA from [TARJETASCONTPROMOCIONES] group by idtarjeta) as q1
   full outer join (select idtarjeta, SUM(puntos) as puntosB from [EXTRACTOPROMOCIONESTARJETA] group by idtarjeta  ) q2 on q1.IDTARJETA=q2.IDTARJETA where puntosA<>PuntosB or puntosA is null or PuntosB is null 
  
  
  order by idtarjeta
  select idtarjeta, SUM(puntos) from [EXTRACTOPROMOCIONESTARJETA] group by idtarjeta order by idtarjeta
  
  
  --- CONSULTA PARA VER PUNTOS A VENCER
  select idtarjeta, sum(puntos) as totales, SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end) as vencer 
  from EXTRACTOPROMOCIONESTARJETA group by idtarjeta 
  having SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end)>0
  order by vencer
  
  select * FROM [EXTRACTOPROMOCIONESTARJETA] where idtarjeta=41787174
  
  --- ELIMINAR LO INSERTADO EN EXTRACTO
  DELETE FROM [EXTRACTOPROMOCIONESTARJETA] where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103)
  
  --- INSERTAR EN EXTRACTO
  INSERT INTO [EXTRACTOPROMOCIONESTARJETA] (IDTARJETA, FECHA, TIPO, CODIGO, DESCRIPCION, PUNTOS, CONSUMICIONES, IMPORTE, TICKETS, Z, N, ALIAS) 
  select idtarjeta, getDate(), 1, 0, 'PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103), -SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end)
  ,0,0,0,0, 'B', '' 
  from EXTRACTOPROMOCIONESTARJETA group by idtarjeta 
  having SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end)>0
  
  
  select CONVERT(nvarchar(30), GETDATE(), 103)
  
  select idtarjeta, COUNT(1) from [TARJETASCONTPROMOCIONES] group by idtarjeta
  
  --- TOTAL 3180
  --- ESTOS SON PARA ACTUALIZAR 3008
  select [EXTRACTOPROMOCIONESTARJETA].idtarjeta, puntos 
  from [EXTRACTOPROMOCIONESTARJETA] 
  inner join [TARJETASCONTPROMOCIONES] on [EXTRACTOPROMOCIONESTARJETA].IDTARJETA=[TARJETASCONTPROMOCIONES].idtarjeta
  where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103) and IDFRONT=0
  
  --- ESTOS SON PARA INSERTAR 172
  select [EXTRACTOPROMOCIONESTARJETA].idtarjeta, puntos 
  from [EXTRACTOPROMOCIONESTARJETA] 
  where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103) and IDTARJETA not in (select [EXTRACTOPROMOCIONESTARJETA].idtarjeta
  from [EXTRACTOPROMOCIONESTARJETA] 
  inner join [TARJETASCONTPROMOCIONES] on [EXTRACTOPROMOCIONESTARJETA].IDTARJETA=[TARJETASCONTPROMOCIONES].idtarjeta
  where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103) and IDFRONT=0)
  
  --- ACTUALIZACIONES
  
  
  ----INSERCIONES
  INSERT INTO [TARJETASCONTPROMOCIONES] (IDTARJETA, IDFRONT, PUNTOSACUMULADOS) 
  select [EXTRACTOPROMOCIONESTARJETA].idtarjeta, 0, puntos 
  from [EXTRACTOPROMOCIONESTARJETA] 
  where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103) and IDTARJETA not in (select [EXTRACTOPROMOCIONESTARJETA].idtarjeta
  from [EXTRACTOPROMOCIONESTARJETA] 
  inner join [TARJETASCONTPROMOCIONES] on [EXTRACTOPROMOCIONESTARJETA].IDTARJETA=[TARJETASCONTPROMOCIONES].idtarjeta
  where DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103) and IDFRONT=0)
  
  
  --- ACTUALIZAR LOS ACUMULADOS QUE YA EXISTEN, SINO INSERTA
  MERGE INTO [TARJETASCONTPROMOCIONES]
  USING (select [EXTRACTOPROMOCIONESTARJETA].idtarjeta, puntos 
  from [EXTRACTOPROMOCIONESTARJETA] WHERE idtarjeta>0 and DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103))
  AS PUNTOS
  ON PUNTOS.idtarjeta=[TARJETASCONTPROMOCIONES].idtarjeta and [TARJETASCONTPROMOCIONES].idfront=0
  WHEN MATCHED THEN
  UPDATE SET [TARJETASCONTPROMOCIONES].fgwl = [TARJETASCONTPROMOCIONES].puntosacumulados+puntos.puntos
  WHEN NOT MATCHED THEN
  INSERT (IDTARJETA, IDFRONT, fgwl)
  VALUES (PUNTOS.idtarjeta, 0, PUNTOS.PUNTOS);
  
  
  
  select puntosacumulados, fgwl from [TARJETASCONTPROMOCIONES]
  
  ----BORRAR NUEVOS REGISTROS EN ACUMULADOS
  
  select * from [TARJETASCONTPROMOCIONES] where fgwl is not null
  select * from [TARJETASCONTPROMOCIONES] where CONSACUMULADAS is null and IMPORTEACUMULADO is null and TICKETSACUMULADOS is null
  
  
  --- RESULTADO FINAL
  --- INSERTAR EN EXTRACTO
  INSERT INTO [EXTRACTOPROMOCIONESTARJETA] (IDTARJETA, FECHA, TIPO, CODIGO, DESCRIPCION, PUNTOS, CONSUMICIONES, IMPORTE, TICKETS, Z, N, ALIAS) 
  select idtarjeta, getDate(), 1, 0, 'PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103), -SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end)
  ,0,0,0,0, 'B', '' 
  from EXTRACTOPROMOCIONESTARJETA group by idtarjeta 
  having SUM(case when PUNTOS<0 then PUNTOS else case when FECHA<=DATEADD (year , -1 , GETDATE()) then PUNTOS else 0 end end)>0
  
  --- ACTUALIZAR LOS ACUMULADOS QUE YA EXISTEN, SINO INSERTA
  MERGE INTO [TARJETASCONTPROMOCIONES]
  USING (select [EXTRACTOPROMOCIONESTARJETA].idtarjeta, puntos 
  from [EXTRACTOPROMOCIONESTARJETA] WHERE idtarjeta>0 and DESCRIPCION='PUNTOS VENCIDOS '+CONVERT(nvarchar(30), GETDATE(), 103))
  AS PUNTOS
  ON PUNTOS.idtarjeta=[TARJETASCONTPROMOCIONES].idtarjeta and [TARJETASCONTPROMOCIONES].idfront=0
  WHEN MATCHED THEN
  UPDATE SET [TARJETASCONTPROMOCIONES].puntosacumulados = [TARJETASCONTPROMOCIONES].puntosacumulados+puntos.puntos
  WHEN NOT MATCHED THEN
  INSERT (IDTARJETA, IDFRONT, puntosacumulados)
  VALUES (PUNTOS.idtarjeta, 0, PUNTOS.PUNTOS);
  
  