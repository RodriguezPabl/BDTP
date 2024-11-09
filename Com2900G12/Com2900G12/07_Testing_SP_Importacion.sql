USE Com2900G12
GO

EXEC Venta.ImportarVenta @RutaArchivo='F:\TP_integrador_Archivos\Ventas_registradas.csv'

EXEC Producto.ImportarCatalogo @RutaArchivo='F:\TP_integrador_Archivos\Productos\catalogo.csv'

