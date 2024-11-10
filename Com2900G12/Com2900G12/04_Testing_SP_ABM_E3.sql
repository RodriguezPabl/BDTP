USE Com2900G12

-- ##### SP's de Sucursal #####
SELECT * FROM Sucursal.Sucursal
--Insercion correcta
EXEC Sucursal.InsertarSucursal @Ciudad='San Justo', @Telefono='1234-9983', @Direccion='Florencio Varela 114',@Horario='8-21'
EXEC Sucursal.InsertarSucursal @Ciudad='Ramos Mejia', @Telefono='1234-9984', @Direccion='Av. de Mayo 1123',@Horario='8-21'
--Insercion erronea (los campos telefono y direccion son UNIQUE)
EXEC Sucursal.InsertarSucursal @Ciudad='San Justo', @Telefono='1234-9983', @Direccion='Florencio Varela 114',@Horario='8-21'
--Insercion erronea (todos los campos son null)
EXEC Sucursal.InsertarSucursal
--Actualizacion correcta
EXEC Sucursal.ModificarSucursal @SucursalID=2, @Telefono='4899-4321'
--Actualizacion Erronea (el numero de sucrusal no existe y los campos telefono y direccion son UNIQUE)
EXEC Sucursal.ModificarSucursal @SucursalID=1092939, @Telefono='4899-4321',@Direccion='Florencio Varela 114'
--Borrado correcto
EXEC Sucursal.BorrarSucursal @SucursalID=2
--Borrado erroneo (sucursal no encontrada)
EXEC Sucursal.BorrarSucursal @SucursalID=1092939

-- ##### ACLARACION: TODOS LOS SP TIENEN VALIDACION PARA PARAMETROS NULOS Y POR SI NO ENCUENTRA LA PRIMARY KEY PARA ACTUALIZAR O BORRAR(NO VAMOS A HACER TODOS LOS CASOS PARA CADA TABLA) #####

-- ##### SP's de Cargo #####
SELECT * FROM Sucursal.Cargo
--Insercion correcta
EXEC Sucursal.InsertarCargo @Descripcion='Cajero'
EXEC Sucursal.InsertarCargo @Descripcion='Supervisor'
--Actualizacion correcta
EXEC Sucursal.ModificarCargo @CargoID=2, @Descripcion='Gerente'
--Borrado exitoso
EXEC Sucursal.BorrarCargo @CargoID=2

-- ##### SP's de Empleado #####
SELECT * FROM Sucursal.Empleado
--Insercion correcta
EXEC Sucursal.InsertarEmpleado @Nombre='Pablo',@Apellido='Aguilera',@DNI='12345678',@Direccion='Florencio Varela 333',@Email='pa@alumno.edu.ar',@EmailEmpresarial='pa@empresa.com.ar',
	@Cuil='20-12345678-4',@Turno='TM',@SucursalID=1,@CargoID=1
EXEC Sucursal.InsertarEmpleado @Nombre='Emanuel',@Apellido='Rodriguez',@DNI='23456789',@Direccion='Luis Viale 1234',@Email='er@alumno.edu.ar',@EmailEmpresarial='er@empresa.com.ar',
	@Cuil='20-23456789-4',@Turno='TM',@SucursalID=1,@CargoID=1
--Insercion erronea (mail y mail empresarial UNIQUE)
EXEC Sucursal.InsertarEmpleado @Nombre='Roberto',@Apellido='Nogueira',@DNI='12345679',@Direccion='Florencio Varela 333',@Email='pa@alumno.edu.ar',@EmailEmpresarial='pa@empresa.com.ar',
	@Cuil='20-12345679-4',@Turno='TT',@SucursalID=1,@CargoID=1
--Insercion erronea (sucursal y cargo inexistentes)
EXEC Sucursal.InsertarEmpleado @Nombre='Roberto',@Apellido='Nogueira',@DNI='12345679',@Direccion='Florencio Varela 333',@Email='rn@alumno.edu.ar',@EmailEmpresarial='rn@empresa.com.ar',
	@Cuil='20-12345679-4',@Turno='TT',@SucursalID=3789812,@CargoID=3212387
