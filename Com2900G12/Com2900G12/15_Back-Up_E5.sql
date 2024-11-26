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

EXEC Sucursal.BackUpDiario 'F:\backup\SemanalCompleto.bak'
EXEC Sucursal.BackUpDiario 'F:\backup\DiarioDiferencial.bak'