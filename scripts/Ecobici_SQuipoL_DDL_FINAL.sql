
/*==============================================================*/
/* CREACION DE BASE DE DATOS                                    */
/*==============================================================*/

USE master;
GO

/*IF DB_ID('Ecobici_SQuipoL') IS NOT NULL
    DROP DATABASE Ecobici_SQuipoL;
GO*/

CREATE DATABASE Ecobici_SQuipoL;
GO

USE Ecobici_SQuipoL;
GO

/*==============================================================*/
/* CREACION DE ESQUEMAS                                         */
/*==============================================================*/

CREATE SCHEMA catalogo;
GO

CREATE SCHEMA personal;
GO

CREATE SCHEMA usuarios;
GO

CREATE SCHEMA movilidad;
GO

CREATE SCHEMA incidentes;
GO

CREATE SCHEMA reportes;
GO

/*==============================================================*/
/* ESQUEMA: catalogo                                            */
/*==============================================================*/

CREATE TABLE catalogo.ESTADO_CIVIL(
    id_estadoCivil INT PRIMARY KEY,
    estado_civil VARCHAR(15) NOT NULL,
    vigente BIT NOT NULL
);
GO

CREATE TABLE catalogo.ALCALDIA(
    id_alcaldia INT PRIMARY KEY,
    alcaldia VARCHAR(22) NOT NULL
);
GO

CREATE TABLE catalogo.BICICLETA_COLOR(
    id_bicicletaColor TINYINT PRIMARY KEY,
    color VARCHAR(18) NOT NULL
);
GO

CREATE TABLE catalogo.ESTADO_BICI(
    id_estado_bici INT PRIMARY KEY,
    descripcion VARCHAR(300),
    nombre_estado VARCHAR(15) NOT NULL
);
GO

CREATE TABLE catalogo.CATALOGO_IDIOMAS(
    id_idioma INT PRIMARY KEY,
    nombre_idioma VARCHAR(30) NOT NULL
);
GO

CREATE TABLE catalogo.ESPECIALIDAD(
    id_especialidad INT PRIMARY KEY,
    especialidad VARCHAR(25) NOT NULL
);
GO

CREATE TABLE catalogo.MOTIVO(
    id_motivo INT PRIMARY KEY,
    motivo_falta VARCHAR(30) NOT NULL
);
GO

CREATE TABLE catalogo.TIPO_INCIDENTE(
    id_tipo_incidente INT PRIMARY KEY,
    nombre_incidente VARCHAR(30) NOT NULL,
    descripcion VARCHAR(80) NOT NULL
);
GO

/*==============================================================*/
/* ESQUEMA: personal                                            */
/*==============================================================*/

CREATE TABLE personal.EMPLEADO(
    id_empleado INT PRIMARY KEY,
    tipo_empleado VARCHAR(2) NOT NULL,
    genero CHAR(1) NOT NULL,
    sueldo DECIMAL(12,2) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono NUMERIC(10,0) NOT NULL,
    RFC CHAR(13) NOT NULL,
    nombre_pila VARCHAR(30) NOT NULL,
    ap_paterno VARCHAR(30) NOT NULL,
    ap_materno VARCHAR(30),
    id_estadoCivil INT NOT NULL,

    CONSTRAINT FK_EMPLEADO_ESTADO_CIVIL
        FOREIGN KEY(id_estadoCivil)
        REFERENCES catalogo.ESTADO_CIVIL(id_estadoCivil),

    CONSTRAINT UQ_EMPLEADO_RFC UNIQUE(RFC),
    CONSTRAINT UQ_EMPLEADO_TELEFONO UNIQUE(telefono),

    CONSTRAINT CK_EMPLEADO_GENERO
        CHECK(genero IN ('M','F')),

    CONSTRAINT CK_EMPLEADO_SUELDO
        CHECK(sueldo > 0),

    CONSTRAINT CK_EMPLEADO_TIPO
        CHECK(tipo_empleado IN ('AD', 'AG','R','M'))
);
GO

CREATE TABLE personal.ADMINISTRACION(
    id_empleado INT PRIMARY KEY,
    profesion VARCHAR(30) NOT NULL,
    ubicacion_trabajo VARCHAR(40) NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado)
);
GO

CREATE TABLE personal.AGENTE(
    id_empleado INT PRIMARY KEY,
    zona_asignada VARCHAR(30) NOT NULL,
    vehiculo_asignado VARCHAR(20) NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado)
);
GO

