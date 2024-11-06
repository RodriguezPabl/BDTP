USE Com2900G12
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Sucursal')
BEGIN
	CREATE TABLE Sucursal.Sucursal (
		SucursalID INT PRIMARY KEY IDENTITY(1,1),
		Ciudad VARCHAR(100),
		Direccion VARCHAR(150),
		Telefono CHAR(9) CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		Horario VARCHAR(50),
		Estado BIT DEFAULT 0, --Ver si se puede cambiar por un TIMESTAMP
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
		Descripcion VARCHAR(25)
	)
END
GO

-- Tabla de empleados
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Empleado')
BEGIN
	CREATE TABLE Sucursal.Empleado (
		EmpleadoID INT PRIMARY KEY IDENTITY(257020,1),
		Nombre VARCHAR(75),
		Apellido VARCHAR(75),
		Dni CHAR(8),
		Direccion VARCHAR(150),
		Email VARCHAR(100),
		EmailEmpresarial VARCHAR(100),
		Cuil CHAR(13),
		Estado BIT DEFAULT 0,
		Turno VARCHAR(16) NOT NULL CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
		SucursalID INT,
		CargoID INT,
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
		Descripcion VARCHAR(50),
		Identificador VARCHAR(50)
	)
END
GO

-- Tabla de factura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Factura')
BEGIN
	CREATE TABLE Venta.Factura (
		FacturaID CHAR(11) PRIMARY KEY,
		TipoDeFactura CHAR(1) CHECK (TipoDeFactura IN ('A', 'B', 'C')),
		TipoDeCliente VARCHAR(20),
		Genero CHAR(1),
		Fecha DATE DEFAULT GETDATE(),
		Hora TIME(0),
		SucursalID INT,
		MedioDePagoID INT,
		CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Sucursal.Sucursal(SucursalID),
		CONSTRAINT FK_MedioDePago FOREIGN KEY (MedioDePagoID) REFERENCES Venta.MedioDePago(MedioDePagoID),
	)
END
GO

-- Tabla de detalle de la factura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'DetalleFactura')
BEGIN
	CREATE TABLE Venta.DetalleFactura(
		NumeroDeItem INT PRIMARY KEY IDENTITY(1,1),
		Cantidad INT,
		FacturaID CHAR(11),
		ProductoID INT,
		CONSTRAINT FK_Factura FOREIGN KEY (FacturaID) REFERENCES Venta.Factura(FacturaID),
		--CONSTRAINT FK_Producto
	)
END
GO

-- Tabla de categoria de productos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Producto' AND TABLE_NAME = 'CategoriaProducto')
BEGIN
	CREATE TABLE Producto.CategoriaProducto(
		CategoriaID INT PRIMARY KEY IDENTITY(1,1),
		NombreCat VARCHAR(50)
	)
END
GO

-- Tabla de producto
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Producto' AND TABLE_NAME = 'Producto')
BEGIN
	CREATE TABLE Producto.Producto(
		ProductoID INT PRIMARY KEY IDENTITY(1,1),
		Nombre VARCHAR(100),
		Moneda VARCHAR (5),
		PrecioUnitario DECIMAL(7,2),
		CategoriaID INT,
		CONSTRAINT FK_Categoria FOREIGN KEY (CategoriaID) REFERENCES Producto.CategoriaProducto(CategoriaID)
	)
END
GO

SELECT * FROM Sucursal.Sucursal
SELECT * FROM Sucursal.Empleado
SELECT * FROM Sucursal.Cargo
SELECT * FROM Venta.Factura
SELECT * FROM Venta.DetalleFactura
SELECT * FROM Venta.MedioDePago
SELECT * FROM Producto.Producto
SELECT * FROM Producto.CategoriaProducto

/*
-- Tabla de catalogo
CREATE TABLE Productos.Catalogo (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    LineaDeProducto VARCHAR(100) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    PrecioReferencial DECIMAL(10, 2) NOT NULL,
    UnidadDeReferencia CHAR(2) NOT NULL,
    Fecha SMALLDATETIME DEFAULT GETDATE()
);
GO

-- Tabla de accesorios electronicos
CREATE TABLE Productos.AccesorioElectronico (
	AElectronicoID INT PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(100) NOT NULL,
	PrecioEnDolares DECIMAL(7,2) NOT NULL -- Luego si se vende se debe transformar a pesos
);
GO

-- Tabla de productos importados
CREATE TABLE Productos.ProductoImportado (
	PImportadoID INT PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(100) NOT NULL,
	Proveedor VARCHAR(100) NOT NULL, -- Quizas se puede omitir
	LineaDeProducto VARCHAR(100) NOT NULL,
	--Cantidad INT, La omitimos ya que no nos importa la administracion de stock de los productos
	Precio DECIMAL(7,2) NOT NULL
);
GO

-- Tabla de ventas
CREATE TABLE Venta.Venta (
    VentaID VARCHAR(100) PRIMARY KEY CHECK (VentaID LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'), 
	TipoDeFactura CHAR(1) CHECK (TipoDeFactura IN ('A', 'B', 'C')),
	Ciudad VARCHAR(100), --ciudad si es Yangon reemplazar por San Justo, etc
	TipoDeCliente VARCHAR(100) , --ver si es una tabla aparte
	Genero VARCHAR(6) ,
	Producto VARCHAR(100),
	PrecioUnitario DECIMAL(10, 2) NOT NULL,
	Cantidad INT,
    Fecha DATE DEFAULT GETDATE(),--Date tiene formato YYYY-MM-DD
	Hora TIME(0),
	MedioDePago VARCHAR(25),
	EmpleadoID INT,
	IdentificadorDePago VARCHAR(50),
	--Eliminado BIT DEFAULT 0, Ver si se considera un borrado logico de una venta por si se aceptan devoluciones (Generar un SP Dar de baja y uno para borrar definitivamente los borrados logicos)
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados.Empleado(EmpleadoID),
	--MedioDePagoID INT,
	--CONSTRAINT FK_MedioDePago FOREIGN KEY (MedioDePagoID) REFERENCES Ventas.MedioDePago(MedioDePagoID) Revisar si usar la tabla MedioDePago
);
GO
*/