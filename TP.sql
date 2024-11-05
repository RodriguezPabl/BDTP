/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
		-Tatiana Greve, 43031180
		-Nogueira Denise, 41234014
	Fecha: 5/11/24
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

CREATE DATABASE Com2900G12
GO

USE Com2900G12
GO

-- Creación de esquemas
CREATE SCHEMA Ventas;
GO
CREATE SCHEMA Productos;
GO
CREATE SCHEMA Empleados;
GO

-- ##### TABLAS #####
-- Tabla de sucursales
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
	Cargo VARCHAR(50) NOT NULL, --ver si es una tabla aparte
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

--##### INSERCIONES #####
CREATE PROCEDURE Ventas.InsertarSucursal
    @Ciudad VARCHAR(100),
    @Direccion VARCHAR(150),
    @Telefono CHAR(9)
AS
BEGIN
    INSERT INTO Ventas.Sucursal (Ciudad, Direccion, Telefono)
    VALUES (@Ciudad, @Direccion, @Telefono);
END;
GO

CREATE PROCEDURE Empleados.InsertarEmpleado
    @Nombre VARCHAR(75),
    @Apellido VARCHAR(75),
    @Dni INT,
    @Direccion VARCHAR(150),
    @Email VARCHAR(100),
    @EmailEmpresarial VARCHAR(100),
    @Cuil CHAR(13),
    @Cargo VARCHAR(50),
    @SucursalID INT,
    @Turno VARCHAR(16)
AS
BEGIN
    INSERT INTO Empleados.Empleado (Nombre, Apellido, Dni, Direccion, Email, EmailEmpresarial, Cuil, Cargo, SucursalID, Turno)
    VALUES (@Nombre, @Apellido, @Dni, @Direccion, @Email, @EmailEmpresarial, @Cuil, @Cargo, @SucursalID, @Turno);
END;
GO

CREATE PROCEDURE Productos.InsertarCatalogo
    @LineaDeProducto VARCHAR(100),
    @Nombre VARCHAR(100),
    @Precio DECIMAL(10, 2),
    @PrecioReferencial DECIMAL(10, 2),
    @UnidadDeReferencia CHAR(2)
AS
BEGIN
    INSERT INTO Productos.Catalogo (LineaDeProducto, Nombre, Precio, PrecioReferencial, UnidadDeReferencia)
    VALUES (@LineaDeProducto, @Nombre, @Precio, @PrecioReferencial, @UnidadDeReferencia);
END;
GO

CREATE PROCEDURE Productos.InsertarAccesorioElectronico
    @Nombre VARCHAR(100),
    @PrecioEnDolares DECIMAL(7, 2)
AS
BEGIN
    INSERT INTO Productos.AccesorioElectronico (Nombre, PrecioEnDolares)
    VALUES (@Nombre, @PrecioEnDolares);
END;
GO

CREATE PROCEDURE Productos.InsertarProductoImportado
    @Nombre VARCHAR(100),
    @Proveedor VARCHAR(100),
    @LineaDeProducto VARCHAR(100),
    @Precio DECIMAL(7, 2)
AS
BEGIN
    INSERT INTO Productos.ProductoImportado (Nombre, Proveedor, LineaDeProducto, Precio)
    VALUES (@Nombre, @Proveedor, @LineaDeProducto, @Precio);
END;
GO

CREATE PROCEDURE Ventas.InsertarVenta
    @VentaID VARCHAR(100),
    @TipoDeFactura CHAR(1),
    @Ciudad VARCHAR(100),
    @TipoDeCliente VARCHAR(100),
    @Genero VARCHAR(10),
    @Producto VARCHAR(100),
    @PrecioUnitario DECIMAL(10, 2),
    @Cantidad INT,
    @Hora TIME,
    @MedioDePago VARCHAR(25),
    @EmpleadoID INT,
    @IdentificadorDePago VARCHAR(50)
AS
BEGIN
    INSERT INTO Ventas.Venta (VentaID, TipoDeFactura, Ciudad, TipoDeCliente, Genero, Producto, PrecioUnitario, Cantidad, Hora, MedioDePago, EmpleadoID, IdentificadorDePago)
    VALUES (@VentaID, @TipoDeFactura, @Ciudad, @TipoDeCliente, @Genero, @Producto, @PrecioUnitario, @Cantidad, @Hora, @MedioDePago, @EmpleadoID, @IdentificadorDePago);