CREATE TABLE personal.RONDIN(
    id_empleado INT PRIMARY KEY,
    id_empleado_supervisor INT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado),

    FOREIGN KEY(id_empleado_supervisor)
        REFERENCES personal.RONDIN(id_empleado)
);
GO

CREATE TABLE personal.MANTENIMIENTO(
    id_empleado INT PRIMARY KEY,
    id_especialidad INT NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado),

    FOREIGN KEY(id_especialidad)
        REFERENCES catalogo.ESPECIALIDAD(id_especialidad)
);
GO

CREATE TABLE personal.COLONIA(
    id_colonia INT PRIMARY KEY,
    colonia VARCHAR(20) NOT NULL,
    id_alcaldia INT NOT NULL,

    FOREIGN KEY(id_alcaldia)
        REFERENCES catalogo.ALCALDIA(id_alcaldia)
);
GO

CREATE TABLE personal.DOMICILIO(
    id_empleado INT NOT NULL,
    id_domicilio INT NOT NULL,
    numero_ext NUMERIC(3,0) NOT NULL,
    numero_int NUMERIC(3,0),
    calle VARCHAR(30) NOT NULL,
    id_colonia INT NOT NULL,

    PRIMARY KEY(id_empleado,id_domicilio),

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado),

    FOREIGN KEY(id_colonia)
        REFERENCES personal.COLONIA(id_colonia)
);
GO

CREATE TABLE personal.IDIOMAS(
    id_empleado INT NOT NULL,
    id_idioma INT NOT NULL,

    PRIMARY KEY(id_empleado,id_idioma),

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado),

    FOREIGN KEY(id_idioma)
        REFERENCES catalogo.CATALOGO_IDIOMAS(id_idioma)
);
GO

CREATE TABLE personal.FALTA(
    id_empleado INT NOT NULL,
    id_falta SMALLINT IDENTITY(1,1),
    fecha DATE NOT NULL,
    id_motivo INT NOT NULL,

    PRIMARY KEY(id_empleado,id_falta),

    FOREIGN KEY(id_empleado)
        REFERENCES personal.EMPLEADO(id_empleado),

    FOREIGN KEY(id_motivo)
        REFERENCES catalogo.MOTIVO(id_motivo)
);
GO

CREATE TABLE personal.FUNCIONES(
    id_funciones INT PRIMARY KEY,
    id_empleado INT NOT NULL,
    nombre_funcion VARCHAR(30) NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.ADMINISTRACION(id_empleado)
);
GO

/*==============================================================*/
/* ESQUEMA: usuarios                                            */
/*==============================================================*/

CREATE TABLE usuarios.USUARIO(
    id_usuario INT PRIMARY KEY,
    correo VARCHAR(30) NOT NULL,
    nombre VARCHAR(40) NOT NULL,
    ap_paterno VARCHAR(40) NOT NULL,
    ap_materno VARCHAR(40),
    codigo_INE CHAR(18) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,

    edad AS DATEDIFF(YEAR, fecha_Nacimiento, GETDATE()),

    CONSTRAINT UQ_USUARIO_CORREO UNIQUE(correo),
    CONSTRAINT UQ_USUARIO_CODIGOINE UNIQUE(codigo_INE),

    CONSTRAINT CK_USUARIO_GENERO
        CHECK(genero IN ('M','F')),

    CONSTRAINT CK_USUARIO_EDAD
        CHECK(DATEDIFF(YEAR, fecha_Nacimiento, GETDATE()) >= 16)
);
GO

CREATE TABLE usuarios.TELEFONO(
    id_telefono INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    telefono CHAR(10) NOT NULL,

    CONSTRAINT UQ_TELEFONO UNIQUE(telefono),

    FOREIGN KEY(id_usuario)
        REFERENCES usuarios.USUARIO(id_usuario)
);
GO

/*==============================================================*/
/* ESQUEMA: movilidad                                           */
/*==============================================================*/

CREATE TABLE movilidad.METODO_PAGO(
    id_metodoPago INT PRIMARY KEY,
    fecha_exp DATE NOT NULL,
    fecha_inicio DATE NOT NULL,
    tipo_pago CHAR(1) NOT NULL,

    CHECK(tipo_pago IN ('T','P')),
    CHECK(fecha_exp >= fecha_inicio)
);
GO

