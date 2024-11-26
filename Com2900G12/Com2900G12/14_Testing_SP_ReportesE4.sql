USE Com2900G12
GO

--Reporte general
EXEC Venta.ReporteDeVentas

--Reporte Mensual por dia de la semana
EXEC Venta.ReporteMensualPorDiaDeLaSemana 3,2019

--Reporte Mensual por turno
EXEC Venta.ReporteTrimestralPorTurnosPorMes 'TM', 1, 2019

--Reporte de productos vendidos
EXEC Venta.ReporteProductosVendidos '2019-01-01', '2024-12-01'

--Reporte de productos vendidos por sucursal
EXEC Venta.ReporteProductosVendidosPorSucursal '2019-01-01', '2024-12-01', 3

--Reporte de los 5 productos mas vendidos en un mes, por semana
EXEC Venta.ReporteProductosMasVendidosPorSemana 2019,3

--Reporte de los 5 productos menos vendidos en un mes, por semana
EXEC Venta.ReporteProductosMenosVendidosPorSemana 2019, 2

--Reporte de total acumulado de ventas para una fecha y sucursal concretas
EXEC Venta.ReporteVentasAcumuladasPorSucursal '2019-01-01', 3

/*
--Reporte de los 5 productos menos vendidos en el mes
EXEC Venta.ReporteProductosMenosVendidosEnElMes 2019, 1
*/