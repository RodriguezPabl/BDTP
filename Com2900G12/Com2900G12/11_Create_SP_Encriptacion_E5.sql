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
