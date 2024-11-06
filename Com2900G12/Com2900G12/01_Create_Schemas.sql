USE Com2900G12
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='Venta')
	EXEC('CREATE SCHEMA Venta')
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='Producto')
	EXEC('CREATE SCHEMA Producto')
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='Sucursal')
	EXEC('CREATE SCHEMA Sucursal')
GO