CREATE TABLE movilidad.TIPO_MEMBRESIA(
    idTipoMembresia INT PRIMARY KEY,
    descripcion VARCHAR(10) NOT NULL,
    duracionDias NUMERIC(4,0) NOT NULL,
    tipoSeguro CHAR(1) NOT NULL,
    tiempoExcedente DECIMAL(18,0) NOT NULL,
    costoBase DECIMAL(10,2) NOT NULL,
    tarifaExcedente DECIMAL(10,2) NOT NULL,
    tipoBeneficio CHAR(1) NOT NULL,

    CHECK(costoBase >= 0),
    CHECK(tarifaExcedente >= 0),
    CHECK(duracionDias > 0)
);
GO

CREATE TABLE movilidad.SUSCRIPCION(
    idSuscripcion INT PRIMARY KEY,
    estado CHAR(1) NOT NULL,
    fechaFin DATE NOT NULL,
    fechaInicio DATE NOT NULL,
    id_usuario INT NOT NULL,
    idMetodoPago INT NOT NULL,
    idTipoMembresia INT NOT NULL,

    FOREIGN KEY(id_usuario)
        REFERENCES usuarios.USUARIO(id_usuario),

    FOREIGN KEY(idMetodoPago)
        REFERENCES movilidad.METODO_PAGO(id_MetodoPago),

    FOREIGN KEY(idTipoMembresia)
        REFERENCES movilidad.TIPO_MEMBRESIA(idTipoMembresia),

    CHECK(estado IN ('A','C','V')),
    CHECK(fechaFin >= fechaInicio)
);
GO

CREATE TABLE movilidad.TARJETA_MOVILIDAD(
    idTarjetaMovilidad INT PRIMARY KEY,
    id_tarjeta_reposicion INT,
    id_usuario INT NOT NULL,
    fechaBaja DATE NOT NULL,
    saldo DECIMAL(10,2) NOT NULL,
    codigoQR VARBINARY(100) NOT NULL,
    fechaEmision DATE NOT NULL,
    activa BIT NOT NULL,
    tipoEmision VARCHAR(20) NOT NULL, 

    FOREIGN KEY(id_usuario)
        REFERENCES usuarios.USUARIO(id_usuario),

    FOREIGN KEY(id_tarjeta_reposicion)
        REFERENCES movilidad.TARJETA_MOVILIDAD(idTarjetaMovilidad),

    UNIQUE(codigoQR),

    CHECK(saldo >= 0),
    CHECK(tipoEmision IN ('Primera','Reposicion'))
);
GO

CREATE TABLE movilidad.ESTACION(
    id_estacion INT PRIMARY KEY,
    terminales_disponibles INT NOT NULL,
    terminales_totales INT NOT NULL,
    nombre_estacion VARCHAR(20) NOT NULL,
    id_empleado INT NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.RONDIN(id_empleado),

    CHECK(
        terminales_disponibles >= 0
        AND terminales_totales >= 0
        AND terminales_disponibles <= terminales_totales
    )
);
GO

CREATE TABLE movilidad.BICICLETA(
    idBicicleta INT PRIMARY KEY,
    modelo CHAR(1) NOT NULL,
    num_serie NUMERIC(10,0) NOT NULL,
    id_estado_bici INT NOT NULL,
    id_estacion INT NOT NULL,
    id_bicicletaColor TINYINT NOT NULL,

    FOREIGN KEY(id_estado_bici)
        REFERENCES catalogo.ESTADO_BICI(id_estado_bici),

    FOREIGN KEY(id_estacion)
        REFERENCES movilidad.ESTACION(id_estacion),

    FOREIGN KEY(id_bicicletaColor)
        REFERENCES catalogo.BICICLETA_COLOR(id_bicicletaColor),

    UNIQUE(num_serie),

    CHECK(modelo IN ('G','M','C'))
);
GO

CREATE TABLE movilidad.VIAJE(
    idViaje INT PRIMARY KEY,
    costo DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    ruta VARCHAR(60) NOT NULL,
    hora_inicio DATETIME2 NOT NULL,
    hora_fin DATETIME2 NOT NULL,
    duracion NUMERIC(6,0) NOT NULL,
    num_referencia VARCHAR(20) NOT NULL,
    idBicicleta INT NOT NULL,
    id_estacion_inicio INT NOT NULL,
    id_estacion_fin INT NOT NULL,
    idTarjetaMovilidad INT NOT NULL,

    FOREIGN KEY(idBicicleta)
        REFERENCES movilidad.BICICLETA(idBicicleta),

    FOREIGN KEY(id_estacion_inicio)
        REFERENCES movilidad.ESTACION(id_estacion),

    FOREIGN KEY(id_estacion_fin)
        REFERENCES movilidad.ESTACION(id_estacion),

    FOREIGN KEY(idTarjetaMovilidad)
        REFERENCES movilidad.TARJETA_MOVILIDAD(idTarjetaMovilidad),

    UNIQUE(num_referencia),

    CHECK(costo >= 0),
    CHECK(duracion > 0),
    CHECK(hora_fin > hora_inicio)
);
GO

