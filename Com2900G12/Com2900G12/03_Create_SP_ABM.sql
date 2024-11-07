USE Com2900G12
GO

-- SP's de Sucursal
CREATE OR ALTER PROCEDURE Sucursal.InsertarSucursal
    @Ciudad VARCHAR(100) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Telefono CHAR(9) = NULL,
    @Horario VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @Ciudad IS NULL
        SET @Errores = @Errores + 'El parámetro Ciudad no puede ser NULL. ';
    
    IF @Direccion IS NULL
        SET @Errores = @Errores + 'El parámetro Direccion no puede ser NULL. ';
    
    IF @Telefono IS NULL
        SET @Errores = @Errores + 'El parámetro Telefono no puede ser NULL. ';
    
    IF @Horario IS NULL
        SET @Errores = @Errores + 'El parámetro Horario no puede ser NULL. ';

    -- Verificar si ya existe una sucursal con la misma Dirección o Teléfono (violación de restricciones UNIQUE)
    IF EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Direccion = @Direccion)
    BEGIN
        SET @Errores = @Errores + 'Ya existe una sucursal con la misma Dirección. ';
    END

    IF EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Telefono = @Telefono)
    BEGIN
        SET @Errores = @Errores + 'Ya existe una sucursal con el mismo Teléfono. ';
    END

	IF @Errores <> ''
	BEGIN
		RAISERROR(@Errores,16,1)
		RETURN
	END

    INSERT INTO Sucursal.Sucursal (Ciudad, Direccion, Telefono, Horario)
    VALUES (@Ciudad, @Direccion, @Telefono, @Horario);
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.ModificarSucursal
    @SucursalID INT = NULL,
    @Ciudad VARCHAR(100) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Telefono CHAR(9) = NULL,
	@Horario VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE SucursalID = @SucursalID)
        SET @Errores = @Errores + 'Sucursal no encontrada. ';

    -- Verificar si la nueva Dirección ya existe (si se pasa una nueva dirección)
    IF @Direccion IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Direccion = @Direccion AND SucursalID <> @SucursalID)
        SET @Errores = @Errores + 'Ya existe una sucursal con esa dirección. ';

    -- Verificar si el nuevo Teléfono ya existe (si se pasa un nuevo teléfono)
    IF @Telefono IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Telefono = @Telefono AND SucursalID <> @SucursalID)
        SET @Errores = @Errores + 'Ya existe una sucursal con ese teléfono. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Sucursal.Sucursal
    SET 
        Ciudad = COALESCE(@Ciudad, Ciudad),
        Direccion = COALESCE(@Direccion, Direccion),
        Telefono = COALESCE(@Telefono, Telefono),
		Horario = COALESCE(@Horario, Horario)
    WHERE SucursalID = @SucursalID;
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.BorrarSucursal
    @SucursalID INT
AS
BEGIN
    -- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE SucursalID = @SucursalID)
    BEGIN
        RAISERROR('Sucursal no encontrada.',16,1);
		RETURN
    END

    -- Actualizar el estado de la sucursal a 1 (eliminada o inactiva)
    UPDATE Sucursal.Sucursal
    SET Estado = 1
    WHERE SucursalID = @SucursalID;
END;
GO


-- SP's de Cargo
CREATE OR ALTER PROCEDURE Sucursal.InsertarCargo
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el parámetro es NULL
    IF @Descripcion IS NULL
        SET @Errores = @Errores + 'El parámetro Descripcion no puede ser NULL. ';

    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Sucursal.Cargo (Descripcion)
    VALUES (@Descripcion);
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.ModificarCargo
    @CargoID INT = NULL,
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el Cargo existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE CargoID = @CargoID)
        SET @Errores = @Errores + 'Cargo no encontrado. ';

    -- Verificar si la nueva Descripción ya existe
    IF @Descripcion IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE Descripcion = @Descripcion AND CargoID <> @CargoID)
        SET @Errores = @Errores + 'Ya existe un cargo con esa descripción. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Sucursal.Cargo
    SET 
        Descripcion = COALESCE(@Descripcion, Descripcion)
    WHERE CargoID = @CargoID;
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.BorrarCargo
    @CargoID INT
AS
BEGIN
    -- Verificar si el cargo existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE CargoID = @CargoID)
    BEGIN
        RAISERROR('Cargo no encontrado.', 16, 1);
        RETURN;
    END

    -- Eliminar el cargo
    DELETE FROM Sucursal.Cargo
    WHERE CargoID = @CargoID;
END;
GO

