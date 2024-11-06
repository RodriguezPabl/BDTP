USE master
GO

IF NOT EXISTS (SELECT name From master.dbo.sysdatabases WHERE name='Com2900G12')
BEGIN
	CREATE DATABASE Com2900G12
	COLLATE Latin1_General_CI_AI --ver si hay que modificar
END
GO

USE Com2900G12
GO

/*
use master 
drop database Com2900G12
*/