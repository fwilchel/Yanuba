 SELECT tipo_mov, nro_mov, fecha_mov, IIF(SUBSTR(valor_mov, 18, 1)='+', 1, -1)*VAL(SUBSTR(valor_mov, 1, 17))*IIF(dc_mov="D", 1, 0) AS debito, IIF(SUBSTR(valor_mov, 18, 1)='+', 1, -1)*VAL(SUBSTR(valor_mov, 1, 17))*IIF(dc_mov="C", 1, 0) AS credito FROM plano INTO CURSOR c1
 SELECT tipo_mov, nro_mov, fecha_mov, SUM(debito), SUM(credito), SUM(debito-credito) FROM c1 GROUP BY 1, 2, 3
 USE
 SELECT c1
 USE
 SELECT plano
 USE
 
**
