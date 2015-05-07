*** 
*** ReFox XII  #CO125117  Fredy Wilches  Soft Studio Ltda [VFP90]
***
 SET DELETED ON
 SET CENTURY ON
 SET DATE TO dmy
 SET EXCLUSIVE OFF
 SET PATH TO DATA\, progs\
 SET TALK OFF
 OPEN DATABASE data\interfaz
 IF TYPE('goApp.Class')="C" .AND. UPPER(goapp.class)==UPPER("app_application")
    MESSAGEBOX("La aplicación ya está en ejecución.", 48, goapp.ccaption)
    IF VARTYPE(goapp.oframe)="O"
       goapp.oframe.show()
    ENDIF
    RETURN
 ENDIF
 RELEASE goapp
 PUBLIC goapp
 LOCAL lclastsettalk, llappran, lnseconds, losplash
 LOCAL lacheck[1]
 lclastsettalk = SET("TALK")
 losplash = .NULL.
 SET TALK OFF
 IF  .NOT. EMPTY("app_splash")
    losplash = NEWOBJECT("app_splash", "INTERFAZ2_APP.VCX")
    IF VARTYPE(losplash)="O"
       lnseconds = SECONDS()
       losplash.show()
    ENDIF
 ENDIF
 goapp = NEWOBJECT("app_application", "INTERFAZ2_APP.VCX")
 IF VARTYPE(goapp)="O" .AND. ACLASS(lacheck, goapp)>0 .AND. ASCAN(lacheck, UPPER("_application"))>0
    goapp.creference = 'goApp'
    goapp.cformmediatorname = "app_mediator"
    IF VARTYPE(losplash)="O"
       IF SECONDS()<lnseconds+3
          = INKEY(3-(SECONDS()-lnseconds), "MH")
       ENDIF
       losplash.release()
       losplash = .NULL.
    ENDIF
    RELEASE lacheck, losplash, lnseconds
    application.visible = .T.
    SET ESCAPE OFF
    DO FORM fondo
    IF  .NOT. goapp.show()
       IF TYPE('goApp.Name')="C"
          MESSAGEBOX("No se puede ejecutar la aplicación.", 16, goapp.ccaption)
          goapp.release()
       ELSE
          MESSAGEBOX("No se puede ejecutar la aplicación.", 16)
       ENDIF
    ELSE
       llappran = .T.
    ENDIF
    IF TYPE('goApp.lReadEvents')="L"
       IF goapp.lreadevents
          goapp.release()
       ENDIF
    ELSE
       RELEASE goapp
    ENDIF
 ELSE
    MESSAGEBOX("Esta aplicación debe crear una instancia "+CHR(13)+"de un objeto que desciende de "+"_application"+".", 16)
    RELEASE goapp
 ENDIF
 IF lclastsettalk=="ON"
    SET TALK ON
 ELSE
    SET TALK OFF
 ENDIF
 IF TYPE('goApp')="O"
    RETURN goapp
 ELSE
    RETURN llappran
 ENDIF
 
**
*** 
*** ReFox - todo no se pierde 
***
