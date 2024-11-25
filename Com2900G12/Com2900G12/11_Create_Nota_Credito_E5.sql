use Com2900G12
go

CREATE OR ALTER PROCEDURE Venta.GenerarNotaDeCredito
    @Motivo VARCHAR(50),
    @FacturaID INT,
    @DetalleVentaID INT = NULL
AS
BEGIN  
    DECLARE @Errores VARCHAR(MAX) = '';  -- Variable para almacenar los errores
    IF NOT EXISTS(SELECT 1 FROM Venta.Factura WHERE FacturaID = @FacturaID)
        SET @Errores = @Errores + 'La factura no existe.';

	DECLARE @Monto DECIMAL(9, 2) = (SELECT TotalConIva FROM Venta.Factura WHERE FacturaID = @FacturaID)

	IF @DetalleVentaID IS NOT NULL
	BEGIN
		SET @Monto = (SELECT dv.Subtotal
			FROM Venta.Venta v
			INNER JOIN Venta.Factura f ON v.VentaID = f.VentaID
			INNER JOIN Venta.DetalleVenta dv ON v.VentaID = dv.VentaID
			WHERE f.FacturaID = @FacturaID AND dv.NumeroDeItem = @DetalleVentaID
			)
		IF @Monto IS NULL
			SET @Errores = @Errores + 'El detalleVenta no esta enlazado a la misma venta que la factura'
		ELSE
			SET @Monto = @Monto * 1.21
	END

   /* IF @Monto > (SELECT TotalConIva FROM Venta.Factura WHERE FacturaID = @FacturaID)
    BEGIN
        PRINT 'El monto de la nota de credito no puede ser mayor al total de la factura.';
        RETURN;
    END
	*/
	IF @Errores <> ''
	BEGIN
		RAISERROR(@Errores,16,1)
		RETURN
	END

    INSERT INTO Venta.NotaDeCredito(Monto, Motivo, FacturaID, DetalleVentaID)
    VALUES(@Monto, @Motivo, @FacturaID, @DetalleVentaID);

    PRINT 'Nota de credito generada exitosamente.';
END
GO