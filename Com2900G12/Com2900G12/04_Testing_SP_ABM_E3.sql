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

/* Entrega 3
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega. */

USE Com2900G12

-- ##### SP's de Sucursal #####
SELECT * FROM Sucursal.Sucursal
--Insercion correcta
EXEC Sucursal.InsertarSucursal @Ciudad='Moron', @Telefono='1234-9983', @Direccion='Carlos Calvo 114',@Horario='8-21'
EXEC Sucursal.InsertarSucursal @Ciudad='Haedo', @Telefono='1234-9984', @Direccion='Int. Carrere 1123',@Horario='8-21'
--Insercion erronea (los campos telefono y direccion son UNIQUE)
EXEC Sucursal.InsertarSucursal @Ciudad='San Justo', @Telefono='1234-9983', @Direccion='Carlos Calvo 114',@Horario='8-21'
--Insercion erronea (todos los campos son null)
EXEC Sucursal.InsertarSucursal
--Actualizacion correcta
EXEC Sucursal.ModificarSucursal @SucursalID=2, @Telefono='4899-4321'
--Actualizacion Erronea (el numero de sucrusal no existe y los campos telefono y direccion son UNIQUE)
EXEC Sucursal.ModificarSucursal @SucursalID=1092939, @Telefono='4899-4321',@Direccion='Carlos Calvo 114'
--Borrado correcto
EXEC Sucursal.BorrarSucursal @SucursalID=2
--Borrado erroneo (sucursal no encontrada)
EXEC Sucursal.BorrarSucursal @SucursalID=1092939

-- ##### ACLARACION: TODOS LOS SP TIENEN VALIDACION PARA PARAMETROS NULOS Y POR SI NO ENCUENTRA LA PRIMARY KEY PARA ACTUALIZAR O BORRAR(NO VAMOS A HACER TODOS LOS CASOS PARA CADA TABLA) #####

-- ##### SP's de Cargo #####
SELECT * FROM Sucursal.Cargo
--Insercion correcta
EXEC Sucursal.InsertarCargo 'CajeroSupervisor'
EXEC Sucursal.InsertarCargo 'GerenteSupervisor'
--Actualizacion correcta
EXEC Sucursal.ModificarCargo @CargoID=2, @Descripcion='GerenteSupremo'
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
EXEC Sucursal.ModificarEmpleado @EmpleadoID=1, @Nombre='Pedro'
--Borrado exitoso
EXEC Sucursal.BorrarEmpleado @EmpleadoID=1

-- ##### SP's de MedioDePago #####
SELECT * FROM Venta.MedioDePago
--Insercion exitosa
EXEC Venta.InsertarMedioDePago @DescripcionESP='Debito', @DescripcionING='Debit'
EXEC Venta.InsertarMedioDePago @DescripcionESP='Cupon',@DescripcionING='Coupon'
--Actualizacion exitosa
EXEC Venta.ModificarMedioDePago @MedioDePagoID=2, @DescripcionING='Coupen'
--Borrado exitoso
EXEC Venta.BorrarMedioDePago @MedioDePagoID=2

-- ##### SP's de Cliente #####
SELECT * FROM Venta.Cliente
--Insercion exitosa
EXEC Venta.InsetarCliente @TipoDeCliente='Miembro',@Genero='M',@Nombre='Pepe',@Apellido='Lopez',@DNI='98324755'
EXEC Venta.InsetarCliente @TipoDeCliente='Normal',@Genero='F',@Nombre='Romina',@Apellido='Martinez',@DNI='98324756'
--Actualizacion exitosa
EXEC Venta.ModificarCliente @ClienteID=1, @Apellido='Ruiz'
--Borrado exitoso
EXEC Venta.BorrarCliente @ClienteID=2

/*
-- ##### SP's de Factura #####
SELECT * FROM Venta.Factura
--Insercion exitosa
EXEC Venta.CompletarVenta @VentaID=3, @VentaNum=1,@TipoDeFactura='A',@EmpleadoID=1,@MedioDePagoID=1,@ClienteID=1,@Identificador=33
EXEC Venta.InsertarFactura @FacturaID=2,@TipoDeFactura='B',@EmpleadoID=1,@MedioDePagoID=1,@ClienteID=2,@Identificador=34
--Actualizacion exitosa
EXEC Venta.ModificarFactura @FacturaNum=2,@TipoDeFactura='C'
--No se puede borrar factura
*/

-- ##### SP's de CategoriaProducto #####
SELECT * FROM Producto.CategoriaProducto
--Insercion exitosa
EXEC Producto.InsertarCategoriaProducto @NombreCat='Armaduras'
EXEC Producto.InsertarCategoriaProducto @NombreCat='Armas'
EXEC Producto.InsertarCategoriaProducto @NombreCat='Calzados'
--Actualizacion exitosa
EXEC Producto.ModificarCategoriaProducto @CategoriaID=3,@NombreCat='Calzado',@LineaDeProducto='Calzado'
--Borrado exitoso
EXEC Producto.BorrarCategoriaProducto @CategoriaID=3

-- ##### SP's de Producto #####
SELECT * FROM Producto.Producto
--Insercion exitosa
EXEC Producto.InsertarProducto @Nombre='Espada1',@Moneda='USD', @PrecioUnitario=15,@CategoriaID=2
EXEC Producto.InsertarProducto @Nombre='Espada2',@Moneda='USD',@PrecioUnitario=10,@CategoriaID=2
EXEC Producto.InsertarProducto @Nombre='Casco',@Moneda='USD',@PrecioUnitario=20,@CategoriaID=1
EXEC Producto.InsertarProducto @Nombre='Botas',@Moneda='USD',@PrecioUnitario=25,@CategoriaID=1
--Actualizacion exitosa
EXEC Producto.ModificarProducto @ProductoID=4,@PrecioUnitario=17
--Borrado exitoso
EXEC Producto.BorrarProducto @ProductoID=4

/*
-- ##### SP's de DetalleFactura #####
SELECT * FROM Venta.DetalleFactura
--Insercion correcta
EXEC Venta.InsertarDetalleFactura @Cantidad=1, @FacturaID=1, @ProductoID=1
EXEC Venta.InsertarDetalleFactura @Cantidad=1, @FacturaID=1, @ProductoID=2
EXEC Venta.InsertarDetalleFactura @Cantidad=2, @FacturaID=1, @ProductoID=3
--Actualizacion correcta
EXEC Venta.ModificarDetalleFactura @NumeroDeItem=2, @Cantidad=2
--No se puede borrar detalle de factura
*/