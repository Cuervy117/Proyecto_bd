/*
==============================================================
PROYECTO : ECOBICI
  AUTORES  : Díaz Antúnez David
             Hernández Acosta Mauricio Gabriel
             Sánchez Luján César Ricardo

  FECHA    : 01/06/2026
  VERSIÓN  : 1.0 FINAL
Descripción:
Script DCL para la creación de roles, logins, usuarios
y asignación de permisos para la base de datos
Ecobici_SQuipoL.
==============================================================
*/

/*==============================================================
ELIMINAR USUARIOS DE LA BASE DE DATOS SI EXISTEN
==============================================================*/

USE Ecobici_SQuipoL;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuarioConsulta')
    DROP USER usuarioConsulta;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuarioGestor')
    DROP USER usuarioGestor;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuarioAdministrador')
    DROP USER usuarioAdministrador;
GO

/*==============================================================
ELIMINAR ROLES SI EXISTEN
==============================================================*/

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rolConsulta')
    DROP ROLE rolConsulta;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rolGestor')
    DROP ROLE rolGestor;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rolAdministrador')
    DROP ROLE rolAdministrador;
GO

/*==============================================================
ELIMINAR LOGINS SI EXISTEN
==============================================================*/

USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuarioConsulta')
    DROP LOGIN usuarioConsulta;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuarioGestor')
    DROP LOGIN usuarioGestor;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuarioAdministrador')
    DROP LOGIN usuarioAdministrador;
GO

/*==============================================================
CREACION DE ROLES
==============================================================*/

USE Ecobici_SQuipoL;
GO

CREATE ROLE rolConsulta;
GO

CREATE ROLE rolGestor;
GO

CREATE ROLE rolAdministrador;
GO

/*==============================================================
PERMISOS DEL ROL CONSULTA
==============================================================*/

GRANT SELECT ON SCHEMA::catalogo TO rolConsulta;
GRANT SELECT ON SCHEMA::usuarios TO rolConsulta;
GRANT SELECT ON SCHEMA::movilidad TO rolConsulta;
GRANT SELECT ON SCHEMA::incidentes TO rolConsulta;
GRANT SELECT ON SCHEMA::personal TO rolConsulta;
GRANT SELECT ON SCHEMA::reportes TO rolConsulta;
GO

/*==============================================================
PERMISOS DEL ROL GESTOR
==============================================================*/

GRANT SELECT, INSERT, UPDATE
ON SCHEMA::usuarios
TO rolGestor;

GRANT SELECT, INSERT, UPDATE
ON SCHEMA::movilidad
TO rolGestor;

GRANT SELECT, INSERT, UPDATE
ON SCHEMA::incidentes
TO rolGestor;

GRANT SELECT
ON SCHEMA::catalogo
TO rolGestor;

GRANT SELECT
ON SCHEMA::personal
TO rolGestor;

GRANT SELECT
ON SCHEMA::reportes
TO rolGestor;
GO

/*==============================================================
PERMISOS DEL ROL ADMINISTRADOR
==============================================================*/

GRANT CONTROL
ON DATABASE::Ecobici_SQuipoL
TO rolAdministrador;
GO

/*==============================================================
CREACION DE LOGINS
==============================================================*/

USE master;
GO

CREATE LOGIN usuarioConsulta
WITH PASSWORD = '1234Zaq*';
GO

CREATE LOGIN usuarioGestor
WITH PASSWORD = '1234Zaq*';
GO

CREATE LOGIN usuarioAdministrador
WITH PASSWORD = '1234Zaq*';
GO

/*==============================================================
CREACION DE USUARIOS EN LA BASE DE DATOS
==============================================================*/

USE Ecobici_SQuipoL;
GO

CREATE USER usuarioConsulta
FOR LOGIN usuarioConsulta;
GO

CREATE USER usuarioGestor
FOR LOGIN usuarioGestor;
GO

CREATE USER usuarioAdministrador
FOR LOGIN usuarioAdministrador;
GO

/*==============================================================
ASIGNACION DE ROLES
==============================================================*/

ALTER ROLE rolConsulta
ADD MEMBER usuarioConsulta;
GO

ALTER ROLE rolGestor
ADD MEMBER usuarioGestor;
GO

ALTER ROLE rolAdministrador
ADD MEMBER usuarioAdministrador;
GO

/*==============================================================
PROCEDIMIENTO PARA CREAR USUARIOS DINAMICAMENTE
==============================================================*/

CREATE OR ALTER PROCEDURE personal.pusuCrearUsuarioBD
(
    @Usuario SYSNAME,
    @Password VARCHAR(12),
    @Rol VARCHAR(20)
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL =
    'CREATE LOGIN ' + QUOTENAME(@Usuario) +
    ' WITH PASSWORD = ''' + @Password + '''';

    EXEC(@SQL);

    SET @SQL =
    'USE Ecobici_SQuipoL;
      CREATE USER ' + QUOTENAME(@Usuario) +
    ' FOR LOGIN ' + QUOTENAME(@Usuario);

    EXEC(@SQL);

    IF UPPER(@Rol) = 'CONSULTA'
        SET @SQL =
        'ALTER ROLE rolConsulta ADD MEMBER ' + QUOTENAME(@Usuario);

    ELSE IF UPPER(@Rol) = 'GESTOR'
        SET @SQL =
        'ALTER ROLE rolGestor ADD MEMBER ' + QUOTENAME(@Usuario);

    ELSE IF UPPER(@Rol) = 'ADMINISTRADOR'
        SET @SQL =
        'ALTER ROLE rolAdministrador ADD MEMBER ' + QUOTENAME(@Usuario);

    EXEC(@SQL);

END;
GO

/*==============================================================
EJEMPLOS DE USO
==============================================================*/

-- EXEC personal.pusuCrearUsuarioBD
--      'usuarioPrueba',
--      'Abcd1234*',
--      'CONSULTA';

-- EXEC personal.pusuCrearUsuarioBD
--      'usuarioGestor2',
--      'Abcd1234*',
--      'GESTOR';

-- EXEC personal.pusuCrearUsuarioBD
--      'usuarioAdmin2',
--      'Abcd1234*',
--      'ADMINISTRADOR';

PRINT 'SEGURIDAD CONFIGURADA CORRECTAMENTE';
GO
