/*=========================================================
  PROYECTO : ECOBICI
  AUTORES  : Díaz Antúnez David
             Hernández Acosta Mauricio Gabriel
             Sánchez Luján César Ricardo

  FECHA    : 01/06/2026
  VERSIÓN  : 1.0 FINAL

  DESCRIPCIÓN:
  Script de consultas, informes / estadisticas
=========================================================*/

USE Ecobici_SQuipoL;
GO
--1.     Estadísticas de los daños en las bicicletas con mayor frecuencia. 
SELECT
    b.id_bicicleta,
    COUNT(i.id_incidente) AS TotalDaños
FROM movilidad.BICICLETA b
INNER JOIN movilidad.VIAJE v
    ON b.id_bicicleta = v.id_bicicleta
INNER JOIN incidentes.INCIDENTE i
    ON v.id_viaje = i.id_viaje
GROUP BY b.id_bicicleta
HAVING COUNT(i.id_incidente) > 0
ORDER BY TotalDaños DESC;


--2.     Top 5 de los accidentes más frecuentes (descripción del daño, cantidad)

SELECT TOP 5
    ti.nombre_incidente AS [Descripcion del daño],
    COUNT(*) AS Cantidad
FROM incidentes.INCIDENTE i
INNER JOIN catalogo.TIPO_INCIDENTE ti
    ON i.id_tipo_incidente = ti.id_tipo_incidente
GROUP BY ti.nombre_incidente
ORDER BY Cantidad DESC;


--3. Estaciones con más reportes de accidentes. Listado de estaciones con el número de accidentes en un periodo de tiempo (fecha inicio – fecha fin) ordenados de mayor a menor

DECLARE @FechaInicio DATE = '2026-01-01';
DECLARE @FechaFin DATE = '2027-12-31';

SELECT
    e.nombre_estacion,
    YEAR(i.fecha) AS Año,
    MONTH(i.fecha) AS Mes,
    COUNT(*) AS TotalAccidentes
FROM incidentes.INCIDENTE i
JOIN movilidad.VIAJE v
    ON i.id_viaje = v.id_viaje
JOIN movilidad.ESTACION e
    ON v.id_estacion_inicio = e.id_estacion
GROUP BY
    e.nombre_estacion,
    YEAR(i.fecha),
    MONTH(i.fecha)
ORDER BY TotalAccidentes DESC;

--4.     Total de accidentes en un rango de fechas, listados de mayor a menor (fecha y tipo de accidente y número de accidentes)

