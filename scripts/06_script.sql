-- =========================
-- ELIMINAR SI EXISTE (SAFE)
-- =========================
IF OBJECT_ID('Cliente') IS NOT NULL DROP TABLE Cliente;
IF OBJECT_ID('Direccion') IS NOT NULL DROP TABLE Direccion;
IF OBJECT_ID('Localidad') IS NOT NULL DROP TABLE Localidad;
IF OBJECT_ID('Provincia') IS NOT NULL DROP TABLE Provincia;

IF OBJECT_ID('Migracion_Direccion') IS NOT NULL DROP PROCEDURE Migracion_Direccion;
IF OBJECT_ID('Migracion_Localidad') IS NOT NULL DROP PROCEDURE Migracion_Localidad;
IF OBJECT_ID('Migracion_Provincia') IS NOT NULL DROP PROCEDURE Migracion_Provincia;
IF OBJECT_ID('Migracion_Cliente') IS NOT NULL DROP PROCEDURE Migracion_Cliente;

GO

-- ==================
-- TABLA: Provincia
-- ==================

CREATE TABLE Provincia (
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50)
)
GO

ALTER TABLE Provincia ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo)
GO

CREATE PROCEDURE Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Provincia (prov_nombre)
        SELECT DISTINCT Cliente_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL
        UNION
        SELECT DISTINCT Proveedor_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Proveedor_Provincia IS NOT NULL
        UNION
        SELECT DISTINCT Sucursal_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Sucursal_Provincia IS NOT NULL
END
GO

-- ==================
-- TABLA: Localidad
-- ==================

CREATE TABLE Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT
)
GO

ALTER TABLE Localidad ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo)
GO
ALTER TABLE Localidad ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES Provincia(prov_codigo)
GO

CREATE PROCEDURE Migracion_Localidad
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Localidad (loca_nombre, loca_provincia)
    SELECT DISTINCT m.Cliente_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Cliente_Provincia
    WHERE m.Cliente_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Proveedor_Provincia
    WHERE m.Proveedor_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Sucursal_Provincia
    WHERE m.Sucursal_Localidad IS NOT NULL
END
GO

-- ==================
-- TABLA: Direccion
-- ==================

CREATE TABLE Direccion (
    dire_codigo INT IDENTITY(1,1),
    dire_calle_altura VARCHAR(75),
    dire_localidad INT
)
GO

ALTER TABLE Direccion ADD CONSTRAINT PK_Direccion PRIMARY KEY (dire_codigo)
GO
ALTER TABLE Direccion ADD CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (dire_localidad) REFERENCES Localidad(loca_codigo)
GO

CREATE PROCEDURE Migracion_Direccion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Direccion (dire_calle_altura, dire_localidad)
    SELECT DISTINCT m.Cliente_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Cliente_Localidad
    WHERE m.Cliente_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Proveedor_Localidad
    WHERE m.Proveedor_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Sucursal_Localidad
    WHERE m.Sucursal_Direccion IS NOT NULL
END
GO

-- ==================
-- TABLA: Cliente
-- ==================

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

ALTER TABLE Cliente ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion) REFERENCES Direccion (dire_codigo)
GO

CREATE PROCEDURE Migracion_Cliente
AS
BEGIN
    SET NOCOUNT ON;

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
        dir.dire_codigo,
        tm.Cliente_FechaNacimiento,
        tm.Cliente_Mail,
        tm.Cliente_Telefono,
        tm.Cliente_Dni
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN Direccion dir ON dir.dire_calle_altura = tm.Cliente_Direccion;

END
GO

-- ==================
-- EJECUTAR MIGRACIONES
-- ==================

EXEC Migracion_Provincia
GO
EXEC Migracion_Localidad
GO
EXEC Migracion_Direccion
GO
EXEC Migracion_Cliente
GO