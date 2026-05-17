USE Ecobici_SQuipoL;
GO

/*==============================================================*/
/* CATALOGOS                                                    */
/*==============================================================*/

INSERT INTO catalogo.ESTADO_CIVIL VALUES
(1,'Soltero',1),
(2,'Casado',1),
(3,'Divorciado',1),
(4,'Viudo',1);
GO

INSERT INTO catalogo.ALCALDIA VALUES
(1,'Coyoacan'),
(2,'Benito Juarez'),
(3,'Cuauhtemoc'),
(4,'Miguel Hidalgo'),
(5,'Alvaro Obregon');
GO

INSERT INTO catalogo.BICICLETA_COLOR VALUES
(1,'Verde'),
(2,'Blanco'),
(3,'Negro'),
(4,'Rojo'),
(5,'Azul');
GO

INSERT INTO catalogo.ESTADO_BICI VALUES
(1,'Disponible para uso','Disponible'),
(2,'En mantenimiento','Mantenimiento'),
(3,'Fuera de servicio','Baja');
GO

INSERT INTO catalogo.CATALOGO_IDIOMAS VALUES
(1,'Español'),
(2,'Ingles'),
(3,'Frances');
GO

INSERT INTO catalogo.ESPECIALIDAD VALUES
(1,'Reparacion'),
(2,'Limpieza'),
(3,'Transporte');
GO

INSERT INTO catalogo.MOTIVO VALUES
(1,'Retardo'),
(2,'Inasistencia'),
(3,'Permiso');
GO

INSERT INTO catalogo.TIPO_INCIDENTE VALUES
(1,'Choque','Choque con vehiculo'),
(2,'Caida','Caida del usuario'),
(3,'Robo','Intento de robo'),
(4,'Falla mecanica','Problema con bicicleta');
GO

/*==============================================================*/
/* EMPLEADOS                                                    */
/*==============================================================*/

INSERT INTO personal.EMPLEADO VALUES
(1,'R','M',12500,'1989-02-10',5511111111,'RFCEMP0000001','Luis','Perez','Lopez',1),
(2,'R','F',12800,'1991-03-15',5522222222,'RFCEMP0000002','Maria','Garcia','Diaz',2),
(3,'R','M',13200,'1988-07-20',5533333333,'RFCEMP0000003','Carlos','Torres','Ruiz',1),
(4,'R','F',12900,'1990-11-05',5544444444,'RFCEMP0000004','Laura','Santos','Mora',2),
(5,'R','M',14000,'1985-01-01',5555555555,'RFCEMP0000005','Jorge','Mendez','Rios',1),

(6,'AG','M',16000,'1987-04-11',5566666666,'RFCEMP0000006','Diego','Hernandez','Luna',1),
(7,'AG','F',16200,'1992-05-18',5577777777,'RFCEMP0000007','Ana','Lopez','Perez',2),
(8,'AG','M',16500,'1986-08-09',5588888888,'RFCEMP0000008','Pedro','Ramirez','Soto',1),
(9,'AG','F',17000,'1993-01-30',5599999999,'RFCEMP0000009','Lucia','Flores','Reyes',1),
(10,'AG','M',16800,'1984-06-22',5512121212,'RFCEMP0000010','Mario','Vega','Ruiz',2),

(11,'AD','F',22000,'1980-03-12',5523232323,'RFCEMP0000011','Patricia','Campos','Diaz',2),
(12,'AD','M',24000,'1979-07-17',5534343434,'RFCEMP0000012','Fernando','Castro','Lopez',1),

(13,'M','M',15000,'1988-09-21',5545454545,'RFCEMP0000013','Raul','Jimenez','Sosa',1),
(14,'M','F',14800,'1991-12-01',5556565656,'RFCEMP0000014','Monica','Rojas','Lara',2),
(15,'M','M',15500,'1985-11-11',5567676767,'RFCEMP0000015','Ricardo','Navarro','Gil',1);
GO

