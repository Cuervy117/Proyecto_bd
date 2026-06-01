---
proyecto: Ecobici SQuipoL
tipo: Entrega Académica / Base de Datos
estatus: En desarrollo
---

# 📋 Pendientes Críticos - Proyecto Ecobici 2026-2

> [!IMPORTANT]
> Esta lista contiene los elementos faltantes obligatorios y las correcciones urgentes basadas estrictamente en la **lista de cotejo** de la materia[cite: 1] para asegurar la máxima calificación.

---

## 🚨 CORRECCIONES URGENTES (Reglas de Negocio e Integridad)

- [ ] **Corregir códigos de Tipo de Empleado (`creaBase.sql` y `cargaInicial.sql`)**
	- *Problema:* El check actual valida `('AD', 'AG', 'R', 'M')`.
	- *Corrección:* Modificar a los caracteres exactos solicitados por la rúbrica: `A` (Agente), `R` (Rondines), `D` (Administrador), `M` (Mantenimiento).
- [ ] **Modificar la descripción del Estado Civil (`cargaInicial.sql`)**
	- *Corrección:* Cambiar el mapeo de la clave `O` en la tabla `catalogo.ESTADO_CIVIL`. Actualmente dice "Otro", debe decir **"Concubinato"**.
- [ ] **Resolver variables comentadas (`informes.sql`)**
	- *Corrección:* Descomentar las líneas `DECLARE @FechaInicio...` en las consultas 6, 11 y 15 para evitar que el script trone al ejecutarse en un solo bloque.
- [ ] **Actualizar lógica semántica de Bicicleta (`creaBase.sql`)**
	- *Corrección:* Mapear conceptualmente el campo `modelo` para que refleje el tamaño solicitado: `C` (Chica), `M` (Mediana), `G` (Grande).
- [ ] **Sincronizar fechas de Suscripción (`cargaInicial.sql`)**
	- *Corrección:* Ajustar los rangos de fechas insertados en `movilidad.SUSCRIPCION` para que la membresía Básica (ID 1) respete su duración lógica de 30 días en lugar de un año entero.

---

## 🛠️ LÓGICA PROGRAMÁTICA FALTANTE (DML Avanzada)

### 1. Procedimientos Almacenados Requeridos (Implementar en `dml.sql`)[cite: 1]
> [!NOTE]
> Todos los SP deben incluir control de transacciones (`BEGIN TRAN` / `COMMIT` / `ROLLBACK`) y bloques `TRY...CATCH` para el manejo de errores[cite: 1].

- [ ] **SP 1, 2 y 5: Gestión de Usuarios**[cite: 3, 4]
	- [ ] `usuarios.sp_RegistrarUsuario`: Registro general con diferentes perfiles[cite: 4].
	- [ ] `usuarios.sp_AltaUsuarioPlan`: Alta del usuario vinculado a su plan/membresía, control de costo de tarjeta ($50 primera vez) y recargas[cite: 1, 3, 5].
	- [ ] `usuarios.sp_ModificarUsuario`: Actualización de datos generales.
	- [ ] `usuarios.sp_EliminarUsuario`: Borrado seguro que maneje la cascada de dependencias[cite: 1].
	- [ ] `movilidad.sp_ReposicionTarjeta`: Registro de reposición aplicando costo semántico de $80[cite: 1, 3].
- [ ] **SP 3: Registrar un Viaje**[cite: 4]
	- [ ] `movilidad.sp_RegistrarViaje`: Lógica completa para iniciar/finalizar el recorrido[cite: 4].
- [ ] **SP 4 y 9: Gestión de Rondines**[cite: 6]
	- [ ] `personal.sp_RegistrarRondin`[cite: 6]
	- [ ] `personal.sp_ActualizarRondin`
- [ ] **SP 6: Modificar una Falta**
	- [ ] `personal.sp_ModificarFalta`: Permitir la actualización de la fecha fin, descripción y motivo.
- [ ] **SP 7: Borrar Método de Pago**
	- [ ] `movilidad.sp_BorrarMetodoPago`: Si el usuario ya no tiene otro método de pago registrado, debe cancelar la suscripción automáticamente.
- [ ] **SP 8: Registrar un Incidente**
	- [ ] `incidentes.sp_RegistrarIncidente`
- [ ] **SP 10: Wrappers para Estadísticas**
	- [ ] Encapsular al menos 4 de los informes en procedimientos almacenados independientes que muestren un mínimo de 10 registros.

### 2. Objetos de Base de Datos Adicionales[cite: 1]
- [ ] **Completar las 3 Vistas requeridas (`creaBase.sql`)**[cite: 1]
	- Actulmente solo existe `movilidad.VW_VIAJE_TARIFA_ADICIONAL`. Desarrollar 2 vistas más para cumplir la rúbrica[cite: 1].
- [ ] **Implementar Buscador con LIKE (`informes.sql` o en un SP)**
	- Desarrollar una funcionalidad de búsqueda (ej. buscar usuarios por nombre o empleados por RFC) utilizando el operador `LIKE`.

---

## 📦 ESTRUCTURA DE ARCHIVOS PARA ENTREGA FINAL

- [ ] **Separar pruebas de triggers (`valida triggers.sql`)**
	- *Acción:* Mover los bloques de prueba con transacciones (`BEGIN TRAN ... ROLLBACK`) de `dml.sql` a este nuevo archivo independiente para cumplir con el listado de 6 scripts requeridos[cite: 2].

---
### 📈 Notas de Seguimiento del Equipo
*Usa esta sección para asignar responsables en tu Obsidian si lo requieres.*
- **Diseño Físico/DDL:** 
- **Lógica de Programación (SPs/Triggers):** 
- **Consultas y QA:**