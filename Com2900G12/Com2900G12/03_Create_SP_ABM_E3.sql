USE Com2900G12
GO

-- SP's de Sucursal
CREATE OR ALTER PROCEDURE Sucursal.InsertarSucursal
    @Ciudad VARCHAR(100) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Telefono CHAR(9) = NULL,
    @Horario VARCHAR(50) = NULL,
	@ReemplazarPor VARCHAR(100) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los par�metros es NULL
    IF @Ciudad IS NULL
        SET @Errores = @Errores + 'El par�metro Ciudad no puede ser NULL. ';
    
    IF @Direccion IS NULL
        SET @Errores = @Errores + 'El par�metro Direccion no puede ser NULL. ';
    
    IF @Telefono IS NULL
        SET @Errores = @Errores + 'El par�metro Telefono no puede ser NULL. ';
    
    IF @Horario IS NULL
        SET @Errores = @Errores + 'El par�metro Horario no puede ser NULL. ';

    -- Verificar si ya existe una sucursal con la misma Direcci�n o Tel�fono (violaci�n de restricciones UNIQUE)
    IF EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Direccion = @Direccion)
    BEGIN
        SET @Errores = @Errores + 'Ya existe una sucursal con la misma Direcci�n. ';
    END

    IF EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Telefono = @Telefono)
    BEGIN
        SET @Errores = @Errores + 'Ya existe una sucursal con el mismo Tel�fono. ';
    END

	IF @Errores <> ''
	BEGIN
		RAISERROR(@Errores,16,1)
		RETURN
	END

    INSERT INTO Sucursal.Sucursal (Ciudad, Direccion, Telefono, Horario, ReemplazarPor)
    VALUES (@Ciudad, @Direccion, @Telefono, @Horario, @ReemplazarPor);
END;
GO

CREATE OR ALTER PROCEDURE Sucursal.ModificarSucursal
    @SucursalID INT = NULL,
    @Ciudad VARCHAR(100) = NULL,
    @Direccion VARCHAR(150) = NULL,
    @Telefono CHAR(9) = NULL,
	@Horario VARCHAR(50) = NULL,
	@ReemplazarPor VARCHAR(100) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la sucursal existe
    IF NOT EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE SucursalID = @SucursalID)
        SET @Errores = @Errores + 'Sucursal no encontrada. ';

    -- Verificar si la nueva Direcci�n ya existe (si se pasa una nueva direcci�n)
    IF @Direccion IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Direccion = @Direccion AND SucursalID <> @SucursalID)
        SET @Errores = @Errores + 'Ya existe una sucursal con esa direcci�n. ';

    -- Verificar si el nuevo Tel�fono ya existe (si se pasa un nuevo tel�fono)
    IF @Telefono IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Sucursal WHERE Telefono = @Telefono AND SucursalID <> @SucursalID)
        SET @Errores = @Errores + 'Ya existe una sucursal con ese tel�fono. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
    UPDATE Sucursal.Sucursal
    SET 
        Ciudad = COALESCE(@Ciudad, Ciudad),
        Direccion = COALESCE(@Direccion, Direccion),
        Telefono = COALESCE(@Telefono, Telefono),
		Horario = COALESCE(@Horario, Horario),
		ReemplazarPor = COALESCE(@ReemplazarPor, ReemplazarPor)
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
    SET FechaBorrado = GETDATE()
    WHERE SucursalID = @SucursalID;
END;
GO


