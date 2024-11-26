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