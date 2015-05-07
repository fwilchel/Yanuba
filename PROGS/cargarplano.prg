 CLOSE TABLE ALL
 USE config
 m.destino = destino
 USE
 USE plano EXCLUSIVE
 ZAP
 gnfieldcount = AFIELDS(arreglo)
 CLEAR
 f = FOPEN(ALLTRIM(m.destino)+"CGBATCH.DAT")
 m.tamrenglon = 1991
 renglon = FGETS(f, tamrenglon)
 DO WHILE LEN(m.renglon)>0
    m.acumulado = 1
    FOR ncount = 1 TO gnfieldcount
       m.campo = arreglo(ncount, 1)
       m.tamano = arreglo(ncount, 3)
       &campo=SUBSTR(renglon, acumulado, m.tamano)
       m.acumulado = m.acumulado+m.tamano
    ENDFOR
    INSERT INTO plano FROM MEMVAR
    WAIT WINDOW NOWAIT STR(RECCOUNT())
    renglon = FGETS(f, tamrenglon)
 ENDDO
 FCLOSE(f)
 BROWSE NOAPPEND NOEDIT NODELETE NORMAL
 USE
 RETURN
 
**
