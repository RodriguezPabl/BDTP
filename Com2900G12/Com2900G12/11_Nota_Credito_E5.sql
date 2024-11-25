use Com2900G12
go

CREATE OR ALTER PROCEDURE Venta.GenerarNotaDeCredito
    @Motivo VARCHAR(50),
    @FacturaID INT,
    @DetalleVentaID INT = NULL
AS
BEGIN  

    IF NOT EXISTS(SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
    BEGIN
        PRINT 'La factura no existe.';
        RETURN;
    END

	DECLARE @Monto DECIMAL(9, 2) = (SELECT TotalConIva FROM Venta.Factura WHERE FacturaID = @FacturaID)

   /* IF @Monto > (SELECT TotalConIva FROM Venta.Factura WHERE FacturaID = @FacturaID)
    BEGIN
        PRINT 'El monto de la nota de credito no puede ser mayor al total de la factura.';
        RETURN;
    END
	*/
	
    INSERT INTO Venta.NotaDeCredito(Monto, Motivo, FacturaID, DetalleVentaID)
    VALUES(@Monto, @Motivo, @FacturaID, @DetalleVentaID);

    PRINT 'Nota de credito generada exitosamente.';
END

go

exec Venta.GenerarNotaDeCredito 'Devolucion', 1, 1

SELECT * FROM Venta.Factura 