-- SP's de Empleado
CREATE OR ALTER PROCEDURE Sucursal.InsertarEmpleado
    @Nombre VARCHAR(75) = NULL,
    @Apellido VARCHAR(75) = NULL,
    @Dni CHAR(8) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Email VARCHAR(100) = NULL,
    @EmailEmpresarial VARCHAR(100) = NULL,
    @Cuil CHAR(13) = NULL,
    @Estado BIT = 0,
    @Turno VARCHAR(16) = NULL,
    @SucursalID INT = NULL,
    @CargoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @Nombre IS NULL
        SET @Errores = @Errores + 'El parámetro Nombre no puede ser NULL. ';
    
    IF @Apellido IS NULL
        SET @Errores = @Errores + 'El parámetro Apellido no puede ser NULL. ';
    
    IF @Dni IS NULL
        SET @Errores = @Errores + 'El parámetro Dni no puede ser NULL. ';
    
    IF @Direccion IS NULL
        SET @Errores = @Errores + 'El parámetro Direccion no puede ser NULL. ';
    
    IF @Email IS NULL
        SET @Errores = @Errores + 'El parámetro Email no puede ser NULL. ';
    
    IF @EmailEmpresarial IS NULL
        SET @Errores = @Errores + 'El parámetro EmailEmpresarial no puede ser NULL. ';
    
    IF @Cuil IS NULL
        SET @Errores = @Errores + 'El parámetro Cuil no puede ser NULL. ';
    
    IF @Turno IS NULL
        SET @Errores = @Errores + 'El parámetro Turno no puede ser NULL. ';
    
    IF @SucursalID IS NULL
        SET @Errores = @Errores + 'El parámetro SucursalID no puede ser NULL. ';
    
    IF @CargoID IS NULL
        SET @Errores = @Errores + 'El parámetro CargoID no puede ser NULL. ';
    
    -- Verificar si el email o email empresarial ya existen
    IF EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE Email = @Email)
        SET @Errores = @Errores + 'Ya existe un empleado con el mismo Email. ';
    
    IF EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE EmailEmpresarial = @EmailEmpresarial)
        SET @Errores = @Errores + 'Ya existe un empleado con el mismo Email Empresarial. ';

	-- Verificar si la sucursal y cargo existen
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE SucursalID = @SucursalID)
        SET @Errores = @Errores + 'La sucursal especificada no existe. ';

	IF NOT EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE CargoID = @CargoID)
        SET @Errores = @Errores + 'El cargo especificado no existe. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Sucursal.Empleado (Nombre, Apellido, Dni, Direccion, Email, EmailEmpresarial, Cuil, Estado, Turno, SucursalID, CargoID)
    VALUES (@Nombre, @Apellido, @Dni, @Direccion, @Email, @EmailEmpresarial, @Cuil, @Estado, @Turno, @SucursalID, @CargoID);
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.ModificarEmpleado
    @EmpleadoID INT = NULL,
    @Nombre VARCHAR(75) = NULL,
    @Apellido VARCHAR(75) = NULL,
    @Dni CHAR(8) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Email VARCHAR(100) = NULL,
    @EmailEmpresarial VARCHAR(100) = NULL,
    @Cuil CHAR(13) = NULL,
    @Turno VARCHAR(16) = NULL,
    @SucursalID INT = NULL,
    @CargoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el Empleado existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE EmpleadoID = @EmpleadoID)
        SET @Errores = @Errores + 'Empleado no encontrado. ';

    -- Verificar si el nuevo Email ya existe
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE Email = @Email AND EmpleadoID <> @EmpleadoID)
        SET @Errores = @Errores + 'Ya existe un empleado con ese email. ';

    -- Verificar si el nuevo Email Empresarial ya existe
    IF @EmailEmpresarial IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE EmailEmpresarial = @EmailEmpresarial AND EmpleadoID <> @EmpleadoID)
        SET @Errores = @Errores + 'Ya existe un empleado con ese email empresarial. ';

	-- Verificar si la nueva sucursal existe
	IF @SucursalID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE SucursalID = @SucursalID)
		SET @Errores = @Errores + 'La nueva sucursal elegida no existe. ';

	-- Verificar si el nuevo cargo existe
	IF @CargoID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE CargoID = @CargoID)
		SET @Errores = @Errores + 'El nuevo cargo elegido no existe. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Sucursal.Empleado
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        Apellido = COALESCE(@Apellido, Apellido),
        Dni = COALESCE(@Dni, Dni),
        Direccion = COALESCE(@Direccion, Direccion),
        Email = COALESCE(@Email, Email),
        EmailEmpresarial = COALESCE(@EmailEmpresarial, EmailEmpresarial),
        Cuil = COALESCE(@Cuil, Cuil),
        Turno = COALESCE(@Turno, Turno),
        SucursalID = COALESCE(@SucursalID, SucursalID),
        CargoID = COALESCE(@CargoID, CargoID)
    WHERE EmpleadoID = @EmpleadoID;
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.BorrarEmpleado
    @EmpleadoID INT
