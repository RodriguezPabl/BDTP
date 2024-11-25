USE Com2900G12
GO

CREATE OR ALTER PROCEDURE Venta.ReporteDeVentas
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Facturas AS (
        SELECT
            v.VentaID AS ID_Factura,
            v.TipoDeFactura,
            CASE 
				WHEN s.ReemplazarPor IS NOT NULL THEN s.ReemplazarPor
				ELSE s.Ciudad
			END AS Ciudad,
            c.TipoDeCliente,
            c.Genero,
            p.NombreCat AS LineaDeProducto,
            pr.Nombre AS Producto,
            pr.PrecioUnitario,
			pr.Moneda,
            dv.Cantidad,
            v.Fecha,
            v.Hora,
            mp.DescripcionESP AS MedioDePago,
            e.EmpleadoID,
            s.SucursalID AS Sucursal,
			v.Total,
			v.TotalConIva
        FROM
            Venta.Venta v
            INNER JOIN Venta.Cliente c ON v.ClienteID = c.ClienteID
            INNER JOIN Venta.DetalleVenta dv ON v.VentaID = dv.VentaID
            INNER JOIN Producto.Producto pr ON dv.ProductoID = pr.ProductoID
            INNER JOIN Producto.CategoriaProducto p ON pr.CategoriaID = p.CategoriaID
            INNER JOIN Venta.MedioDePago mp ON v.MedioDePagoID = mp.MedioDePagoID
            INNER JOIN Sucursal.Empleado e ON v.EmpleadoID = e.EmpleadoID
            INNER JOIN Sucursal.Sucursal s ON s.SucursalID = e.SucursalID
    )

    SELECT 
        DATENAME(WEEKDAY, f.Fecha) AS DiaSemana,
        f.ID_Factura,
        f.TipoDeFactura,
        f.Ciudad,
        f.TipoDeCliente,
        f.Genero,
        f.LineaDeProducto,
        f.Producto,
        f.PrecioUnitario,
		f.Moneda,
        f.Cantidad,
        f.Fecha,
        f.Hora,
        f.MedioDePago,
        f.EmpleadoID,
        f.Sucursal,
		f.Total,
		f.TotalConIva
    INTO #Reporte
    FROM
        Facturas f

    -- Convertimos a formato XML
    SELECT * 
    FROM #Reporte
    FOR XML PATH('Factura'), ROOT('ReporteFacturaMensual'), TYPE
    
    -- Limpiamos la tabla temporal
    DROP TABLE #Reporte;
END;
GO

CREATE OR ALTER PROCEDURE Venta.ReporteMensualPorDiaXML
    @Mes INT,           -- Mes de la factura (1-12)
    @Anio INT           -- Año de la factura (por ejemplo 2024)
AS
BEGIN
	SELECT 
		DATENAME(WEEKDAY, f.Fecha) AS DiaSemana,
		SUM(f.Total) AS TotalFacturado
	FROM Venta.Factura f
	WHERE MONTH(f.Fecha) = @Mes AND YEAR(f.Fecha) = @Anio
    GROUP BY DATENAME(WEEKDAY, f.Fecha), DATEPART(WEEKDAY, f.Fecha)
    ORDER BY DATEPART(WEEKDAY, f.Fecha)
	FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteTrimestralPorMesXML
	@Anio INT