END;
GO

--##### MODIFICACIONES #####
CREATE PROCEDURE Ventas.ActualizarSucursal
    @SucursalID INT,
    @Ciudad VARCHAR(100) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Telefono CHAR(9) = NULL
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
        Ciudad = COALESCE(@Ciudad, Ciudad),
        Direccion = COALESCE(@Direccion, Direccion),
        Telefono = COALESCE(@Telefono, Telefono)
    WHERE SucursalID = @SucursalID;
END;
GO

CREATE PROCEDURE Empleados.ActualizarEmpleado
    @EmpleadoID INT,
    @Nombre VARCHAR(75) = NULL,
    @Apellido VARCHAR(75) = NULL,
    @Dni INT = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Email VARCHAR(100) = NULL,
    @EmailEmpresarial VARCHAR(100) = NULL,
    @Cuil CHAR(13) = NULL,
    @Cargo VARCHAR(50) = NULL,
    @SucursalID INT = NULL,
    @Turno VARCHAR(16) = NULL
AS
BEGIN
    -- Verificar si el empleado existe
    IF NOT EXISTS (SELECT 1 FROM Empleados.Empleado WHERE EmpleadoID = @EmpleadoID)
    BEGIN
        RAISERROR('Empleado no encontrado.', 16, 1);
        RETURN;
    END
    UPDATE Empleados.Empleado
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        Apellido = COALESCE(@Apellido, Apellido),
        Dni = COALESCE(@Dni, Dni),
        Direccion = COALESCE(@Direccion, Direccion),
        Email = COALESCE(@Email, Email),
        EmailEmpresarial = COALESCE(@EmailEmpresarial, EmailEmpresarial),
        Cuil = COALESCE(@Cuil, Cuil),
        Cargo = COALESCE(@Cargo, Cargo),
        SucursalID = COALESCE(@SucursalID, SucursalID),
        Turno = COALESCE(@Turno, Turno)
    WHERE EmpleadoID = @EmpleadoID;
END;
GO

CREATE PROCEDURE Productos.ActualizarCatalogo
    @ProductoID INT,
    @LineaDeProducto VARCHAR(100) = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(10, 2) = NULL,
    @PrecioReferencial DECIMAL(10, 2) = NULL,
    @UnidadDeReferencia VARCHAR(100) = NULL
