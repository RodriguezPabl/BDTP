-- Crear roles
CREATE ROLE Cliente;
CREATE ROLE Empleado;
CREATE ROLE Supervisor;
CREATE ROLE Administrador;

-- Crear usuarios de ejemplo
CREATE USER Cliente1 FOR LOGIN Cliente1Login;
CREATE USER Empleado1 FOR LOGIN Empleado1Login;
CREATE USER Supervisor1 FOR LOGIN Supervisor1Login;
CREATE USER Admin1 FOR LOGIN Admin1Login;

-- Asignar roles a usuarios
ALTER ROLE Cliente ADD MEMBER Cliente1;
ALTER ROLE Empleado ADD MEMBER Empleado1;
ALTER ROLE Supervisor ADD MEMBER Supervisor1;
ALTER ROLE Administrador ADD MEMBER Admin1;

-- Conceder permisos
GRANT SELECT ON Ventas TO Cliente;
GRANT INSERT, SELECT, UPDATE ON Ventas TO Empleado;
GRANT INSERT, SELECT, UPDATE, DELETE ON Ventas TO Supervisor;
GRANT CONTROL ON Ventas TO Administrador;

-- Permiso para generar notas de crédito a Supervisores
GRANT INSERT, SELECT, UPDATE ON NotasCredito TO Supervisor;
