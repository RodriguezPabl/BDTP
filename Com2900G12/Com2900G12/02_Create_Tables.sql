USE Com2900G12
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Sucursal' AND TABLE_NAME = 'Sucursal')
BEGIN
	CREATE TABLE Sucursal.Sucursal (
		SucursalID INT PRIMARY KEY IDENTITY(1,1),
		Ciudad VARCHAR(100) NOT NULL,
		Direccion VARCHAR(150) NOT NULL,
		Telefono CHAR(9) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		Horario VARCHAR(50) NOT NULL,
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
		EmpleadoID INT PRIMARY KEY IDENTITY(257020,1),
		Nombre VARCHAR(75) NOT NULL,
		Apellido VARCHAR(75) NOT NULL,
		Dni CHAR(8) NOT NULL,
		Direccion VARCHAR(150) NOT NULL,
		Email VARCHAR(100) NOT NULL,
		EmailEmpresarial VARCHAR(100) NOT NULL,
		Cuil CHAR(13) NOT NULL,
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
		Descripcion VARCHAR(50) NOT NULL,
		Identificador VARCHAR(50),
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
		FechaBorrado DATE DEFAULT NULL
	)
END
GO

-- Tabla de factura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'Factura')
BEGIN
	CREATE TABLE Venta.Factura (
		FacturaID INT PRIMARY KEY,
		TipoDeFactura CHAR(1)  NOT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
		Fecha DATE DEFAULT GETDATE(),
		Hora TIME(0) DEFAULT GETDATE(),
		FechaBorrado DATE DEFAULT NULL,
		EmpleadoID INT NOT NULL,
		MedioDePagoID INT NOT NULL,
		ClienteID INT NOT NULL,
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
		NombreCat VARCHAR(50) NOT NULL UNIQUE,
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
		Moneda VARCHAR (5) NOT NULL,
		PrecioUnitario DECIMAL(7,2) NOT NULL,
		FechaBorrado DATE DEFAULT NULL,
		CategoriaID INT NOT NULL,
		CONSTRAINT FK_Categoria FOREIGN KEY (CategoriaID) REFERENCES Producto.CategoriaProducto(CategoriaID)
	)
END
GO

-- Tabla de detalle de la factura
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Venta' AND TABLE_NAME = 'DetalleFactura')
BEGIN
	CREATE TABLE Venta.DetalleFactura(
		NumeroDeItem INT PRIMARY KEY IDENTITY(1,1),
		Cantidad INT NOT NULL,
		FacturaID INT NOT NULL,
		ProductoID INT NOT NULL,
		FechaBorrado DATE DEFAULT NULL,
		CONSTRAINT FK_Factura FOREIGN KEY (FacturaID) REFERENCES Venta.Factura(FacturaID),
		CONSTRAINT FK_Producto FOREIGN KEY (ProductoID) REFERENCES Producto.Producto(ProductoID)
	)
END
GO

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