-- Cambiar el contexto a la base de datos correcta
USE Com2900G12;
GO

CREATE OR ALTER PROCEDURE Sucursal.AgregarCamposEmpleados
AS
BEGIN
    ALTER TABLE Sucursal.Empleado 
    ADD 
        DniTemp VARBINARY(MAX),
        CuilTemp VARBINARY(MAX),
        DireccionTemp VARBINARY(MAX),
        EmailTemp VARBINARY(MAX),
        EmailEmpresarialTemp VARBINARY(MAX);
END
go
EXECUTE Sucursal.AgregarCamposEmpleados
GO
CREATE OR ALTER PROCEDURE Sucursal.EncriptarDatosEmpleado
AS
BEGIN
    DECLARE @FraseClave NVARCHAR(128) = 'QuieroMiPanDanes'; -- Frase clave para el cifrado
    BEGIN TRANSACTION;

    UPDATE Sucursal.Empleado
    SET 
        DniTemp = EncryptByPassPhrase(@FraseClave, Dni, 1, CONVERT(varbinary, EmpleadoNum)),
        CuilTemp = EncryptByPassPhrase(@FraseClave, Cuil, 1, CONVERT(varbinary, EmpleadoNum)),
        DireccionTemp = EncryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(varbinary, EmpleadoNum)),
        EmailTemp = EncryptByPassPhrase(@FraseClave, Email, 1, CONVERT(varbinary, EmpleadoNum)),
        EmailEmpresarialTemp = EncryptByPassPhrase(@FraseClave, EmailEmpresarial, 1, CONVERT(varbinary, EmpleadoNum));

    COMMIT TRANSACTION;


    ALTER TABLE Sucursal.Empleado DROP CONSTRAINT UQ_Email;
    ALTER TABLE Sucursal.Empleado DROP CONSTRAINT UQ_EmailEmpresarial;

    ALTER TABLE Sucursal.Empleado
    DROP COLUMN Dni, Cuil, Direccion, Email, EmailEmpresarial;

    EXEC sp_rename 'Sucursal.Empleado.DniTemp', 'Dni', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.CuilTemp', 'Cuil', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.DireccionTemp', 'Direccion', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.EmailTemp', 'Email', 'COLUMN';
    EXEC sp_rename 'Sucursal.Empleado.EmailEmpresarialTemp', 'EmailEmpresarial', 'COLUMN';

    PRINT 'Cifrado completado exitosamente.';
END
GO
