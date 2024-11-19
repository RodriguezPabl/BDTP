/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
		-Tatiana Greve, 43031180
		-Nogueira Denise, 41234014
	Fecha: 12/11/24
*/

/* Entrega 4
Se proveen maestros de XXX.
Ver archivo “Datasets para importar” en Miel.
Se requiere que importe toda la información antes mencionada a la base de datos:
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
• Considere este comportamiento al generar el código. Debe admitir la importación de
novedades periódicamente.
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
realicen tareas por fuera de un SP.
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
estructura requerida.
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
interpretarlo como JSON o CSV). */


USE Com2900G12
GO

--sucursal
SELECT * FROM Sucursal.Sucursal
EXEC Sucursal.ImportarSucursal 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'sucursal';
SELECT * FROM Sucursal.Sucursal
EXEC Sucursal.ImportarSucursal 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'sucursal';
SELECT * FROM Sucursal.Sucursal

--Cargo y Empleado
select * from Sucursal.Cargo
select * from Sucursal.Empleado
EXEC Sucursal.ImportarCargoEmpleado 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';
select * from Sucursal.Cargo
select * from Sucursal.Empleado
EXEC Sucursal.ImportarCargoEmpleado 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';
select * from Sucursal.Cargo
select * from Sucursal.Empleado

--Medio De Pago
SELECT * FROM Venta.MedioDePago
EXEC Venta.ImportarMedioDePago 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'medios de pago';
SELECT * FROM Venta.MedioDePago
EXEC Venta.ImportarMedioDePago 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'medios de pago';
SELECT * FROM Venta.MedioDePago

--CategoriaProducto
SELECT * FROM Producto.CategoriaProducto
EXEC Producto.ImportarCategoriaProducto 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Clasificacion productos';
SELECT * FROM Producto.CategoriaProducto
EXEC Producto.ImportarCategoriaProducto 'F:\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Clasificacion productos';
SELECT * FROM Producto.CategoriaProducto

--Catalogo
SELECT * FROM Producto.Producto
EXEC Producto.ImportarCatalogo 'F:\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT * FROM Producto.Producto
EXEC Producto.ImportarCatalogo 'F:\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT * FROM Producto.Producto

--AccesorioElectronico
SELECT * FROM Producto.Producto
EXEC Producto.ImportarAccesorioElectronico 'F:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', 'Sheet1'
SELECT * FROM Producto.Producto
EXEC Producto.ImportarAccesorioElectronico 'F:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', 'Sheet1'
SELECT * FROM Producto.Producto

--ProductoImportado
SELECT * FROM Producto.Producto
EXEC Producto.ImportarProductosImportados 'F:\TP_integrador_Archivos\Productos\Productos_importados.xlsx', 'Listado de Productos'
SELECT * FROM Producto.Producto
EXEC Producto.ImportarProductosImportados 'F:\TP_integrador_Archivos\Productos\Productos_importados.xlsx', 'Listado de Productos'
SELECT * FROM Producto.Producto

--Cliente, DetalleVenta, Venta y Factura
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.DetalleVenta
SELECT * FROM Venta.Venta
SELECT * FROM Venta.Factura
EXEC Venta.ImportarVenta 'F:\TP_integrador_Archivos\Ventas_registradas.csv'
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.DetalleVenta
SELECT * FROM Venta.Venta
SELECT * FROM Venta.Factura
EXEC Venta.ImportarVenta 'F:\TP_integrador_Archivos\Ventas_registradas.csv'
SELECT * FROM Venta.Cliente
SELECT * FROM Venta.DetalleVenta
SELECT * FROM Venta.Venta
SELECT * FROM Venta.Factura