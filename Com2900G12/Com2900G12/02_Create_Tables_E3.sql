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
GO

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
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Cliente')
BEGIN
	CREATE TABLE Venta.Cliente (
		ClienteID INT PRIMARY KEY IDENTITY(1,1),
		TipoDeCliente VARCHAR(20) NOT NULL,
		Genero CHAR(1) NOT NULL,
		Nombre VARCHAR(50),
		Apellido VARCHAR (50),
		DNI CHAR(8),
		FechaBorrado DATE DEFAULT NULL
	)
END
GO

-- Tabla de venta
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
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Factura')
BEGIN
	CREATE TABLE Venta.Factura(
		FacturaID INT PRIMARY KEY IDENTITY(1,1),
		TipoDeFactura CHAR(1)  NOT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
		Fecha DATETIME DEFAULT GETDATE(),
		Total DECIMAL(9,2),
		TotalConIva DECIMAL(9,2),
		VentaID INT NOT NULL,
		CONSTRAINT FK_VentaF FOREIGN KEY (VentaID) REFERENCES Venta.Venta(VentaID),
	)
END
GO

-- Tabla de detalle de la venta
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
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'NotaDeCredito')
BEGIN
	CREATE TABLE Venta.NotaDeCredito(
		NotaDeCreditoID INT IDENTITY(1,1),
		FechaDeEmision DATETIME DEFAULT GETDATE(),
		Motivo VARCHAR(50),
		FacturaID INT NOT NULL,
		ProductoID INT NOT NULL,
		CONSTRAINT FK_FacturaNdC FOREIGN KEY (FacturaID) REFERENCES Venta.Factura(FacturaID),
		CONSTRAINT FK_ProductoNdC FOREIGN KEY (ProductoID) REFERENCES Producto.Producto(ProductoID)
	)
END
GO