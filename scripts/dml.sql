USE Ecobici_SQuipoL;
GO

/*=========================================================
  PROYECTO : ECOBICI
  AUTORES  : Díaz Núñez David
             Hernández Acosta Mauricio Gabriel
             Sánchez Luján César Ricardo

  FECHA    : 01/06/2026
  VERSIÓN  : 1.0 FINAL
  DESCRIPCIÓN: Script de lógica programática (DML Avanzada).
               Incluye Triggers, UDFs y Stored Procedures transaccionales.
=========================================================*/

/*==============================================================*/
/* TRIGGERS                                                     */
/*==============================================================*/

/*
Descripción:
Actualiza automáticamente la estación actual de una bicicleta
cuando se registra la finalización de un viaje.
*/
CREATE OR ALTER TRIGGER movilidad.trg_viaje_actualiza_ubicacion_bicicleta
ON movilidad.viaje
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE B
    SET B.id_estacion = I.id_estacion_fin
    FROM movilidad.bicicleta AS B
    INNER JOIN inserted AS I
        ON B.id_bicicleta = I.id_bicicleta;
END;
GO

/*
Descripción:
Al eliminar un método de pago, cancela las suscripciones
que lo utilizan, elimina la referencia al método y después
borra el método de pago.
*/
CREATE OR ALTER TRIGGER movilidad.trg_metodo_pago_cancela_suscripcion
ON movilidad.metodo_pago
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE S
    SET S.estado = 'C',
        S.fecha_fin = CAST(GETDATE() AS DATE),
        S.id_metodo_pago = NULL
    FROM movilidad.suscripcion AS S
    INNER JOIN deleted AS D
        ON S.id_metodo_pago = D.id_metodo_pago
    WHERE S.estado = 'A';

    DELETE MP
    FROM movilidad.metodo_pago AS MP
    INNER JOIN deleted AS D
        ON MP.id_metodo_pago = D.id_metodo_pago;
END;
GO

/*
Descripción:
Al registrar ciertos incidentes mecánicos o de vandalismo,
la bicicleta se marca automáticamente como dañada.
*/
CREATE OR ALTER TRIGGER incidentes.trg_incidente_marca_bicicleta
ON incidentes.incidente
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE B
    SET B.id_estado_bici = 2
    FROM movilidad.bicicleta AS B
    INNER JOIN movilidad.viaje AS V
        ON B.id_bicicleta = V.id_bicicleta
    INNER JOIN inserted AS I
        ON V.id_viaje = I.id_viaje
    WHERE I.id_tipo_incidente IN (4,5,6,7);
END;
GO

/*
Descripción:
Evita registrar viajes con bicicletas dañadas o dadas de baja.
*/
CREATE OR ALTER TRIGGER movilidad.trg_viaje_valida_bicicleta_operativa
ON movilidad.viaje
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN movilidad.bicicleta AS B
            ON I.id_bicicleta = B.id_bicicleta
        INNER JOIN catalogo.estado_bici AS EB
            ON B.id_estado_bici = EB.id_estado_bici
        WHERE EB.codigo <> 'F'
    )
    BEGIN
        RAISERROR('No se puede registrar el viaje: la bicicleta no esta en funcionamiento.', 16, 1);
        RETURN;
    END;

    INSERT INTO movilidad.viaje
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

/*
Descripción:
Desactiva automáticamente la tarjeta anterior cuando se genera su reposición.
*/
CREATE OR ALTER TRIGGER movilidad.trg_tarjeta_desactiva_por_reposicion
ON movilidad.tarjeta_movilidad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE TAnterior
    SET TAnterior.activa = 0,
        TAnterior.fecha_baja = CAST(GETDATE() AS DATE)
    FROM movilidad.tarjeta_movilidad AS TAnterior
    INNER JOIN inserted AS Nueva
        ON TAnterior.id_tarjeta_movilidad = Nueva.id_tarjeta_reposicion
    WHERE Nueva.tipo_emision = 'Reposicion'
      AND Nueva.id_tarjeta_reposicion IS NOT NULL;
END;
GO


/*==============================================================*/
/* FUNCIONES (UDFs)                                             */
/*==============================================================*/

/*
Descripción:
Calcular la edad de un usuario basándose en su fecha de nacimiento.
*/
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

/*
Descripción:
Calcular la duración en meses de una suscripción.
*/
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

