USE Ecobici_SQuipoL;
GO

/*=========================================================
  PROYECTO : ECOBICI
  AUTORES  : Díaz Núñez David
             Hernández Acosta Mauricio Gabriel
             Sánchez Luján César Ricardo

  FECHA    : 01/06/2026
  VERSIÓN  : 1.0 FINAL

  DESCRIPCIÓN:
 
	Actualiza automáticamente la estación actual de una bicicleta
	cuando se registra la finalización de un viaje.*/
=========================================================*/



CREATE OR ALTER TRIGGER movilidad.trgViajeActualizaUbicacionBicicleta
ON movilidad.VIAJE
AFTER INSERT
AS
BEGIN
    UPDATE B
    SET B.id_estacion = I.id_estacion_fin
    FROM movilidad.BICICLETA AS B
    INNER JOIN inserted AS I
        ON B.id_bicicleta = I.id_bicicleta;
END;
GO

/*Descripción
Al eliminar un método de pago, cancela las suscripciones
que lo utilizan, elimina la referencia al método y después
borra el método de pago.*/

CREATE OR ALTER TRIGGER movilidad.trgMetodoPagoCancelaSuscripcion
ON movilidad.METODO_PAGO
INSTEAD OF DELETE
AS
BEGIN
    UPDATE S
    SET S.estado = 'C',
        S.fecha_fin = CAST(GETDATE() AS DATE),
        S.id_metodo_pago = NULL
    FROM movilidad.SUSCRIPCION AS S
    INNER JOIN deleted AS D
        ON S.id_metodo_pago = D.id_metodo_pago
    WHERE S.estado = 'A';

    DELETE MP
    FROM movilidad.METODO_PAGO AS MP
    INNER JOIN deleted AS D
        ON MP.id_metodo_pago = D.id_metodo_pago;
END;
GO

CREATE OR ALTER TRIGGER incidentes.trgIncidenteMarcaBicicleta
ON incidentes.INCIDENTE
AFTER INSERT
AS
BEGIN
    UPDATE B
    SET B.id_estado_bici = 2
    FROM movilidad.BICICLETA AS B
    INNER JOIN movilidad.VIAJE AS V
        ON B.id_bicicleta = V.id_bicicleta
    INNER JOIN inserted AS I
        ON V.id_viaje = I.id_viaje
    WHERE I.id_tipo_incidente IN (4,5,6,7);
END;
GO

/*Descripción:
Evita registrar viajes con bicicletas dañadas o dadas de baja.*/

CREATE OR ALTER TRIGGER movilidad.trgViajeValidaBicicletaOperativa
ON movilidad.VIAJE
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN movilidad.BICICLETA AS B
            ON I.id_bicicleta = B.id_bicicleta
        INNER JOIN catalogo.ESTADO_BICI AS EB
            ON B.id_estado_bici = EB.id_estado_bici
        WHERE EB.codigo <> 'F'
    )
    BEGIN
        RAISERROR('No se puede registrar el viaje: la bicicleta no esta en funcionamiento.', 16, 1);
        RETURN;
    END;

    INSERT INTO movilidad.VIAJE
    (
        id_viaje,
        costo,
        fecha,
        ruta,
        hora_inicio,
        hora_fin,
        num_referencia,
        id_bicicleta,
        id_estacion_inicio,
        id_estacion_fin,
        id_tarjeta_movilidad
    )
    SELECT
        id_viaje,
        costo,
        fecha,
        ruta,
        hora_inicio,
        hora_fin,
        num_referencia,
        id_bicicleta,
        id_estacion_inicio,
        id_estacion_fin,
        id_tarjeta_movilidad
    FROM inserted;
END;
GO

/*Descripción:
Desactiva automaticamente una tarjeta cuando se genero su reposición*/

CREATE OR ALTER TRIGGER movilidad.trgTarjetaDesactivaPorReposicion
ON movilidad.TARJETA_MOVILIDAD
AFTER INSERT
AS
BEGIN
    UPDATE TAnterior
    SET TAnterior.activa = 0,
        TAnterior.fecha_baja = CAST(GETDATE() AS DATE)
    FROM movilidad.TARJETA_MOVILIDAD AS TAnterior
    INNER JOIN inserted AS Nueva
        ON TAnterior.id_tarjeta_movilidad = Nueva.id_tarjeta_reposicion
    WHERE Nueva.tipo_emision = 'Reposicion'
      AND Nueva.id_tarjeta_reposicion IS NOT NULL;
END;
GO

/*==============================================================*/
/* TRIGGER 1: trgViajeActualizaUbicacionBicicleta              */
/* Al insertar un viaje, la bicicleta cambia a la estación fin. */
/*==============================================================*/

BEGIN TRANSACTION;

