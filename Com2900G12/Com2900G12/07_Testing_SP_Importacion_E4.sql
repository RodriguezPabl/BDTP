USE Com2900G12
GO

--sucursal
SELECT * FROM Sucursal.Sucursal
EXEC Sucursal.ImportarSucursal 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'sucursal';

--Cargo y Empleado
select * from Sucursal.Cargo
select * from Sucursal.Empleado
EXEC Sucursal.ImportarCargoEmpleado 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';

--Medio De Pago
SELECT * FROM Venta.MedioDePago
EXEC Venta.ImportarMedioDePago 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'medios de pago';

--CategoriaProducto
SELECT * FROM Producto.CategoriaProducto
EXEC Producto.ImportarCategoriaProducto 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Clasificacion productos';

--Catalogo
SELECT * FROM Producto.Producto
EXEC Producto.ImportarCatalogo 'F:\TP_integrador_Archivos\Productos\catalogo.csv'

--AccesorioElectronico
SELECT * FROM Producto.Producto
EXEC Producto.ImportarAccesorioElectronico 'F:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', 'Sheet1'

--ProductoImportado
SELECT * FROM Producto.Producto
EXEC Producto.ImportarProductosImportados 'F:\TP_integrador_Archivos\Productos\Productos_importados.xlsx', 'Listado de Productos'

--Cliente y Factura
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.Factura
SELECT * FROM Venta.DetalleFactura
EXEC Venta.ImportarClienteFactura 'F:\TP_integrador_Archivos\Ventas_registradas.csv'

