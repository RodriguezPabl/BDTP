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






