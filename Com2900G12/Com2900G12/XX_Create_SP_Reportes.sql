USE Com2900G12
GO

CREATE OR ALTER PROCEDURE Venta.ReporteGeneralOrdenadoPorFecha
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
            dv.Cantidad,
            v.Fecha,
            v.Hora,
            mp.DescripcionESP AS MedioDePago,
            e.EmpleadoID,
            s.SucursalID AS Sucursal,
			v.Total
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
        f.Cantidad,
        f.Fecha,
        f.Hora,
        f.MedioDePago,
        f.EmpleadoID,
        f.Sucursal,
		f.Total
    INTO #Reporte
    FROM
        Facturas f

    -- Convertimos a formato XML
    SELECT * 
    FROM #Reporte
    FOR XML PATH('Factura'), ROOT('ReporteFacturaMensual');
    
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
BEGIN
	
END
GO

--Reporte general
EXEC Venta.ReporteGeneralOrdenadoPorFecha

--Reporte Mensual por dia de la semana
EXEC Venta.ReporteMensualPorDiaXML 3,2019

--Reporte Mensual por turno
EXEC Venta.ReporteTrimestralPorMesXML 2024