AS
BEGIN
    -- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Empleado WHERE EmpleadoID = @EmpleadoID)
    BEGIN
        RAISERROR('Empleado no encontrado.',16,1);
		RETURN
    END

    -- Actualizar el estado de la sucursal a 1 (eliminada o inactiva)
    UPDATE Sucursal.Empleado
    SET Estado = 1
    WHERE EmpleadoID = @EmpleadoID;
END;
GO

-- SP's de MedioDePago
CREATE OR ALTER PROCEDURE Venta.InsertarMedioDePago
    @Descripcion VARCHAR(50) = NULL,
    @Identificador VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @Descripcion IS NULL
        SET @Errores = @Errores + 'El parámetro Descripcion no puede ser NULL. ';
    
    IF @Identificador IS NULL
        SET @Errores = @Errores + 'El parámetro Identificador no puede ser NULL. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Venta.MedioDePago (Descripcion, Identificador)
    VALUES (@Descripcion, @Identificador);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarMedioDePago
    @MedioDePagoID INT,
    @Descripcion VARCHAR(50) = NULL,
    @Identificador VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el MedioDePago existe
    IF NOT EXISTS (SELECT 1 FROM Venta.MedioDePago WHERE MedioDePagoID = @MedioDePagoID)
        SET @Errores = @Errores + 'Medio de pago no encontrado. ';

    -- Verificar si la nueva Descripción ya existe
    IF @Descripcion IS NOT NULL AND EXISTS (SELECT 1 FROM Venta.MedioDePago WHERE Descripcion = @Descripcion AND MedioDePagoID <> @MedioDePagoID)
        SET @Errores = @Errores + 'Ya existe un medio de pago con esa descripción. ';

    -- Verificar si el nuevo Identificador ya existe
    IF @Identificador IS NOT NULL AND EXISTS (SELECT 1 FROM Venta.MedioDePago WHERE Identificador = @Identificador AND MedioDePagoID <> @MedioDePagoID)
        SET @Errores = @Errores + 'Ya existe un medio de pago con ese identificador. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Venta.MedioDePago
    SET 
        Descripcion = COALESCE(@Descripcion, Descripcion),
        Identificador = COALESCE(@Identificador, Identificador)
    WHERE MedioDePagoID = @MedioDePagoID;
END;
GO

CREATE OR ALTER PROCEDURE Venta.BorrarMedioDePago
    @MedioDePagoID INT
AS
BEGIN
    -- Verificar si el medio de pago existe
    IF NOT EXISTS (SELECT 1 FROM Venta.MedioDePago WHERE MedioDePagoID = @MedioDePagoID)
    BEGIN
        RAISERROR('Medio de pago no encontrado.', 16, 1);
        RETURN;
    END

    -- Eliminar el medio de pago
    DELETE FROM Venta.MedioDePago
    WHERE MedioDePagoID = @MedioDePagoID;
END;
GO

