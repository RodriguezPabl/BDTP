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