/*==============================================================*/
/* SUBTIPOS EMPLEADOS                                           */
/*==============================================================*/

INSERT INTO personal.RONDIN VALUES
(1,NULL),
(2,1),
(3,1),
(4,2),
(5,3);
GO

INSERT INTO personal.AGENTE VALUES
(6,'Centro','Moto'),
(7,'Norte','Automovil'),
(8,'Sur','Moto'),
(9,'Poniente','Camioneta'),
(10,'Oriente','Moto');
GO

INSERT INTO personal.ADMINISTRACION VALUES
(11,'Contador','Oficina Central'),
(12,'Administrador','Oficina Norte');
GO

INSERT INTO personal.MANTENIMIENTO VALUES
(13,1),
(14,2),
(15,3);
GO

/*==============================================================*/
/* COLONIAS Y DOMICILIOS                                        */
/*==============================================================*/

INSERT INTO personal.COLONIA VALUES
(1,'Del Valle',2),
(2,'Roma Norte',3),
(3,'Condesa',4),
(4,'Copilco',1),
(5,'Santa Fe',5);
GO

INSERT INTO personal.DOMICILIO VALUES
(1,1,120,NULL,'Insurgentes',1),
(2,1,55,2,'Division del Norte',2),
(3,1,340,NULL,'Reforma',3),
(4,1,78,NULL,'Universidad',4),
(5,1,220,NULL,'Patriotismo',5);
GO

/*==============================================================*/
/* IDIOMAS                                                      */
/*==============================================================*/

INSERT INTO personal.IDIOMAS VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,1),
(6,1),
(7,2),
(8,1),
(9,3),
(10,1);
GO

/*==============================================================*/
/* FUNCIONES ADMINISTRACION                                     */
/*==============================================================*/

INSERT INTO personal.FUNCIONES VALUES
(1,11,'Control financiero'),
(2,11,'Nominas'),
(3,12,'Gestion operativa'),
(4,12,'Recursos humanos');
GO

/*==============================================================*/
/* USUARIOS                                                     */
/*==============================================================*/

INSERT INTO usuarios.USUARIO VALUES
(1,'juan@gmail.com','Juan','Perez','Lopez','INE00000000000001','2000-01-10','M'),
(2,'laura@gmail.com','Laura','Ruiz','Santos','INE00000000000002','1999-03-21','F'),
(3,'diego@gmail.com','Diego','Mora','Diaz','INE00000000000003','2001-05-12','M'),
(4,'ana@gmail.com','Ana','Lopez','Garcia','INE00000000000004','1998-02-28','F'),
(5,'mario@gmail.com','Mario','Hernandez','Luna','INE00000000000005','1997-09-18','M');
GO

INSERT INTO usuarios.TELEFONO VALUES
(1,1,'5510101010'),
(2,2,'5520202020'),
(3,3,'5530303030'),
(4,4,'5540404040'),
(5,5,'5550505050');
GO

/*==============================================================*/
/* MEMBRESIAS                                                   */
/*==============================================================*/

INSERT INTO movilidad.METODO_PAGO VALUES
(1,'2028-01-01','2025-01-01','T'),
(2,'2028-02-01','2025-02-01','P'),
(3,'2028-03-01','2025-03-01','T'),
(4,'2028-04-01','2025-04-01','P'),
(5,'2028-05-01','2025-05-01','T');
GO

INSERT INTO movilidad.TIPO_MEMBRESIA VALUES
(1,'Basica',30,'B',45,120,5,'N'),
(2,'Mensual',180,'M',60,450,3,'G'),
(3,'Premium',365,'P',90,1000,1,'C');
GO

INSERT INTO movilidad.SUSCRIPCION VALUES
(1,'A','2026-12-31','2026-01-01',1,1,1),
(2,'A','2026-12-31','2026-01-01',2,2,2),
(3,'A','2026-12-31','2026-01-01',3,3,3),
(4,'A','2026-12-31','2026-01-01',4,4,1),
(5,'A','2026-12-31','2026-01-01',5,5,2);
GO

