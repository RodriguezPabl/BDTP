USE Com2900G12
GO


EXEC Sucursal.EncriptarDatosEmpleado;
GO
SELECT * FROM Sucursal.Empleado;

-- Declarar la frase clave utilizada para el cifrado
DECLARE @FraseClave NVARCHAR(128) = 'QuieroMiPanDanes';

-- Desencriptar los datos y mostrarlos
SELECT 
    EmpleadoID,
    EmpleadoNum,
    CONVERT(VARCHAR(8), DecryptByPassPhrase(@FraseClave, Dni, 1, CONVERT(VARBINARY, EmpleadoNum))) AS DniDesencriptado,
    CONVERT(VARCHAR(13), DecryptByPassPhrase(@FraseClave, Cuil, 1, CONVERT(VARBINARY, EmpleadoNum))) AS CuilDesencriptado,
    CONVERT(VARCHAR(150), DecryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(VARBINARY, EmpleadoNum))) AS DireccionDesencriptada,
    CONVERT(VARCHAR(100), DecryptByPassPhrase(@FraseClave, Email, 1, CONVERT(VARBINARY, EmpleadoNum))) AS EmailDesencriptado,
    CONVERT(VARCHAR(100), DecryptByPassPhrase(@FraseClave, EmailEmpresarial, 1, CONVERT(VARBINARY, EmpleadoNum))) AS EmailEmpresarialDesencriptado
FROM Sucursal.Empleado;
GO

/*
USE MASTER
GO
DROP DATABASE Com2900G12*/