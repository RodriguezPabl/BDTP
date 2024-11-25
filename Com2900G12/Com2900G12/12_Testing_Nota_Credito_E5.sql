USE Com2900G12
GO

exec Venta.GenerarNotaDeCredito 'Devolucion', 1

SELECT * FROM Venta.NotaDeCredito
SELECT * fROM Venta.Factura