/*==============================================================*/
/* TARJETAS                                                     */
/*==============================================================*/

INSERT INTO movilidad.TARJETA_MOVILIDAD VALUES
(1,NULL,1,'2030-01-01',150,0x1111,'2025-01-01',1,'Primera'),
(2,NULL,2,'2030-01-01',200,0x2222,'2025-01-01',1,'Primera'),
(3,NULL,3,'2030-01-01',180,0x3333,'2025-01-01',1,'Primera'),
(4,NULL,4,'2030-01-01',100,0x4444,'2025-01-01',1,'Primera'),
(5,NULL,5,'2030-01-01',250,0x5555,'2025-01-01',1,'Primera');
GO

/*==============================================================*/
/* ESTACIONES                                                   */
/*==============================================================*/

INSERT INTO movilidad.ESTACION VALUES
(1,10,15,'CU',1),
(2,8,15,'Roma',2),
(3,7,15,'Condesa',3),
(4,11,15,'Reforma',4),
(5,9,15,'Polanco',5);
GO

/*==============================================================*/
/* 25 BICICLETAS                                                */
/*==============================================================*/

INSERT INTO movilidad.BICICLETA VALUES
(1,'G',1001,1,1,1),
(2,'M',1002,1,1,2),
(3,'C',1003,1,1,3),
(4,'G',1004,2,1,4),
(5,'M',1005,1,1,5),

(6,'G',1006,1,2,1),
(7,'M',1007,1,2,2),
(8,'C',1008,1,2,3),
(9,'G',1009,2,2,4),
(10,'M',1010,1,2,5),

(11,'G',1011,1,3,1),
(12,'M',1012,1,3,2),
(13,'C',1013,1,3,3),
(14,'G',1014,2,3,4),
(15,'M',1015,1,3,5),

(16,'G',1016,1,4,1),
(17,'M',1017,1,4,2),
(18,'C',1018,1,4,3),
(19,'G',1019,2,4,4),
(20,'M',1020,1,4,5),

(21,'G',1021,1,5,1),
(22,'M',1022,1,5,2),
(23,'C',1023,1,5,3),
(24,'G',1024,2,5,4),
(25,'M',1025,1,5,5);
GO

/*==============================================================*/
/* TEMPORADA                                                    */
/*==============================================================*/

INSERT INTO reportes.TEMPORADA VALUES
(1,'Primavera 2026','2026-03-01','2026-05-31');
GO

/*==============================================================*/
/* REPORTES (20)                                                */
/*==============================================================*/

INSERT INTO reportes.REPORTE VALUES
(1,'2026-05-01','Reporte rondin',0,0,1,1),
(2,'2026-05-02','Reporte rondin',1,1,1,1),
(3,'2026-05-03','Reporte rondin',0,0,1,1),
(4,'2026-05-04','Reporte rondin',1,2,1,1),

(5,'2026-05-01','Reporte rondin',0,0,2,1),
(6,'2026-05-02','Reporte rondin',1,1,2,1),
(7,'2026-05-03','Reporte rondin',0,0,2,1),
(8,'2026-05-04','Reporte rondin',1,2,2,1),

(9,'2026-05-01','Reporte rondin',0,0,3,1),
(10,'2026-05-02','Reporte rondin',1,1,3,1),
(11,'2026-05-03','Reporte rondin',0,0,3,1),
(12,'2026-05-04','Reporte rondin',1,2,3,1),

(13,'2026-05-01','Reporte rondin',0,0,4,1),
(14,'2026-05-02','Reporte rondin',1,1,4,1),
(15,'2026-05-03','Reporte rondin',0,0,4,1),
(16,'2026-05-04','Reporte rondin',1,2,4,1),

(17,'2026-05-01','Reporte rondin',0,0,5,1),
(18,'2026-05-02','Reporte rondin',1,1,5,1),
(19,'2026-05-03','Reporte rondin',0,0,5,1),
(20,'2026-05-04','Reporte rondin',1,2,5,1);
GO