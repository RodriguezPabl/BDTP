USE Com2900G12
GO

CREATE TABLE Ventas.Sucursal (
    SucursalID INT PRIMARY KEY IDENTITY(1,1),
	Ciudad VARCHAR(100) NOT NULL, 
	Direccion VARCHAR(150) NOT NULL,
	Telefono CHAR(9) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	CONSTRAINT UQ_Direccion UNIQUE (Direccion),
	CONSTRAINT UQ_Telefono UNIQUE (Telefono) -- 2 sucursales prodrian estar en la misma ciudad, pero no con la misma direccion o telefono
);
GO

-- Tabla de empleados
CREATE TABLE Empleados.Empleado (
    EmpleadoID INT PRIMARY KEY IDENTITY(257020,1),
    Nombre VARCHAR(75) NOT NULL,
	Apellido VARCHAR(75) NOT NULL,
	Dni int NOT NULL CHECK (Dni BETWEEN 10000000 AND 99999999),
	Direccion VARCHAR(150) NOT NULL,
    Email VARCHAR(100) NOT NULL,
	EmailEmpresarial VARCHAR(100) NOT NULL,
	Cuil CHAR(13) NOT NULL,
	Cargo VARCHAR(50) NOT NULL,
	SucursalID INT,
	Turno VARCHAR(16) NOT NULL CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
    CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursal(SucursalID),
    CONSTRAINT UQ_Email UNIQUE (Email),
	CONSTRAINT UQ_EmailEmpresarial UNIQUE (EmailEmpresarial)
);
GO

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
CREATE TABLE Ventas.Venta (
    VentaID VARCHAR(100) PRIMARY KEY CHECK (VentaID LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'), 
	TipoDeFactura CHAR(1) NOT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
	Ciudad VARCHAR(100) NOT NULL, --ciudad si es Yangon reemplazar por San Justo, etc
	TipoDeCliente VARCHAR(100) NOT NULL, --ver si es una tabla aparte
	Genero VARCHAR(6) NOT NULL,
	Producto VARCHAR(100),
	PrecioUnitario DECIMAL(10, 2) NOT NULL,
	Cantidad INT NOT NULL,
    Fecha DATE NOT NULL DEFAULT GETDATE(),--Date tiene formato YYYY-MM-DD
	Hora TIME(0) NOT NULL,
	MedioDePago VARCHAR(25),
	EmpleadoID INT,
	IdentificadorDePago VARCHAR(50),
	--Eliminado BIT DEFAULT 0, Ver si se considera un borrado logico de una venta por si se aceptan devoluciones (Generar un SP Dar de baja y uno para borrar definitivamente los borrados logicos)
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados.Empleado(EmpleadoID),
	--MedioDePagoID INT,
	--CONSTRAINT FK_MedioDePago FOREIGN KEY (MedioDePagoID) REFERENCES Ventas.MedioDePago(MedioDePagoID) Revisar si usar la tabla MedioDePago
);
GO