 * ER/Studio 8.0 SQL Code Generation
 * Company :      FI-UNAM
 * Project :      ECOBICI_RELACIONAL.DM1
 * Author :       CesarSL
 *
 * Date Created : Saturday, May 16, 2026 20:40:42
 * Target DBMS : Microsoft SQL Server 2008
 */
/* 
 * TABLE: ESTADO_CIVIL 
 */
CREATE TABLE ESTADO_CIVIL(
    id_estadoCivil    int            NOT NULL,
    estado_civil    varchar(15)    NOT NULL,
    vigente           bit            NOT NULL,
    CONSTRAINT PK32 PRIMARY KEY NONCLUSTERED (id_estadoCivil)
)
go
IF OBJECT_ID('ESTADO_CIVIL') IS NOT NULL
    PRINT '<<< CREATED TABLE ESTADO_CIVIL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ESTADO_CIVIL >>>'
go

/* 
 * TABLE: EMPLEADO 
 */
CREATE TABLE EMPLEADO(
    id_empleado         int               NOT NULL,
    tipo_empleado       char(1)           NOT NULL,
    genero              char(1)           NOT NULL,
    sueldo              money             NOT NULL,
    fecha_nacimiento    date              NOT NULL,
    telefono            numeric(10, 0)    NOT NULL,
    RFC                 char(13)          NOT NULL,
    nombre_pila         varchar(30)       NOT NULL,
    ap_paterno         varchar(30)       NOT NULL,
    ap_materno         varchar(30)       NULL,
    id_estadoCivil      int               NOT NULL,
    CONSTRAINT PK13 PRIMARY KEY NONCLUSTERED (id_empleado), 
    CONSTRAINT RefESTADO_CIVIL62 FOREIGN KEY (id_estadoCivil)
    REFERENCES ESTADO_CIVIL(id_estadoCivil), 
    CONSTRAINT UQ_EMPLEADO_RFC UNIQUE (RFC), 
    CONSTRAINT CK_EMPLEADO_GENERO CHECK (genero IN ('M', 'F')), 
    CONSTRAINT CK_EMPLEADO_SUELDO CHECK (sueldo > 0)
)
go
IF OBJECT_ID('EMPLEADO') IS NOT NULL
    PRINT '<<< CREATED TABLE EMPLEADO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE EMPLEADO >>>'
go

/* 
 * TABLE: ADMINISTRACION 
 */
CREATE TABLE ADMINISTRACION(
    id_empleado          int            NOT NULL,
    profesion            varchar(30)    NOT NULL,
    ubicacion_trabajo    varchar(40)    NOT NULL,
    CONSTRAINT PK16 PRIMARY KEY NONCLUSTERED (id_empleado), 
    CONSTRAINT RefEMPLEADO8 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado)
)
go
IF OBJECT_ID('ADMINISTRACION') IS NOT NULL
    PRINT '<<< CREATED TABLE ADMINISTRACION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ADMINISTRACION >>>'
go

/* 
 * TABLE: AGENTE 
 */
CREATE TABLE AGENTE(
    id_empleado          int            NOT NULL,
    zona_asignada        varchar(30)    NOT NULL,
    vehiculo_asignado    varchar(20)    NOT NULL,
    CONSTRAINT PK14 PRIMARY KEY NONCLUSTERED (id_empleado), 
    CONSTRAINT RefEMPLEADO12 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado)
)
go
IF OBJECT_ID('AGENTE') IS NOT NULL
    PRINT '<<< CREATED TABLE AGENTE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE AGENTE >>>'
go

/* 
 * TABLE: ALCALDIA 
 */
CREATE TABLE ALCALDIA(
    id_alcaldia    int            NOT NULL,
    alcaldia       varchar(22)    NOT NULL,
    CONSTRAINT PK31 PRIMARY KEY NONCLUSTERED (id_alcaldia)
)
go
IF OBJECT_ID('ALCALDIA') IS NOT NULL
    PRINT '<<< CREATED TABLE ALCALDIA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ALCALDIA >>>'