PRINT 'TRIGGER 1 - ANTES DE INSERTAR LOS VIAJES';

SELECT id_bicicleta, id_estacion
FROM movilidad.BICICLETA
WHERE id_bicicleta IN (1,2,3,5,6);

INSERT INTO movilidad.VIAJE VALUES
(1001,25,'2027-02-01','CU-ROMA',
 '2027-02-01 08:00','2027-02-01 08:30',
 'PRUEBA_V001',1,1,2,1);

INSERT INTO movilidad.VIAJE VALUES
(1002,25,'2027-02-01','ROMA-CONDESA',
 '2027-02-01 09:00','2027-02-01 09:25',
 'PRUEBA_V002',2,2,3,2);

INSERT INTO movilidad.VIAJE VALUES
(1003,30,'2027-02-01','CONDESA-REFORMA',
 '2027-02-01 10:00','2027-02-01 10:35',
 'PRUEBA_V003',3,3,4,3);

INSERT INTO movilidad.VIAJE VALUES
(1004,20,'2027-02-01','REFORMA-POLANCO',
 '2027-02-01 11:00','2027-02-01 11:20',
 'PRUEBA_V004',5,4,5,5);

INSERT INTO movilidad.VIAJE VALUES
(1005,22,'2027-02-01','POLANCO-CU',
 '2027-02-01 12:00','2027-02-01 12:25',
 'PRUEBA_V005',6,5,1,6);

PRINT 'TRIGGER 1 - VIAJES INSERTADOS';

SELECT id_viaje, id_bicicleta, id_estacion_inicio, id_estacion_fin
FROM movilidad.VIAJE
WHERE id_viaje BETWEEN 1001 AND 1005;

PRINT 'TRIGGER 1 - DESPUES: LA BICICLETA DEBE ESTAR EN LA ESTACION FINAL';

SELECT id_bicicleta, id_estacion
FROM movilidad.BICICLETA
WHERE id_bicicleta IN (1,2,3,5,6);

ROLLBACK TRANSACTION;
GO


/*==============================================================*/
/* TRIGGER 2: trgMetodoPagoCancelaSuscripcion                   */
/* Al eliminar el método, la suscripción queda cancelada.       */
/*==============================================================*/

BEGIN TRANSACTION;

PRINT 'TRIGGER 2 - ANTES DE ELIMINAR LOS METODOS DE PAGO';

SELECT id_suscripcion, estado, id_metodo_pago, fecha_fin
FROM movilidad.SUSCRIPCION
WHERE id_metodo_pago IN (1,2,3,4,5);

SELECT id_metodo_pago, tipo_pago
FROM movilidad.METODO_PAGO
WHERE id_metodo_pago IN (1,2,3,4,5);

DELETE FROM movilidad.METODO_PAGO
WHERE id_metodo_pago = 1;

DELETE FROM movilidad.METODO_PAGO
WHERE id_metodo_pago = 2;

DELETE FROM movilidad.METODO_PAGO
WHERE id_metodo_pago = 3;

DELETE FROM movilidad.METODO_PAGO
WHERE id_metodo_pago = 4;

DELETE FROM movilidad.METODO_PAGO
WHERE id_metodo_pago = 5;

PRINT 'TRIGGER 2 - DESPUES: SUSCRIPCIONES CANCELADAS Y SIN METODO DE PAGO';

SELECT id_suscripcion, estado, id_metodo_pago, fecha_fin
FROM movilidad.SUSCRIPCION
WHERE id_suscripcion IN (1,2,3,4,5);

PRINT 'TRIGGER 2 - LOS METODOS YA NO DEBEN APARECER';

SELECT id_metodo_pago, tipo_pago
FROM movilidad.METODO_PAGO
WHERE id_metodo_pago IN (1,2,3,4,5);

ROLLBACK TRANSACTION;
GO


/*==============================================================*/
/* TRIGGER 3: trgIncidenteMarcaBicicleta                        */
/* Al registrar ciertos incidentes, la bicicleta queda dañada.  */
/*==============================================================*/

BEGIN TRANSACTION;

PRINT 'TRIGGER 3 - ANTES DE INSERTAR INCIDENTES';

SELECT id_bicicleta, id_estado_bici
FROM movilidad.BICICLETA
WHERE id_bicicleta IN (1,2,3,5,6);

INSERT INTO incidentes.INCIDENTE VALUES
(1001,'Insurgentes',101,31001,'2027-02-02','19.43','-99.13',1,4,6,1);

INSERT INTO incidentes.INCIDENTE VALUES
(1002,'Reforma',202,67002,'2027-02-02','19.42','-99.15',4,5,7,2);

INSERT INTO incidentes.INCIDENTE VALUES
(1003,'Universidad',303,45003,'2027-02-02','19.40','-99.17',7,6,8,3);

