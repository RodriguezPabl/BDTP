/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
	Fecha: 26/11/24
*/

/* Entrega 5
Requisitos de seguridad
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
La información de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma.
*/

USE Com2900G12;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuarioEmpleado')
BEGIN
    CREATE LOGIN usuarioEmpleado WITH PASSWORD = 'Com2900G12';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuarioSupervisor')
BEGIN
    CREATE LOGIN usuarioSupervisor WITH PASSWORD = 'Com2900G12';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Empleado' AND type = 'R')
BEGIN
    CREATE ROLE Empleado;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Supervisor' AND type = 'R')
BEGIN
    CREATE ROLE Supervisor;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_permissions WHERE grantee_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Supervisor') AND major_id = OBJECT_ID('Venta.GenerarNotaDeCredito') AND permission_name = 'EXECUTE')
BEGIN
    GRANT EXECUTE ON Venta.GenerarNotaDeCredito TO Supervisor;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_permissions WHERE grantee_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Supervisor') AND major_id = OBJECT_ID('Venta.NotaDeCredito') AND permission_name = 'SELECT')
BEGIN
    GRANT SELECT ON Venta.NotaDeCredito TO Supervisor;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_permissions WHERE grantee_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Supervisor') AND major_id = OBJECT_ID('Venta.Factura') AND permission_name = 'SELECT')
BEGIN
    GRANT SELECT ON Venta.Factura TO Supervisor;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_permissions WHERE grantee_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Empleado') AND major_id = OBJECT_ID('Sucursal.Empleado') AND permission_name = 'SELECT')
BEGIN
    GRANT SELECT ON Sucursal.Empleado TO Empleado;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuarioEmpleado')
BEGIN
    CREATE USER usuarioEmpleado FOR LOGIN usuarioEmpleado;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuarioSupervisor')
BEGIN
    CREATE USER usuarioSupervisor FOR LOGIN usuarioSupervisor;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_role_members WHERE role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Empleado') AND member_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'usuarioEmpleado'))
BEGIN
    EXEC sp_addrolemember 'Empleado', 'usuarioEmpleado';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_role_members WHERE role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Supervisor') AND member_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'usuarioSupervisor'))
BEGIN
    EXEC sp_addrolemember 'Supervisor', 'usuarioSupervisor';
END
GO
