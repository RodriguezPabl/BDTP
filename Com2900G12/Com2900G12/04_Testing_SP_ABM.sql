USE Com2900G12
GO

SELECT * FROM Sucursal.Sucursal
GO
SELECT * FROM Sucursal.Cargo
GO
SELECT * FROM Sucursal.Empleado
GO

EXEC Sucursal.InsertarEmpleado @Nombre='Pablo',@Apellido='Aguilera',@DNI='12345678',@Direccion='Florencio Varela 333',@Email='abc@alumno.edu.ar',@EmailEmpresarial='abc@empresa.com.ar',
	@Cuil='20-12345678-4',@Turno='TM',@SucursalID=1,@CargoID=1
GO

EXEC Sucursal.InsertarSucursal @Ciudad='San Justo', @Telefono='1234-9983', @Direccion='Florencio Varela 114',@Horario='8-21'
GO

EXEC Sucursal.InsertarCargo @Descripcion='Cajero'
GO

EXEC Sucursal.InsertarEmpleado @Nombre='Pablo',@Apellido='Aguilera',@DNI='12345678',@Direccion='Florencio Varela 333',@Email='abc@alumno.edu.ar',@EmailEmpresarial='abc@empresa.com.ar',
	@Cuil='20-12345678-4',@Turno='TM',@SucursalID=1,@CargoID=1
GO

EXEC Sucursal.ModificarSucursal @SucursalID=1, @Horario='9-20'

EXEC Sucursal.ModificarEmpleado @SucursalID=2, @CargoID=3

SELECT * FROM Sucursal.Sucursal
GO
SELECT * FROM Sucursal.Cargo
GO
SELECT * FROM Sucursal.Empleado
GO