go

/* 
 * TABLE: BICICLETA_COLOR 
 */
CREATE TABLE BICICLETA_COLOR(
    id_bicicletaColor    tinyint        NOT NULL,
    color                varchar(18)    NOT NULL,
    CONSTRAINT PK27 PRIMARY KEY NONCLUSTERED (id_bicicletaColor)
)
go
IF OBJECT_ID('BICICLETA_COLOR') IS NOT NULL
    PRINT '<<< CREATED TABLE BICICLETA_COLOR >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE BICICLETA_COLOR >>>'
go

/* 
 * TABLE: ESTADO_BICI 
 */
CREATE TABLE ESTADO_BICI(
    id_estado_bici    int             NOT NULL,
    descripcion       varchar(300)    NULL,
    nombre_estado     varchar(15)     NOT NULL,
    CONSTRAINT PK11 PRIMARY KEY NONCLUSTERED (id_estado_bici)
)
go
IF OBJECT_ID('ESTADO_BICI') IS NOT NULL
    PRINT '<<< CREATED TABLE ESTADO_BICI >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ESTADO_BICI >>>'
go

/* 
 * TABLE: RONDIN 
 */
CREATE TABLE RONDIN(
    id_empleado               int    NOT NULL,
    id_empleado_supervisor    int    NULL,
    CONSTRAINT PK15 PRIMARY KEY NONCLUSTERED (id_empleado), 
    CONSTRAINT RefRONDIN51 FOREIGN KEY (id_empleado_supervisor)
    REFERENCES RONDIN(id_empleado),
    CONSTRAINT RefEMPLEADO10 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado)
)
go
IF OBJECT_ID('RONDIN') IS NOT NULL
    PRINT '<<< CREATED TABLE RONDIN >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE RONDIN >>>'
go

/* 
 * TABLE: ESTACION 
 */
CREATE TABLE ESTACION(
    id_estacion               int            NOT NULL,
    terminales_disponibles    int            NOT NULL,
    terminales_totales        int            NOT NULL,
    nombre_estacion           varchar(20)    NOT NULL,
    id_empleado               int            NOT NULL,
    CONSTRAINT PK26 PRIMARY KEY NONCLUSTERED (id_estacion), 
    CONSTRAINT RefRONDIN52 FOREIGN KEY (id_empleado)
    REFERENCES RONDIN(id_empleado), 
    CONSTRAINT CK_ESTACION_TERMINALES CHECK (terminales_disponibles >= 0 AND terminales_totales >= 0 AND terminales_disponibles <= terminales_totales)
)
go
IF OBJECT_ID('ESTACION') IS NOT NULL
    PRINT '<<< CREATED TABLE ESTACION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ESTACION >>>'
go

/* 
 * TABLE: BICICLETA 
 */
CREATE TABLE BICICLETA(
    idBicicleta          int               NOT NULL,
    modelo               char(1)           NOT NULL,
    num_serie            numeric(10, 0)    NOT NULL,
    id_estado_bici       int               NOT NULL,
    id_estacion          int               NOT NULL,
    id_bicicletaColor    tinyint           NOT NULL,
    CONSTRAINT PK9 PRIMARY KEY NONCLUSTERED (idBicicleta), 
    CONSTRAINT RefBICICLETA_COLOR58 FOREIGN KEY (id_bicicletaColor)
    REFERENCES BICICLETA_COLOR(id_bicicletaColor),
    CONSTRAINT RefESTADO_BICI17 FOREIGN KEY (id_estado_bici)
    REFERENCES ESTADO_BICI(id_estado_bici),
    CONSTRAINT RefESTACION20 FOREIGN KEY (id_estacion)
    REFERENCES ESTACION(id_estacion), 
    CONSTRAINT UQ_BICICLETA_NUM_SERIE UNIQUE (num_serie), 
    CONSTRAINT CK_BICICLETA_MODELO CHECK (modelo IN ('G', 'M', 'C'))
)
go
IF OBJECT_ID('BICICLETA') IS NOT NULL
    PRINT '<<< CREATED TABLE BICICLETA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE BICICLETA >>>'
