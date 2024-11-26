USE Com2900G12
GO

--ejecutar primero usuarioEmpleado para ver que no tiene permisos
EXECUTE AS USER = 'usuarioEmpleado';
GO
exec Venta.GenerarNotaDeCredito 'Devolucion', 1

EXECUTE AS USER = 'usuarioSupervisor';
GO
exec Venta.GenerarNotaDeCredito 'Devolucion', 1


SELECT USER_NAME(); 
GO

REVERT;
GO

-- Verificar que se volvi� al usuario original
SELECT USER_NAME();  -- Esto debe devolver el nombre del usuario original
GO

SELECT * FROM Venta.NotaDeCredito
SELECT * fROM Venta.Factura