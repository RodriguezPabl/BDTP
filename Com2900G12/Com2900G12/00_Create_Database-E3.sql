USE master
GO

IF NOT EXISTS (SELECT name From master.dbo.sysdatabases WHERE name='Com2900G12')
BEGIN
	CREATE DATABASE Com2900G12
	COLLATE Modern_Spanish_CI_AS --ver si hay que modificar
END
GO

USE Com2900G12
GO



/*
use master 
drop database Com2900G12
*/