go

/* 
 * TABLE: CATALOGO_IDIOMAS 
 */
CREATE TABLE CATALOGO_IDIOMAS(
    id_idioma        int            NOT NULL,
    nombre_idioma    varchar(30)    NOT NULL,
    CONSTRAINT PK34 PRIMARY KEY NONCLUSTERED (id_idioma)
)
go
IF OBJECT_ID('CATALOGO_IDIOMAS') IS NOT NULL
    PRINT '<<< CREATED TABLE CATALOGO_IDIOMAS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CATALOGO_IDIOMAS >>>'
go

/* 
 * TABLE: COLONIA 
 */
CREATE TABLE COLONIA(
    id_colonia     int            NOT NULL,
    colonia        varchar(20)    NOT NULL,
    id_alcaldia    int            NOT NULL,
    CONSTRAINT PK30 PRIMARY KEY NONCLUSTERED (id_colonia), 
    CONSTRAINT RefALCALDIA59 FOREIGN KEY (id_alcaldia)
    REFERENCES ALCALDIA(id_alcaldia)
)
go
IF OBJECT_ID('COLONIA') IS NOT NULL
    PRINT '<<< CREATED TABLE COLONIA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE COLONIA >>>'
go

/* 
 * TABLE: DOMICILIO 
 */
CREATE TABLE DOMICILIO(
    id_empleado     int              NOT NULL,
    id_domicilio    int              NOT NULL,
    numero_ext      numeric(3, 0)    NOT NULL,
    numero_int      numeric(3, 0)    NULL,
    calle           varchar(30)      NOT NULL,
    id_colonia      int              NOT NULL,
    CONSTRAINT PK24 PRIMARY KEY NONCLUSTERED (id_empleado, id_domicilio), 
    CONSTRAINT RefCOLONIA61 FOREIGN KEY (id_colonia)
    REFERENCES COLONIA(id_colonia),
    CONSTRAINT RefEMPLEADO30 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado)
)
go
IF OBJECT_ID('DOMICILIO') IS NOT NULL
    PRINT '<<< CREATED TABLE DOMICILIO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE DOMICILIO >>>'
go

/* 
 * TABLE: USUARIO 
 */
CREATE TABLE USUARIO(
    id_usuario         int              NOT NULL,
    correo             varchar(30)      NOT NULL,
    nombre             varchar(40)      NOT NULL,
    ap_paterno         varchar(40)      NOT NULL,
    ap_materno         varchar(40)      NULL,
    codigoINE          char(18)         NOT NULL,
    fechaNacimiento    date             NOT NULL,
    genero             char(1)          NOT NULL,
    CONSTRAINT PK1 PRIMARY KEY NONCLUSTERED (id_usuario), 
    CONSTRAINT UQ_USUARIO_CORREO UNIQUE (correo), 
    CONSTRAINT UQ_USUARIO_CODIGOINE UNIQUE (codigoINE), 
    CONSTRAINT CK_USUARIO_GENERO CHECK (genero IN ('M', 'F'))
)
go
IF OBJECT_ID('USUARIO') IS NOT NULL
    PRINT '<<< CREATED TABLE USUARIO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE USUARIO >>>'
go

/* 
 * TABLE: TARJETA_MOVILIDAD 
 */