AS
BEGIN
	SELECT
		DATENAME(month, f.Fecha) AS Mes,
		e.Turno,
		SUM(f.Total) AS TotalFacturado
	FROM Venta.Factura f 
	INNER JOIN Venta.Venta v ON v.VentaID = f.VentaID
	INNER JOIN Sucursal.Empleado e ON e.EmpleadoID = v.EmpleadoID
	WHERE YEAR(f.Fecha) = @Anio
	GROUP BY DATENAME(month, f.Fecha),MONTH(f.Fecha), e.Turno
	ORDER BY MONTH(f.Fecha)
	FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteProductosVendidos
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN
	SELECT 
        p.Nombre AS Producto,         -- Nombre del producto (se asume que hay una columna Nombre en la tabla Producto)
        SUM(dv.Cantidad) AS CantidadVendida
    FROM Venta.DetalleVenta dv
    INNER JOIN Venta.Venta v ON dv.VentaID = v.VentaID
    INNER JOIN Producto.Producto p ON dv.ProductoID = p.ProductoID
    WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin  -- Filtra por el rango de fechas
    GROUP BY p.Nombre
    ORDER BY CantidadVendida DESC   -- Ordena de mayor a menor cantidad
	FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteProductosVendidosPorSucursal
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN
	SELECT 
        p.Nombre AS Producto,         -- Nombre del producto (se asume que hay una columna Nombre en la tabla Producto)
		CASE 
			WHEN s.ReemplazarPor IS NOT NULL THEN s.ReemplazarPor
			ELSE s.Ciudad
		END AS Sucursal,
        SUM(dv.Cantidad) AS CantidadVendida
    FROM Venta.DetalleVenta dv
    INNER JOIN Venta.Venta v ON dv.VentaID = v.VentaID
    INNER JOIN Producto.Producto p ON dv.ProductoID = p.ProductoID
	INNER JOIN Sucursal.Empleado e ON e.EmpleadoID = v.EmpleadoID
	INNER JOIN Sucursal.Sucursal s ON s.SucursalID = e.SucursalID
    WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin  -- Filtra por el rango de fechas
    GROUP BY 	
		CASE 
			WHEN s.ReemplazarPor IS NOT NULL THEN s.ReemplazarPor
			ELSE s.Ciudad
		END,
		p.Nombre
    ORDER BY 
		CASE 
			WHEN s.ReemplazarPor IS NOT NULL THEN s.ReemplazarPor
			ELSE s.Ciudad
		END,
		CantidadVendida DESC   -- Ordena de mayor a menor cantidad
	FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteProductosMasVendidosPorSemana
    @Año INT,  -- Año especificado
    @Mes INT   -- Mes especificado
AS
BEGIN
    -- Construir la fecha de inicio y fin del mes
    DECLARE @FechaInicio DATE = DATEFROMPARTS(@Año, @Mes, 1); -- Primer día del mes
    DECLARE @FechaFin DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FechaInicio)); -- Último día del mes

    ;WITH ProductosPorSemana AS (
        SELECT 
            p.Nombre AS Producto,                           -- Nombre del producto
            DATEPART(WK, v.Fecha) AS SemanaDelAño,         -- Semana del año
            SUM(dv.Cantidad) AS CantidadVendida            -- Cantidad total vendida
        FROM Venta.DetalleVenta dv
        INNER JOIN Venta.Venta v ON dv.VentaID = v.VentaID
        INNER JOIN Producto.Producto p ON dv.ProductoID = p.ProductoID
        WHERE 
            YEAR(v.Fecha) = @Año                            -- Filtra por el año
            AND MONTH(v.Fecha) = @Mes                       -- Filtra por el mes
        GROUP BY p.Nombre, DATEPART(WK, v.Fecha)            -- Agrupa por producto y semana del año
    )
    -- Seleccionamos los 5 productos más vendidos de cada semana dentro del mes
    SELECT 
        SemanaDelAño,               -- Semana del año
        Producto,                   -- Nombre del producto
        CantidadVendida             -- Cantidad vendida
    FROM (
        SELECT 
            SemanaDelAño,
            Producto,
            CantidadVendida,
            ROW_NUMBER() OVER (PARTITION BY SemanaDelAño ORDER BY CantidadVendida DESC) AS RowNum  -- Genera un número de fila por semana
        FROM 
            ProductosPorSemana
        WHERE SemanaDelAño BETWEEN DATEPART(WK, @FechaInicio) AND DATEPART(WK, @FechaFin)  -- Filtra las semanas dentro del rango de fechas del mes
    ) AS ProductosPorSemanaOrdenados
    WHERE RowNum <= 5  -- Limita a los 5 productos más vendidos de cada semana
    ORDER BY 
        SemanaDelAño,            -- Primero ordenamos por semana del año
        RowNum                  -- Luego ordenamos por la cantidad vendida (de mayor a menor)
    FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE  -- Devuelve el resultado en formato XML
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteProductosMenosVendidosPorSemana
    @Año INT,  -- Año especificado
    @Mes INT   -- Mes especificado
