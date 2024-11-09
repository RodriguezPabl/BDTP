USE Com2900G12
GO

--sucursal
EXEC Sucursal.ImportarSucursal 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'sucursal';
GO
select * from  Sucursal.Sucursal;
GO
--Cargo y Empleado
EXEC Sucursal.ImportarCargoEmpleado 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';
go
select * from Sucursal.Cargo
select * from Sucursal.Empleado
-- VER EL REPLACE PARA EL MAIL (NO FUNCIONA)

--Medio De Pago
EXEC Venta.ImportarMedioDePago 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'medios de pago';
SELECT * FROM Venta.MedioDePago

--Cliente y Factura
EXEC Venta.ImportarClienteFactura 'F:\TP_integrador_Archivos\Ventas_registradas.csv'
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.Factura 
--HAY QUE REEMPLAZAR LA CIUDAD POR LA QUE TIENE LA SUCURSAL
--VER LOS CARACTERES DE NOMBRE DE PRODUCTO
--FALTARON CAMPOS DEL CSV POR METER EN TABLAS