CREATE TABLE TARJETA_MOVILIDAD(
    idTarjetaMovilidad       int               NOT NULL,
    id_tarjeta_reposicion    int               NULL,
    id_usuario               int               NOT NULL,
    fechaBaja                date              NOT NULL,
    saldo                    money             NOT NULL,
    codigoQR                 varbinary(100)    NOT NULL,
    fechaEmision             date              NOT NULL,
    activa                   bit               NOT NULL,
    tipoEmision              varchar(20)       NOT NULL,
    CONSTRAINT PK3 PRIMARY KEY NONCLUSTERED (idTarjetaMovilidad), 
    CONSTRAINT RefUSUARIO3 FOREIGN KEY (id_usuario)
    REFERENCES USUARIO(id_usuario),
    CONSTRAINT RefTARJETA_MOVILIDAD56 FOREIGN KEY (id_tarjeta_reposicion)
    REFERENCES TARJETA_MOVILIDAD(idTarjetaMovilidad), 
    CONSTRAINT UQ_TARJETA_CODIGOQR UNIQUE (codigoQR), 
    CONSTRAINT CK_TARJETA_SALDO CHECK (saldo >= 0), 
    CONSTRAINT CK_TARJETA_TIPO_EMISION CHECK (tipoEmision IN ('Primera', 'Reposicion'))
)
go
IF OBJECT_ID('TARJETA_MOVILIDAD') IS NOT NULL
    PRINT '<<< CREATED TABLE TARJETA_MOVILIDAD >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TARJETA_MOVILIDAD >>>'
go

/* 
 * TABLE: VIAJE 
 */
CREATE TABLE VIAJE(
    idViaje               int              NOT NULL,
    costo                 money            NOT NULL,
    fecha                 date             NOT NULL,
    ruta                  varchar(60)      NOT NULL,
    hora_inicio           datetime         NOT NULL,
    hora_fin              datetime         NOT NULL,
    duracion              numeric(6, 0)    NOT NULL,
    num_referencia        varchar(20)      NOT NULL,
    idBicicleta           int              NOT NULL,
    id_estacion_inicio    int              NOT NULL,
    id_estacion_fin       int              NOT NULL,
    idTarjetaMovilidad    int              NOT NULL,
    CONSTRAINT PK7 PRIMARY KEY NONCLUSTERED (idViaje), 
    CONSTRAINT RefBICICLETA15 FOREIGN KEY (idBicicleta)
    REFERENCES BICICLETA(idBicicleta),
    CONSTRAINT RefESTACION16 FOREIGN KEY (id_estacion_inicio)
    REFERENCES ESTACION(id_estacion),
    CONSTRAINT RefESTACION18 FOREIGN KEY (id_estacion_fin)
    REFERENCES ESTACION(id_estacion),
    CONSTRAINT RefTARJETA_MOVILIDAD19 FOREIGN KEY (idTarjetaMovilidad)
    REFERENCES TARJETA_MOVILIDAD(idTarjetaMovilidad), 
    CONSTRAINT UQ_VIAJE_NUM_REFERENCIA UNIQUE (num_referencia), 
    CONSTRAINT CK_VIAJE_COSTO CHECK (costo >= 0), 
    CONSTRAINT CK_VIAJE_HORAS CHECK (hora_fin > hora_inicio)
)
go
IF OBJECT_ID('VIAJE') IS NOT NULL
    PRINT '<<< CREATED TABLE VIAJE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE VIAJE >>>'
go

/* 
 * TABLE: TIPO_INCIDENTE 
 */
CREATE TABLE TIPO_INCIDENTE(
    id_tipo_incidente    int            NOT NULL,
    nombre_incidente     varchar(30)    NOT NULL,
    descripcion          varchar(80)    NOT NULL,
    CONSTRAINT PK12 PRIMARY KEY NONCLUSTERED (id_tipo_incidente)
)
go
IF OBJECT_ID('TIPO_INCIDENTE') IS NOT NULL
    PRINT '<<< CREATED TABLE TIPO_INCIDENTE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TIPO_INCIDENTE >>>'
go

/* 
 * TABLE: INCIDENTE 
 */