INSERT INTO incidentes.INCIDENTE VALUES
(1004,'Patriotismo',404,38004,'2027-02-02','19.44','-99.11',13,7,9,4);

INSERT INTO incidentes.INCIDENTE VALUES
(1005,'Chapultepec',505,61005,'2027-02-02','19.45','-99.18',16,4,10,5);

PRINT 'TRIGGER 3 - INCIDENTES INSERTADOS';

SELECT id_incidente, id_viaje, id_tipo_incidente
FROM incidentes.INCIDENTE
WHERE id_incidente BETWEEN 1001 AND 1005;

PRINT 'TRIGGER 3 - DESPUES: LAS BICICLETAS DEBEN TENER ESTADO 2, DANADA';

SELECT id_bicicleta, id_estado_bici
FROM movilidad.BICICLETA
WHERE id_bicicleta IN (1,2,3,5,6);

ROLLBACK TRANSACTION;
GO


/*==============================================================*/
/* TRIGGER 4: trgViajeValidaBicicletaOperativa                  */
/* Impide registrar viajes para bicicletas dañadas.             */
/*==============================================================*/

BEGIN TRANSACTION;

PRINT 'TRIGGER 4 - BICICLETAS DANADAS QUE SE INTENTARAN USAR';

SELECT id_bicicleta, id_estado_bici
FROM movilidad.BICICLETA
WHERE id_bicicleta IN (4,9,14,19,24);

INSERT INTO movilidad.VIAJE VALUES
(2001,25,'2027-02-03','CU-ROMA',
 '2027-02-03 08:00','2027-02-03 08:30',
 'PRUEBA_D001',4,1,2,1);

INSERT INTO movilidad.VIAJE VALUES
(2002,25,'2027-02-03','ROMA-CU',
 '2027-02-03 09:00','2027-02-03 09:30',
 'PRUEBA_D002',9,2,1,2);

INSERT INTO movilidad.VIAJE VALUES
(2003,25,'2027-02-03','CONDESA-ROMA',
 '2027-02-03 10:00','2027-02-03 10:30',
 'PRUEBA_D003',14,3,2,3);

INSERT INTO movilidad.VIAJE VALUES
(2004,25,'2027-02-03','REFORMA-CU',
 '2027-02-03 11:00','2027-02-03 11:30',
 'PRUEBA_D004',19,4,1,4);

INSERT INTO movilidad.VIAJE VALUES
(2005,25,'2027-02-03','POLANCO-ROMA',
 '2027-02-03 12:00','2027-02-03 12:30',
 'PRUEBA_D005',24,5,2,5);

PRINT 'TRIGGER 4 - LOS VIAJES NO DEBEN HABER SIDO REGISTRADOS';

SELECT id_viaje, id_bicicleta, num_referencia
FROM movilidad.VIAJE
WHERE id_viaje BETWEEN 2001 AND 2005;

ROLLBACK TRANSACTION;
GO


/*==============================================================*/
/* TRIGGER 5: trgTarjetaDesactivaPorReposicion                  */
/* Al insertar una reposición, desactiva la tarjeta anterior.   */
/*==============================================================*/

BEGIN TRANSACTION;

PRINT 'TRIGGER 5 - ANTES DE REGISTRAR REPOSICIONES';

SELECT id_tarjeta_movilidad, id_usuario, activa, fecha_baja
FROM movilidad.TARJETA_MOVILIDAD
WHERE id_tarjeta_movilidad IN (1,2,3,4,5);

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1001,1,1,'2030-01-01',100,0x9001,'2027-02-04',1,'Reposicion');

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1002,2,2,'2030-01-01',100,0x9002,'2027-02-04',1,'Reposicion');

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1003,3,3,'2030-01-01',100,0x9003,'2027-02-04',1,'Reposicion');

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1004,4,4,'2030-01-01',100,0x9004,'2027-02-04',1,'Reposicion');

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1005,5,5,'2030-01-01',100,0x9005,'2027-02-04',1,'Reposicion');

PRINT 'TRIGGER 5 - TARJETAS NUEVAS DE REPOSICION';

SELECT id_tarjeta_movilidad, id_tarjeta_reposicion, id_usuario, activa, tipo_emision
FROM movilidad.TARJETA_MOVILIDAD
WHERE id_tarjeta_movilidad BETWEEN 1001 AND 1005;

PRINT 'TRIGGER 5 - TARJETAS ANTERIORES DESACTIVADAS';

SELECT id_tarjeta_movilidad, id_usuario, activa, fecha_baja
FROM movilidad.TARJETA_MOVILIDAD
WHERE id_tarjeta_movilidad IN (1,2,3,4,5);

