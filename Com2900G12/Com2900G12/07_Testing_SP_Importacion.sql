USE Com2900G12
GO

EXEC Venta.ImportarVenta @RutaArchivo='C:\Users\aguil\Documents\GitHub\BDTP\TP_integrador_Archivos\Ventas_registradas.csv'


EXEC Producto.ImportarCatalogo @RutaArchivo='C:\Users\aguil\Documents\GitHub\BDTP\TP_integrador_Archivos\Productos\catalogo.csv'

--sucursal
EXEC Sucursal.ImportarSucursal 'C:\Users\aguil\Documents\GitHub\BDTP\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Sucursal';
GO
select * from  Sucursal.Sucursal;
GO
--cargar cargos de temp
EXEC Sucursal.ImportarCargoEmpleado 'C:\Users\aguil\Documents\GitHub\BDTP\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';
go
select * from Sucursal.Cargo
select * from Sucursal.Empleado




