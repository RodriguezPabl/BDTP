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

--CategoriaProducto
EXEC Producto.ImportarCategoriaProducto 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Clasificacion productos';
SELECT * FROM Producto.CategoriaProducto

--Catalogo
EXEC Producto.ImportarCatalogo 'F:\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT * FROM Producto.Producto

--AccesorioElectronico
EXEC Producto.ImportarAccesorioElectronico 'F:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', 'Sheet1'
SELECT * FROM Producto.Producto

--ProductoImportado
EXEC Producto.ImportarProductosImportados 'F:\TP_integrador_Archivos\Productos\Productos_importados.xlsx', 'Listado de Productos'
SELECT * FROM Producto.Producto

--Cliente y Factura
EXEC Venta.ImportarClienteFactura 'F:\TP_integrador_Archivos\Ventas_registradas.csv'
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.Factura
SELECT * FROM Venta.DetalleFactura
--HAY QUE REEMPLAZAR LA CIUDAD POR LA QUE TIENE LA SUCURSAL
--NO ENCUENTRA LOS NOMBRES DE PRODUCTO EN LA TABLA PRODUCTO (VER URGENTE)

