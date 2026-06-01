/*=========================================================
  PROYECTO : ECOBICI
  AUTORES  : Díaz Núñez David
             Hernández Acosta Mauricio Gabriel
             Sánchez Luján César Ricardo

  FECHA    : 01/06/2026
  VERSIÓN  : 1.0 FINAL

  DESCRIPCIÓN:
  Script de creación de la base de datos ECOBICI.
  Incluye la definición de tablas, claves primarias,
  claves foráneas, restricciones, valores por defecto
  y carga inicial de datos. El modelo relacional fue
  actualizado y validado para garantizar consistencia
  con la implementación física en SQL Server.
=========================================================*/

USE [Ecobici_SQuipoL]
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

CREATE TABLE catalogo.alcaldia(
    id_alcaldia INT PRIMARY KEY,
    alcaldia VARCHAR(22) NOT NULL
);
GO

CREATE TABLE catalogo.bicicleta_color(
    id_bicicleta_color TINYINT NOT NULL,
    color VARCHAR(18) NOT NULL

	CONSTRAINT pk_bicicleta_color 
        PRIMARY KEY (id_bicicleta_color)
);
GO

CREATE TABLE catalogo.estado_bici(
    id_estado_bici INT NOT NULL,
    codigo CHAR(1) NOT NULL UNIQUE,
    descripcion VARCHAR(20) NOT NULL,

    CONSTRAINT pk_estado_bici 
        PRIMARY KEY (id_estado_bici),

    CONSTRAINT u_estado_bici_codigo 
        UNIQUE (codigo),

    CONSTRAINT ck_estado_bici_codigo
        CHECK (codigo IN ('F','D','B'))
);
GO

CREATE TABLE catalogo.estado_civil(
    id_estado_civil INT NOT NULL,
    codigo CHAR(1) NOT NULL UNIQUE,
    estado_civil VARCHAR(15) NOT NULL,
    vigente BIT NOT NULL,

     CONSTRAINT pk_estado_civil 
        PRIMARY KEY (id_estado_civil),

    CONSTRAINT u_estado_civil_codigo 
        UNIQUE (codigo),

    CONSTRAINT ck_estado_civil_codigo
        CHECK (codigo IN ('S','C','D','V','O'))
);
GO

CREATE TABLE catalogo.catalogo_idiomas(
    id_idioma INT NOT NULL,
    nombre_idioma VARCHAR(30) NOT NULL

	CONSTRAINT pk_catalogo_idiomas 
        PRIMARY KEY (id_idioma)
);
GO

CREATE TABLE catalogo.especialidad(
    id_especialidad INT NOT NULL,
    especialidad VARCHAR(25) NOT NULL

	CONSTRAINT pk_especialidad 
        PRIMARY KEY (id_especialidad)
);
GO

CREATE TABLE catalogo.motivo(
    id_motivo INT NOT NULL,
    motivo_falta VARCHAR(30) NOT NULL

	CONSTRAINT pk_motivo 
        PRIMARY KEY (id_motivo)
);
GO

CREATE TABLE catalogo.tipo_incidente(
    id_tipo_incidente INT NOT NULL,
    nombre_incidente VARCHAR(30) NOT NULL,
    descripcion VARCHAR(80) NOT NULL

	CONSTRAINT pk_tipo_incidente 
        PRIMARY KEY (id_tipo_incidente)
);
GO

/*==============================================================*/
/* ESQUEMA: personal                                            */
/*==============================================================*/

CREATE TABLE personal.empleado(
    id_empleado INT NOT NULL,
    tipo_empleado VARCHAR(2) NOT NULL,
    genero CHAR(1) NOT NULL,
	edad AS DATEDIFF(YEAR, fecha_nacimiento, GETDATE()),
    sueldo DECIMAL(12,2) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono NUMERIC(10,0) NOT NULL,
    RFC CHAR(13) NOT NULL,
    nombre_pila VARCHAR(30) NOT NULL,
    ap_paterno VARCHAR(30) NOT NULL,
    ap_materno VARCHAR(30),
    id_estado_civil INT NOT NULL,

    CONSTRAINT pk_empleado 
        PRIMARY KEY (id_empleado),

    CONSTRAINT fk_empleado_estado_civil
        FOREIGN KEY (id_estado_civil)
        REFERENCES catalogo.estado_civil(id_estado_civil),

    CONSTRAINT u_empleado_rfc 
        UNIQUE (RFC),

    CONSTRAINT u_empleado_telefono 
        UNIQUE (telefono),

    CONSTRAINT ck_empleado_genero
        CHECK (genero IN ('M','F')),

    CONSTRAINT ck_empleado_sueldo
        CHECK (sueldo > 0),

    CONSTRAINT ck_empleado_tipo
        CHECK (tipo_empleado IN ('AD','AG','R','M'))
);
GO