-- SP's de Factura
CREATE OR ALTER PROCEDURE Venta.InsertarFactura
    @FacturaID CHAR(11) = NULL,
    @TipoDeFactura CHAR(1) = NULL,
    @TipoDeCliente VARCHAR(20) = NULL,
    @Genero CHAR(1) = NULL,
    @Fecha DATE = NULL,
    @Hora TIME(0) = NULL,
    @SucursalID INT = NULL,
    @MedioDePagoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @FacturaID IS NULL
        SET @Errores = @Errores + 'El parámetro FacturaID no puede ser NULL. ';
    
    IF @TipoDeFactura IS NULL
        SET @Errores = @Errores + 'El parámetro TipoDeFactura no puede ser NULL. ';
    
    IF @TipoDeCliente IS NULL
        SET @Errores = @Errores + 'El parámetro TipoDeCliente no puede ser NULL. ';
    
    IF @Genero IS NULL
        SET @Errores = @Errores + 'El parámetro Genero no puede ser NULL. ';
    
    IF @Fecha IS NULL
        SET @Errores = @Errores + 'El parámetro Fecha no puede ser NULL. ';
    
    IF @Hora IS NULL
        SET @Errores = @Errores + 'El parámetro Hora no puede ser NULL. ';
    
    IF @SucursalID IS NULL
        SET @Errores = @Errores + 'El parámetro SucursalID no puede ser NULL. ';
    
    IF @MedioDePagoID IS NULL
        SET @Errores = @Errores + 'El parámetro MedioDePagoID no puede ser NULL. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Venta.Factura (FacturaID, TipoDeFactura, TipoDeCliente, Genero, Fecha, Hora, SucursalID, MedioDePagoID)
    VALUES (@FacturaID, @TipoDeFactura, @TipoDeCliente, @Genero, @Fecha, @Hora, @SucursalID, @MedioDePagoID);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarFactura
    @FacturaID CHAR(11),
    @TipoDeFactura CHAR(1) = NULL,
    @TipoDeCliente VARCHAR(20) = NULL,
    @Genero CHAR(1) = NULL,
    @Fecha DATE = NULL,
    @Hora TIME(0) = NULL,
    @SucursalID INT = NULL,
    @MedioDePagoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la Factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
        SET @Errores = @Errores + 'Factura no encontrada. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Venta.Factura
    SET 
        TipoDeFactura = COALESCE(@TipoDeFactura, TipoDeFactura),
        TipoDeCliente = COALESCE(@TipoDeCliente, TipoDeCliente),
        Genero = COALESCE(@Genero, Genero),
        Fecha = COALESCE(@Fecha, Fecha),
        Hora = COALESCE(@Hora, Hora),
        SucursalID = COALESCE(@SucursalID, SucursalID),
        MedioDePagoID = COALESCE(@MedioDePagoID, MedioDePagoID)
    WHERE FacturaID = @FacturaID;
END;
GO

CREATE OR ALTER PROCEDURE Venta.BorrarFactura
    @FacturaID CHAR(11)
AS
BEGIN
    -- Verificar si la factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
    BEGIN
        RAISERROR('Factura no encontrada.', 16, 1);
        RETURN;
    END

    -- Verificar si la factura tiene registros dependientes en otras tablas
    IF EXISTS (SELECT 1 FROM Venta.DetalleFactura WHERE FacturaID = @FacturaID)
    BEGIN
        RAISERROR('La factura tiene registros en DetalleFactura. Elimine los detalles primero.', 16, 1);
        RETURN;
    END

    -- Eliminar la factura
    DELETE FROM Venta.Factura
    WHERE FacturaID = @FacturaID;
END;
GO

-- SP's de CategoriaProducto
CREATE OR ALTER PROCEDURE Producto.InsertarCategoriaProducto
    @NombreCat VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el parámetro es NULL
    IF @NombreCat IS NULL
        SET @Errores = @Errores + 'El parámetro NombreCat no puede ser NULL. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Producto.CategoriaProducto (NombreCat)
    VALUES (@NombreCat);
END;
GO

CREATE OR ALTER PROCEDURE Producto.ModificarCategoriaProducto
    @CategoriaID INT,
    @NombreCat VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la Categoria existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
        SET @Errores = @Errores + 'Categoría no encontrada. ';

    -- Verificar si el nuevo NombreCat ya existe
    IF @NombreCat IS NOT NULL AND EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE NombreCat = @NombreCat AND CategoriaID <> @CategoriaID)
        SET @Errores = @Errores + 'Ya existe una categoría con ese nombre. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Producto.CategoriaProducto
    SET 
        NombreCat = COALESCE(@NombreCat, NombreCat)
    WHERE CategoriaID = @CategoriaID;
END;
GO

CREATE OR ALTER PROCEDURE Producto.BorrarCategoriaProducto
    @CategoriaID INT
AS
BEGIN
    -- Verificar si la categoría existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
    BEGIN
        RAISERROR('Categoría de producto no encontrada.', 16, 1);
        RETURN;
    END

    -- Verificar si la categoría tiene productos asociados
    IF EXISTS (SELECT 1 FROM Producto.Producto WHERE CategoriaID = @CategoriaID)
    BEGIN
        RAISERROR('La categoría tiene productos asociados. Debes borrar los productos primero.', 16, 1);
        RETURN;
    END

    -- Borrar la categoría
    DELETE FROM Producto.CategoriaProducto
    WHERE CategoriaID = @CategoriaID;
END;
GO

