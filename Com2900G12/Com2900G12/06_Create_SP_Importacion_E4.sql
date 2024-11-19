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

/* Entrega 4
Se proveen maestros de XXX.
Ver archivo “Datasets para importar” en Miel.
Se requiere que importe toda la información antes mencionada a la base de datos:
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
• Considere este comportamiento al generar el código. Debe admitir la importación de
novedades periódicamente.
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
realicen tareas por fuera de un SP.
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
estructura requerida.
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
interpretarlo como JSON o CSV). */

use Com2900G12;
GO

CREATE OR ALTER PROCEDURE Sucursal.ImportarSucursal
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempSucursal;

    -- Crear la tabla temporal local
    CREATE TABLE #TempSucursal (
        [Ciudad] VARCHAR(50),
        [Reemplazar por] VARCHAR(50),
        [Direccion] VARCHAR(100),
        [Horario] VARCHAR(100),
        [Telefono] VARCHAR(50)
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempSucursal SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;


    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
    INSERT INTO Sucursal.Sucursal (Ciudad, ReemplazarPor, Direccion, Horario, Telefono)
    SELECT 
        [Ciudad], [Reemplazar por], [Direccion], [Horario], [Telefono]
    FROM 
        #TempSucursal AS Temp
    WHERE 
        NOT EXISTS (
            SELECT 1
            FROM Sucursal.Sucursal AS S
            WHERE 
                S.Direccion = Temp.[Direccion] OR
                S.Telefono = Temp.[Telefono]
        );

	DROP TABLE #TempSucursal
END
GO


CREATE OR ALTER PROCEDURE Sucursal.ImportarCargoEmpleado
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempCargoEmpleado;

    -- Crear la tabla temporal local
    CREATE TABLE #TempCargoEmpleado (
        [Legajo/ID] VARCHAR(50),
        [Nombre] VARCHAR(100),
        [Apellido] VARCHAR(100),
        [DNI] INT,
        [Direccion] VARCHAR(200),
        [email personal] VARCHAR(100),
        [email empresa] VARCHAR(100),
        [CUIL] VARCHAR(50),
        [Cargo] VARCHAR(50),
        [Sucursal] VARCHAR(50),
        [Turno] VARCHAR(50)		
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempCargoEmpleado SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;

	UPDATE #TempCargoEmpleado
	SET [email personal] = REPLACE(REPLACE(([email personal]), CHAR(9), ''), ' ', '')

	UPDATE #TempCargoEmpleado
	SET [email empresa] = REPLACE(REPLACE(([email empresa]), CHAR(9), ''), ' ', '')

    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
    INSERT INTO Sucursal.Cargo (Descripcion)
    SELECT DISTINCT
        ([Cargo])
    FROM 
        #TempCargoEmpleado AS Temp
    WHERE [Cargo] IS NOT NULL AND
        NOT EXISTS (
            SELECT 1
            FROM Sucursal.Cargo AS S
            WHERE S.Descripcion = (Temp.[Cargo])
        );
    
    INSERT INTO Sucursal.Empleado (EmpleadoNum, Nombre, Apellido, Dni, Direccion, Email, EmailEmpresarial, Cuil, SucursalID, CargoID, Turno) 
    SELECT 
		([Legajo/ID]),
        ([Nombre]), 
        ([Apellido]), 
        ([DNI]), 
        ([Direccion]), 
        ([email personal]), 
        ([email empresa]),
		([CUIL]),
        (SELECT SucursalID FROM Sucursal.Sucursal WHERE ReemplazarPor = ([Sucursal])),
        (SELECT CargoID FROM Sucursal.Cargo WHERE Descripcion = ([Cargo])),
        ([Turno])
    FROM 
        #TempCargoEmpleado AS Temp
    WHERE Sucursal IS NOT NULL AND
        NOT EXISTS (
            SELECT 1
            FROM Sucursal.Empleado AS S
            WHERE S.Email = ([email personal]) OR
                  S.EmailEmpresarial = ([email empresa])
        );

    -- Eliminar la tabla temporal
    DROP TABLE #TempCargoEmpleado;
END
GO

CREATE OR ALTER PROCEDURE Venta.ImportarMedioDePago
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempMedioDePago;

    -- Crear la tabla temporal local
    CREATE TABLE #TempMedioDePago (
		Medio VARCHAR (50),
		ING VARCHAR(50),
		ESP VARCHAR (50)
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempMedioDePago SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;

    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
    INSERT INTO Venta.MedioDePago(DescripcionESP, DescripcionING)
    SELECT DISTINCT
        ([ESP]),
		([ING])
    FROM 
        #TempMedioDePago AS Temp
    WHERE [ESP] IS NOT NULL AND
        NOT EXISTS (
            SELECT 1
            FROM Venta.MedioDePago AS S
            WHERE S.DescripcionESP = (Temp.[ESP])
        );

    -- Eliminar la tabla temporal
    DROP TABLE #TempMedioDePago;