CREATE TABLE INCIDENTE(
    id_incidente         int              NOT NULL,
    calle                varchar(30)      NOT NULL,
    numero               numeric(4, 0)    NOT NULL,
    codigo_postal        numeric(5, 0)    NOT NULL,
    fecha                date             NOT NULL,
    latitud              varchar(20)      NOT NULL,
    longitud             varchar(20)      NOT NULL,
    idViaje              int              NOT NULL,
    id_tipo_incidente    int              NOT NULL,
    id_empleado          int              NOT NULL,
    id_colonia           int              NOT NULL,
    CONSTRAINT PK8 PRIMARY KEY NONCLUSTERED (id_incidente), 
    CONSTRAINT RefCOLONIA60 FOREIGN KEY (id_colonia)
    REFERENCES COLONIA(id_colonia),
    CONSTRAINT RefVIAJE21 FOREIGN KEY (idViaje)
    REFERENCES VIAJE(idViaje),
    CONSTRAINT RefTIPO_INCIDENTE22 FOREIGN KEY (id_tipo_incidente)
    REFERENCES TIPO_INCIDENTE(id_tipo_incidente),
    CONSTRAINT RefAGENTE25 FOREIGN KEY (id_empleado)
    REFERENCES AGENTE(id_empleado)
)
go
IF OBJECT_ID('INCIDENTE') IS NOT NULL
    PRINT '<<< CREATED TABLE INCIDENTE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE INCIDENTE >>>'
go

/* 
 * TABLE: ENCUESTA 
 */
CREATE TABLE ENCUESTA(
    id_encuesta     int              NOT NULL,
    id_incidente    int              NOT NULL,
    puntuacion      numeric(2, 0)    NOT NULL,
    fecha           date             NOT NULL,
    comentario      varchar(120)     NOT NULL,
    CONSTRAINT PK10 PRIMARY KEY NONCLUSTERED (id_encuesta), 
    CONSTRAINT RefINCIDENTE23 FOREIGN KEY (id_incidente)
    REFERENCES INCIDENTE(id_incidente), 
    CONSTRAINT CK_ENCUESTA_PUNTUACION CHECK (puntuacion BETWEEN 1 AND 10)
)
go
IF OBJECT_ID('ENCUESTA') IS NOT NULL
    PRINT '<<< CREATED TABLE ENCUESTA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ENCUESTA >>>'
go

/* 
 * TABLE: ESPECIALIDAD 
 */
CREATE TABLE ESPECIALIDAD(
    id_especialidad    int            NOT NULL,
    especialidad       varchar(25)    NOT NULL,
    CONSTRAINT PK33 PRIMARY KEY NONCLUSTERED (id_especialidad)
)
go
IF OBJECT_ID('ESPECIALIDAD') IS NOT NULL
    PRINT '<<< CREATED TABLE ESPECIALIDAD >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ESPECIALIDAD >>>'
go

/* 
 * TABLE: MOTIVO 
 */
CREATE TABLE MOTIVO(
    id_motivo       int            NOT NULL,
    motivo_falta    varchar(30)    NOT NULL,
    CONSTRAINT PK19 PRIMARY KEY NONCLUSTERED (id_motivo)
)
go
IF OBJECT_ID('MOTIVO') IS NOT NULL
    PRINT '<<< CREATED TABLE MOTIVO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE MOTIVO >>>'
go

/* 
 * TABLE: FALTA 
 */
CREATE TABLE FALTA(
    id_empleado    int         NOT NULL,
    id_falta       smallint    IDENTITY(1,1),
    fecha          date        NOT NULL,
    id_motivo      int         NOT NULL,
    CONSTRAINT PK18 PRIMARY KEY NONCLUSTERED (id_empleado, id_falta), 
    CONSTRAINT RefEMPLEADO41 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT RefMOTIVO42 FOREIGN KEY (id_motivo)
    REFERENCES MOTIVO(id_motivo)
)
go
IF OBJECT_ID('FALTA') IS NOT NULL
    PRINT '<<< CREATED TABLE FALTA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE FALTA >>>'
go

/* 
 * TABLE: FUNCIONES 
 */