SELECT
    CASE MONTH(i.fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS Mes,
    ti.nombre_incidente AS TipoAccidente,
    COUNT(*) AS NumeroAccidentes
FROM incidentes.INCIDENTE i
INNER JOIN catalogo.TIPO_INCIDENTE ti
    ON i.id_tipo_incidente = ti.id_tipo_incidente
GROUP BY
    MONTH(i.fecha),
    ti.nombre_incidente
ORDER BY NumeroAccidentes DESC;

--5.     Total de usuarios por rangos de edades (10 a 15 años, 15-20 años, 20 a 30 años, más de 30 años)

SELECT
    CASE
        WHEN u.edad BETWEEN 10 AND 15 THEN '10-15'
        WHEN u.edad BETWEEN 16 AND 20 THEN '16-20'
        WHEN u.edad BETWEEN 21 AND 30 THEN '21-30'
        ELSE 'Mas de 30'
    END AS RangoEdad,
    tm.descripcion AS TipoMembresia,
    COUNT(*) AS TotalUsuarios
FROM usuarios.USUARIO u
JOIN movilidad.SUSCRIPCION s
    ON u.id_usuario = s.id_usuario
JOIN movilidad.TIPO_MEMBRESIA tm
    ON s.id_tipo_membresia = tm.id_tipo_membresia
GROUP BY
    CASE
        WHEN u.edad BETWEEN 10 AND 15 THEN '10-15'
        WHEN u.edad BETWEEN 16 AND 20 THEN '16-20'
        WHEN u.edad BETWEEN 21 AND 30 THEN '21-30'
        ELSE 'Mas de 30'
    END,
    tm.descripcion
ORDER BY RangoEdad;

--6.     Inventario de las bicicletas (todos los datos de las bicicletas) por estaciones con el número (total) de viajes, por un periodo de tiempo, incluir el número de accidentes si ha tenido

--DECLARE @FechaInicio DATE = '2026-01-01';
--DECLARE @FechaFin DATE = '2027-12-31';

SELECT
    e.nombre_estacion,
    b.id_bicicleta,
    b.modelo,
    b.num_serie,
    eb.descripcion AS EstadoBicicleta,
    bc.color,
    COUNT(DISTINCT v.id_viaje) AS TotalViajes,
    COUNT(DISTINCT i.id_incidente) AS TotalAccidentes
FROM movilidad.BICICLETA b
INNER JOIN movilidad.ESTACION e
    ON b.id_estacion = e.id_estacion
INNER JOIN catalogo.ESTADO_BICI eb
    ON b.id_estado_bici = eb.id_estado_bici
INNER JOIN catalogo.BICICLETA_COLOR bc
    ON b.id_bicicleta_color = bc.id_bicicleta_color
LEFT JOIN movilidad.VIAJE v
    ON b.id_bicicleta = v.id_bicicleta
    AND v.fecha BETWEEN @FechaInicio AND @FechaFin
LEFT JOIN incidentes.INCIDENTE i
    ON v.id_viaje = i.id_viaje
GROUP BY
    e.nombre_estacion,
    b.id_bicicleta,
    b.modelo,
    b.num_serie,
    eb.descripcion,
    bc.color
ORDER BY
    TotalViajes DESC,
    TotalAccidentes DESC;

--7.     Listado de usuarios (datos generales), datos de su membresía y el tiempo en meses que tienen la membresía.

SELECT
    u.id_usuario,
    u.nombre,
    u.ap_paterno,
    u.ap_materno,
    u.correo,
    u.edad,
    tm.descripcion AS TipoMembresia,
    s.fecha_inicio,
    s.fecha_fin,
    DATEDIFF(MONTH, s.fecha_inicio, GETDATE()) AS MesesConMembresia
FROM usuarios.USUARIO u
INNER JOIN movilidad.SUSCRIPCION s
    ON u.id_usuario = s.id_usuario
INNER JOIN movilidad.TIPO_MEMBRESIA tm
    ON s.id_tipo_membresia = tm.id_tipo_membresia
ORDER BY MesesConMembresia DESC;

--8.     Agentes mejor recocidos en un mes especifico, para eso cada agente auxilia a un usuario en algún incidente y el usuario llena una pequeña encuesta.

SELECT
    a.id_empleado AS Agente,
    e.nombre_pila,
    e.ap_paterno,
    MONTH(en.fecha) AS Mes,
    COUNT(en.id_encuesta) AS TotalEncuestas,
    ROUND(AVG(CAST(en.puntuacion AS DECIMAL(5,2))),2) AS PromedioPuntuacion
FROM personal.AGENTE a
INNER JOIN personal.EMPLEADO e
    ON a.id_empleado = e.id_empleado
INNER JOIN incidentes.INCIDENTE i
    ON a.id_empleado = i.id_empleado
INNER JOIN incidentes.ENCUESTA en
    ON i.id_incidente = en.id_incidente
GROUP BY
    a.id_empleado,
    e.nombre_pila,
    e.ap_paterno,
    MONTH(en.fecha)
ORDER BY
    PromedioPuntuacion DESC,
    TotalEncuestas DESC;

--9.     Reporte diario de los empleados que hacen rondines (fecha, descripción, si hubo incidentes o no, número de accidentes, estación donde se obtiene el reporte). 
--		 Ellos cuentan a su vez con un supervisor que también es empleado que hace rondines, este dato también deberá aparecer en el informe.

SELECT
    r.fecha,
    r.descripcion,

    CASE
        WHEN r.bandera_incidente = 1 THEN 'Si'
        ELSE 'No'
    END AS HuboIncidentes,

    r.numero_incidentes,

    est.nombre_estacion,

    emp.nombre_pila + ' ' + emp.ap_paterno AS EmpleadoRondin,

    ISNULL(
        sup.nombre_pila + ' ' + sup.ap_paterno,
        'Sin supervisor'
    ) AS Supervisor

FROM reportes.REPORTE r

INNER JOIN personal.EMPLEADO emp
    ON r.id_empleado = emp.id_empleado

INNER JOIN personal.RONDIN ro
    ON emp.id_empleado = ro.id_empleado

LEFT JOIN personal.EMPLEADO sup
    ON ro.id_empleado_supervisor = sup.id_empleado

LEFT JOIN movilidad.ESTACION est
    ON emp.id_empleado = est.id_empleado

ORDER BY r.fecha DESC;

--10.  Listado de empleados con su tipo, todos sus datos

SELECT
    e.*,a.*,r.*,
    CASE
        WHEN a.id_empleado IS NOT NULL THEN 'Agente'
        WHEN r.id_empleado IS NOT NULL THEN 'Empleado de Rondin'
        ELSE 'Empleado'
    END AS TipoEmpleado
FROM personal.EMPLEADO e
LEFT JOIN personal.AGENTE a
    ON e.id_empleado = a.id_empleado
LEFT JOIN personal.RONDIN r
    ON e.id_empleado = r.id_empleado
ORDER BY e.id_empleado;

--11.  Informe de los recorridos (viajes), por estación y/o por periodo de tiempo (fecha inicio y fecha fin); 
--		nombre del usuario, estación de partida, lugar de llegada, tiempo en minutos del recorrido y costo.

--DECLARE @FechaInicio DATE = '2026-01-01';
--DECLARE @FechaFin DATE = '2027-12-31';

SELECT
    v.id_viaje,
    v.ruta,
    v.num_referencia,

    u.nombre + ' ' + u.ap_paterno + ' ' + u.ap_materno AS Usuario,

    ei.nombre_estacion AS EstacionPartida,
    ef.nombre_estacion AS EstacionLlegada,

    v.fecha,
    v.duracion AS TiempoMinutos,
    v.costo

FROM movilidad.VIAJE v

INNER JOIN movilidad.TARJETA_MOVILIDAD tm
    ON v.id_tarjeta_movilidad = tm.id_tarjeta_movilidad

INNER JOIN usuarios.USUARIO u
    ON tm.id_usuario = u.id_usuario

INNER JOIN movilidad.ESTACION ei
    ON v.id_estacion_inicio = ei.id_estacion

INNER JOIN movilidad.ESTACION ef
    ON v.id_estacion_fin = ef.id_estacion

WHERE v.fecha BETWEEN @FechaInicio AND @FechaFin

ORDER BY v.fecha DESC;

--12.  Épocas del año con número de recorridos ordenados de mayor a menor

SELECT
    t.nombre_temp AS Temporada,

    CASE MONTH(v.fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS Mes,

    COUNT(*) AS TotalRecorridos

FROM movilidad.VIAJE v
INNER JOIN reportes.TEMPORADA t
ON CASE
    WHEN MONTH(v.fecha) IN (3,4,5) THEN 1
    WHEN MONTH(v.fecha) IN (6,7,8) THEN 2
    WHEN MONTH(v.fecha) IN (9,10,11) THEN 3
    ELSE 4
END = t.id_temporada

GROUP BY
    t.nombre_temp,
    MONTH(v.fecha)

ORDER BY
    TotalRecorridos DESC,
    MONTH(v.fecha);

--13.  Obtener pada cada agente sus datos personales y el listado de los accidentes que ha atendido (tipo de accidente, fecha, lugar)

SELECT
    a.id_empleado AS Agente,

    e.nombre_pila,
    e.ap_paterno,
    e.ap_materno,
    e.rfc, 
	e.genero,
	e.telefono,

    ti.nombre_incidente AS TipoAccidente,

    i.fecha,

    est.nombre_estacion AS Lugar

FROM personal.AGENTE a

INNER JOIN personal.EMPLEADO e
    ON a.id_empleado = e.id_empleado

INNER JOIN incidentes.INCIDENTE i
    ON a.id_empleado = i.id_empleado

INNER JOIN catalogo.TIPO_INCIDENTE ti
    ON i.id_tipo_incidente = ti.id_tipo_incidente

INNER JOIN movilidad.VIAJE v
    ON i.id_viaje = v.id_Viaje

INNER JOIN movilidad.ESTACION est
    ON v.id_estacion_inicio = est.id_estacion

ORDER BY
    a.id_empleado,
    i.fecha DESC;

--14. Para el área de recursos humanos es importante un informe mensual de todos los empleados y sus datos: RFC, nombre completo y sueldo, 
--asimismo nombre de los empleados y puesto de los que tengan un sueldo de 13000 mensuales y pertenezcan a la tercera edad.

SELECT
    e.rfc,
    e.nombre_pila + ' ' + e.ap_paterno + ' ' + e.ap_materno AS NombreCompleto,

    CASE e.tipo_empleado
        WHEN 'AG' THEN 'Agente'
        WHEN 'R'  THEN 'Empleado de Rondin'
        WHEN 'M'  THEN 'Mantenimiento'
        WHEN 'AD' THEN 'Administracion'
        ELSE e.tipo_empleado
    END AS Puesto,

    e.sueldo,

    DATEDIFF(YEAR,e.fecha_nacimiento,GETDATE()) AS Edad,

    CASE
        WHEN e.sueldo = 13000
         AND DATEDIFF(YEAR,e.fecha_nacimiento,GETDATE()) >= 60
        THEN 'SI'
        ELSE 'NO'
    END AS CumpleCriterioRH

FROM personal.EMPLEADO e
ORDER BY e.ap_paterno,e.ap_materno, e.nombre_pila desc;

--15. Estadística de faltas de los empleados en un periodo de tiempo: tipo de falta, total de ese tipo de falta en el periodo elegido.

--DECLARE @FechaInicio DATE = '2026-06-01';
--DECLARE @FechaFin DATE = '2026-12-31';

SELECT
    YEAR(f.fecha) AS Anio,

    CASE MONTH(f.fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS Mes,

    m.motivo_falta AS TipoFalta,

    COUNT(*) AS TotalFaltas

FROM personal.FALTA f
INNER JOIN catalogo.MOTIVO m
    ON f.id_motivo = m.id_motivo

WHERE f.fecha BETWEEN @FechaInicio AND @FechaFin

GROUP BY
    YEAR(f.fecha),
    MONTH(f.fecha),
    m.motivo_falta

ORDER BY
    TotalFaltas DESC,
    YEAR(f.fecha),
    MONTH(f.fecha);
