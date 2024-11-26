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

USE Com2900G12
GO

--ejecutar primero usuarioEmpleado para ver que no tiene permisos
EXECUTE AS USER = 'usuarioEmpleado';
GO
exec Venta.GenerarNotaDeCredito 'Devolucion', 1

REVERT;
GO

-- Verificar que se volvi� al usuario original
SELECT USER_NAME();  -- Esto debe devolver el nombre del usuario original
GO

--ejecutar como supervisor
EXECUTE AS USER = 'usuarioSupervisor';
GO
exec Venta.GenerarNotaDeCredito 'Devolucion', 1

SELECT USER_NAME(); 
GO

SELECT * FROM Venta.NotaDeCredito