CREATE TABLE FUNCIONES(
    id_funciones      int            NOT NULL,
    id_empleado       int            NOT NULL,
    nombre_funcion    varchar(30)    NOT NULL,
    CONSTRAINT PK21 PRIMARY KEY NONCLUSTERED (id_funciones), 
    CONSTRAINT RefADMINISTRACION57 FOREIGN KEY (id_empleado)
    REFERENCES ADMINISTRACION(id_empleado)
)
go
IF OBJECT_ID('FUNCIONES') IS NOT NULL
    PRINT '<<< CREATED TABLE FUNCIONES >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE FUNCIONES >>>'
go

/* 
 * TABLE: IDIOMAS 
 */
CREATE TABLE IDIOMAS(
    id_empleado    int    NOT NULL,
    id_idioma      int    NOT NULL,
    CONSTRAINT PK23 PRIMARY KEY NONCLUSTERED (id_empleado, id_idioma), 
    CONSTRAINT RefEMPLEADO49 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT RefCATALOGO_IDIOMAS66 FOREIGN KEY (id_idioma)
    REFERENCES CATALOGO_IDIOMAS(id_idioma)
)
go
IF OBJECT_ID('IDIOMAS') IS NOT NULL
    PRINT '<<< CREATED TABLE IDIOMAS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE IDIOMAS >>>'
go

/* 
 * TABLE: MANTENIMIENTO 
 */
CREATE TABLE MANTENIMIENTO(
    id_empleado        int    NOT NULL,
    id_especialidad    int    NOT NULL,
    CONSTRAINT PK17 PRIMARY KEY NONCLUSTERED (id_empleado), 
    CONSTRAINT RefEMPLEADO11 FOREIGN KEY (id_empleado)
    REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT RefESPECIALIDAD65 FOREIGN KEY (id_especialidad)
    REFERENCES ESPECIALIDAD(id_especialidad)
)
go
IF OBJECT_ID('MANTENIMIENTO') IS NOT NULL
    PRINT '<<< CREATED TABLE MANTENIMIENTO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE MANTENIMIENTO >>>'
go

/* 
 * TABLE: METODO_PAGO 
 */
CREATE TABLE METODO_PAGO(
    idMetodoPago    int        NOT NULL,
    fechaExp        date       NOT NULL,
    fechaInicio     date       NOT NULL,
    tipoPago        char(1)    NOT NULL,
    CONSTRAINT PK4 PRIMARY KEY NONCLUSTERED (idMetodoPago), 
    CONSTRAINT CK_METODO_PAGO_TIPO CHECK (tipoPago IN ('T', 'P')), 
    CONSTRAINT CK_METODO_PAGO_FECHAS CHECK (fechaExp >= fechaInicio)
)
go
IF OBJECT_ID('METODO_PAGO') IS NOT NULL
    PRINT '<<< CREATED TABLE METODO_PAGO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE METODO_PAGO >>>'
go

/* 
 * TABLE: TEMPORADA 
 */
CREATE TABLE TEMPORADA(
    id_temporada    int            NOT NULL,
    nombre_temp     varchar(30)    NOT NULL,
    fecha_inicio    date           NOT NULL,
    fecha_fin       date           NOT NULL,
    CONSTRAINT PK22 PRIMARY KEY NONCLUSTERED (id_temporada), 
    CONSTRAINT CK_TEMPORADA_FECHAS CHECK (fecha_fin >= fecha_inicio)
)
go
IF OBJECT_ID('TEMPORADA') IS NOT NULL
    PRINT '<<< CREATED TABLE TEMPORADA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TEMPORADA >>>'
go

/* 
 * TABLE: REPORTE 
 */
CREATE TABLE REPORTE(
    id_reporte           int              NOT NULL,
    fecha                date             NOT NULL,
    descripcion          varchar(90)      NOT NULL,
    bandera_incidente    bit              NOT NULL,
    numero_incidentes    numeric(2, 0)    NOT NULL,
    id_empleado          int              NOT NULL,
    id_temporada         int              NOT NULL,
    CONSTRAINT PK20 PRIMARY KEY NONCLUSTERED (id_reporte), 
    CONSTRAINT RefRONDIN39 FOREIGN KEY (id_empleado)
    REFERENCES RONDIN(id_empleado),
    CONSTRAINT RefTEMPORADA40 FOREIGN KEY (id_temporada)
    REFERENCES TEMPORADA(id_temporada), 
    CONSTRAINT CK_REPORTE_NUM_INCIDENTES CHECK (numero_incidentes >= 0)
)
go
IF OBJECT_ID('REPORTE') IS NOT NULL
    PRINT '<<< CREATED TABLE REPORTE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE REPORTE >>>'
