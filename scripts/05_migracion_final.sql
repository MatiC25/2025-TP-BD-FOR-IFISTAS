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

Migracion_Cliente
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
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN Direccion dir ON dir.dire_calle_altura = tm.Cliente_Direccion;

END
GO

EXEC Migracion_Cliente
GO

CREATE TABLE Envio(
    envi_numero INT,
    envi_fecha_programada DATETIME2,
    envi_fecha_entrega DATETIME2, 
    envi_importe_traslado DECIMAL(10, 2),
    envi_importe_subida DECIMAL(10, 2)
)
GO

ALTER Envio ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_numero)
GO

CREATE PROCEDURE Migracion_Envio
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO Envio (
        envi_numero,
        envi_fecha_programada,
        envi_fecha_entrega,
        envi_importe_traslado,
        envi_importe_subida
    )
    SELECT DISTINCT
        tm.Envio_Numero,
        tm.Envio_Fecha_Programada,
        tm.Envio_Fecha,
        tm.Envio_ImporteTranslado,
        tm.Envio_ImporteSubida
        from GD1C2025.gd_esquema.Maestra tm
END
GO

CREATE TABLE Sucursal( 
    sucu_numero INT NOT NULL,
    sucu_direccion INT,
    sucu_telefono INT,
    sucu_mail VARCHAR(100),
)
GO

ALTER Sucursal ADD CONSTRAINT PK_Sucursal_Numero PRIMARY KEY (sucu_numero)
GO

CREATE PROCEDURE Migracion_Sucursal
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO Sucursal(
        sucu_numero,
        sucu_direccion,
        sucu_telefono,
        sucu_mail
    )
    SELECT DISTINCT
        tm.Sucursal_NroSucursal,
        d.dire_codigo,
        tm.Sucursal_telefono,
        Sucursal_mail
        from GD1C2025.gd_esquema.Maestra tm
        JOIN Direccion d ON d.dire_calle_altura = m.Cliente_Direccion
        JOIN Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN Provincia p ON p.prov_codigo = l.loca_provincia
        AND p.prov_nombre = m.Cliente_Provincia
        AND l.loca_nombre = m.Cliente_Localidad;
GO

-- ==================
-- TABLA: Factura
-- ==================   

CREATE TABLE Factura( 
    fact_numero INT,
    fact_sucursal INT, -- CODIGO asociado a la sucursal || VARCHAR(50)
    fact_cliente INT, -- CODIGO asociado al cliente || VARCHAR(50)
    fact_total DECIMAL(10, 2),
    fact_envio INT, -- Codigo asociado al envio
    fact_fecha_hora DATETIME2, -- DATETIME
)
GO

ALTER TABLE Factura ADD CONSTRAINT PK_Fact_Numero PRIMARY KEY (fact_numero)
ADD CONSTRAINT PK_Fact_Sucursal PRIMARY KEY (fact_sucursal)
GO

ALTER TABLE Factura ADD CONSTRAINT FK_FACT_Envio FOREIGN KEY (fact_envio) REFERENCES Envio (envi_numero)
ADD CONSTRAINT FK_Fact_cliente FOREIGN KEY (fact_cliente) REFERENCES Cliente (clie_codigo)
GO

CREATE PROCEDURE Migracion_Factura
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Factura(
        fact_numero,
        fact_sucursal, --> Numero de sucursal asociado
        fact_cliente, --> Numero de cleinte asociado
        fact_total,
        fact_envio, --> Numero de Envio asociado
        fact_fecha_hora
    )
    SELECT DISTINCT
        tm.Factura_Numero,
        s.sucu_numero,
        c.clie_codigo,
        tm.Factura_Total,
        e.envi_numero,
        tm.Factura_Fecha
        FROM GD1C2025.gd_esquema.Maestra tm
        LEFT JOIN Sucursal s on tm.Sucursal_NroSucursal = s.sucu_numero
        JOIN Cliente c ON tm.Cliente_Dni = c.clie_dni 
                        AND tm.Cliente_Nombre = c.clie_nombre 
                        AND tm.Cliente_Nombre = c.clie_nombre
        JOIN Envio e ON tm.Envio_Numero = e.envi_numero
        WHERE tm.Factura_Numero IS NOT NULL
END
GO


-- ==================
-- TABLA: Estado
-- ==================

CREATE TABLE Estado (
    esta_codigo INT IDENTITY(1,1),
    esta_tipo VARCHAR(30) NOT NULL 
)
GO

ALTER TABLE Estado ADD CONSTRAINT PK_Estado PRIMARY KEY (esta_codigo)
GO 

CREATE PROCEDURE Migracion_Estado
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Estado (
        esta_tipo 
    )
    SELECT 
        tm.Pedido_Estado
        FROM GD1C2025.gd_esquema.Maestra tm
        WHERE tm.Pedido_Estado IS NOT NULL
END
GO

-- ==================
-- TABLA: Pedido
-- ==================

CREATE TABLE Pedido(
    pedi_numero INT,
    pedi_sucursal INT,
    pedi_cliente INT,
    pedi_fecha_hora DATETIME2,
    pedi_total DECIMAL(10, 2),
    pedi_estado VARCHAR(20) -- 'Entregado', 'Cancelado'
)
GO

ALTER TABLE Pedido ADD CONSTRAINT PK_Pedido_Numero PRIMARY KEY (pedi_numero)
GO
ALTER TABLE Pedido ADD CONSTRAINT FK_Pedido_Clinete FOREIGN KEY (pedi_cliente) REFERENCES Cliente(clie_codigo)
GO
ALTER TABLE Pedido ADD CONSTRAINT FK_Pedido_Estado FOREIGN KEY (pedi_estado) REFERENCES Estado(esta_codigo)
GO

CREATE PROCEDURE Migracion_Pedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pedido (
        pedi_numero,
        pedi_sucursal,
        pedi_cliente,
        pedi_fecha_hora,
        pedi_total,
        pedi_estado
    )

    SELECT 
        tm.Pedido_Numero,
        tm.Sucursal_NroSucursal,
        c.clie_codigo,
        tm.Pedido_Fecha,
        tm.Pedido_Total,
        e.esta_codigo
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN Cliente c ON tm.Cliente_Nombre+tm.Cliente_Apellido+tm.Cliente_Dni = c.clie_nombre+c.clie_apellido+c.clie_dni
    JOIN Estado e ON tm.Pedido_Estado = e.esta_tipo
    WHERE tm.Pedido_Numero IS NOT NULL
END
GO


-- ==================
-- TABLA: Pedido
-- ==================

CREATE TABLE Madera (
    made_codigo INT NOT NULL,
    made_color VARCHAR(20),
    made_dureza VARCHAR(20)
)
GO

ALTER TABLE Madera ADD CONSTRAINT FK_Madera_Codigo FOREIGN KEY (made_codigo) REFERENCES Tipo_Material (tipo_nombre)
GO

CREATE PROCEDURE Migracion_Madera
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Madera(
        made_color,
        made_dureza
    )
    SELECT DISTINCT
        m.mate_codigo
        tm.Madera_Color,
        tm.Madera_Dureza
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN Material m ON m.mate_tipo LIKE 'Madera'
        WHERE tm.Madera_Color IS NOT NULL AND tm.Madera_Dureza IS NOT NULL
END
GO