CREATE TABLE personal.administracion(
    id_empleado INT NOT NULL,
    profesion VARCHAR(30) NOT NULL,
    ubicacion_trabajo VARCHAR(40) NOT NULL,

    CONSTRAINT pk_administracion 
        PRIMARY KEY (id_empleado),

    CONSTRAINT fk_administracion_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado)
);
GO

CREATE TABLE personal.agente(
    id_empleado INT NOT NULL,
    zona_asignada VARCHAR(30) NOT NULL,
    vehiculo_asignado VARCHAR(20) NOT NULL,

    CONSTRAINT pk_agente 
        PRIMARY KEY (id_empleado),

    CONSTRAINT fk_agente_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado)
);
GO

CREATE TABLE personal.rondin(
    id_empleado INT NOT NULL,
    id_empleado_supervisor INT NULL,

    CONSTRAINT pk_rondin 
        PRIMARY KEY (id_empleado),

    CONSTRAINT fk_rondin_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado),

    CONSTRAINT fk_rondin_supervisor
        FOREIGN KEY (id_empleado_supervisor)
        REFERENCES personal.rondin(id_empleado)
);
GO

CREATE TABLE personal.mantenimiento(
    id_empleado INT NOT NULL,
    id_especialidad INT NOT NULL,

    CONSTRAINT pk_mantenimiento 
        PRIMARY KEY (id_empleado),

    CONSTRAINT fk_mantenimiento_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado),

    CONSTRAINT fk_mantenimiento_especialidad
        FOREIGN KEY (id_especialidad)
        REFERENCES catalogo.especialidad(id_especialidad)
);
GO

CREATE TABLE personal.colonia(
    id_colonia INT NOT NULL,
    colonia VARCHAR(20) NOT NULL,
    id_alcaldia INT NOT NULL,

    CONSTRAINT pk_colonia 
        PRIMARY KEY (id_colonia),

    CONSTRAINT fk_colonia_alcaldia
        FOREIGN KEY (id_alcaldia)
        REFERENCES catalogo.alcaldia(id_alcaldia)
);
GO

CREATE TABLE personal.domicilio(
    id_empleado INT NOT NULL,
    id_domicilio INT NOT NULL,
    numero_ext NUMERIC(3,0) NOT NULL,
    numero_int NUMERIC(3,0),
    calle VARCHAR(30) NOT NULL,
    id_colonia INT NOT NULL,
	
	CONSTRAINT pk_domicilio 
        PRIMARY KEY (id_empleado, id_domicilio),

    CONSTRAINT fk_domicilio_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado),

    CONSTRAINT fk_domicilio_colonia
        FOREIGN KEY (id_colonia)
        REFERENCES personal.colonia(id_colonia)
);
GO

CREATE TABLE personal.idiomas(
    id_empleado INT NOT NULL,
    id_idioma INT NOT NULL,
	
	CONSTRAINT pk_idiomas 
        PRIMARY KEY (id_empleado, id_idioma),

    CONSTRAINT fk_idiomas_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado),

    CONSTRAINT fk_idiomas_catalogo
        FOREIGN KEY (id_idioma)
        REFERENCES catalogo.catalogo_idiomas(id_idioma)
);
GO

CREATE TABLE personal.falta(
    id_empleado INT NOT NULL,
    id_falta SMALLINT IDENTITY(1,1),
    fecha DATE NOT NULL,
    id_motivo INT NOT NULL,

    CONSTRAINT pk_falta 
        PRIMARY KEY (id_empleado, id_falta),

    CONSTRAINT fk_falta_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES personal.empleado(id_empleado),

    CONSTRAINT fk_falta_motivo
        FOREIGN KEY (id_motivo)
        REFERENCES catalogo.motivo(id_motivo)
);
GO

CREATE TABLE personal.funciones(
    id_funciones INT NOT NULL,
    id_empleado INT NOT NULL,
    nombre_funcion VARCHAR(30) NOT NULL,

     CONSTRAINT pk_funciones 
        PRIMARY KEY (id_funciones),

    CONSTRAINT fk_funciones_administracion
        FOREIGN KEY (id_empleado)
        REFERENCES personal.administracion(id_empleado)
);
GO

/*==============================================================*/
/* ESQUEMA: usuarios                                            */
/*==============================================================*/