go

/* 
 * TABLE: TIPO_MEMBRESIA 
 */
CREATE TABLE TIPO_MEMBRESIA(
    idTipoMembresia    int               NOT NULL,
    descripcion        varchar(10)       NOT NULL,
    duracionDias       numeric(4, 0)     NOT NULL,
    tipoSeguro         char(1)           NOT NULL,
    tiempoExcedente     decimal(18, 0)    NOT NULL,
    costoBase          money             NOT NULL,
    tarifaExcedente     money             NOT NULL,
    tipoBeneficio      char(1)           NOT NULL,
    CONSTRAINT PK5 PRIMARY KEY NONCLUSTERED (idTipoMembresia), 
    CONSTRAINT CK_TIPO_MEMBRESIA_COSTO CHECK (costoBase >= 0 AND tarifaExcedente >= 0), 
    CONSTRAINT CK_TIPO_MEMBRESIA_DURACION CHECK (duracionDias > 0), 
    CONSTRAINT CK_TIPO_MEMBRESIA_EXCEDENTE CHECK (tiempoExcedente >= 0)
)
go
IF OBJECT_ID('TIPO_MEMBRESIA') IS NOT NULL
    PRINT '<<< CREATED TABLE TIPO_MEMBRESIA >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TIPO_MEMBRESIA >>>'
go

/* 
 * TABLE: SUSCRIPCION 
 */
CREATE TABLE SUSCRIPCION(
    idSuscripcion      int        NOT NULL,
    estado             char(1)    NOT NULL,
    fechaFin           date       NOT NULL,
    fechaInicio        date       NOT NULL,
    id_usuario         int        NOT NULL,
    idMetodoPago       int        NOT NULL,
    idTipoMembresia    int        NOT NULL,
    CONSTRAINT PK2 PRIMARY KEY NONCLUSTERED (idSuscripcion), 
    CONSTRAINT RefUSUARIO6 FOREIGN KEY (id_usuario)
    REFERENCES USUARIO(id_usuario),
    CONSTRAINT RefMETODO_PAGO13 FOREIGN KEY (idMetodoPago)
    REFERENCES METODO_PAGO(idMetodoPago),
    CONSTRAINT RefTIPO_MEMBRESIA14 FOREIGN KEY (idTipoMembresia)
    REFERENCES TIPO_MEMBRESIA(idTipoMembresia), 
    CONSTRAINT CK_SUSCRIPCION_ESTADO CHECK (estado IN ('A', 'C', 'V')), 
    CONSTRAINT CK_SUSCRIPCION_FECHAS CHECK (fechaFin >= fechaInicio)
)
go
IF OBJECT_ID('SUSCRIPCION') IS NOT NULL
    PRINT '<<< CREATED TABLE SUSCRIPCION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SUSCRIPCION >>>'
go

/* 
 * TABLE: TELEFONO 
 */
CREATE TABLE TELEFONO(
    idTelefono    int         NOT NULL,
    id_usuario    int         NOT NULL,
    telefono      char(10)    NOT NULL,
    CONSTRAINT PK6 PRIMARY KEY NONCLUSTERED (idTelefono), 
    CONSTRAINT RefUSUARIO54 FOREIGN KEY (id_usuario)
    REFERENCES USUARIO(id_usuario), 
    CONSTRAINT UQ_TELEFONO_TELEFONO UNIQUE (telefono)
)
go
IF OBJECT_ID('TELEFONO') IS NOT NULL
    PRINT '<<< CREATED TABLE TELEFONO >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TELEFONO >>>'
go