AS
BEGIN
    -- Construir la fecha de inicio y fin del mes
    DECLARE @FechaInicio DATE = DATEFROMPARTS(@Año, @Mes, 1); -- Primer día del mes
    DECLARE @FechaFin DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FechaInicio)); -- Último día del mes

    ;WITH ProductosPorSemana AS (
        SELECT 
            p.Nombre AS Producto,                           -- Nombre del producto
            DATEPART(WK, v.Fecha) AS SemanaDelAño,         -- Semana del año
            SUM(dv.Cantidad) AS CantidadVendida            -- Cantidad total vendida
        FROM Venta.DetalleVenta dv
        INNER JOIN Venta.Venta v ON dv.VentaID = v.VentaID
        INNER JOIN Producto.Producto p ON dv.ProductoID = p.ProductoID
        WHERE 
            YEAR(v.Fecha) = @Año                            -- Filtra por el año
            AND MONTH(v.Fecha) = @Mes                       -- Filtra por el mes
        GROUP BY p.Nombre, DATEPART(WK, v.Fecha)            -- Agrupa por producto y semana del año
    )
    -- Seleccionamos los 5 productos menos vendidos de cada semana dentro del mes
    SELECT 
        SemanaDelAño,               -- Semana del año
        Producto,                   -- Nombre del producto
        CantidadVendida             -- Cantidad vendida
    FROM (
        SELECT 
            SemanaDelAño,
            Producto,
            CantidadVendida,
            ROW_NUMBER() OVER (PARTITION BY SemanaDelAño ORDER BY CantidadVendida ASC) AS RowNum  -- Ordenamos de menor a mayor cantidad vendida
        FROM 
            ProductosPorSemana
        WHERE SemanaDelAño BETWEEN DATEPART(WK, @FechaInicio) AND DATEPART(WK, @FechaFin)  -- Filtra las semanas dentro del rango de fechas del mes
    ) AS ProductosPorSemanaOrdenados
    WHERE RowNum <= 5  -- Limita a los 5 productos menos vendidos de cada semana
    ORDER BY 
        SemanaDelAño,            -- Primero ordenamos por semana del año
        RowNum                  -- Luego ordenamos por la cantidad vendida (de menor a mayor)
    FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE  -- Devuelve el resultado en formato XML
END
GO

CREATE OR ALTER PROCEDURE Venta.ReporteVentasAcumuladasPorSucursal
    @Fecha DATE,              -- Fecha específica para el reporte
    @SucursalID INT           -- ID de la sucursal para filtrar
AS
BEGIN
    SELECT 
        v.VentaID,                             -- ID de la venta
        v.Fecha AS FechaVenta,                 -- Fecha de la venta
        dv.Subtotal,                         -- Monto de la venta
		CASE 
			WHEN s.ReemplazarPor IS NOT NULL THEN s.ReemplazarPor
			ELSE s.Ciudad
		END AS Sucursal,                  -- Sucursal (considerando ciudad o reemplazo si aplica)
        SUM(dv.Subtotal) OVER (
            PARTITION BY s.SucursalID
            ORDER BY v.Fecha
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS TotalAcumulado                     -- Total acumulado hasta la venta actual
    FROM Venta.Venta v
    INNER JOIN Venta.DetalleVenta dv ON v.VentaID = dv.VentaID
	INNER JOIN Sucursal.Empleado e ON e.EmpleadoID = v.EmpleadoID
    INNER JOIN Sucursal.Sucursal s ON e.SucursalID = s.SucursalID
    WHERE 
        v.Fecha = @Fecha                        -- Filtra por la fecha proporcionada
        AND s.SucursalID = @SucursalID          -- Filtra por la sucursal proporcionada
    ORDER BY v.Fecha                                -- Ordena por la fecha de la venta
	FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE  -- Devuelve el resultado en formato XML
END
GO

/*
CREATE OR ALTER PROCEDURE Venta.ReporteProductosMenosVendidosEnElMes
    @Año INT,  -- Año especificado
    @Mes INT   -- Mes especificado
AS
BEGIN
    ;WITH ProductosPorMes AS (
        SELECT 
            p.Nombre AS Producto,                          -- Nombre del producto
            SUM(dv.Cantidad) AS CantidadVendida            -- Cantidad total vendida en el mes
        FROM Venta.DetalleVenta dv
        INNER JOIN Venta.Venta v ON dv.VentaID = v.VentaID
        INNER JOIN Producto.Producto p ON dv.ProductoID = p.ProductoID
        WHERE 
            YEAR(v.Fecha) = @Año                            -- Filtra por el año
            AND MONTH(v.Fecha) = @Mes                       -- Filtra por el mes
        GROUP BY p.Nombre                                  -- Agrupa solo por el nombre del producto
    )
    -- Seleccionamos los 5 productos menos vendidos en el mes
    SELECT TOP 5
        Producto,                   -- Nombre del producto
        CantidadVendida             -- Cantidad vendida en el mes
    FROM 
        ProductosPorMes
    ORDER BY 
        CantidadVendida ASC         -- Ordena por la cantidad vendida (de menor a mayor)
    FOR XML PATH('Factura'), ROOT('Venta.Venta'), TYPE  -- Devuelve el resultado en formato XML
END
GO
*/