CREATE TABLE usuarios.usuario(
    id_usuario INT NOT NULL,
    correo VARCHAR(30) NOT NULL,
    nombre VARCHAR(40) NOT NULL,
    ap_paterno VARCHAR(40) NOT NULL,
    ap_materno VARCHAR(40),
    codigo_ine CHAR(18) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,

    edad AS DATEDIFF(YEAR, fecha_nacimiento, GETDATE()),

    CONSTRAINT pk_usuario 
        PRIMARY KEY (id_usuario),

    CONSTRAINT u_usuario_correo 
        UNIQUE (correo),

    CONSTRAINT u_usuario_codigo_ine 
        UNIQUE (codigo_ine),

    CONSTRAINT ck_usuario_genero
        CHECK (genero IN ('M','F'))

);
GO

CREATE TABLE usuarios.telefono(
    id_telefono INT NOT NULL,
    id_usuario INT NOT NULL,
    telefono CHAR(10) NOT NULL,

    CONSTRAINT pk_telefono 
        PRIMARY KEY (id_telefono),

    CONSTRAINT u_telefono_numero 
        UNIQUE (telefono),

    CONSTRAINT fk_telefono_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios.usuario(id_usuario)
);
GO

/*==============================================================*/
/* ESQUEMA: movilidad                                           */
/*==============================================================*/

CREATE TABLE movilidad.metodo_pago(
    id_metodo_pago INT NOT NULL,
    fecha_exp DATE NOT NULL,
    fecha_inicio DATE NOT NULL,
    tipo_pago CHAR(1) NOT NULL,
	
	CONSTRAINT pk_metodo_pago 
        PRIMARY KEY (id_metodo_pago),

    CONSTRAINT ck_metodo_pago_tipo
        CHECK (tipo_pago IN ('D','C','P')),

    CONSTRAINT ck_metodo_pago_fecha
        CHECK (fecha_exp >= fecha_inicio)
);
GO

CREATE TABLE movilidad.tipo_membresia(
    id_tipo_membresia INT NOT NULL,

    tipo_membresia CHAR(1) NOT NULL,

    descripcion VARCHAR(15) NOT NULL,
    duracion_dias NUMERIC(4,0) NOT NULL,
    tipo_seguro CHAR(1) NOT NULL,
    tiempo_excedente DECIMAL(18,0) NOT NULL,
    costo_base DECIMAL(10,2) NOT NULL,
    tarifa_excedente DECIMAL(10,2) NOT NULL,
    tipo_beneficio CHAR(1) NOT NULL,

    CONSTRAINT pk_tipo_membresia 
        PRIMARY KEY (id_tipo_membresia),

    CONSTRAINT ck_tipo_membresia_tipo
        CHECK (tipo_membresia IN ('B','I','P')),

    CONSTRAINT ck_tipo_membresia_costo
        CHECK (costo_base >= 0),

    CONSTRAINT ck_tipo_membresia_tarifa
        CHECK (tarifa_excedente >= 0),

    CONSTRAINT ck_tipo_membresia_duracion
        CHECK (duracion_dias > 0)
);
GO

CREATE TABLE movilidad.suscripcion(
    id_suscripcion INT NOT NULL,
    estado CHAR(1) NOT NULL,
    fecha_fin DATE NOT NULL,
    fecha_inicio DATE NOT NULL,
    id_usuario INT NOT NULL,
    id_metodo_pago INT NULL,
    id_tipo_membresia INT NOT NULL,

     CONSTRAINT pk_suscripcion 
        PRIMARY KEY (id_suscripcion),

    CONSTRAINT fk_suscripcion_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios.usuario(id_usuario),

    CONSTRAINT fk_suscripcion_metodo_pago
        FOREIGN KEY (id_metodo_pago)
        REFERENCES movilidad.metodo_pago(id_metodo_pago),

    CONSTRAINT fk_suscripcion_tipo_membresia
        FOREIGN KEY (id_tipo_membresia)
        REFERENCES movilidad.tipo_membresia(id_tipo_membresia),

    CONSTRAINT ck_suscripcion_estado
        CHECK (estado IN ('A','C','V')),

    CONSTRAINT ck_suscripcion_fecha
        CHECK (fecha_fin >= fecha_inicio)
);
GO

