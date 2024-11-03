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
	Localidad NVARCHAR(100) NOT NULL, --ejemplo Sanjusto, Provincia de Buenos Aires
	--codigo postal con check A1111
	CodigoPostal NVARCHAR(5) NOT NULL CHECK (CodigoPostal LIKE '[A-Z][0-9][0-9][0-9][0-9]'),	
	Direccion NVARCHAR(100) NOT NULL, --av geral paz 1234
	--telefono con check  1111-1111
	Telefono NVARCHAR(9) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
);
go

insert into Ventas.Sucursal (Localidad,CodigoPostal,Direccion,Telefono) values ('San Justo','B1754','Av. Brig. Gral. Juan Manuel de Rosas 3634','5555-5551'),
																			('Ramos Mejia','B1704','Av. de Mayo 791','5555-5552'),
																			('Lomas del Mirador','B1753',' Pres. Juan Domingo Perón 763','5555-5553')
go

CREATE PROCEDURE Ventas.ActualizarSucursal
    @SucursalID INT,
    @Localidad NVARCHAR(100) = NULL,
    @CodigoPostal NVARCHAR(5) = NULL,
    @Direccion NVARCHAR(100) = NULL,
    @Telefono NVARCHAR(9) = NULL
AS
BEGIN
	-- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.Sucursal WHERE SucursalID = @SucursalID)
    BEGIN
        RAISERROR('Sucursal no encontrada.', 16, 1);
        RETURN;
    END

	UPDATE Ventas.Sucursal
    SET
        Localidad = COALESCE(@Localidad, Localidad),
        CodigoPostal = COALESCE(@CodigoPostal, CodigoPostal),
        Direccion = COALESCE(@Direccion, Direccion),
        Telefono = COALESCE(@Telefono, Telefono)
    WHERE SucursalID = @SucursalID;
END;
go

CREATE PROCEDURE Ventas.InsertarSucursal
    @Localidad NVARCHAR(100),
    @CodigoPostal NVARCHAR(5),
    @Direccion NVARCHAR(100),
    @Telefono NVARCHAR(9)
AS
BEGIN
	INSERT INTO Ventas.Sucursal (Localidad, CodigoPostal, Direccion, Telefono)
    VALUES (@Localidad, @CodigoPostal, @Direccion, @Telefono);
END;
go

CREATE PROCEDURE Ventas.EliminarSucursal
    @SucursalID INT
