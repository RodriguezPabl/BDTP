/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
		-Tatiana Greve, 43031180
		-Nogueira Denise, 41234014

*/

/*
Entrega 3
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
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/
/*
use master

drop database Com2900G12
*/
create database Com2900G12
go

use Com2900G12
go

-- ##### TABLAS #####
-- Creación de esquemas
CREATE SCHEMA Ventas;
go
CREATE SCHEMA Catalogo;
go
CREATE SCHEMA Empleados;
go

-- Tabla de sucursales
CREATE TABLE Ventas.Sucursal (
    SucursalID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
	Localidad NVARCHAR(100) NOT NULL, --ejemplo Sanjusto, Provincia de Buenos Aires
	--codigo postal con check A1111
	CodigoPostal NVARCHAR(5) NOT NULL CHECK (CodigoPostal LIKE '[A-Z][0-9][0-9][0-9][0-9]'),	
	Direccion NVARCHAR(100) NOT NULL, --av geral paz 1234
	--telefono con check  1111-1111
	Telefono NVARCHAR(8) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
);

go

-- Tabla de empleados
CREATE TABLE Empleados.Empleado (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
	Apellido NVARCHAR(100) NOT NULL,
	--dni con check 11111111 98999999
	Dni int NOT NULL CHECK (Dni BETWEEN 10000000 AND 99999999),

	Localidad NVARCHAR(100) NOT NULL, --ejemplo Sanjusto, Provincia de Buenos Aires
	--codigo postal con check A1111
	CodigoPostal NVARCHAR(5) NOT NULL CHECK (CodigoPostal LIKE '[A-Z][0-9][0-9][0-9][0-9]'),	
	Direccion NVARCHAR(100) NOT NULL, --av geral paz 1234

    Email NVARCHAR(100) NOT NULL,
	EmailEmpresarial NVARCHAR(100) NOT NULL,
	Cuil NVARCHAR(100) NOT NULL,
	Cargo NVARCHAR(100) NOT NULL,--ver si es una tabla aparte
	SucursalID INT,
	--turno TM, TT, TN, Jornada Completa
	Turno NVARCHAR(16) NOT NULL CHECK (Turno IN ('TM', 'TT', 'TN', 'Jornada Completa')),--ver si es una tabla aparte
    CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursal(SucursalID),
    CONSTRAINT UQ_Email UNIQUE (Email),
	CONSTRAINT UQ_EmailEmpresarial UNIQUE (EmailEmpresarial)
);
go
--Tabla MedioDePago
CREATE TABLE Ventas.MedioDePago (
	MedioDePagoID INT PRIMARY KEY IDENTITY(1,1),
	Nombre NVARCHAR(100) NOT NULL
);
go
-- Tabla de productos
CREATE TABLE Catalogo.Producto (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
	LineaDeProducto NVARCHAR(100) NOT NULL,--ver si es una tabla aparte
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    SucursalID INT,
    CONSTRAINT FK_Producto_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursal(SucursalID)
);
go
-- Tabla de ventas
CREATE TABLE Ventas.Venta (
	--ventaId 750-67-8428
    VentaID NVARCHAR(100) PRIMARY KEY CHECK (VentaID LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'), 
	--TipoDeFactura A, B, C
	TipoDeFactura NVARCHAR(1) NOT NULL CHECK (TipoDeFactura IN ('A', 'B', 'C')),
	--ciudad si es Yangon reemplazar por San Justo
	Ciudad NVARCHAR(100) NOT NULL,
	TipoDeCliente NVARCHAR(100) NOT NULL, --ver si es una tabla aparte
	Genero NVARCHAR(6) NOT NULL,
	ProductoID INT,
	PrecioUnitario DECIMAL(10, 2) NOT NULL,
	Cantidad INT NOT NULL,
    Fecha DATE NOT NULL DEFAULT GETDATE(),--Date tiene formato YYYY-MM-DD
	Hora TIME NOT NULL,
	MedioDePagoID INT,
	IdentificadorDePago NVARCHAR(100) NOT NULL, --cvu / tarjeta de credito / efectivo --
	EmpleadoID INT,
    Total DECIMAL(10, 2),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados.Empleado(EmpleadoID),
	CONSTRAINT FK_Nombre_Producto FOREIGN KEY (ProductoID) REFERENCES Catalogo.Producto(ProductoID),
	CONSTRAINT FK_MedioDePago FOREIGN KEY (MedioDePagoID) REFERENCES Ventas.MedioDePago(MedioDePagoID)
);
go
-- Tabla de detalles de ventas
/*
CREATE TABLE Ventas.DetalleVentas (
    DetalleID INT PRIMARY KEY IDENTITY(1,1),
    VentaID INT,
    ProductoID INT,
    Cantidad INT,
    Precio DECIMAL(10, 2),
    CONSTRAINT FK_Detalle_Venta FOREIGN KEY (VentaID) REFERENCES Ventas.Ventas(VentaID),
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (ProductoID) REFERENCES Catalogo.Productos(ProductoID)
);
*/

select * from Ventas.Venta
go
--select * from Ventas.DetalleVentas
select * from Ventas.Sucursal
go
select * from Catalogo.Producto
go
select * from Empleados.Empleado
go
/*
-- ##### STORED PROCEDURES #####
-- Procedimiento para insertar una nueva venta
CREATE PROCEDURE InsertarVenta(
    @EmpleadoID INT,
    @Total DECIMAL(10, 2),
    @DetalleVenta XML
	)
AS
BEGIN
    INSERT INTO Ventas.Ventas (EmpleadoID, Total) 
    VALUES (@EmpleadoID, @Total);
    
    DECLARE @VentaID INT = SCOPE_IDENTITY();

    -- Insertar detalles desde XML
    INSERT INTO Ventas.DetalleVentas (VentaID, ProductoID, Cantidad, Precio)
    SELECT 
        @VentaID,
        Det.value('(ProductoID)[1]', 'INT'),
        Det.value('(Cantidad)[1]', 'INT'),
        Det.value('(Precio)[1]', 'DECIMAL(10, 2)')
    FROM @DetalleVenta.nodes('/Detalles/Detalle') AS Det(Det);
END;

-- Procedimiento para registrar un empleado
CREATE PROCEDURE InsertarEmpleado
    @Nombre NVARCHAR(100),
    @SucursalID INT,
    @Email NVARCHAR(100)
AS
BEGIN
    INSERT INTO Empleados.Empleados (Nombre, SucursalID, Email) 
    VALUES (@Nombre, @SucursalID, @Email);
END;

-- ##### REPORTES #####
-- Reporte mensual
CREATE PROCEDURE ReporteMensual
    @Mes INT,
    @Anio INT
AS
BEGIN
    SELECT 
        DAY(Fecha) AS Dia,
        SUM(Total) AS TotalFacturado
    FROM Ventas.Ventas
    WHERE MONTH(Fecha) = @Mes AND YEAR(Fecha) = @Anio
    GROUP BY DAY(Fecha);
END;*/