AS
BEGIN
    -- Verificar si el catalogo existe
    IF NOT EXISTS (SELECT 1 FROM Productos.Catalogo WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Catalogo no encontrado.', 16, 1);
        RETURN;
    END
    UPDATE Productos.Catalogo
    SET 
        LineaDeProducto = COALESCE(@LineaDeProducto, LineaDeProducto),
        Nombre = COALESCE(@Nombre, Nombre),
        Precio = COALESCE(@Precio, Precio),
        PrecioReferencial = COALESCE(@PrecioReferencial, PrecioReferencial),
        UnidadDeReferencia = COALESCE(@UnidadDeReferencia, UnidadDeReferencia)
    WHERE ProductoID = @ProductoID;
END;
GO

CREATE PROCEDURE Productos.ActualizarAccesorioElectronico
    @AElectronicoID INT,
    @Nombre VARCHAR(100) = NULL,
    @PrecioEnDolares DECIMAL(7, 2) = NULL
AS
BEGIN
    -- Verificar si el accesorio electronico existe
    IF NOT EXISTS (SELECT 1 FROM Productos.AccesorioElectronico WHERE AElectronicoID = @AElectronicoID)
    BEGIN
        RAISERROR('Accesorio electronico no encontrado.', 16, 1);
        RETURN;
    END
    UPDATE Productos.AccesorioElectronico
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        PrecioEnDolares = COALESCE(@PrecioEnDolares, PrecioEnDolares)
    WHERE AElectronicoID = @AElectronicoID;
END;
GO

CREATE PROCEDURE Productos.ActualizarProductoImportado
    @PImportadoID INT,
    @Nombre VARCHAR(100) = NULL,
    @Proveedor VARCHAR(100) = NULL,
    @LineaDeProducto VARCHAR(100) = NULL,
    @Precio DECIMAL(7, 2) = NULL
AS
BEGIN
    -- Verificar si el producto importado existe
    IF NOT EXISTS (SELECT 1 FROM Productos.ProductoImportado WHERE PImportadoID = @PImportadoID)
    BEGIN
        RAISERROR('Producto importado no encontrado.', 16, 1);
        RETURN;
    END
    UPDATE Productos.ProductoImportado
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        Proveedor = COALESCE(@Proveedor, Proveedor),
        LineaDeProducto = COALESCE(@LineaDeProducto, LineaDeProducto),
        Precio = COALESCE(@Precio, Precio)
    WHERE PImportadoID = @PImportadoID;
END;
GO

CREATE PROCEDURE Ventas.ActualizarVenta
    @VentaID VARCHAR(100),
    @TipoDeFactura CHAR(1) = NULL,
    @Ciudad VARCHAR(100) = NULL,
    @TipoDeCliente VARCHAR(100) = NULL,
    @Genero VARCHAR(6) = NULL,
    @Producto VARCHAR(100) = NULL,
    @PrecioUnitario DECIMAL(10, 2) = NULL,
    @Cantidad INT = NULL,
    @Hora TIME = NULL,
    @MedioDePago VARCHAR(25) = NULL,
    @EmpleadoID INT = NULL,
    @IdentificadorDePago VARCHAR(50) = NULL
AS
BEGIN
    -- Verificar si la venta existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE VentaID = @VentaID)
    BEGIN
        RAISERROR('Venta no encontrada.', 16, 1);
        RETURN;
    END
    UPDATE Ventas.Venta
    SET 
        TipoDeFactura = COALESCE(@TipoDeFactura, TipoDeFactura),
        Ciudad = COALESCE(@Ciudad, Ciudad),
        TipoDeCliente = COALESCE(@TipoDeCliente, TipoDeCliente),
        Genero = COALESCE(@Genero, Genero),
        Producto = COALESCE(@Producto, Producto),
        PrecioUnitario = COALESCE(@PrecioUnitario, PrecioUnitario),
        Cantidad = COALESCE(@Cantidad, Cantidad),
        Hora = COALESCE(@Hora, Hora),
        MedioDePago = COALESCE(@MedioDePago, MedioDePago),
        EmpleadoID = COALESCE(@EmpleadoID, EmpleadoID),
        IdentificadorDePago = COALESCE(@IdentificadorDePago, IdentificadorDePago)
    WHERE VentaID = @VentaID;
END;
GO


--##### BORRADOS #####

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
GO

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
GO

CREATE PROCEDURE Productos.EliminarCatalogo
    @ProductoID INT