AS
BEGIN
    -- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.Sucursal WHERE SucursalID = @SucursalID)
    BEGIN
        RAISERROR('Sucursal no encontrada.', 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.Sucursal
    WHERE SucursalID = @SucursalID;
END;
go

-- Tabla de empleados
CREATE TABLE Empleados.Empleado (
    EmpleadoID INT PRIMARY KEY IDENTITY(257020,1),
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
    --cargo Cajero, Supervisor, Gerente de Sucursal
	Cargo NVARCHAR(100) NOT NULL, --ver si es una tabla aparte
	SucursalID INT,
	--turno TM, TT, TN, Jornada Completa
	Turno NVARCHAR(16) NOT NULL CHECK (Turno IN ('TM', 'TT', 'TN', 'Jornada Completa')),--ver si es una tabla aparte
    CONSTRAINT FK_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursal(SucursalID),
    CONSTRAINT UQ_Email UNIQUE (Email),
	CONSTRAINT UQ_EmailEmpresarial UNIQUE (EmailEmpresarial)
);
go


CREATE PROCEDURE Empleados.InsertarEmpleado
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Dni INT,
    @Localidad NVARCHAR(100),
    @CodigoPostal NVARCHAR(5),
    @Direccion NVARCHAR(100),
    @Email NVARCHAR(100),
    @EmailEmpresarial NVARCHAR(100),
    @Cuil NVARCHAR(100),
    @Cargo NVARCHAR(100),
    @SucursalID INT,
    @Turno NVARCHAR(16)
AS
BEGIN
    INSERT INTO Empleados.Empleado (Nombre, Apellido, Dni, Localidad, CodigoPostal, Direccion, Email, EmailEmpresarial, Cuil, Cargo, SucursalID, Turno)
    VALUES (@Nombre, @Apellido, @Dni, @Localidad, @CodigoPostal, @Direccion, @Email, @EmailEmpresarial, @Cuil, @Cargo, @SucursalID, @Turno);
END;
go

CREATE PROCEDURE Empleados.ActualizarEmpleado
    @EmpleadoID INT,
    @Nombre NVARCHAR(100) = NULL,
    @Apellido NVARCHAR(100) = NULL,
    @Dni INT = NULL,
    @Localidad NVARCHAR(100) = NULL,
    @CodigoPostal NVARCHAR(5) = NULL,
    @Direccion NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @EmailEmpresarial NVARCHAR(100) = NULL,
    @Cuil NVARCHAR(100) = NULL,
    @Cargo NVARCHAR(100) = NULL,
    @SucursalID INT = NULL,
    @Turno NVARCHAR(16) = NULL
AS
BEGIN
    -- Verificar si el empleado existe
    IF NOT EXISTS (SELECT 1 FROM Empleados.Empleado WHERE EmpleadoID = @EmpleadoID)
    BEGIN
        RAISERROR('Empleado no encontrado.', 16, 1);
        RETURN;
    END

    -- Actualizar los campos solo si se proporciona un valor
    UPDATE Empleados.Empleado
    SET
        Nombre = COALESCE(@Nombre, Nombre),
        Apellido = COALESCE(@Apellido, Apellido),
        Dni = COALESCE(@Dni, Dni),
        Localidad = COALESCE(@Localidad, Localidad),
        CodigoPostal = COALESCE(@CodigoPostal, CodigoPostal),
        Direccion = COALESCE(@Direccion, Direccion),
        Email = COALESCE(@Email, Email),
        EmailEmpresarial = COALESCE(@EmailEmpresarial, EmailEmpresarial),
        Cuil = COALESCE(@Cuil, Cuil),
        Cargo = COALESCE(@Cargo, Cargo),
        SucursalID = COALESCE(@SucursalID, SucursalID),
        Turno = COALESCE(@Turno, Turno)
    WHERE EmpleadoID = @EmpleadoID;
END;
go

CREATE PROCEDURE Empleados.EliminarEmpleado
    @EmpleadoID INT
AS
BEGIN
    -- Verificar si el empleado existe
    IF NOT EXISTS (SELECT 1 FROM Empleados.Empleado WHERE EmpleadoID = @EmpleadoID)
    BEGIN
        RAISERROR('Empleado no encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM Empleados.Empleado
    WHERE EmpleadoID = @EmpleadoID;
END;
go

--Tabla MedioDePago
CREATE TABLE Ventas.MedioDePago (
	MedioDePagoID INT PRIMARY KEY IDENTITY(1,1),
	Nombre NVARCHAR(100) NOT NULL
);
go

CREATE PROCEDURE Ventas.InsertarMedioDePago
    @Nombre NVARCHAR(100)
AS
BEGIN
    INSERT INTO Ventas.MedioDePago (Nombre)
    VALUES (@Nombre);
END;
go

CREATE PROCEDURE Ventas.ActualizarMedioDePago
    @MedioDePagoID INT,
    @Nombre NVARCHAR(100) = NULL
AS
BEGIN
    -- Verificar si el medio de pago existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.MedioDePago WHERE MedioDePagoID = @MedioDePagoID)
    BEGIN
        RAISERROR('Medio de pago no encontrado.', 16, 1);
        RETURN;
    END

    -- Actualizar el nombre solo si se proporciona un valor
    UPDATE Ventas.MedioDePago
    SET Nombre = COALESCE(@Nombre, Nombre)
    WHERE MedioDePagoID = @MedioDePagoID;
END;
go

CREATE PROCEDURE Ventas.EliminarMedioDePago
    @MedioDePagoID INT
AS
BEGIN
    -- Verificar si el medio de pago existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.MedioDePago WHERE MedioDePagoID = @MedioDePagoID)
    BEGIN
        RAISERROR('Medio de pago no encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.MedioDePago
    WHERE MedioDePagoID = @MedioDePagoID;
END;
go

-- Tabla de productos
CREATE TABLE Catalogo.Producto (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
	LineaDeProducto NVARCHAR(100) NOT NULL,--ver si es una tabla aparte
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
	PrecioReferencial DECIMAL(10, 2),
	UnidadDeReferencia NVARCHAR(2),
    SucursalID INT,
    CONSTRAINT FK_Producto_Sucursal FOREIGN KEY (SucursalID) REFERENCES Ventas.Sucursal(SucursalID)
);
go

CREATE PROCEDURE Catalogo.InsertarProducto
    @LineaDeProducto NVARCHAR(100),
    @Nombre NVARCHAR(100),
    @Precio DECIMAL(10, 2),
    @PrecioReferencial DECIMAL(10, 2) = NULL,
    @UnidadDeReferencia NVARCHAR(2) = NULL,
    @SucursalID INT
AS
BEGIN
    INSERT INTO Catalogo.Producto (LineaDeProducto, Nombre, Precio, PrecioReferencial, UnidadDeReferencia, SucursalID)
    VALUES (@LineaDeProducto, @Nombre, @Precio, @PrecioReferencial, @UnidadDeReferencia, @SucursalID);
END;
go

CREATE PROCEDURE Catalogo.ActualizarProducto
    @ProductoID INT,
    @LineaDeProducto NVARCHAR(100) = NULL,
    @Nombre NVARCHAR(100) = NULL,
    @Precio DECIMAL(10, 2) = NULL,
    @PrecioReferencial DECIMAL(10, 2) = NULL,
    @UnidadDeReferencia NVARCHAR(2) = NULL,
    @SucursalID INT = NULL
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Catalogo.Producto WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        RETURN;
    END

    -- Actualizar los campos solo si se proporciona un valor
    UPDATE Catalogo.Producto
    SET
        LineaDeProducto = COALESCE(@LineaDeProducto, LineaDeProducto),
        Nombre = COALESCE(@Nombre, Nombre),
        Precio = COALESCE(@Precio, Precio),
        PrecioReferencial = COALESCE(@PrecioReferencial, PrecioReferencial),
        UnidadDeReferencia = COALESCE(@UnidadDeReferencia, UnidadDeReferencia),
        SucursalID = COALESCE(@SucursalID, SucursalID)
    WHERE ProductoID = @ProductoID;
END;
go

CREATE PROCEDURE Catalogo.EliminarProducto
    @ProductoID INT
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Catalogo.Producto WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM Catalogo.Producto
    WHERE ProductoID = @ProductoID;
END;
go

CREATE TABLE Catalogo.Catalogo (
    ProductoID INT PRIMARY KEY,
    LineaDeProducto NVARCHAR(100) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,  -- Cambiar a DECIMAL
    PrecioReferencial DECIMAL(10, 2), -- Cambiar a DECIMAL
    UnidadDeReferencia NVARCHAR(100),
    Fecha DATETIME
);
go

CREATE PROCEDURE Catalogo.InsertarCatalogo
    @ProductoID INT,
    @LineaDeProducto NVARCHAR(100),
    @Nombre NVARCHAR(100),
    @Precio DECIMAL(10, 2),
    @PrecioReferencial DECIMAL(10, 2) = NULL,
    @UnidadDeReferencia NVARCHAR(100),
    @Fecha DATETIME
AS
BEGIN
    INSERT INTO Catalogo.Catalogo (ProductoID, LineaDeProducto, Nombre, Precio, PrecioReferencial, UnidadDeReferencia, Fecha)
    VALUES (@ProductoID, @LineaDeProducto, @Nombre, @Precio, @PrecioReferencial, @UnidadDeReferencia, @Fecha);
END;
GO

CREATE PROCEDURE Catalogo.ActualizarCatalogo
    @ProductoID INT,
    @LineaDeProducto NVARCHAR(100) = NULL,
    @Nombre NVARCHAR(100) = NULL,
    @Precio DECIMAL(10, 2) = NULL,
    @PrecioReferencial DECIMAL(10, 2) = NULL,
    @UnidadDeReferencia NVARCHAR(100) = NULL,
    @Fecha DATETIME = NULL
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Catalogo.Catalogo WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Producto no encontrado en el catálogo.', 16, 1);
        RETURN;
    END

    -- Actualizar los campos solo si se proporciona un valor
    UPDATE Catalogo.Catalogo
    SET
        LineaDeProducto = COALESCE(@LineaDeProducto, LineaDeProducto),
        Nombre = COALESCE(@Nombre, Nombre),
        Precio = COALESCE(@Precio, Precio),
        PrecioReferencial = COALESCE(@PrecioReferencial, PrecioReferencial),
        UnidadDeReferencia = COALESCE(@UnidadDeReferencia, UnidadDeReferencia),
        Fecha = COALESCE(@Fecha, Fecha)
    WHERE ProductoID = @ProductoID;
END;
GO

CREATE PROCEDURE Catalogo.EliminarCatalogo
    @ProductoID INT
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Catalogo.Catalogo WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Producto no encontrado en el catálogo.', 16, 1);
        RETURN;
    END

    DELETE FROM Catalogo.Catalogo
    WHERE ProductoID = @ProductoID;
END;
GO

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

CREATE PROCEDURE Ventas.InsertarVenta
    @VentaID NVARCHAR(100),
    @TipoDeFactura NVARCHAR(1),
    @Ciudad NVARCHAR(100),
    @TipoDeCliente NVARCHAR(100),
    @Genero NVARCHAR(6),
    @ProductoID INT,
    @PrecioUnitario DECIMAL(10, 2),
    @Cantidad INT,
    @Hora TIME,
    @MedioDePagoID INT,
    @IdentificadorDePago NVARCHAR(100),
    @EmpleadoID INT,
    @Total DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Ventas.Venta (VentaID, TipoDeFactura, Ciudad, TipoDeCliente, Genero, ProductoID, PrecioUnitario, Cantidad, Fecha, Hora, MedioDePagoID, IdentificadorDePago, EmpleadoID, Total)
    VALUES (@VentaID, @TipoDeFactura, @Ciudad, @TipoDeCliente, @Genero, @ProductoID, @PrecioUnitario, @Cantidad, GETDATE(), @Hora, @MedioDePagoID, @IdentificadorDePago, @EmpleadoID, @Total);
END;
GO

CREATE PROCEDURE Ventas.ActualizarVenta
    @VentaID NVARCHAR(100),
    @TipoDeFactura NVARCHAR(1) = NULL,
    @Ciudad NVARCHAR(100) = NULL,
    @TipoDeCliente NVARCHAR(100) = NULL,
    @Genero NVARCHAR(6) = NULL,
    @ProductoID INT = NULL,
    @PrecioUnitario DECIMAL(10, 2) = NULL,
    @Cantidad INT = NULL,
    @Hora TIME = NULL,
    @MedioDePagoID INT = NULL,
    @IdentificadorDePago NVARCHAR(100) = NULL,
    @EmpleadoID INT = NULL,
    @Total DECIMAL(10, 2) = NULL
AS
BEGIN
    -- Verificar si la venta existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE VentaID = @VentaID)
    BEGIN
        RAISERROR('Venta no encontrada.', 16, 1);
        RETURN;
    END

    -- Actualizar los campos solo si se proporciona un valor
    UPDATE Ventas.Venta
    SET
        TipoDeFactura = COALESCE(@TipoDeFactura, TipoDeFactura),
        Ciudad = COALESCE(@Ciudad, Ciudad),
        TipoDeCliente = COALESCE(@TipoDeCliente, TipoDeCliente),
        Genero = COALESCE(@Genero, Genero),
        ProductoID = COALESCE(@ProductoID, ProductoID),
        PrecioUnitario = COALESCE(@PrecioUnitario, PrecioUnitario),
        Cantidad = COALESCE(@Cantidad, Cantidad),
        Hora = COALESCE(@Hora, Hora),
        MedioDePagoID = COALESCE(@MedioDePagoID, MedioDePagoID),
        IdentificadorDePago = COALESCE(@IdentificadorDePago, IdentificadorDePago),
        EmpleadoID = COALESCE(@EmpleadoID, EmpleadoID),
        Total = COALESCE(@Total, Total)
    WHERE VentaID = @VentaID;
