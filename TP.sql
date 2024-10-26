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

create database PruebaTP
go

use PruebaTP
go

-- ##### TABLAS #####
-- Creación de esquemas
CREATE SCHEMA Ventas
CREATE SCHEMA Catalogo
CREATE SCHEMA Empleados

-- Tabla de sucursales
CREATE TABLE Ventas.Sucursales (
    SucursalID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL
);

-- Tabla de empleados
CREATE TABLE Empleados.Empleados (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    SucursalID INT,
    CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursales(SucursalID),
    Email NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Email UNIQUE (Email)
);

-- Tabla de productos
CREATE TABLE Catalogo.Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    SucursalID INT,
    CONSTRAINT FK_Producto_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursales(SucursalID)
);

-- Tabla de ventas
CREATE TABLE Ventas.Ventas (
    VentaID INT PRIMARY KEY IDENTITY(1,1),
    EmpleadoID INT,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Total DECIMAL(10, 2),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados.Empleados(EmpleadoID)
);

-- Tabla de detalles de ventas
CREATE TABLE Ventas.DetalleVentas (
    DetalleID INT PRIMARY KEY IDENTITY(1,1),
    VentaID INT,
    ProductoID INT,
    Cantidad INT,
    Precio DECIMAL(10, 2),
    CONSTRAINT FK_Detalle_Venta FOREIGN KEY (VentaID) REFERENCES Ventas.Ventas(VentaID),
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (ProductoID) REFERENCES Catalogo.Productos(ProductoID)
);

select * from Ventas.Ventas
select * from Ventas.DetalleVentas
select * from Ventas.Sucursales
select * from Catalogo.Productos
select * from Empleados.Empleados

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
END;