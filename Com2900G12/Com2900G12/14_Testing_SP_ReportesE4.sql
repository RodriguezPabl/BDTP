/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
	Fecha: 26/11/24
*/

/* Entrega 5
Requisitos de seguridad
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
La información de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma.
*/

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