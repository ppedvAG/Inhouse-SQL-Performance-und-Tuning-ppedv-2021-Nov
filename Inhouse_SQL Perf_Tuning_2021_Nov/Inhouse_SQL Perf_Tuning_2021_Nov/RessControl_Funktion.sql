
USE [master]
GO
CREATE FUNCTION [dbo].[classSusiHans]() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname
      IF ( 'Susi'=SUSER_NAME())
          SET @grp_name = 'MAGruppe'
     IF ('Hans'=SUSER_NAME())
          SET @grp_name = 'ITGruppe'
    RETURN @grp_name
END;
GO




