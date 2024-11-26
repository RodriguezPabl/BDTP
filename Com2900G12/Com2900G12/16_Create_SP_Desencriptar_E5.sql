-- Cambiar el contexto a la base de datos correcta
USE Com2900G12;
GO


CREATE OR ALTER PROCEDURE Sucursal.AgregarCamposEmpleados
AS
BEGIN
    ALTER TABLE Sucursal.Empleado 
    ADD 
        DniOriginal NVARCHAR(MAX),
        CuilOriginal NVARCHAR(MAX),
        DireccionOriginal NVARCHAR(MAX),
        EmailOriginal NVARCHAR(MAX),
        EmailEmpresarialOriginal NVARCHAR(MAX);
END
go
EXECUTE Sucursal.AgregarCamposEmpleados
GO

CREATE OR ALTER PROCEDURE Sucursal.DesencriptarDatosEmpleado
AS
BEGIN
    DECLARE @FraseClave NVARCHAR(128) = 'QuieroMiPanDanes';

UPDATE Sucursal.Empleado
    SET 
        DniOriginal = CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, Dni, 1, CONVERT(varbinary, EmpleadoNum))),
        CuilOriginal = CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, Cuil, 1, CONVERT(varbinary, EmpleadoNum))),
        DireccionOriginal = CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(varbinary, EmpleadoNum))),
        EmailOriginal = CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, Email, 1, CONVERT(varbinary, EmpleadoNum))),
        EmailEmpresarialOriginal = CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, EmailEmpresarial, 1, CONVERT(varbinary, EmpleadoNum)));

    -- Eliminar las columnas cifradas
    ALTER TABLE Sucursal.Empleado
    DROP COLUMN Dni, Cuil, Direccion, Email, EmailEmpresarial;

    -- Renombrar las columnas temporales
    EXEC sp_rename 'Sucursal.Empleado.DniOriginal', 'Dni', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.CuilOriginal', 'Cuil', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.DireccionOriginal', 'Direccion', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.EmailOriginal', 'Email', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.EmailEmpresarialOriginal', 'EmailEmpresarial', 'COLUMN';

    PRINT 'Desencriptado completado exitosamente.';
    
END;
GO