-- SP's de Cargo
CREATE OR ALTER PROCEDURE Sucursal.InsertarCargo
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el par�metro es NULL
    IF @Descripcion IS NULL
        SET @Errores = @Errores + 'El par�metro Descripcion no puede ser NULL. ';

	-- Verificar si ya hay un cargo con esa descripcion existe
    IF @Descripcion IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE Descripcion = @Descripcion)
        SET @Errores = @Errores + 'Cargo ya existente. ';

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

    -- Verificar si la nueva Descripci�n ya existe
    IF @Descripcion IS NOT NULL AND EXISTS (SELECT 1 FROM Sucursal.Cargo WHERE Descripcion = @Descripcion AND CargoID <> @CargoID)
        SET @Errores = @Errores + 'Ya existe un cargo con esa descripci�n. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
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
    UPDATE Sucursal.Cargo
	SET FechaBorrado = GETDATE()
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
    @Turno VARCHAR(16) = NULL,
    @SucursalID INT = NULL,
    @CargoID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los par�metros es NULL
    IF @Nombre IS NULL
        SET @Errores = @Errores + 'El par�metro Nombre no puede ser NULL. ';
    
    IF @Apellido IS NULL
        SET @Errores = @Errores + 'El par�metro Apellido no puede ser NULL. ';
    
    IF @Dni IS NULL
        SET @Errores = @Errores + 'El par�metro Dni no puede ser NULL. ';
    
    IF @Direccion IS NULL
        SET @Errores = @Errores + 'El par�metro Direccion no puede ser NULL. ';
    
    IF @Email IS NULL
        SET @Errores = @Errores + 'El par�metro Email no puede ser NULL. ';
    
    IF @EmailEmpresarial IS NULL
        SET @Errores = @Errores + 'El par�metro EmailEmpresarial no puede ser NULL. ';
    
    IF @Cuil IS NULL
        SET @Errores = @Errores + 'El par�metro Cuil no puede ser NULL. ';
    
    IF @Turno IS NULL
        SET @Errores = @Errores + 'El par�metro Turno no puede ser NULL. ';
    
    IF @SucursalID IS NULL
        SET @Errores = @Errores + 'El par�metro SucursalID no puede ser NULL. ';
    
    IF @CargoID IS NULL
        SET @Errores = @Errores + 'El par�metro CargoID no puede ser NULL. ';
    
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
    INSERT INTO Sucursal.Empleado (Nombre, Apellido, Dni, Direccion, Email, EmailEmpresarial, Cuil, Turno, SucursalID, CargoID)
    VALUES (@Nombre, @Apellido, @Dni, @Direccion, @Email, @EmailEmpresarial, @Cuil, @Turno, @SucursalID, @CargoID);
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

    -- Realizar la actualizaci�n
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
    SET FechaBorrado = GETDATE()
    WHERE EmpleadoID = @EmpleadoID;
END;
GO

-- SP's de MedioDePago
CREATE OR ALTER PROCEDURE Venta.InsertarMedioDePago
    @DescripcionESP VARCHAR(50) = NULL,
    @DescripcionING VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los par�metros es NULL
    IF @DescripcionESP IS NULL
        SET @Errores = @Errores + 'El par�metro DescripcionESP no puede ser NULL. ';
    
    IF @DescripcionING IS NULL
        SET @Errores = @Errores + 'El par�metro DescripcionING no puede ser NULL. ';

    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Venta.MedioDePago (DescripcionESP, DescripcionING)
    VALUES (@DescripcionESP, @DescripcionING);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarMedioDePago
    @MedioDePagoID INT,
    @DescripcionESP VARCHAR(50) = NULL,
    @DescripcionING VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el MedioDePago existe
    IF NOT EXISTS (SELECT 1 FROM Venta.MedioDePago WHERE MedioDePagoID = @MedioDePagoID)
    BEGIN
        RAISERROR('Medio de pago no encontrado. ', 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
    UPDATE Venta.MedioDePago
    SET 
        DescripcionESP = COALESCE(@DescripcionESP, DescripcionESP),
        DescripcionING = COALESCE(@DescripcionING, DescripcionING)
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
    UPDATE Venta.MedioDePago
	SET FechaBorrado = GETDATE()
    WHERE MedioDePagoID = @MedioDePagoID;
END;
GO

-- SP's de Cliente
CREATE OR ALTER PROCEDURE Venta.InsetarCliente
	@TipoDeCliente VARCHAR(20),
	@Genero CHAR(1),
	@Nombre VARCHAR(50) = NULL,
	@Apellido VARCHAR (50) = NULL,
	@DNI CHAR(8) = NULL
AS
BEGIN
	DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores
	--Verrificar si algun parametro es NULL
	IF @TipoDeCliente IS NULL
        SET @Errores = @Errores + 'El par�metro TipoDeCliente no puede ser NULL. ';
    
    IF @Genero IS NULL
        SET @Errores = @Errores + 'El par�metro Genero no puede ser NULL. ';

	-- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

	-- Insertar los datos en la tabla
    INSERT INTO Venta.Cliente (TipoDeCliente,Genero,Nombre,Apellido,DNI)
    VALUES (@TipoDeCliente,@Genero,@Nombre,@Apellido,@DNI);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarCliente
	@ClienteID INT = NULL,
	@TipoDeCliente VARCHAR(20) = NULL,
	@Genero CHAR(1) = NULL,
	@Nombre VARCHAR(50) = NULL,
	@Apellido VARCHAR (50) = NULL,
	@DNI CHAR(8) = NULL
AS
BEGIN
	DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la Factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Cliente WHERE ClienteID = @ClienteID)
        SET @Errores = @Errores + 'Cliente no encontrado. ';

	-- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

	--Realizar la actualizacion
	UPDATE Venta.CLiente
	SET
		TipoDeCliente = COALESCE(@TipoDeCliente,TipoDeCliente),
		Genero = COALESCE(@Genero,Genero),
		Nombre = COALESCE(@Nombre,Nombre),
		Apellido = COALESCE(@Apellido,Apellido),
		DNI = COALESCE(@DNI,DNI)
	WHERE ClienteID = @ClienteID
