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
Cuando un cliente reclama la devoluci�n de un producto se genera una nota de cr�dito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de cr�dito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de cr�dito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen informaci�n personal.
La informaci�n de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan pol�ticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una pol�tica de respaldo adecuada para cumplir con este requisito y justifique la
misma.
*/

USE Com2900G12
GO

CREATE OR ALTER PROCEDURE Sucursal.BackUpDiario
	@Path NVARCHAR(255)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'BACKUP DATABASE Com2900G12 TO DISK = ''' + @Path + ''' WITH DIFFERENTIAL, NAME = ''BackUp Diferencial Diario'', FORMAT;'
	
	EXEC sp_executesql @sql
END
GO

CREATE OR ALTER PROCEDURE Sucursal.BackUpSemanal
	@Path NVARCHAR(255)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'BACKUP DATABASE Com2900G12 TO DISK = ''' + @Path + ''' WITH FORMAT, NAME = ''BackUp Completo Semanal'', FORMAT;'
	
	EXEC sp_executesql @sql
END
GO

EXEC Sucursal.BackUpSemanal'F:\backup\SemanalCompleto.bak'
EXEC Sucursal.BackUpDiario 'F:\backup\DiarioDiferencial.bak'