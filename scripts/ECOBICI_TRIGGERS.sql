USE Ecobici_SQuipoL;
GO

/*==============================================================
Autor: Equipo SQuipoL
Fecha de creación: 31/05/2026
==============================================================*/

/*Descripción:
Actualiza automáticamente la estación actual de una bicicleta
cuando se registra la finalización de un viaje.*/

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
    SET NOCOUNT ON;

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
