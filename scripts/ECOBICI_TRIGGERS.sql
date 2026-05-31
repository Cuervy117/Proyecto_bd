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
        ON B.idBicicleta = I.idBicicleta;
END;
GO

select * from movilidad.VIAJE
select * from movilidad.BICICLETA

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
        S.fechaFin = CAST(GETDATE() AS DATE),
        S.idMetodoPago = NULL
    FROM movilidad.SUSCRIPCION AS S
    INNER JOIN deleted AS D
        ON S.idMetodoPago = D.id_metodoPago
    WHERE S.estado = 'A';

    DELETE MP
    FROM movilidad.METODO_PAGO AS MP
    INNER JOIN deleted AS D
        ON MP.id_metodoPago = D.id_metodoPago;
END;
GO

CREATE OR ALTER TRIGGER incidentes.trgIncidenteMarcaBicicletaDanada
ON incidentes.INCIDENTE
AFTER INSERT
AS
BEGIN
    UPDATE B
    SET B.id_estado_bici = 2
    FROM movilidad.BICICLETA AS B
    INNER JOIN movilidad.VIAJE AS V
        ON B.idBicicleta = V.idBicicleta
    INNER JOIN inserted AS I
        ON V.idViaje = I.idViaje
    WHERE I.id_tipo_incidente IN (4,5,6,7);
END;
GO

USE Ecobici_SQuipoL;
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
            ON I.idBicicleta = B.idBicicleta
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
        idViaje,
        costo,
        fecha,
        ruta,
        hora_inicio,
        hora_fin,
        num_referencia,
        idBicicleta,
        id_estacion_inicio,
        id_estacion_fin,
        idTarjetaMovilidad
    )
    SELECT
        idViaje,
        costo,
        fecha,
        ruta,
        hora_inicio,
        hora_fin,
        num_referencia,
        idBicicleta,
        id_estacion_inicio,
        id_estacion_fin,
        idTarjetaMovilidad
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
        TAnterior.fechaBaja = CAST(GETDATE() AS DATE)
    FROM movilidad.TARJETA_MOVILIDAD AS TAnterior
    INNER JOIN inserted AS Nueva
        ON TAnterior.idTarjetaMovilidad = Nueva.id_tarjeta_reposicion
    WHERE Nueva.tipoEmision = 'Reposicion'
      AND Nueva.id_tarjeta_reposicion IS NOT NULL;
END;
GO