/*==============================================================*/
/* ESQUEMA: incidentes                                          */
/*==============================================================*/

CREATE TABLE incidentes.INCIDENTE(
    id_incidente INT PRIMARY KEY,
    calle VARCHAR(30) NOT NULL,
    numero NUMERIC(4,0) NOT NULL,
    codigo_postal NUMERIC(5,0) NOT NULL,
    fecha DATE NOT NULL,
    latitud VARCHAR(20) NOT NULL,
    longitud VARCHAR(20) NOT NULL,
    idViaje INT NOT NULL,
    id_tipo_incidente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_colonia INT NOT NULL,

    FOREIGN KEY(idViaje)
        REFERENCES movilidad.VIAJE(idViaje),

    FOREIGN KEY(id_tipo_incidente)
        REFERENCES catalogo.TIPO_INCIDENTE(id_tipo_incidente),

    FOREIGN KEY(id_empleado)
        REFERENCES personal.AGENTE(id_empleado),

    FOREIGN KEY(id_colonia)
        REFERENCES personal.COLONIA(id_colonia)
);
GO

CREATE TABLE incidentes.ENCUESTA(
    id_encuesta INT PRIMARY KEY,
    id_incidente INT NOT NULL,
    puntuacion NUMERIC(2,0) NOT NULL,
    fecha DATE NOT NULL,
    comentario VARCHAR(120) NOT NULL,

    FOREIGN KEY(id_incidente)
        REFERENCES incidentes.INCIDENTE(id_incidente),

    CHECK(puntuacion BETWEEN 1 AND 10)
);
GO

/*==============================================================*/
/* ESQUEMA: reportes                                            */
/*==============================================================*/

CREATE TABLE reportes.TEMPORADA(
    id_temporada INT PRIMARY KEY,
    nombre_temp VARCHAR(30) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,

    CHECK(fecha_fin >= fecha_inicio)
);
GO

CREATE TABLE reportes.REPORTE(
    id_reporte INT PRIMARY KEY,
    fecha DATE NOT NULL,
    descripcion VARCHAR(90) NOT NULL,
    bandera_incidente BIT NOT NULL,
    numero_incidentes NUMERIC(2,0) NOT NULL,
    id_empleado INT NOT NULL,
    id_temporada INT NOT NULL,

    FOREIGN KEY(id_empleado)
        REFERENCES personal.RONDIN(id_empleado),

    FOREIGN KEY(id_temporada)
        REFERENCES reportes.TEMPORADA(id_temporada),

    CHECK(numero_incidentes >= 0)
);
GO

/*==============================================================*/
/* INDICES                                                      */
/*==============================================================*/

CREATE INDEX IDX_VIAJE_FECHA
ON movilidad.VIAJE(fecha);
GO

CREATE INDEX IDX_INCIDENTE_FECHA
ON incidentes.INCIDENTE(fecha);
GO

CREATE INDEX IDX_SUSCRIPCION_USUARIO
ON movilidad.SUSCRIPCION(id_usuario);
GO

/*==============================================================*/
/* VISTA                                                        */
/*==============================================================*/

CREATE VIEW movilidad.VW_VIAJE_TARIFA_ADICIONAL
AS
SELECT
    V.idViaje,

    CASE
        WHEN V.duracion > TM.tiempoExcedente
        THEN (V.duracion - TM.tiempoExcedente) * TM.tarifaExcedente
        ELSE 0
    END AS tarifaAdicional

FROM movilidad.VIAJE V
INNER JOIN movilidad.TARJETA_MOVILIDAD T
    ON V.idTarjetaMovilidad = T.idTarjetaMovilidad
INNER JOIN movilidad.SUSCRIPCION S
    ON T.id_usuario = S.id_usuario
INNER JOIN movilidad.TIPO_MEMBRESIA TM
    ON S.idTipoMembresia = TM.idTipoMembresia;
GO

PRINT 'BASE DE DATOS CON ESQUEMAS CREADA CORRECTAMENTE';
GO
