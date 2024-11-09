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
        [DNI] VARCHAR(50),
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
    
    INSERT INTO Sucursal.Empleado (Nombre, Apellido, Dni, Direccion, Email, EmailEmpresarial, Cuil, SucursalID, CargoID, Turno) 
    SELECT 
        ([Nombre]), 
        ([Apellido]), 
        ([DNI]), 
        ([Direccion]), 
        REPLACE([email personal], ' ',''), 
        REPLACE([email empresa], ' ',''), 
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
            WHERE S.Email = REPLACE(Temp.[email personal], ' ','') OR
                  S.EmailEmpresarial = REPLACE(Temp.[email empresa], ' ','')
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

CREATE OR ALTER PROCEDURE Venta.ImportarClienteFactura
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
        Precio_Unitario VARCHAR(50),
        Cantidad VARCHAR(50),
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

	INSERT INTO Venta.Cliente (TipoDeCliente, Genero)
	SELECT DISTINCT
		([Tipo_de_Cliente]),
        CASE 
            WHEN [Genero] = 'Female' THEN 'F'
            WHEN [Genero] = 'Male' THEN 'M'
            ELSE 'O' -- Si el valor es distinto de 'Female' o 'Male', asigna 'O'
        END
	FROM #TempVenta AS Temp
	WHERE NOT EXISTS (
		SELECT 1
		FROM Venta.Cliente AS C
		WHERE C.[TipoDeCliente] = [Tipo_de_Cliente] OR C.[Genero] = [Genero]
	)
	
	INSERT INTO Venta.Factura (FacturaID,TipoDeFactura,Fecha,Hora,Identificador,EmpleadoID,MedioDePagoID,ClienteID)
	SELECT
		([ID_Factura]),
		([Tipo_de_Factura]),
		([Fecha]),
		([Hora]),
		([Identificador_de_Pago]),
		(SELECT EmpleadoID FROM Sucursal.Empleado WHERE EmpleadoID = ([Empleado])),
		(SELECT MedioDePagoID FROM Venta.MedioDePago WHERE DescripcionING = ([Medio_de_Pago])),
		(SELECT ClienteID FROM Venta.Cliente WHERE TipoDeCliente = Temp.Tipo_de_Cliente AND Genero = 
			CASE 
				WHEN Temp.Genero = 'Female' THEN 'F'
				WHEN Temp.Genero = 'Male' THEN 'M'
				ELSE 'O' -- Si el valor es distinto de 'Female' o 'Male', asigna 'O'
			END
		)
	FROM #TempVenta AS Temp
	WHERE NOT EXISTS (
		SELECT 1
		FROM Venta.Factura AS F
		WHERE Temp.[ID_Factura] = F.FacturaID
	)
	
	DROP TABLE #TempVenta
END;
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

    -- Seleccionar los datos para ver los resultados del BULK INSERT
    SELECT * FROM #TempCatalogo;
END;
GO






