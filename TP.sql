if not exists (select name from master.dbo.sysdatabases where name = 'Supermercado')
begin
	Create database Supermercado
	Collate Latin1_General_CI_AI;
end
go

use Supermercado
go

if not exists (select * from sys.schemas where name = 'Administrador')
begin
	exec('Create schema Administrador')
end
go

if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'Administrador' and TABLE_NAME = 'Ventas')
begin
	Create table Administrador.Ventas (
	facturaID varchar(11) primary key,
	tipoFactura char,
	ciudad varchar(30),
	tipoCliente varchar(6),
	genero varchar(6),
	lineaDeProducto varchar(25),
	precioUnitario decimal(9,2),
	cantidad int,
	total decimal(11,2),
	fecha date,
	hora time,
	medioDePago varchar(15),
	empleado int,
	sucursal varchar(25)
	)
end
go