-- SP's de Producto
CREATE OR ALTER PROCEDURE Producto.InsertarProducto
    @Nombre VARCHAR(100) = NULL,
    @Moneda VARCHAR(5) = NULL,
    @PrecioUnitario DECIMAL(7,2) = NULL,
    @CategoriaID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @Nombre IS NULL
        SET @Errores = @Errores + 'El parámetro Nombre no puede ser NULL. ';
    
    IF @Moneda IS NULL
        SET @Errores = @Errores + 'El parámetro Moneda no puede ser NULL. ';
    
    IF @PrecioUnitario IS NULL
        SET @Errores = @Errores + 'El parámetro PrecioUnitario no puede ser NULL. ';
    
    IF @CategoriaID IS NULL
        SET @Errores = @Errores + 'El parámetro CategoriaID no puede ser NULL. ';
    
    -- Verificar si la categoría existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
        SET @Errores = @Errores + 'La categoría especificada no existe. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Producto.Producto (Nombre, Moneda, PrecioUnitario, CategoriaID)
    VALUES (@Nombre, @Moneda, @PrecioUnitario, @CategoriaID);
END;
GO

CREATE OR ALTER PROCEDURE Producto.ModificarProducto
    @ProductoID INT,
    @Nombre VARCHAR(100) = NULL,
    @Moneda VARCHAR(5) = NULL,
    @PrecioUnitario DECIMAL(7,2) = NULL,
    @CategoriaID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el Producto existe
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE ProductoID = @ProductoID)
        SET @Errores = @Errores + 'Producto no encontrado. ';

    -- Verificar si el nuevo Nombre ya existe en la misma categoría
    IF @Nombre IS NOT NULL AND EXISTS (SELECT 1 FROM Producto.Producto WHERE Nombre = @Nombre AND ProductoID <> @ProductoID AND CategoriaID = COALESCE(@CategoriaID, CategoriaID))
        SET @Errores = @Errores + 'Ya existe un producto con ese nombre en la misma categoría. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Producto.Producto
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        Moneda = COALESCE(@Moneda, Moneda),
        PrecioUnitario = COALESCE(@PrecioUnitario, PrecioUnitario),
        CategoriaID = COALESCE(@CategoriaID, CategoriaID)
    WHERE ProductoID = @ProductoID;
END;
GO

CREATE OR ALTER PROCEDURE Producto.BorrarProducto
    @ProductoID INT
AS
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        RETURN;
    END

    -- Borrar el producto
    DELETE FROM Producto.Producto
    WHERE ProductoID = @ProductoID;
END;
GO

-- SP's de DetalleFactura
CREATE OR ALTER PROCEDURE Venta.InsertarDetalleFactura
    @Cantidad INT = NULL,
    @FacturaID CHAR(11) = NULL,
    @ProductoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los parámetros es NULL
    IF @Cantidad IS NULL
        SET @Errores = @Errores + 'El parámetro Cantidad no puede ser NULL. ';
    
    IF @FacturaID IS NULL
        SET @Errores = @Errores + 'El parámetro FacturaID no puede ser NULL. ';
    
    IF @ProductoID IS NULL
        SET @Errores = @Errores + 'El parámetro ProductoID no puede ser NULL. ';
    
    -- Verificar si la factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
        SET @Errores = @Errores + 'La factura especificada no existe. ';
    
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE ProductoID = @ProductoID)
        SET @Errores = @Errores + 'El producto especificado no existe. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Venta.DetalleFactura (Cantidad, FacturaID, ProductoID)
    VALUES (@Cantidad, @FacturaID, @ProductoID);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarDetalleFactura
    @NumeroDeItem INT,
    @Cantidad INT = NULL,
    @FacturaID CHAR(11) = NULL,
    @ProductoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el DetalleFactura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.DetalleFactura WHERE NumeroDeItem = @NumeroDeItem)
        SET @Errores = @Errores + 'Detalle de factura no encontrado. ';

    -- Verificar si la FacturaID existe
    IF @FacturaID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
        SET @Errores = @Errores + 'Factura no encontrada. ';

    -- Verificar si el ProductoID existe
    IF @ProductoID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Producto.Producto WHERE ProductoID = @ProductoID)
        SET @Errores = @Errores + 'Producto no encontrado. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualización
    UPDATE Venta.DetalleFactura
    SET 
        Cantidad = COALESCE(@Cantidad, Cantidad),
        FacturaID = COALESCE(@FacturaID, FacturaID),
        ProductoID = COALESCE(@ProductoID, ProductoID)
    WHERE NumeroDeItem = @NumeroDeItem;
END;
GO

CREATE OR ALTER PROCEDURE Venta.BorrarDetalleFactura
    @NumeroDeItem INT
AS
BEGIN
    -- Verificar si el detalle de factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.DetalleFactura WHERE NumeroDeItem = @NumeroDeItem)
    BEGIN
        RAISERROR('Detalle de factura no encontrado.', 16, 1);
        RETURN;
    END

    -- Borrar el detalle de factura
    DELETE FROM Venta.DetalleFactura
    WHERE NumeroDeItem = @NumeroDeItem;
END;
GO