END;
GO

CREATE PROCEDURE Ventas.EliminarVenta
    @VentaID NVARCHAR(100)
AS
BEGIN
    -- Verificar si la venta existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE VentaID = @VentaID)
    BEGIN
        RAISERROR('Venta no encontrada.', 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.Venta
    WHERE VentaID = @VentaID;
END;
GO

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
select * from Catalogo.Producto
go
select * from Empleados.Empleado
go

--tabla para obtener el path del archivo .sql E:\Unlam\BaseDeDatosAplicada\2024-2C\TP\BDTP\TP.sql


--Insertar datos de catalogo.csv from ../TP_integrador_Archivos\Productos\catalogo.csv
/*
BULK INSERT Catalogo.Catalogo
FROM 'E:\Unlam\BaseDeDatosAplicada\2024-2C\TP\BDTP\TP_integrador_Archivos\Productos\catalogo.csv'  -- Ruta relativa
WITH
(
	FORMAT = 'CSV',       -- Maneja automáticamente las comillas y delimitadores
    CODEPAGE = '65001',  -- UTF-8
	FIRSTROW = 2
);
go 
select * from Catalogo.Catalogo
GO
--Stored procedure de insercion de csv
CREATE OR ALTER PROCEDURE ImportarDesdeCSV
    @Schema NVARCHAR(128),
    @Tabla NVARCHAR(128),
    @Ruta NVARCHAR(255)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT
    SET @SQL = 'BULK INSERT ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Tabla) + '
                FROM ' + QUOTENAME(@Ruta, '''') + ' -- Ruta relativa
                WITH
                (
                    FORMAT = ''CSV'',       -- Maneja automáticamente las comillas y delimitadores
                    CODEPAGE = ''65001'',  -- UTF-8
                    FIRSTROW = 2
                );';

    -- Ejecutar la instrucción SQL dinámica
    EXEC sp_executesql @SQL;
END;

--VACIAR TABLA CATALOGO
TRUNCATE TABLE Catalogo.Catalogo

EXEC ImportarDesdeCSV 'Catalogo', 'Catalogo', 'E:\Unlam\BaseDeDatosAplicada\2024-2C\TP\BDTP\TP_integrador_Archivos\Productos\catalogo.csv';


EXEC xp_cmdshell 'echo %CD%';


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell';

EXEC xp_cmdshell 'cd';



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
*/

