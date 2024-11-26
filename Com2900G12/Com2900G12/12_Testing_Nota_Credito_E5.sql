USE Com2900G12
GO

--ejecutar primero usuarioEmpleado para ver que no tiene permisos
EXECUTE AS USER = 'usuarioSupervisor';
GO

EXECUTE AS USER = 'usuarioEmpleado';
GO

SELECT USER_NAME(); 
GO

REVERT;
GO

-- Verificar que se volvi� al usuario original
SELECT USER_NAME();  -- Esto debe devolver el nombre del usuario original
GO
exec Venta.GenerarNotaDeCredito 'Devolucion', 1

SELECT * FROM Venta.NotaDeCredito
SELECT * fROM Venta.Factura