DROP TABLE Direccion
DROP TABLE Localidad
DROP TABLE Provincia
DROP PROCEDURE Migracion_Direccion
DROP PROCEDURE Migracion_Localidad
DROP PROCEDURE	Migracion_Provincia

---- PROVINCIA FUNCIONANDO ----

CREATE TABLE Provincia(
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50)
)

GO

ALTER TABLE Provincia
ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo)

GO

CREATE PROCEDURE Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON

	INSERT INTO Provincia (prov_nombre)
        SELECT Cliente_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Cliente_Provincia IS NOT NULL
        UNION
        SELECT Proveedor_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Proveedor_Provincia IS NOT NULL
        UNION
        SELECT Sucursal_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Sucursal_Provincia IS NOT NULL
END

GO

---- LOCALIDAD FUNCIONANDO ---- (Los puntos y comas de la cosas y la diferencia de espacios del mismo parametro)
---- Habría que delegar la funcion UPPER(LTRIM(RTRIM(REPLACE()))) a otra que tambien elimine los espacios adicionales
---- Sigue sin funcionar, sigue soltando las mismas 12368 filas

CREATE TABLE Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT
)

GO

ALTER TABLE Localidad
ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo)
GO

ALTER TABLE Localidad
ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES Provincia(prov_codigo)
GO

CREATE PROCEDURE Migracion_Localidad
AS
BEGIN   
    SET NOCOUNT ON

    INSERT INTO Localidad (loca_nombre, loca_provincia)

    SELECT DISTINCT
        m.Cliente_Localidad,
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
        p.prov_nombre = m.Cliente_Provincia

    UNION

    SELECT DISTINCT
        m.Proveedor_Localidad, 
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
        p.prov_nombre = m.Proveedor_Provincia

    UNION

    SELECT DISTINCT
        m.Sucursal_Localidad, 
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
			p.prov_nombre = m.Sucursal_Provincia
END
GO
EXEC Migracion_Provincia
GO
EXEC Migracion_Localidad

-- == Direccion == --

CREATE TABLE Direccion (
    dire_codigo INT IDENTITY(1,1), -- No sabemos si vamos a crear un codigo asociado a la direccion para no tener que comparar string
                                     -- con la direccion entre Sucursal, direccion y cliente || VARCHAR(100)
    dire_calle_altura VARCHAR(75),
    dire_localidad INT-- id de localidad
)

GO
ALTER TABLE Direccion
ADD CONSTRAINT PK_Direccion PRIMARY KEY (dire_codigo)
GO
ALTER TABLE Direccion
ADD CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (dire_localidad) REFERENCES Localidad(loca_codigo)
GO

CREATE PROCEDURE Migracion_Direccion
AS
BEGIN   
    SET NOCOUNT ON

    INSERT INTO Direccion (dire_calle_altura, dire_localidad) -- NombreDeLaCalle || Codigo asociado a la localidad de esa calle

    SELECT DISTINCT
        m.Cliente_Direccion, 
        l.loca_codigo --> 1
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON 
        l.loca_nombre = m.Cliente_Localidad 
    WHERE m.Cliente_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT
        m.Proveedor_Direccion, 
        l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON 
        l.loca_nombre = m.Proveedor_Localidad
    WHERE m.Proveedor_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT
        m.Sucursal_Direccion, 
        l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON 
		l.loca_nombre = m.Sucursal_Localidad
    WHERE m.Sucursal_Direccion IS NOT NULL
END
GO
EXEC Migracion_Direccion

-- == Cliente ==--

CREATE TABLE Cliente (
    clie_codigo INT IDENTITY(1,1),
    clie_nombre VARCHAR(50),
    clie_apellido VARCHAR(50),
    clie_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50)  TODO
    clie_fecha_nacimiento DATETIME2,
    clie_mail VARCHAR(100),
    clie_telefono CHAR(8), 
    clie_dni CHAR(8)
)

GO

ALTER TABLE Cliente ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo)
GO

ALTER TABLE Cliente ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion)
GO

CREATE PROCEDURE Migracion_Cliente
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO Cliente (
        clie_nombre,
        clie_apellido,
        clie_direccion,
        clie_fecha_nacimiento,
        clie_mail,
        clie_telefono,
        clie_dni
    )
    SELECT DISTINCT
        tm.Cliente_Nombre,
        tm.Cliente_Apellido,
        dir.direc_codigo,
        tm.Cliente_FechaNacimiento,
        tm.Cliente_Mail,
        tm.Cliente_Telefono,
        tm.Cliente_Dni
    FROM gd_esquema.Maestra tm
    JOIN Direccion dir ON dir.dire_calle_altura = tm.Cliente_Direccion;

END
GO

EXEC Migracion_Cliente
GO