CREATE TABLE movilidad.tarjeta_movilidad(
    id_tarjeta_movilidad INT NOT NULL,
    id_tarjeta_reposicion INT,
    id_usuario INT NOT NULL,
    fecha_baja DATE NOT NULL,
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0,
    codigo_QR VARBINARY(100) NOT NULL,
    fecha_emision DATE NOT NULL DEFAULT GETDATE(),
    activa BIT NOT NULL,
    tipo_emision VARCHAR(20) NOT NULL , 

    CONSTRAINT pk_tarjeta_movilidad 
        PRIMARY KEY (id_tarjeta_movilidad),

    CONSTRAINT fk_tarjeta_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios.usuario(id_usuario),

    CONSTRAINT fk_tarjeta_reposicion
        FOREIGN KEY (id_tarjeta_reposicion)
        REFERENCES movilidad.tarjeta_movilidad(id_tarjeta_movilidad),

    CONSTRAINT u_tarjeta_codigoQR 
        UNIQUE (codigo_QR),

    CONSTRAINT ck_tarjeta_saldo
        CHECK (saldo >= 0),

    CONSTRAINT ck_tarjeta_tipo_emision
        CHECK (tipo_emision IN ('Primera','Reposicion'))
);
GO

CREATE TABLE movilidad.estacion(
    id_estacion INT NOT NULL,
    terminales_disponibles INT NOT NULL,
    terminales_totales INT NOT NULL,
    nombre_estacion VARCHAR(20) NOT NULL,
    id_empleado INT NOT NULL,

    CONSTRAINT pk_estacion 
        PRIMARY KEY (id_estacion),

    CONSTRAINT fk_estacion_rondin
        FOREIGN KEY (id_empleado)
        REFERENCES personal.rondin(id_empleado),

    CONSTRAINT ck_estacion_terminales
        CHECK (
            terminales_disponibles >= 0
            AND terminales_totales >= 0
            AND terminales_disponibles <= terminales_totales
        )
);
GO

CREATE TABLE movilidad.bicicleta(
    id_bicicleta INT NOT NULL,
    modelo CHAR(1) NOT NULL,
    num_serie NUMERIC(10,0) NOT NULL,
    id_estado_bici INT NOT NULL,
    id_estacion INT NOT NULL,
    id_bicicleta_color TINYINT NOT NULL,

    CONSTRAINT pk_bicicleta 
        PRIMARY KEY (id_bicicleta),

    CONSTRAINT fk_bicicleta_estado
        FOREIGN KEY (id_estado_bici)
        REFERENCES catalogo.estado_bici(id_estado_bici),

    CONSTRAINT fk_bicicleta_estacion
        FOREIGN KEY (id_estacion)
        REFERENCES movilidad.estacion(id_estacion),

    CONSTRAINT fk_bicicleta_color
        FOREIGN KEY (id_bicicleta_color)
        REFERENCES catalogo.bicicleta_color(id_bicicleta_color),

    CONSTRAINT u_bicicleta_num_serie 
        UNIQUE (num_serie),

    CONSTRAINT ck_bicicleta_modelo
        CHECK (modelo IN ('C','M','G'))
);
GO

CREATE TABLE movilidad.viaje(
    id_viaje INT NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    ruta VARCHAR(60) NOT NULL,
    hora_inicio DATETIME2 NOT NULL,
    hora_fin DATETIME2 NOT NULL,

    duracion AS DATEDIFF(MINUTE, hora_inicio, hora_fin),

    num_referencia VARCHAR(20) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_estacion_inicio INT NOT NULL,
    id_estacion_fin INT NOT NULL,
    id_tarjeta_movilidad INT NOT NULL,

    CONSTRAINT pk_viaje 
        PRIMARY KEY (id_viaje),

    CONSTRAINT fk_viaje_bicicleta
        FOREIGN KEY (id_bicicleta)
        REFERENCES movilidad.bicicleta(id_bicicleta),

    CONSTRAINT fk_viaje_estacion_inicio
        FOREIGN KEY (id_estacion_inicio)
        REFERENCES movilidad.estacion(id_estacion),

    CONSTRAINT fk_viaje_estacion_fin
        FOREIGN KEY (id_estacion_fin)
        REFERENCES movilidad.estacion(id_estacion),

    CONSTRAINT fk_viaje_tarjeta
        FOREIGN KEY (id_tarjeta_movilidad)
        REFERENCES movilidad.tarjeta_movilidad(id_tarjeta_movilidad),

    CONSTRAINT u_viaje_referencia 
        UNIQUE (num_referencia),

    CONSTRAINT ck_viaje_costo
        CHECK (costo >= 0),

    CONSTRAINT ck_viaje_horas
        CHECK (hora_fin > hora_inicio)
);
GO

/*==============================================================*/
/* ESQUEMA: incidentes                                          */
/*==============================================================*/

