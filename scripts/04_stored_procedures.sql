CREATE TABLE Provincia(
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50)
)

-- == PROVINCIA == --
ALTER TABLE Provincia
ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo)

/*
SELECT DISTINCT prov_nombre
    FROM (
        SELECT Cliente_Provincia AS prov_nombre FROM GD1C2025.gd_esquema.Maestra
        UNION
        SELECT Proveedor_Provincia FROM gd_esquema.Maestra
        UNION
        SELECT Sucursal_Provincia FROM gd_esquema.Maestra
    ) AS ProvinciasUnificadas
*/
    -- No hace falta poner el distinct, el union ya elimina los repetidos
    -- No hace falta hacer los selects en el from, eso es casi ilegal según reino, es mejor hacer directamente 
    -- la union con selects separados
CREATE PROCEDURE Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON;

	INSERT INTO Provincia (prov_nombre)
        SELECT Cliente_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Cliente_Provincia IS NOT NULL
        UNION
        SELECT Proveedor_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Proveedor_Provincia IS NOT NULL
        UNION
        SELECT Sucursal_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Sucursal_Provincia IS NOT NULL
END;


CREATE TABLE Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT
);

-- == LOCALIDAD == --
ALTER TABLE Localidad
ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo);

-- FOREIGN KEY
ALTER TABLE Localidad
ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES Provincia(prov_codigo);


CREATE PROCEDURE Migracion_Localidad
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Localidad (loca_nombre, loca_provincia)
    SELECT DISTINCT
        loc.loca_nombre,
        p.prov_codigo
    FROM (
        SELECT Cliente_Localidad AS loca_nombre, Cliente_Provincia AS prov_nombre FROM gd_esquema.Maestra
        UNION
        SELECT Proveedor_Localidad, Proveedor_Provincia FROM gd_esquema.Maestra
        UNION
        SELECT Sucursal_Localidad, Sucursal_Provincia FROM gd_esquema.Maestra
    ) AS loc
    JOIN Provincia p ON p.prov_nombre = loc.prov_nombre;
END

CREATE PROCEDURE Migracion_Localidad
AS
BEGIN   
    SET NOCOUNT ON;
    INSERT INTO Localidad (loca_nombre, loca_provincia) -- NombreDeLaLocalidad | CodigoDeLaProvinciaAsociada

    SELECT Cliente_Localidad, p.prov_codigo 
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Cliente_Provincia

    UNION

    SELECT Proveedor_Localidad, p.prov_codigo 
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Proveedor_Provincia

    UNION
    
    SELECT Sucursal_Localidad, p.prov_codigo 
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Sucursal_Provincia

END;

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

-- == CLIENTE == --
ALTER TABLE Cliente
ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo)
ALTER TABLE Cliente
ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion) REFERENCES Direccion(direc_codigo)

ALTER TABLE Cliente
ADD CONSTRAINT uq_dni UNIQUE (clie_dni) -- El dni debe ser unico\
ALTER TABLE Cliente
ADD CONSTRAINT ck_dni CHECK (LEN(clie_dni) BETWEEN 7 AND 8);

ALTER TABLE Cliente
ADD CONSTRAINT ck_fecha_nacimiento CHECK (clie_fecha_nacimiento < GETDATE()) -- La fecha de nacimiento debe ser menor a la fecha actual

ALTER TABLE Cliente
ADD CONSTRAINT uq_mail UNIQUE (clie_mail)


-- Los dropie porque anda madio mal NOC QUE ONDA habia que o filtrarlo devuelta o 
-- Hay que arreglarlo
ALTER TABLE Cliente DROP CONSTRAINT uq_dni; 
ALTER TABLE Cliente DROP CONSTRAINT uq_mail; 


-- == Cliente == --
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
        dir.direc_codigo,
        tm.Cliente_FechaNacimiento,
        tm.Cliente_Mail,
        tm.Cliente_Telefono,
        tm.Cliente_Dni
    FROM gd_esquema.Maestra tm
    JOIN Direccion dir ON dir.direc_calle = tm.Cliente_Direccion;

END;

DROP PROCEDURE Migracion_Cliente;

BEGIN TRANSACTION;
EXEC Migracoion_Provincia;
EXEC Migracion_Localidad;
EXEC Migracion_Direccion;
EXEC Migracion_Cliente

select * from Provincia
select * from Localidad
select * from Direccion
select * from Cliente


DROP TABLE Provincia
DROP TABLE Localidad
DROP TABLE Provincia
DROP TABLE Cliente

ROLLBACK TRANSACTION