AS
BEGIN
    -- Verificar si el catalogo existe
    IF NOT EXISTS (SELECT 1 FROM Productos.Catalogo WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Catalogo no encontrado.', 16, 1);
        RETURN;
    END
    DELETE FROM Productos.Catalogo
    WHERE ProductoID = @ProductoID;
END;
GO

CREATE PROCEDURE Productos.EliminarAccesorioElectronico
    @AElectronicoID INT
AS
BEGIN
    -- Verificar si el accesorio electronico existe
    IF NOT EXISTS (SELECT 1 FROM Productos.AccesorioElectronico WHERE AElectronicoID = @AElectronicoID)
    BEGIN
        RAISERROR('Accesorio electronico no encontrado.', 16, 1);
        RETURN;
    END
    DELETE FROM Productos.AccesorioElectronico
    WHERE AElectronicoID = @AElectronicoID;
END;
GO

CREATE PROCEDURE Productos.EliminarProductoImportado
    @PImportadoID INT
AS
BEGIN
    -- Verificar si el producto importado existe
    IF NOT EXISTS (SELECT 1 FROM Productos.ProductoImportado WHERE PImportadoID = @PImportadoID)
    BEGIN
        RAISERROR('Producto importado no encontrado.', 16, 1);
        RETURN;
    END
    DELETE FROM Productos.ProductoImportado
    WHERE PImportadoID = @PImportadoID;
END;
GO

CREATE PROCEDURE Ventas.EliminarVenta
    @VentaID VARCHAR(100)
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

/*
select * from Ventas.Sucursal
select * from Empleados.Empleado
select * from Productos.Catalogo
select * from Productos.AccesorioElectronico
select * from Productos.ProductoImportado
select * from Ventas.Venta 

##### PRUEBAS DE INSERCION #####
EXEC Ventas.InsertarSucursal @Ciudad = 'Moron', @Direccion = 'Carlos Calvo 3344', @Telefono = '1234-6789'
EXEC Ventas.InsertarSucursal @Ciudad = 'Haedo', @Direccion = 'Int. Carrere 2598', @Telefono = '1234-6790'
EXEC Ventas.InsertarSucursal @Ciudad = 'Ramos Mejia', @Direccion = 'Av. de Mayo 333', @Telefono = '1234-6791'

EXEC Empleados.InsertarEmpleado @Nombre = 'Juan', @Apellido = 'Pérez', @Dni = 12345678, @Direccion = 'Av. Libertador 1000', @Email = 'juan.perez@example.com', @EmailEmpresarial = 'juan.perez@empresa.com', 
    @Cuil = '20-12345678-9', @Cargo = 'Desarrollador', @SucursalID = 1, @Turno = 'TM'

EXEC Productos.InsertarCatalogo @LineaDeProducto = 'Fruta', @Nombre = 'Banana', @Precio = 0.26, @PrecioReferencial = 1.29, @UnidadDeReferencia = 'kg'
EXEC Productos.InsertarCatalogo @LineaDeProducto = 'Fruta', @Nombre = 'Uva', @Precio = 2.84, @PrecioReferencial = 3.79, @UnidadDeReferencia = 'kg'
EXEC Productos.InsertarCatalogo @LineaDeProducto = 'Fruta', @Nombre = 'Manzana', @Precio = 0.45, @PrecioReferencial = 1.79, @UnidadDeReferencia = 'kg'

EXEC Productos.InsertarAccesorioElectronico @Nombre = 'Cargador Rápido', @PrecioEnDolares = 29.99

EXEC Productos.InsertarProductoImportado @Nombre = 'Laptop XYZ', @Proveedor = 'Proveedor ABC', @LineaDeProducto = 'Computación', @Precio = 799.99

EXEC Ventas.InsertarVenta @VentaID = '001-02-5678', @TipoDeFactura = 'A', @Ciudad = 'San Justo', @TipoDeCliente = 'Regular', @Genero = 'Masculino', @Producto = 'Smartphone XYZ',
	@PrecioUnitario = 499.99, @Cantidad = 1, @Hora = '14:30:00', @MedioDePago = 'Tarjeta', @EmpleadoID = 257020, @IdentificadorDePago = '000202020301230'

##### PRUEBAS DE ELIMINACION #####
EXEC Ventas.EliminarVenta @VentaID='001-02-5678'
EXEC Empleados.EliminarEmpleado @EmpleadoID=257020

##### PRUEBAS DE ACTUALIZACION #####
EXEC Productos.ActualizarAccesorioElectronico @AElectronicoID=1, @PrecioEnDolares=14.99
EXEC Productos.ActualizarProductoImportado @PImportadoID=1, @Nombre='Laptop ABC'
EXEC Ventas.ActualizarSucursal @SucursalID = 2, @Ciudad = 'Buenos Aires', @Direccion = 'Av. Corrientes 1234', @Telefono = '1234-5678'
*/

-- VERIFICACION DE MEMORIA ASIGNADA Y PUERTOS QUE UTILIZA
/*
EXEC sp_configure 'show advanced options', 1;
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max server memory (MB)';
EXEC sp_configure 'min server memory (MB)';

SELECT local_net_address, local_tcp_port
FROM sys.dm_exec_connections
WHERE session_id = @@SPID;
*/


















-- COSAS DE OTRAS ENTREGAS / PARA AGREGAR O CAMBIAR

--Tabla MedioDePago
/*
CREATE TABLE Ventas.MedioDePago (
	MedioDePagoID INT PRIMARY KEY IDENTITY(1,1),
	Nombre NVARCHAR(100) NOT NULL,
	Identificador VARCHAR(50) DEFAULT NULL
);
GO*/


/*
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
go*/

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