CREATE TABLE incidentes.incidente(
    id_incidente INT NOT NULL,
    calle VARCHAR(30) NOT NULL,
    numero NUMERIC(4,0) NOT NULL,
    codigo_postal NUMERIC(5,0) NOT NULL,
    fecha DATE NOT NULL,
    latitud VARCHAR(20) NOT NULL,
    longitud VARCHAR(20) NOT NULL,
    id_viaje INT NOT NULL,
    id_tipo_incidente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_colonia INT NOT NULL,

    CONSTRAINT pk_incidente 
        PRIMARY KEY (id_incidente),

    CONSTRAINT fk_incidente_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES movilidad.viaje(id_viaje),

    CONSTRAINT fk_incidente_tipo
        FOREIGN KEY (id_tipo_incidente)
        REFERENCES catalogo.tipo_incidente(id_tipo_incidente),

    CONSTRAINT fk_incidente_agente
        FOREIGN KEY (id_empleado)
        REFERENCES personal.agente(id_empleado),

    CONSTRAINT fk_incidente_colonia
        FOREIGN KEY (id_colonia)
        REFERENCES personal.colonia(id_colonia)
);
GO

CREATE TABLE incidentes.encuesta(
    id_encuesta INT NOT NULL,
    id_incidente INT NOT NULL,
    puntuacion NUMERIC(2,0) NOT NULL,
    fecha DATE NOT NULL DEFAULT GETDATE(),
    comentario VARCHAR(120) NOT NULL,

    CONSTRAINT pk_encuesta 
        PRIMARY KEY (id_encuesta),

    CONSTRAINT fk_encuesta_incidente
        FOREIGN KEY (id_incidente)
        REFERENCES incidentes.incidente(id_incidente),

    CONSTRAINT ck_encuesta_puntuacion
        CHECK (puntuacion BETWEEN 1 AND 10)

);
GO

/*==============================================================*/
/* ESQUEMA: reportes                                            */
/*==============================================================*/

CREATE TABLE reportes.temporada(
    id_temporada INT NOT NULL,
    nombre_temp VARCHAR(15) NOT NULL

	CONSTRAINT pk_temporada
        PRIMARY KEY (id_temporada),

    CONSTRAINT u_temporada_nombre 
        UNIQUE (nombre_temp)
);
GO

CREATE TABLE reportes.reporte(
    id_reporte INT NOT NULL,
    fecha DATE NOT NULL,
    descripcion VARCHAR(90) NOT NULL,
    bandera_incidente BIT NOT NULL DEFAULT 0,
    numero_incidentes NUMERIC(2,0) NOT NULL DEFAULT 0,
    id_empleado INT NOT NULL,
    id_temporada INT NOT NULL,

    CONSTRAINT pk_reporte 
        PRIMARY KEY (id_reporte),

    CONSTRAINT fk_reporte_rondin
        FOREIGN KEY (id_empleado)
        REFERENCES personal.rondin(id_empleado),

    CONSTRAINT fk_reporte_temporada
        FOREIGN KEY (id_temporada)
        REFERENCES reportes.temporada(id_temporada),

    CONSTRAINT ck_reporte_numero_incidentes
        CHECK (numero_incidentes >= 0)
);
GO

/*==============================================================*/
/* INDICES                                                      */
/*==============================================================*/

CREATE INDEX idx_viaje_fecha
ON movilidad.viaje(fecha);
GO

CREATE INDEX idx_incidente_fecha
ON incidentes.incidente(fecha);
GO

CREATE INDEX idx_suscripcion_usuario
ON movilidad.suscripcion(id_usuario);
GO

/*==============================================================*/
/* VISTA                                                        */
/*==============================================================*/

CREATE OR ALTER VIEW movilidad.vw_viaje_tarifa_adicional
AS
SELECT
    V.id_viaje,
    V.duracion,
    TM.tiempo_excedente,

    CASE
        WHEN V.duracion > TM.tiempo_excedente
        THEN (V.duracion - TM.tiempo_excedente)
             * TM.tarifa_excedente
        ELSE 0
    END AS tarifa_adicional

FROM movilidad.viaje V
INNER JOIN movilidad.tarjeta_movilidad T
    ON V.id_tarjeta_movilidad = T.id_tarjeta_movilidad
INNER JOIN movilidad.suscripcion S
    ON T.id_usuario = S.id_usuario
INNER JOIN movilidad.tipo_membresia TM
    ON S.id_tipo_membresia = TM.id_tipo_membresia;
GO



PRINT 'BASE DE DATOS CON ESQUEMAS CREADA CORRECTAMENTE';
GO
