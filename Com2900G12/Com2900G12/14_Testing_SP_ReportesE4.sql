USE Com2900G12
GO

--Reporte general
EXEC Venta.ReporteDeVentas

--Reporte Mensual por dia de la semana
EXEC Venta.ReporteMensualPorDiaDeLaSemana @Mes=3, @Anio=2019

--Reporte Mensual por turno
EXEC Venta.ReporteTrimestralPorTurnosPorMes @Turno='TM', @Trimestre=1, @Anio=2019

--Reporte de productos vendidos
EXEC Venta.ReporteProductosVendidos @FechaInicio='2019-01-01', @FechaFin='2024-12-01'

--Reporte de productos vendidos por sucursal
EXEC Venta.ReporteProductosVendidosPorSucursal @FechaInicio='2019-01-01', @FechaFin='2024-12-01', @SucursalID=3

--Reporte de los 5 productos mas vendidos en un mes, por semana
EXEC Venta.ReporteProductosMasVendidosPorSemana @Año=2019, @Mes=3

--Reporte de los 5 productos menos vendidos en un mes, por semana
EXEC Venta.ReporteProductosMenosVendidosPorSemana @Año=2019, @Mes=2

--Reporte de total acumulado de ventas para una fecha y sucursal concretas
EXEC Venta.ReporteVentasAcumuladasPorSucursal @Fecha='2019-01-01', @SucursalID=3

/*
--Reporte de los 5 productos menos vendidos en el mes
EXEC Venta.ReporteProductosMenosVendidosEnElMes 2019, 1
*/