ROLLBACK TRANSACTION;
GO

/*
Descripción:
Funciones utilizadas para las edades de los usuarios y los meses de las membresías. 
Y funciones para las estadisticas
==============================================================*/


/*==============================================================*/
/* FUNCION 1: CALCULAR EDAD DE UN USUARIO                       */
/*==============================================================*/

CREATE OR ALTER FUNCTION usuarios.fn_calcular_edad
(
    @fecha_nacimiento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;

    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

    IF DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE()
        SET @edad = @edad - 1;

    RETURN @edad;
END;
GO


/*==============================================================*/
/* FUNCION 2: CALCULAR MESES DE MEMBRESIA                       */
/*==============================================================*/

CREATE OR ALTER FUNCTION movilidad.fn_meses_membresia
(
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @meses INT;

    SET @meses = DATEDIFF(MONTH, @fecha_inicio, @fecha_fin);

    RETURN @meses;
END;
GO

/*==============================================================
FUNCION 3: OBTENER AGENTES MEJOR RECONOCIDOS EN UN MES ESPECIFICO
==============================================================*/

CREATE OR ALTER FUNCTION incidentes.fn_agentes_reconocidos_mes
(
    @anio INT,
    @mes INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        E.id_empleado,
        CONCAT(
            E.nombre_pila, ' ',
            E.ap_paterno, ' ',
            ISNULL(E.ap_materno, '')
        ) AS agente,
        A.zona_asignada,
        A.vehiculo_asignado,
        COUNT(DISTINCT I.id_incidente) AS incidentes_atendidos,
        COUNT(EN.id_encuesta) AS encuestas_recibidas,
        AVG(CAST(EN.puntuacion AS DECIMAL(5,2))) AS promedio_puntuacion
    FROM personal.EMPLEADO AS E
    INNER JOIN personal.AGENTE AS A
        ON E.id_empleado = A.id_empleado
    INNER JOIN incidentes.INCIDENTE AS I
        ON A.id_empleado = I.id_empleado
    INNER JOIN incidentes.ENCUESTA AS EN
        ON I.id_incidente = EN.id_incidente
    WHERE YEAR(EN.fecha) = @anio
      AND MONTH(EN.fecha) = @mes
    GROUP BY
        E.id_empleado,
        E.nombre_pila,
        E.ap_paterno,
        E.ap_materno,
        A.zona_asignada,
        A.vehiculo_asignado
);
GO
/*==============================================================
FUNCION 4: OBTENER VIAJES EN UN PERIODO O ESTACION DADA
==============================================================*/

CREATE OR ALTER FUNCTION movilidad.fn_recorridos_periodo_estacion
(
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @id_estacion INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        V.id_viaje,
        V.fecha,
        CONCAT(
            U.nombre, ' ',
            U.ap_paterno, ' ',
            ISNULL(U.ap_materno, '')
        ) AS usuario,
        EI.nombre_estacion AS estacion_partida,
        EF.nombre_estacion AS lugar_llegada,
        V.duracion AS tiempo_minutos,
        V.costo
    FROM movilidad.VIAJE AS V
    INNER JOIN movilidad.TARJETA_MOVILIDAD AS T
        ON V.id_tarjeta_movilidad = T.id_tarjeta_movilidad
    INNER JOIN usuarios.USUARIO AS U
        ON T.id_usuario = U.id_usuario
    INNER JOIN movilidad.ESTACION AS EI
        ON V.id_estacion_inicio = EI.id_estacion
    INNER JOIN movilidad.ESTACION AS EF
        ON V.id_estacion_fin = EF.id_estacion
    WHERE V.fecha BETWEEN @fecha_inicio AND @fecha_fin
      AND (
            @id_estacion IS NULL
            OR V.id_estacion_inicio = @id_estacion
            OR V.id_estacion_fin = @id_estacion
          )
);
GO


/*==============================================================*/
/* PRUEBAS DE LAS FUNCIONES                                     */
/*==============================================================*/

SELECT
    id_usuario,
    nombre,
    fecha_nacimiento,
    usuarios.fn_calcular_edad(fecha_nacimiento) AS edad_calculada
FROM usuarios.USUARIO;
GO

SELECT
    id_suscripcion,
    fecha_inicio,
    fecha_fin,
    movilidad.fn_meses_membresia(fecha_inicio, fecha_fin) AS meses_membresia
FROM movilidad.SUSCRIPCION;
GO

SELECT *
FROM incidentes.fn_agentes_reconocidos_mes(2026, 7)
ORDER BY promedio_puntuacion DESC, encuestas_recibidas DESC;
GO

SELECT *
FROM movilidad.fn_recorridos_periodo_estacion
(
    '2026-05-01',
    '2027-01-31',
    NULL
);
GO