END
GO

CREATE OR ALTER PROCEDURE Venta.BorrarCliente
	@ClienteID INT
AS
BEGIN
    -- Verificar si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Cliente WHERE ClienteID = @ClienteID)
    BEGIN
        RAISERROR('Cliente no encontrado.', 16, 1);
        RETURN;
    END

	--Realizar la actualizacion
	UPDATE Venta.CLiente
	SET FechaBorrado = GETDATE()
	WHERE ClienteID = @ClienteID
END
GO
	
-- SP's de Factura
CREATE OR ALTER PROCEDURE Venta.InsertarFactura
    @FacturaID INT = NULL,
    @TipoDeFactura CHAR(1) = NULL,
	@Identificador VARCHAR(50) = NULL,
    @EmpleadoID INT = NULL,
    @MedioDePagoID INT = NULL,
	@ClienteID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los par�metros es NULL
    IF @FacturaID IS NULL
        SET @Errores = @Errores + 'El par�metro FacturaID no puede ser NULL. ';
    
    IF @TipoDeFactura IS NULL
        SET @Errores = @Errores + 'El par�metro TipoDeFactura no puede ser NULL. ';

	IF @Identificador IS NULL
        SET @Errores = @Errores + 'El par�metro identificador no puede ser NULL. ';
    
    IF @EmpleadoID IS NULL
        SET @Errores = @Errores + 'El par�metro EmpleadoID no puede ser NULL. ';
    
    IF @MedioDePagoID IS NULL
        SET @Errores = @Errores + 'El par�metro MedioDePagoID no puede ser NULL. ';

    IF @ClienteID IS NULL
        SET @Errores = @Errores + 'El par�metro ClienteID no puede ser NULL. ';
    
    -- Si hay errores, usar RAISEERROR para devolverlos
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Venta.Factura (FacturaID, TipoDeFactura,Identificador, EmpleadoID, MedioDePagoID, ClienteID)
    VALUES (@FacturaID, @TipoDeFactura, @Identificador, @EmpleadoID, @MedioDePagoID, @ClienteID);
END;
GO

CREATE OR ALTER PROCEDURE Venta.ModificarFactura
    @FacturaNum INT,
    @TipoDeFactura CHAR(1) = NULL,
	@Identificador VARCHAR(50) = NULL,
    @EmpleadoID INT = NULL,
    @MedioDePagoID INT = NULL,
	@ClienteID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la Factura existe
    IF NOT EXISTS (SELECT 1 FROM Venta.Factura WHERE FacturaNum = @FacturaNum)
    BEGIN
        RAISERROR('Factura no encontrada.', 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
    UPDATE Venta.Factura
    SET 
        TipoDeFactura = COALESCE(@TipoDeFactura, TipoDeFactura),
		Identificador = COALESCE(@Identificador, Identificador),
        EmpleadoID = COALESCE(@EmpleadoID, EmpleadoID),
        MedioDePagoID = COALESCE(@MedioDePagoID, MedioDePagoID),
		ClienteID = COALESCE(@ClienteID, ClienteID)
    WHERE FacturaNum = @FacturaNum;
END;
GO

-- SP's de CategoriaProducto
CREATE OR ALTER PROCEDURE Producto.InsertarCategoriaProducto
    @NombreCat VARCHAR(50) = NULL,
	@LineaDeProducto VARCHAR(100) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si el par�metro es NULL
    IF @NombreCat IS NULL
    BEGIN
        RAISERROR('El par�metro NombreCat no puede ser NULL. ', 16, 1);
        RETURN;
    END

    -- Insertar los datos en la tabla
    INSERT INTO Producto.CategoriaProducto (NombreCat,LineaDeProducto)
    VALUES (@NombreCat,@LineaDeProducto);
END;
GO

CREATE OR ALTER PROCEDURE Producto.ModificarCategoriaProducto
    @CategoriaID INT,
    @NombreCat VARCHAR(50) = NULL,
	@LineaDeProducto VARCHAR(100) = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si la Categoria existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
        SET @Errores = @Errores + 'Categor�a no encontrada. ';

    -- Verificar si el nuevo NombreCat ya existe
    IF @NombreCat IS NOT NULL AND EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE NombreCat = @NombreCat AND CategoriaID <> @CategoriaID)
        SET @Errores = @Errores + 'Ya existe una categor�a con ese nombre. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
    UPDATE Producto.CategoriaProducto
    SET 
        NombreCat = COALESCE(@NombreCat, NombreCat),
		LineaDeProducto = COALESCE(@LineaDeProducto, LineaDeProducto)
    WHERE CategoriaID = @CategoriaID;