--Actualizacion exitosa
EXEC Sucursal.ModificarEmpleado @EmpleadoID=257020, @Nombre='Pedro'
--Borrado exitoso
EXEC Sucursal.BorrarEmpleado @EmpleadoID=257021

-- ##### SP's de MedioDePago #####
SELECT * FROM Venta.MedioDePago
--Insercion exitosa
EXEC Venta.InsertarMedioDePago @Descripcion='Efectivo'
EXEC Venta.InsertarMedioDePago @Descripcion='Credito',@Identificador='123545654723455'
--Actualizacion exitosa
EXEC Venta.ModificarMedioDePago @MedioDePagoID=2, @Descripcion='Credit Card'
--Borrado exitoso
EXEC Venta.BorrarMedioDePago @MedioDePagoID=2

-- ##### SP's de Cliente #####
SELECT * FROM Venta.Cliente
--Insercion exitosa
EXEC Venta.InsetarCliente @TipoDeCliente='Miembro',@Genero='M'
EXEC Venta.InsetarCliente @TipoDeCliente='Normal',@Genero='F'
--Actualizacion exitosa
EXEC Venta.ModificarCliente @ClienteID=1, @TipoDeCliente='Member'
--Borrado exitoso
EXEC Venta.BorrarCliente @ClienteID=2

-- ##### SP's de Factura #####
SELECT * FROM Venta.Factura
--Insercion exitosa
EXEC Venta.InsertarFactura @FacturaID=1,@TipoDeFactura='A',@EmpleadoID=257020,@MedioDePagoID=1,@ClienteID=1
EXEC Venta.InsertarFactura @FacturaID=2,@TipoDeFactura='B',@EmpleadoID=257020,@MedioDePagoID=1,@ClienteID=2
--Actualizacion exitosa
EXEC Venta.ModificarFactura @FacturaID=2,@TipoDeFactura='A'
--Borrado exitoso
EXEC Venta.BorrarFactura @FacturaID=2

-- ##### SP's de CategoriaProducto #####
SELECT * FROM Producto.CategoriaProducto
--Insercion exitosa
EXEC Producto.InsertarCategoriaProducto @NombreCat='Almacen'
EXEC Producto.InsertarCategoriaProducto @NombreCat='Frescos'
EXEC Producto.InsertarCategoriaProducto @NombreCat='Limpieza'
EXEC Producto.InsertarCategoriaProducto @NombreCat='Otros'
--Actualizacion exitosa
EXEC Producto.ModificarCategoriaProducto @CategoriaID=4,@NombreCat='Congelados'
--Borrado exitoso
EXEC Producto.BorrarCategoriaProducto @CategoriaID=4

-- ##### SP's de Producto #####
SELECT * FROM Producto.Producto
--Insercion exitosa
EXEC Producto.InsertarProducto @Nombre='Banana',@Moneda='ARS', @PrecioUnitario=15,@CategoriaID=2
EXEC Producto.InsertarProducto @Nombre='Manzana',@Moneda='ARS',@PrecioUnitario=10,@CategoriaID=2
EXEC Producto.InsertarProducto @Nombre='Pera',@Moneda='ARS',@PrecioUnitario=20,@CategoriaID=2
EXEC Producto.InsertarProducto @Nombre='Mandarina',@Moneda='ARS',@PrecioUnitario=25,@CategoriaID=2
--Actualizacion exitosa
EXEC Producto.ModificarProducto @ProductoID=4,@PrecioUnitario=17
--Borrado exitoso
EXEC Producto.BorrarProducto @ProductoID=4

-- ##### SP's de DetalleFactura #####
SELECT * FROM Venta.DetalleFactura
--Insercion correcta
EXEC Venta.InsertarDetalleFactura @Cantidad=15, @FacturaID=1, @ProductoID=1
EXEC Venta.InsertarDetalleFactura @Cantidad=5, @FacturaID=1, @ProductoID=2
EXEC Venta.InsertarDetalleFactura @Cantidad=10, @FacturaID=1, @ProductoID=3
--Actualizacion correcta
EXEC Venta.ModificarDetalleFactura @NumeroDeItem=2, @Cantidad=10
--Borrado exitoso
EXEC Venta.BorrarDetalleFactura @NumeroDeItem=3