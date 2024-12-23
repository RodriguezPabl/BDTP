/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
	Fecha: 26/11/24
*/

/* Entrega 3
Luego de decidirse por un motor de base de datos relacional, lleg� el momento de generar la
base de datos.
Deber� instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicaci�n de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregar�a al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
entregado). Incluya comentarios para indicar qu� hace cada m�dulo de c�digo.
Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con �SP�.
Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
en la creaci�n de objetos. NO use el esquema �dbo�.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, n�mero de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la secci�n de pr�cticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega. */

USE Com2900G12
GO

IF OBJECT_ID('Sucursal.Sucursal', 'U') IS NOT NULL
    DROP TABLE Sucursal.Sucursal

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Sucursal')
BEGIN
	CREATE TABLE Sucursal.Sucursal (
		SucursalID INT PRIMARY KEY IDENTITY(1,1),
		Ciudad VARCHAR(100) NOT NULL,
		ReemplazarPor VARCHAR(100) DEFAULT NULL,
		Direccion VARCHAR(150) NOT NULL,
		Telefono VARCHAR(15) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		Horario VARCHAR(100) NOT NULL,
		FechaBorrado DATE DEFAULT NULL,
		CONSTRAINT UQ_Direccion UNIQUE (Direccion),
		CONSTRAINT UQ_Telefono UNIQUE (Telefono)
	)
END
GO

-- Tabla de cargos
IF OBJECT_ID('Sucursal.Cargo', 'U') IS NOT NULL
    DROP TABLE Sucursal.Cargo

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Cargo')
BEGIN
	CREATE TABLE Sucursal.Cargo (
		CargoID INT PRIMARY KEY IDENTITY(1,1),
		Descripcion VARCHAR(25) NOT NULL,
		FechaBorrado DATE DEFAULT NULL
	)
END
GO

-- Tabla de empleados
IF OBJECT_ID('Sucursal.Empleado', 'U') IS NOT NULL
    DROP TABLE Sucursal.Empleado

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Empleado')
BEGIN
	CREATE TABLE Sucursal.Empleado (
		EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
		EmpleadoNum INT DEFAULT NULL,
		Nombre VARCHAR(75) NOT NULL,
		Apellido VARCHAR(75) NOT NULL,
		Dni CHAR(8) NOT NULL,
		Direccion VARCHAR(150) NOT NULL,
		Email VARCHAR(100) NOT NULL,
		EmailEmpresarial VARCHAR(100) NOT NULL,
		Cuil CHAR(13),
		Turno VARCHAR(16) NOT NULL CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
		FechaBorrado DATE DEFAULT NULL,
		SucursalID INT NOT NULL,
		CargoID INT NOT NULL,
		CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Sucursal.Sucursal(SucursalID),
		CONSTRAINT FK_Cargo FOREIGN KEY (CargoID) REFERENCES Sucursal.Cargo(CargoID),
		CONSTRAINT UQ_Email UNIQUE (Email),
		CONSTRAINT UQ_EmailEmpresarial UNIQUE (EmailEmpresarial)
	)
END
GO

-- Tabla de medios de pago
IF OBJECT_ID('Venta.MedioDePago', 'U') IS NOT NULL
    DROP TABLE Venta.MedioDePago

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'MedioDePago')
BEGIN
	CREATE TABLE Venta.MedioDePago (
		MedioDePagoID INT PRIMARY KEY IDENTITY(1,1),
		DescripcionESP VARCHAR(50) NOT NULL,
		DescripcionING VARCHAR(50) NOT NULL,
		FechaBorrado DATE DEFAULT NULL,
	)
END
GO

-- Tabla cliente
IF OBJECT_ID('Venta.Cliente', 'U') IS NOT NULL
    DROP TABLE Venta.Cliente

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Cliente')
BEGIN
	CREATE TABLE Venta.Cliente (
		ClienteID INT PRIMARY KEY IDENTITY(1,1),
		TipoDeCliente VARCHAR(20) NOT NULL,
		Genero CHAR(1) NOT NULL,
		Nombre VARCHAR(50),
		Apellido VARCHAR (50),
		DNI CHAR(8),
		Cuil CHAR(13) DEFAULT NULL,
		FechaBorrado DATE DEFAULT NULL
	)
END
GO

-- Tabla de venta

IF OBJECT_ID('Venta.Venta', 'U') IS NOT NULL
    DROP TABLE Venta.Venta

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Venta')
BEGIN
	CREATE TABLE Venta.Venta (
		VentaID INT PRIMARY KEY IDENTITY(1,1),
		VentaNum VARCHAR(25) DEFAULT NULL,
		TipoDeFactura CHAR(1) DEFAULT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
		Fecha DATE DEFAULT NULL,
		Hora TIME(0) DEFAULT NULL,
		Identificador VARCHAR(50) DEFAULT NULL,
		Total DECIMAL(9,2),
		TotalConIva DECIMAL(9,2),
		EmpleadoID INT DEFAULT NULL,
		MedioDePagoID INT DEFAULT NULL,
		ClienteID INT DEFAULT NULL,
		CONSTRAINT FK_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Sucursal.Empleado(EmpleadoID),
		CONSTRAINT FK_MedioDePago FOREIGN KEY (MedioDePagoID) REFERENCES Venta.MedioDePago(MedioDePagoID),
		CONSTRAINT FK_Cliente FOREIGN KEY (ClienteID) REFERENCES Venta.Cliente(ClienteID)
	)
