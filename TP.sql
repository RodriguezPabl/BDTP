/*
	Bases de datos aplicada
	Grupo 12
	Integrantes:
		-Rodriguez Pablo, 42949072
		-Aguilera Emanuel, 41757402
		-Tatiana Greve, 43031180
		-Nogueira Denise, 41234014

*/

/*
Entrega 3
Luego de decidirse por un motor de base de datos relacional, lleg� el momento de generar la
base de datos.
Deber� instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicaci�n de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregar�a al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deber� entregar
un archivo .sql con el script completo de creaci�n (debe funcionar si se lo ejecuta �tal cual� es
entregado). Incluya comentarios para indicar qu� hace cada m�dulo de c�digo.
Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con �SP�.
Genere esquemas para organizar de forma l�gica los componentes del sistema y aplique esto
en la creaci�n de objetos. NO use el esquema �dbo�.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, n�mero de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la secci�n de pr�cticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/

--Si no existe la base de datos Com2900G12 la crea
if not exists (select name from master.dbo.sysdatabases where name = 'Com2900G12')
begin
	Create database Com2900G12
	Collate Latin1_General_CI_AI;
end
go

use Com2900G12
go

--Si no existe el esquema supermercado lo crea
if not exists (select * from sys.schemas where name = 'supermercado')
begin
	exec('Create schema supermercado')
end
go

--Si no existe el esquema supermercado ni la tabla venta, crea la tabla
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'supermercado' and TABLE_NAME = 'venta')
begin
	Create table supermercado.venta (
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

select *
from supermercado.venta
go