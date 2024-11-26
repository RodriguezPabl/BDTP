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