END;
GO

CREATE OR ALTER PROCEDURE Producto.BorrarCategoriaProducto
    @CategoriaID INT
AS
BEGIN
    -- Verificar si la categor�a existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
    BEGIN
        RAISERROR('Categor�a de producto no encontrada.', 16, 1);
        RETURN;
    END

    -- Borrar la categor�a
    UPDATE Producto.CategoriaProducto
	SET FechaBorrado = GETDATE()
    WHERE CategoriaID = @CategoriaID;
END;
GO

-- SP's de Producto
CREATE OR ALTER PROCEDURE Producto.InsertarProducto
    @Nombre VARCHAR(100) = NULL,
    @Moneda VARCHAR(5),
    @PrecioUnitario DECIMAL(7,2) = NULL,
    @CategoriaID INT = NULL
AS
BEGIN
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores

    -- Verificar si alguno de los par�metros es NULL
    IF @Nombre IS NULL
        SET @Errores = @Errores + 'El par�metro Nombre no puede ser NULL. ';
    
    IF @PrecioUnitario IS NULL
        SET @Errores = @Errores + 'El par�metro PrecioUnitario no puede ser NULL. ';
    
    IF @CategoriaID IS NULL
        SET @Errores = @Errores + 'El par�metro CategoriaID no puede ser NULL. ';
    
    -- Verificar si la categor�a existe
    IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE CategoriaID = @CategoriaID)
        SET @Errores = @Errores + 'La categor�a especificada no existe. ';
    
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

    -- Verificar si el nuevo Nombre ya existe en la misma categor�a
    IF @Nombre IS NOT NULL AND EXISTS (SELECT 1 FROM Producto.Producto WHERE Nombre = @Nombre AND ProductoID <> @ProductoID AND CategoriaID = COALESCE(@CategoriaID, CategoriaID))
        SET @Errores = @Errores + 'Ya existe un producto con ese nombre en la misma categor�a. ';

    -- Si hay errores, lanzar un error con la cadena concatenada
    IF @Errores <> ''
    BEGIN
        RAISERROR(@Errores, 16, 1);  -- Lanzamos los errores concatenados
        RETURN;
    END

    -- Realizar la actualizaci�n
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
    UPDATE Producto.Producto
	SET FechaBorrado = GETDATE()
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

    -- Verificar si alguno de los par�metros es NULL
    IF @Cantidad IS NULL
        SET @Errores = @Errores + 'El par�metro Cantidad no puede ser NULL. ';
    
    IF @FacturaID IS NULL
        SET @Errores = @Errores + 'El par�metro FacturaID no puede ser NULL. ';
    
    IF @ProductoID IS NULL
        SET @Errores = @Errores + 'El par�metro ProductoID no puede ser NULL. ';
    
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

    -- Realizar la actualizaci�n
    UPDATE Venta.DetalleFactura
    SET 
        Cantidad = COALESCE(@Cantidad, Cantidad),
        FacturaID = COALESCE(@FacturaID, FacturaID),
        ProductoID = COALESCE(@ProductoID, ProductoID)
    WHERE NumeroDeItem = @NumeroDeItem;
END;
GO