END
GO

CREATE OR ALTER PROCEDURE Producto.ImportarCategoriaProducto
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempCategoriaProducto;

    -- Crear la tabla temporal local
    CREATE TABLE #TempCategoriaProducto (
		LineaDeProducto VARCHAR(100),
		Producto VARCHAR(100)
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempCategoriaProducto SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;

    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
    INSERT INTO Producto.CategoriaProducto(NombreCat,LineaDeProducto)
    SELECT DISTINCT
        ([LineaDeProducto]),
		([Producto])
    FROM 
        #TempCategoriaProducto AS Temp
    WHERE
        [LineaDeProducto] IS NOT NULL 
        AND [Producto] IS NOT NULL 
        AND NOT EXISTS (
            SELECT 1
            FROM Producto.CategoriaProducto AS S
            WHERE (S.LineaDeProducto = Temp.[Producto] )
        );

    -- Eliminar la tabla temporal
    DROP TABLE #TempCategoriaProducto;
END
GO


CREATE OR ALTER PROCEDURE Producto.ImportarCatalogo
	    @RutaArchivo VARCHAR(255) -- Ruta del archivo CSV
AS
BEGIN
	DROP TABLE IF EXISTS #TempCatalogo

	CREATE TABLE #TempCatalogo (
		Id VARCHAR (10),
		Categoria VARCHAR (100),
		Nombre VARCHAR (200),
		Precio VARCHAR (10),
		PrecioReferencial VARCHAR (10),
		UnidadDeReferencia VARCHAR (10),
		Fecha VARCHAR (25)
	)

	DECLARE @SQL NVARCHAR (MAX)

    SET @SQL = N'BULK INSERT #TempCatalogo
                FROM ' + QUOTENAME(@RutaArchivo, '''') + N'
                WITH (
					FORMAT = ''CSV'',
                    FIELDTERMINATOR = '','',    -- Delimitador de campo (coma)
                    ROWTERMINATOR = ''\n'',     -- Delimitador de fila (salto de línea)
                    FIRSTROW = 2,               -- Empieza desde la segunda fila (la primera fila contiene los encabezados)
					CODEPAGE = ''65001''
                );'

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @SQL;

	UPDATE #TempCatalogo
    SET Nombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, 'Ã©', 'é'), 'Ã±', 'ñ'), 'Ã³', 'ó'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'Âº', 'º'), 'Ãƒº', 'ú'), 'Ã‘', 'Ñ'), 'Ã', 'Á'), '?' , 'ñ'), 'å˜', 'ñ');

	INSERT INTO Producto.Producto (Nombre, PrecioUnitario, CategoriaID, Fecha)
	SELECT DISTINCT
		([Nombre]),
		([Precio]),
		(SELECT CategoriaID FROM Producto.CategoriaProducto WHERE LineaDeProducto = ([Categoria])),
		([Fecha])
	FROM 
		#TempCatalogo AS Temp
    WHERE [Nombre] IS NOT NULL AND
        NOT EXISTS (
            SELECT 1
            FROM Producto.Producto AS S
            WHERE S.Nombre = (Temp.[Nombre])
        );
		
    -- Eliminar la tabla temporal
    DROP TABLE #TempCatalogo;
END;
GO

CREATE OR ALTER PROCEDURE Producto.ImportarAccesorioElectronico
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempEA;

    -- Crear la tabla temporal local
    CREATE TABLE #TempEA (
		Producto VARCHAR(100),
		Precio VARCHAR(100)
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempEA SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;

	UPDATE #TempEA
	SET Producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producto, 'Ã©', 'é'), 'Ã±', 'ñ'), 'Ã³', 'ó'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'Âº', 'º'), 'Ãƒº', 'ú'), 'Ã‘', 'Ñ'), 'Ã', 'Á'), '?' , 'ñ'), 'å˜', 'ñ')

	IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE NombreCat = 'Electronico')
		INSERT INTO Producto.CategoriaProducto (NombreCat) VALUES ('Electronico')

    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
    INSERT INTO Producto.Producto(Nombre,PrecioUnitario,Moneda,CategoriaID)
    SELECT DISTINCT
        ([Producto]),
		([Precio]),
		'USD',
		(SELECT CategoriaID FROM Producto.CategoriaProducto WHERE NombreCat = 'Electronico')
    FROM 
        #TempEA AS Temp
    WHERE
        [Producto] IS NOT NULL 
        AND [Precio] IS NOT NULL 
        AND NOT EXISTS (
            SELECT 1
            FROM Producto.Producto AS S
            WHERE (S.Nombre = Temp.[Producto] )
        );

    -- Eliminar la tabla temporal
    DROP TABLE #TempEA;
END
GO

CREATE OR ALTER PROCEDURE Producto.ImportarProductosImportados
    @Path VARCHAR(255), 
    @Hoja VARCHAR(255)
AS
BEGIN
    -- Eliminar la tabla temporal local si ya existe
    DROP TABLE IF EXISTS #TempPI;

    -- Crear la tabla temporal local
    CREATE TABLE #TempPI (
		ProductoID VARCHAR(100),
		Producto VARCHAR(100),
		Proveedor VARCHAR(100),
		Categoria VARCHAR(100),
		CantidadPorUnidad VARCHAR(100),
		PrecioUnitario VARCHAR(100)
    );

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'INSERT INTO #TempPI SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    -- Ejecutar la consulta
    EXEC sp_executesql @SQL;
	
	UPDATE #TempPI
	SET Producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producto, 'Ã©', 'é'), 'Ã±', 'ñ'), 'Ã³', 'ó'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'Âº', 'º'), 'Ãƒº', 'ú'), 'Ã‘', 'Ñ'), 'Ã', 'Á'), '?' , 'ñ'), 'å˜', 'ñ')

	IF NOT EXISTS (SELECT 1 FROM Producto.CategoriaProducto WHERE NombreCat = 'Importado')
		INSERT INTO Producto.CategoriaProducto (NombreCat) VALUES ('Importado')
	
    -- Insertar datos en la tabla Sucursal verificando si ya existen duplicados
	
    INSERT INTO Producto.Producto(Nombre,PrecioUnitario,CategoriaID)
    SELECT DISTINCT
        ([Producto]),
		([PrecioUnitario]),
		(SELECT CategoriaID FROM Producto.CategoriaProducto WHERE NombreCat = 'Importado')
    FROM 
        #TempPI AS Temp
    WHERE
        [Producto] IS NOT NULL 
        AND [PrecioUnitario] IS NOT NULL 
        AND NOT EXISTS (
            SELECT 1
            FROM Producto.Producto AS S
            WHERE (S.Nombre = Temp.[Producto] )
        );
		
    -- Eliminar la tabla temporal
    DROP TABLE #TempPI;
END
GO

CREATE OR ALTER PROCEDURE Venta.ImportarVenta
    @RutaArchivo VARCHAR(255) -- Ruta del archivo CSV
AS
BEGIN
    -- Verifica si la tabla temporal ya existe, en caso de que se haya ejecutado previamente.
    DROP TABLE IF EXISTS #TempVenta;
    
    -- Crear la tabla temporal con tipo de datos VARCHAR
    
	CREATE TABLE #TempVenta (
        ID_Factura VARCHAR(50),
        Tipo_de_Factura VARCHAR(5),
        Ciudad VARCHAR(50),
        Tipo_de_Cliente VARCHAR(50),
        Genero VARCHAR(10),
        Producto VARCHAR(100),
        Precio_Unitario DECIMAL(7,2),
        Cantidad INT,
        Fecha VARCHAR(50),
        Hora VARCHAR(50),
        Medio_de_Pago VARCHAR(50),
        Empleado VARCHAR(100),
        Identificador_de_pago VARCHAR(100)
    );

    -- Crear la cadena de SQL dinámica para el BULK INSERT
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = N'BULK INSERT #TempVenta
                FROM ' + QUOTENAME(@RutaArchivo, '''') + N'
                WITH (
					FORMAT = ''CSV'',
                    FIELDTERMINATOR = '';'',    -- Delimitador de campo (coma)
                    ROWTERMINATOR = ''\n'',     -- Delimitador de fila (salto de línea)
                    FIRSTROW = 2,               -- Empieza desde la segunda fila (la primera fila contiene los encabezados)
					CODEPAGE = ''65001''
                );';
    
    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @SQL;

	-- Realizar los reemplazos en el campo Producto
    UPDATE #TempVenta
    SET Producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producto, 'Ã©', 'é'), 'Ã±', 'ñ'), 'Ã³', 'ó'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'Âº', 'º'), 'Ãƒº', 'ú'), 'Ã‘', 'Ñ'), 'Ã', 'Á'), '?' , 'ñ'), 'å˜', 'ñ');

	--SELECT * FROM #TempVenta
	
	INSERT INTO Venta.Cliente (TipoDeCliente, Genero, Nombre)
	SELECT DISTINCT
		([Tipo_de_Cliente]),
        CASE 
            WHEN [Genero] = 'Female' THEN 'F'
            WHEN [Genero] = 'Male' THEN 'M'
            ELSE 'O' -- Si el valor es distinto de 'Female' o 'Male', asigna 'O'
        END,
		'ClienteImportado'
	FROM #TempVenta AS Temp
	WHERE NOT EXISTS (
		SELECT 1
		FROM Venta.Cliente AS C
		WHERE (C.[TipoDeCliente] = [Tipo_de_Cliente] OR C.[Genero] = [Genero]) AND Nombre = 'ClienteImportado'
	)
	
	INSERT INTO Venta.Venta (VentaNum,TipoDeFactura,Fecha,Hora,Identificador,EmpleadoID,MedioDePagoID,ClienteID,Total)
	SELECT
		([ID_Factura]),
		([Tipo_de_Factura]),
		([Fecha]),
		([Hora]),
		([Identificador_de_Pago]),
		(SELECT EmpleadoID FROM Sucursal.Empleado WHERE EmpleadoNum = ([Empleado])),
		(SELECT MedioDePagoID FROM Venta.MedioDePago WHERE DescripcionING = ([Medio_de_Pago])),
		(SELECT ClienteID FROM Venta.Cliente WHERE TipoDeCliente = Temp.Tipo_de_Cliente AND Genero = 
			CASE 
				WHEN Temp.Genero = 'Female' THEN 'F'
				WHEN Temp.Genero = 'Male' THEN 'M'
				ELSE 'O' -- Si el valor es distinto de 'Female' o 'Male', asigna 'O'
			END
			AND Nombre = 'ClienteImportado'
		),
		0
	FROM #TempVenta AS Temp
	WHERE NOT EXISTS (
		SELECT 1
		FROM Venta.Venta AS F
		WHERE Temp.[ID_Factura] = F.VentaNum
	)

	INSERT INTO Venta.DetalleVenta(Cantidad,VentaID,ProductoID,Precio,Subtotal)
	SELECT
		([Cantidad]),
		(SELECT VentaID FROM Venta.Venta WHERE VentaNum = ([ID_Factura])),
		(SELECT TOP 1 ProductoID FROM Producto.Producto WHERE Nombre = ([Producto])),
		([Precio_Unitario]),
		CASE
			WHEN (SELECT TOP 1 Moneda FROM Producto.Producto WHERE Nombre = ([Producto])) = 'USD' THEN
				([Cantidad] * [Precio_Unitario]) * (SELECT Venta FROM TipoDeCambio WHERE Moneda = 'USD')
			ELSE
				([Cantidad] * [Precio_Unitario])
		END
	FROM #TempVenta AS Temp
	WHERE NOT EXISTS (
		SELECT 1
		FROM Venta.DetalleVenta AS DF
		JOIN Venta.Venta F ON DF.VentaID = F.VentaID
		JOIN Producto.Producto P ON DF.ProductoID = P.ProductoID
		WHERE Temp.[ID_Factura] = F.VentaNum AND Temp.[Producto] = P.Nombre
	)

	-- Actualizar el Total en la tabla Venta
	UPDATE V
	SET V.Total = ISNULL((
		SELECT SUM(DV.Subtotal)
		FROM Venta.DetalleVenta DV
		WHERE DV.VentaID = V.VentaID
	), 0)
	FROM Venta.Venta V
	WHERE EXISTS (
		SELECT 1
		FROM Venta.DetalleVenta DV
		WHERE DV.VentaID = V.VentaID
	);

	-- Ahora también puedes actualizar el campo TotalConIva si es necesario
	UPDATE V
	SET V.TotalConIva = V.Total * 1.21 -- Ejemplo con IVA del 21%
	FROM Venta.Venta V
	WHERE V.Total > 0; -- Solo actualiza ventas con un total calculado

	-- Insertar los datos en la tabla Venta.Factura
	INSERT INTO Venta.Factura (TipoDeFactura, Fecha, Total, TotalConIva, VentaID)
	SELECT
		V.[TipoDeFactura],  -- Tipo de factura (A, B, C)
		V.[Fecha],            -- Fecha de la venta
		V.[Total],
		V.[TotalConIva],
		V.VentaID  -- Asociar la venta
	FROM Venta.Venta V
	WHERE NOT EXISTS (
    -- Verificar si ya existe una factura con el mismo VentaNum (ID_Factura)
    SELECT 1
    FROM Venta.Factura F
    WHERE F.VentaID = V.VentaID  -- Usar VentaID para evitar duplicados en Factura
	)

	DROP TABLE #TempVenta
END;
GO
