CREATE OR ALTER PROCEDURE Producto.ImportarDesdeExcel
    @Path NVARCHAR(100), 
    @Hoja NVARCHAR(100)
AS
BEGIN
    -- Eliminar la tabla temporal global si ya existe
    IF OBJECT_ID('tempdb..##TEMP') IS NOT NULL
        DROP TABLE ##TEMP;

    -- Construir y ejecutar la consulta para importar los datos
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 
        'SELECT * INTO ##TEMP FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ' +
        '''Excel 12.0;Database=' + @Path + ';HDR=YES;IMEX=1'', ' +
        '''SELECT * FROM [' + @Hoja + '$]'')';

    EXEC sp_executesql @SQL;
END
GO

-- Llamar al procedimiento para importar datos, PRIMER PARAMETRO ES RUTA Y EL SEGUNDO ES LA HOJA 
EXEC Producto.ImportarDesdeExcel 'C:\Users\aguil\Documents\GitHub\BDTP\TP_integrador_Archivos\Informacion_complementaria.xlsx', 'Empleados';

GO
-- Consultar el contenido de la tabla temporal después de ejecutar el procedimiento
SELECT * FROM ##TEMP;


-- Verificar si hay registros duplicados en la tabla temporal ##TEMP

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
                    FIELDTERMINATOR = '';'',    -- Delimitador de campo (coma)
                    ROWTERMINATOR = ''\n'',     -- Delimitador de fila (salto de línea)
                    FIRSTROW = 2               -- Empieza desde la segunda fila (la primera fila contiene los encabezados)
                );';
    
    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @SQL;

    -- Seleccionar los datos para ver los resultados del BULK INSERT
    SELECT * FROM #TempVenta;
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
                    FIRSTROW = 2               -- Empieza desde la segunda fila (la primera fila contiene los encabezados)
                );'

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @SQL;

    -- Seleccionar los datos para ver los resultados del BULK INSERT
    SELECT * FROM #TempCatalogo;
END;
GO