/*
Descripción:
UDF para calcular tarifas excedentes basada en la duración del viaje.
*/
CREATE OR ALTER FUNCTION movilidad.fn_calcular_tarifa_excedente
(
    @duracion INT,
    @tiempo_excedente INT,
    @tarifa_excedente DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @costo DECIMAL(10,2) = 0.0;
    IF @duracion > @tiempo_excedente
        SET @costo = (@duracion - @tiempo_excedente) * @tarifa_excedente;
    RETURN @costo;
END;
GO

/*
Descripción:
UDF para clasificar un usuario por rangos de edad requeridos en estadísticas.
*/
CREATE OR ALTER FUNCTION usuarios.fn_obtener_rango_edad
(
    @edad INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @rango VARCHAR(20);
    IF @edad BETWEEN 10 AND 14
        SET @rango = '10 a 15 anos';
    ELSE IF @edad BETWEEN 15 AND 19
        SET @rango = '15-20 anos';
    ELSE IF @edad BETWEEN 20 AND 30
        SET @rango = '20 a 30 anos';
    ELSE IF @edad > 30
        SET @rango = 'mas de 30 anos';
    ELSE
        SET @rango = 'Menores';
    RETURN @rango;
END;
GO

/*
Descripción:
Obtener los agentes mejores puntuados en encuestas para un mes dado.
*/
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
        CONCAT(E.nombre_pila, ' ', E.ap_paterno, ' ', ISNULL(E.ap_materno, '')) AS agente,
        A.zona_asignada,
        A.vehiculo_asignado,
        COUNT(DISTINCT I.id_incidente) AS incidentes_atendidos,
        COUNT(EN.id_encuesta) AS encuestas_recibidas,
        AVG(CAST(EN.puntuacion AS DECIMAL(5,2))) AS promedio_puntuacion
    FROM personal.empleado AS E
    INNER JOIN personal.agente AS A
        ON E.id_empleado = A.id_empleado
    INNER JOIN incidentes.incidente AS I
        ON A.id_empleado = I.id_empleado
    INNER JOIN incidentes.encuesta AS EN
        ON I.id_incidente = EN.id_incidente
    WHERE YEAR(EN.fecha) = @anio
      AND MONTH(EN.fecha) = @mes
    GROUP BY
        E.id_empleado, E.nombre_pila, E.ap_paterno, E.ap_materno,
        A.zona_asignada, A.vehiculo_asignado
);
GO

/*
Descripción:
Obtener recorridos en un rango de fechas y estación de origen/destino.
*/
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
        CONCAT(U.nombre, ' ', U.ap_paterno, ' ', ISNULL(U.ap_materno, '')) AS usuario,
        EI.nombre_estacion AS estacion_partida,
        EF.nombre_estacion AS lugar_llegada,
        V.duracion AS tiempo_minutos,
        V.costo
    FROM movilidad.viaje AS V
    INNER JOIN movilidad.tarjeta_movilidad AS T
        ON V.id_tarjeta_movilidad = T.id_tarjeta_movilidad
    INNER JOIN usuarios.usuario AS U
        ON T.id_usuario = U.id_usuario
    INNER JOIN movilidad.estacion AS EI
        ON V.id_estacion_inicio = EI.id_estacion
    INNER JOIN movilidad.estacion AS EF
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
/* PROCEDIMIENTOS ALMACENADOS (SPs)                             */
/*==============================================================*/

/*
SP 1: Registro general de usuarios a la base de datos (con perfiles y teléfono opcional)
*/
CREATE OR ALTER PROCEDURE usuarios.sp_RegistrarUsuario
(
    @id_usuario INT,
    @correo VARCHAR(100),
    @nombre VARCHAR(50),
    @ap_paterno VARCHAR(50),
    @ap_materno VARCHAR(50) = NULL,
    @codigo_ine CHAR(18),
    @fecha_nacimiento DATE,
    @genero CHAR(1),
    @telefono VARCHAR(15) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO usuarios.usuario (id_usuario, correo, nombre, ap_paterno, ap_materno, codigo_ine, fecha_nacimiento, genero)
        VALUES (@id_usuario, @correo, @nombre, @ap_paterno, @ap_materno, @codigo_ine, @fecha_nacimiento, @genero);

        IF @telefono IS NOT NULL
        BEGIN
            INSERT INTO usuarios.telefono (id_telefono, id_usuario, telefono)
            VALUES (@id_usuario, @id_usuario, @telefono);
        END

        COMMIT TRANSACTION;
        PRINT 'Usuario registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 2: Alta de un Plan/Membresía vinculada a un usuario (incluye costo de tarjeta $50 si es la primera y recargas)
*/
CREATE OR ALTER PROCEDURE usuarios.sp_AltaUsuarioPlan
(
    @id_suscripcion INT,
    @id_usuario INT,
    @id_tipo_membresia INT,
    @id_metodo_pago INT,
    @id_tarjeta INT,
    @tipo_emision VARCHAR(20), -- 'Primera' o 'Reposicion'
    @saldo_tarjeta DECIMAL(10,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @costo_membresia DECIMAL(10,2);
        DECLARE @duracion_membresia INT;
        
        SELECT @costo_membresia = costo_base, @duracion_membresia = duracion_dias
        FROM movilidad.tipo_membresia
        WHERE id_tipo_membresia = @id_tipo_membresia;

        -- Registrar suscripción
        INSERT INTO movilidad.suscripcion (id_suscripcion, estado, fecha_fin, fecha_inicio, id_usuario, id_metodo_pago, id_tipo_membresia)
        VALUES (@id_suscripcion, 'A', DATEADD(DAY, @duracion_membresia, GETDATE()), GETDATE(), @id_usuario, @id_metodo_pago, @id_tipo_membresia);

        -- Registrar tarjeta de movilidad (Costo de $50 pesos la primera vez)
        DECLARE @costo_emision DECIMAL(10,2) = 0.0;
        IF @tipo_emision = 'Primera'
            SET @costo_emision = 50.0;

        INSERT INTO movilidad.tarjeta_movilidad (id_tarjeta_movilidad, id_tarjeta_reposicion, id_usuario, fecha_baja, saldo, codigo_QR, fecha_emision, activa, tipo_emision)
        VALUES (@id_tarjeta, NULL, @id_usuario, DATEADD(YEAR, 5, GETDATE()), @saldo_tarjeta, CAST(@id_tarjeta AS VARBINARY(100)), GETDATE(), 1, @tipo_emision);

        COMMIT TRANSACTION;
        PRINT 'Plan y tarjeta dados de alta correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 3: Registrar el inicio y finalización de un viaje
*/
CREATE OR ALTER PROCEDURE movilidad.sp_RegistrarViaje
(
    @id_viaje INT,
    @id_bicicleta INT,
    @id_estacion_inicio INT,
    @id_estacion_fin INT,
    @id_tarjeta_movilidad INT,
    @hora_inicio DATETIME,
    @hora_fin DATETIME,
    @num_referencia VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar duración del viaje en minutos
        DECLARE @duracion INT;
        SET @duracion = DATEDIFF(MINUTE, @hora_inicio, @hora_fin);

        -- Obtener usuario y tipo de membresía
        DECLARE @id_usuario INT;
        DECLARE @id_tipo_membresia INT;
        
        SELECT @id_usuario = id_usuario 
        FROM movilidad.tarjeta_movilidad 
        WHERE id_tarjeta_movilidad = @id_tarjeta_movilidad;

        SELECT @id_tipo_membresia = id_tipo_membresia 
        FROM movilidad.suscripcion 
        WHERE id_usuario = @id_usuario AND estado = 'A';

        -- Calcular costo
        DECLARE @costo DECIMAL(10,2) = 0.0;
        IF @id_tipo_membresia IS NOT NULL
        BEGIN
            DECLARE @tiempo_excedente INT;
            DECLARE @tarifa_excedente DECIMAL(10,2);
            
            SELECT @tiempo_excedente = tiempo_excedente, @tarifa_excedente = tarifa_excedente
            FROM movilidad.tipo_membresia
            WHERE id_tipo_membresia = @id_tipo_membresia;

            SET @costo = movilidad.fn_calcular_tarifa_excedente(@duracion, @tiempo_excedente, @tarifa_excedente);
        END

        INSERT INTO movilidad.viaje (id_viaje, duracion, fecha, ruta, hora_inicio, hora_fin, num_referencia, id_bicicleta, id_estacion_inicio, id_estacion_fin, id_tarjeta_movilidad, costo)
        VALUES (@id_viaje, @duracion, CAST(@hora_inicio AS DATE), 'RUTA_TRIP', @hora_inicio, @hora_fin, @num_referencia, @id_bicicleta, @id_estacion_inicio, @id_estacion_fin, @id_tarjeta_movilidad, @costo);

        COMMIT TRANSACTION;
        PRINT 'Viaje registrado con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 4: Registrar un Rondín realizado por un empleado
*/
CREATE OR ALTER PROCEDURE personal.sp_RegistrarRondin
(
    @id_empleado INT,
    @id_empleado_supervisor INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO personal.rondin (id_empleado, id_empleado_supervisor)
        VALUES (@id_empleado, @id_empleado_supervisor);

        COMMIT TRANSACTION;
        PRINT 'Rondin registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 5: Eliminar un usuario de forma segura
*/
CREATE OR ALTER PROCEDURE usuarios.sp_EliminarUsuario
(
    @id_usuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- El borrado en cascada (ON DELETE CASCADE) se encarga de eliminar automáticamente
        -- los registros relacionados en teléfono, suscripción, tarjeta, viaje, etc.
        DELETE FROM usuarios.usuario
        WHERE id_usuario = @id_usuario;

        COMMIT TRANSACTION;
        PRINT 'Usuario y todos sus registros relacionados eliminados en cascada.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 6: Modificar los datos de una Falta (fecha fin, descripción y motivo)
*/
CREATE OR ALTER PROCEDURE personal.sp_ModificarFalta
(
    @id_falta INT,
    @fecha_fin DATE,
    @descripcion VARCHAR(200),
    @id_motivo INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE personal.falta
        SET fecha_fin = @fecha_fin,
            descripcion = @descripcion,
            id_motivo = @id_motivo
        WHERE id_falta = @id_falta;

        COMMIT TRANSACTION;
        PRINT 'Falta modificada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 7: Borrar un método de pago (cancela suscripciones si es el único asociado)
*/
CREATE OR ALTER PROCEDURE movilidad.sp_BorrarMetodoPago
(
    @id_metodo_pago INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- El trigger trg_metodo_pago_cancela_suscripcion se disparará automáticamente
        -- al borrar el registro de metodo_pago, cancelando la suscripción asociada.
        DELETE FROM movilidad.metodo_pago
        WHERE id_metodo_pago = @id_metodo_pago;

        COMMIT TRANSACTION;
        PRINT 'Método de pago eliminado y suscripciones asociadas canceladas.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 8: Registrar un Incidente vial o de bicicleta
*/
CREATE OR ALTER PROCEDURE incidentes.sp_RegistrarIncidente
(
    @id_incidente INT,
    @calle VARCHAR(50),
    @numero INT,
    @id_colonia INT,
    @fecha DATE,
    @latitud VARCHAR(20),
    @longitud VARCHAR(20),
    @id_viaje INT,
    @id_tipo_incidente INT,
    @id_empleado INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO incidentes.incidente (id_incidente, calle, numero, id_colonia, fecha, latitud, longitud, id_viaje, id_tipo_incidente, id_empleado)
        VALUES (@id_incidente, @calle, @numero, @id_colonia, @fecha, @latitud, @longitud, @id_viaje, @id_tipo_incidente, @id_empleado);

        COMMIT TRANSACTION;
        PRINT 'Incidente registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 9: Actualizar los datos de asignación de un supervisor en un Rondín
*/
CREATE OR ALTER PROCEDURE personal.sp_ActualizarRondin
(
    @id_empleado INT,
    @id_empleado_supervisor INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE personal.rondin
        SET id_empleado_supervisor = @id_empleado_supervisor
        WHERE id_empleado = @id_empleado;

        COMMIT TRANSACTION;
        PRINT 'Supervisor de Rondín actualizado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 10: Reposición de Tarjeta de Movilidad (costo semántico $80 por reposición)
*/
CREATE OR ALTER PROCEDURE movilidad.sp_ReposicionTarjeta
(
    @id_nueva_tarjeta INT,
    @id_tarjeta_anterior INT,
    @saldo_inicial DECIMAL(10,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_usuario INT;
        SELECT @id_usuario = id_usuario
        FROM movilidad.tarjeta_movilidad
        WHERE id_tarjeta_movilidad = @id_tarjeta_anterior;

        -- Descontar el costo semántico de la reposición ($80) del saldo inicial si corresponde
        DECLARE @saldo_final DECIMAL(10,2);
        SET @saldo_final = @saldo_inicial - 80.00;
        IF @saldo_final < 0
            SET @saldo_final = 0.00;

        -- El trigger trg_tarjeta_desactiva_por_reposicion se ejecutará tras el INSERT,
        -- desactivando la tarjeta anterior automáticamente.
        INSERT INTO movilidad.tarjeta_movilidad (id_tarjeta_movilidad, id_tarjeta_reposicion, id_usuario, fecha_baja, saldo, codigo_QR, fecha_emision, activa, tipo_emision)
        VALUES (@id_nueva_tarjeta, @id_tarjeta_anterior, @id_usuario, DATEADD(YEAR, 5, GETDATE()), @saldo_final, CAST(@id_nueva_tarjeta AS VARBINARY(100)), GETDATE(), 1, 'Reposicion');

        COMMIT TRANSACTION;
        PRINT 'Reposición de tarjeta registrada con costo de $80 aplicado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*
SP 11: Buscador de usuarios por coincidencia de nombre (Buscador con LIKE)
*/
CREATE OR ALTER PROCEDURE usuarios.sp_BuscarUsuarioPorNombre
(
    @nombre_busqueda VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_usuario, correo, CONCAT(nombre, ' ', ap_paterno, ' ', ISNULL(ap_materno, '')) AS nombre_completo, codigo_ine, edad, genero
    FROM usuarios.usuario
    WHERE nombre LIKE '%' + @nombre_busqueda + '%'
       OR ap_paterno LIKE '%' + @nombre_busqueda + '%'
       OR ap_materno LIKE '%' + @nombre_busqueda + '%';
END;
GO

/*
SPs de Reportes / Estadísticas (Wrappers para informes requeridos)
===================================================================*/

/*
SP de Reporte 1: Estadísticas de los daños en las bicicletas con mayor frecuencia
*/
CREATE OR ALTER PROCEDURE reportes.sp_EstadisticaDanosBicicletas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 10 
        ti.nombre_incidente AS tipo_dano, 
        COUNT(i.id_incidente) AS total_reportes
    FROM incidentes.incidente i
    INNER JOIN catalogo.tipo_incidente ti 
        ON i.id_tipo_incidente = ti.id_tipo_incidente
    GROUP BY ti.nombre_incidente
    ORDER BY total_reportes DESC;
END;
GO

/*
SP de Reporte 2: Top 5 de los accidentes más frecuentes (descripción del daño y cantidad)
*/
CREATE OR ALTER PROCEDURE reportes.sp_TopAccidentesMasFrecuentes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 5 
        ti.descripcion_incidente AS descripcion_dano, 
        COUNT(i.id_incidente) AS cantidad_accidentes
    FROM incidentes.incidente i
    INNER JOIN catalogo.tipo_incidente ti 
        ON i.id_tipo_incidente = ti.id_tipo_incidente
    GROUP BY ti.descripcion_incidente
    ORDER BY cantidad_accidentes DESC;
END;
GO

/*
SP de Reporte 3: Estaciones con más reportes de accidentes en un periodo de tiempo
*/
CREATE OR ALTER PROCEDURE reportes.sp_EstacionesMasAccidentes
(
    @fecha_inicio DATE,
    @fecha_fin DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 10
        e.nombre_estacion,
        COUNT(i.id_incidente) AS numero_accidentes
    FROM incidentes.incidente i
    INNER JOIN movilidad.viaje v 
        ON i.id_viaje = v.id_viaje
    INNER JOIN movilidad.estacion e 
        ON v.id_estacion_inicio = e.id_estacion
    WHERE i.fecha BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY e.nombre_estacion
    ORDER BY numero_accidentes DESC;
END;
GO

/*
SP de Reporte 4: Total de usuarios por rangos de edades
*/
CREATE OR ALTER PROCEDURE reportes.sp_TotalUsuariosPorRangoEdad
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        usuarios.fn_obtener_rango_edad(edad) AS rango_edad,
        COUNT(id_usuario) AS total_usuarios
    FROM usuarios.usuario
    GROUP BY usuarios.fn_obtener_rango_edad(edad)
    ORDER BY total_usuarios DESC;
END;
GO