END
GO

-- Tabla de categoria de productos
IF OBJECT_ID('Producto.CategoriaProducto', 'U') IS NOT NULL
    DROP TABLE Producto.CategoriaProducto

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Producto' AND TABLE_NAME = 'CategoriaProducto')
BEGIN
	CREATE TABLE Producto.CategoriaProducto(
		CategoriaID INT PRIMARY KEY IDENTITY(1,1),
		NombreCat VARCHAR(50) NOT NULL,
		LineaDeProducto VARCHAR(100),
		FechaBorrado DATE DEFAULT NULL
	)
END
GO

-- Tabla de producto
IF OBJECT_ID('Producto.Producto', 'U') IS NOT NULL
    DROP TABLE Producto.Producto

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Producto' AND TABLE_NAME = 'Producto')
BEGIN
	CREATE TABLE Producto.Producto(
		ProductoID INT PRIMARY KEY IDENTITY(1,1),
		Nombre VARCHAR(100) NOT NULL,
		Moneda VARCHAR (5) DEFAULT 'ARS',
		PrecioUnitario DECIMAL(7,2) NOT NULL,
		Fecha DATETIME DEFAULT GETDATE(),
		FechaBorrado DATE DEFAULT NULL,
		CategoriaID INT NOT NULL,
		CONSTRAINT FK_Categoria FOREIGN KEY (CategoriaID) REFERENCES Producto.CategoriaProducto(CategoriaID)
	)
END
GO

-- Tabla de factura
IF OBJECT_ID('Venta.Factura', 'U') IS NOT NULL
    DROP TABLE Venta.Factura

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Factura')
BEGIN
	CREATE TABLE Venta.Factura(
		FacturaID INT PRIMARY KEY IDENTITY(1,1),
		TipoDeFactura CHAR(1)  NOT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
		Fecha DATE DEFAULT GETDATE(),
		Total DECIMAL(9,2),
		TotalConIva DECIMAL(9,2),
		CuitDelEmisor CHAR(13) DEFAULT '20-22222222-3', -- Segun el arca el concepto de CUIT genérico (20-22222222-3) se refiere a una situación especial en la que un contribuyente no tiene un número de CUIT válido o asignado
		VentaID INT NOT NULL,
		CONSTRAINT FK_VentaF FOREIGN KEY (VentaID) REFERENCES Venta.Venta(VentaID),
	)
END
GO

-- Tabla de detalle de la venta
IF OBJECT_ID('Venta.DetalleVenta', 'U') IS NOT NULL
    DROP TABLE Venta.DetalleVenta

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'DetalleVenta')
BEGIN
	CREATE TABLE Venta.DetalleVenta(
		NumeroDeItem INT PRIMARY KEY IDENTITY(1,1),
		Cantidad INT NOT NULL,
		Subtotal DECIMAL(9,2),
		Precio DECIMAL(7,2),
		VentaID INT NOT NULL,
		ProductoID INT NOT NULL,
		CONSTRAINT FK_Venta FOREIGN KEY (VentaID) REFERENCES Venta.Venta(VentaID),
		CONSTRAINT FK_Producto FOREIGN KEY (ProductoID) REFERENCES Producto.Producto(ProductoID)
	)
END
GO

-- Tabla de nota de credito
IF OBJECT_ID('Venta.NotaDeCredito', 'U') IS NOT NULL
    DROP TABLE Venta.NotaDeCredito

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'NotaDeCredito')
BEGIN
	CREATE TABLE Venta.NotaDeCredito(
		NotaDeCreditoID INT IDENTITY(1,1),
		FechaDeEmision DATETIME DEFAULT GETDATE(),
		Monto DECIMAL(9,2),
		Motivo VARCHAR(50),
		FacturaID INT NOT NULL,
		DetalleVentaID INT,
		CONSTRAINT FK_FacturaNdC FOREIGN KEY (FacturaID) REFERENCES Venta.Factura(FacturaID),
		CONSTRAINT FK_DetalleVentaNdC FOREIGN KEY (DetalleVentaID) REFERENCES Venta.DetalleVenta(NumeroDeItem)
	)
END
GO


-- Tabla de tipo de cambio
IF OBJECT_ID('Venta.NotaDeCambio', 'U') IS NOT NULL
    DROP TABLE Venta.NotaDeCambio

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'TipoDeCambio')
BEGIN
	CREATE TABLE Venta.TipoDeCambio(
		TipoDeCambioID INT IDENTITY(1,1),
		Moneda CHAR(3),
		Compra DECIMAL(7,2),
		Venta DECIMAL(7,2),
		FechaDeEmision DATETIME DEFAULT GETDATE()
	)
END
GO