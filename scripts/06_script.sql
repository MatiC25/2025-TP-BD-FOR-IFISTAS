-- ========================================
-- 1. BORRADO DE ÍNDICES SI YA EXISTEN
-- ========================================
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Cliente_Dni_NombreApellido')
    DROP INDEX IX_Cliente_Dni_NombreApellido ON Cliente;

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Estado_Tipo')
    DROP INDEX IX_Estado_Tipo ON Estado;

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Sucursal_Numero')
    DROP INDEX IX_Sucursal_Numero ON Sucursal;

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Maestra_Join')
    DROP INDEX IX_Maestra_Join ON GD1C2025.gd_esquema.Maestra;


IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Maestra_Optimizada')
    DROP INDEX IX_Maestra_Optimizada ON GD1C2025.gd_esquema.Maestra;

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Estado_Tipo_Entregado')
    DROP INDEX IX_Estado_Tipo_Entregado ON Estado;

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Estado_Tipo_Cancelado')
    DROP INDEX IX_Estado_Tipo_Cancelado ON Estado;



-- =========================
-- ELIMINAR SI EXISTE (SAFE)
-- =========================

IF OBJECT_ID('Pedido') IS NOT NULL DROP TABLE Pedido;
IF OBJECT_ID('Estado') IS NOT NULL DROP TABLE Estado;
IF OBJECT_ID('Factura') IS NOT NULL DROP TABLE Factura;
IF OBJECT_ID('Sucursal') IS NOT NULL DROP TABLE Sucursal;
IF OBJECT_ID('Envio') IS NOT NULL DROP TABLE Envio;
IF OBJECT_ID('Cliente') IS NOT NULL DROP TABLE Cliente;
IF OBJECT_ID('Direccion') IS NOT NULL DROP TABLE Direccion;
IF OBJECT_ID('Localidad') IS NOT NULL DROP TABLE Localidad;
IF OBJECT_ID('Provincia') IS NOT NULL DROP TABLE Provincia;

IF OBJECT_ID('Migracion_Direccion') IS NOT NULL DROP PROCEDURE Migracion_Direccion;
IF OBJECT_ID('Migracion_Localidad') IS NOT NULL DROP PROCEDURE Migracion_Localidad;
IF OBJECT_ID('Migracion_Provincia') IS NOT NULL DROP PROCEDURE Migracion_Provincia;
IF OBJECT_ID('Migracion_Cliente') IS NOT NULL DROP PROCEDURE Migracion_Cliente;
IF OBJECT_ID('Migracion_Envio') IS NOT NULL DROP PROCEDURE Migracion_Envio;
IF OBJECT_ID('Migracion_Sucursal') IS NOT NULL DROP PROCEDURE Migracion_Sucursal;
IF OBJECT_ID('Migracion_Factura') IS NOT NULL DROP PROCEDURE Migracion_Factura;
IF OBJECT_ID('Migracion_Estado') IS NOT NULL DROP PROCEDURE Migracion_Estado;
IF OBJECT_ID('Migracion_Pedido') IS NOT NULL DROP PROCEDURE Migracion_Pedido;

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
CREATE OR ALTER PROCEDURE Migracion_Direccion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Direccion (dire_calle_altura, dire_localidad)
    SELECT DISTINCT m.Cliente_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Cliente_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Cliente_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Cliente_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Proveedor_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Proveedor_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Proveedor_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Sucursal_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Sucursal_Provincia
        AND p.prov_codigo = l.loca_provincia
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
CREATE OR ALTER PROCEDURE Migracion_Cliente
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
        m.Cliente_Nombre, 
        m.Cliente_Apellido, 
        d.dire_codigo, 
        m.Cliente_FechaNacimiento, 
        m.Cliente_Mail, 
        m.Cliente_Telefono, 
        m.Cliente_Dni
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Direccion d ON d.dire_calle_altura = m.Cliente_Direccion
    JOIN Localidad l ON l.loca_codigo = d.dire_localidad AND l.loca_nombre = m.Cliente_Localidad
    JOIN Provincia p ON p.prov_codigo = l.loca_provincia
                    AND p.prov_nombre = m.Cliente_Provincia
END
GO

-- ==================
-- TABLA: Envio
-- ==================

CREATE TABLE Envio(
    envi_numero INT NOT NULL,
    envi_fecha_programada DATETIME2,
    envi_fecha_entrega DATETIME2, 
    envi_importe_traslado DECIMAL(10, 2),
    envi_importe_subida DECIMAL(10, 2)
)
GO

ALTER TABLE Envio ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_numero)
GO

CREATE PROCEDURE Migracion_Envio
AS
BEGIN
    SET NOCOUNT ON;

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
        tm.Envio_ImporteTraslado,
        tm.Envio_ImporteSubida
        from GD1C2025.gd_esquema.Maestra tm
        where tm.Envio_Numero IS NOT NULL
END
GO

-- ==================
-- TABLA: Sucursal
-- ==================

CREATE TABLE Sucursal( 
    sucu_numero INT NOT NULL,
    sucu_direccion INT,
    sucu_telefono INT,
    sucu_mail VARCHAR(100)
)
GO

ALTER TABLE Sucursal ADD CONSTRAINT PK_Sucursal_Numero PRIMARY KEY (sucu_numero)
GO

ALTER TABLE Sucursal ADD CONSTRAINT FK_Sucursal_Direccion FOREIGN KEY (sucu_direccion) REFERENCES Direccion (dire_codigo)
GO

CREATE PROCEDURE Migracion_Sucursal
AS
BEGIN
    SET NOCOUNT ON;

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
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN Direccion d ON d.dire_calle_altura = tm.Sucursal_Direccion
        JOIN Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN Provincia p ON p.prov_codigo = l.loca_provincia
                            AND p.prov_nombre = tm.Sucursal_Provincia
                            AND l.loca_nombre = tm.Sucursal_Localidad
        WHERE tm.Sucursal_NroSucursal IS NOT NULL
END
GO

-- ==================
-- TABLA: Factura
-- ==================

CREATE TABLE Factura( 
    fact_numero INT NOT NULL,
    fact_sucursal INT NOT NULL, -- CODIGO asociado a la sucursal || VARCHAR(50)
    fact_cliente INT, -- CODIGO asociado al cliente || VARCHAR(50)
    fact_total DECIMAL(10, 2),
    fact_envio INT, -- Codigo asociado al envio
    fact_fecha_hora DATETIME2 -- DATETIME
)
GO

ALTER TABLE Factura ADD CONSTRAINT PK_Fact_Numero PRIMARY KEY (fact_numero, fact_sucursal)
GO  

ALTER TABLE Factura ADD CONSTRAINT FK_FACT_Envio FOREIGN KEY (fact_envio) REFERENCES Envio (envi_numero)
GO
ALTER TABLE Factura ADD CONSTRAINT FK_Fact_cliente FOREIGN KEY (fact_cliente) REFERENCES Cliente (clie_codigo)
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
                        AND tm.Cliente_Apellido = c.clie_apellido
        JOIN Envio e ON tm.Envio_Numero = e.envi_numero
        WHERE tm.Factura_Numero IS NOT NULL
END
GO



-- ==================
-- TABLA: Estado
-- ==================

CREATE TABLE Estado (
    esta_codigo INT IDENTITY(1,1),
    esta_tipo VARCHAR(10) NOT NULL 
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
    pedi_numero INT NOT NULL,
    pedi_sucursal INT, --> codigo asociado a la Sucursal
    pedi_cliente INT, --> codigo asociado al Cliente
    pedi_fecha_hora DATETIME2,
    pedi_total DECIMAL(10, 2),
    pedi_estado INT --> Codigo asociado al Estado
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

    ;WITH PedidosFiltrados AS (
    SELECT *
    FROM GD1C2025.gd_esquema.Maestra
    WHERE Pedido_Numero IS NOT NULL
)

    INSERT INTO Pedido (
        pedi_numero,
        pedi_sucursal,
        pedi_cliente,
        pedi_fecha_hora,
        pedi_total,
    -- pedi_estado
    )

    SELECT DISTINCT
        tm.Pedido_Numero,
        tm.Sucursal_NroSucursal,
        c.clie_codigo,
        tm.Pedido_Fecha,
        tm.Pedido_Total,
    --    e.esta_codigo
    FROM PedidosFiltrados tm
    JOIN Cliente c ON tm.Cliente_Nombre = c.clie_nombre AND tm.Cliente_Apellido = c.clie_apellido AND tm.Cliente_Dni = c.clie_dni
    --JOIN Estado e ON tm.Pedido_Estado = e.esta_tipo
    JOIN Sucursal s ON tm.Sucursal_NroSucursal = s.sucu_numero
    WHERE tm.Pedido_Numero IS NOT NULL
END
GO

-- ========================================
-- 2. CREACIÓN DE ÍNDICES PARA MIGRACIÓN
-- ========================================

CREATE NONCLUSTERED  INDEX IX_Cliente_Dni_NombreApellido 
ON Cliente (clie_dni, clie_nombre, clie_apellido);

CREATE NONCLUSTERED  INDEX IX_Estado_Tipo 
ON Estado (esta_tipo);

CREATE NONCLUSTERED  INDEX IX_Sucursal_Numero 
ON Sucursal (sucu_numero);

CREATE NONCLUSTERED INDEX IX_Estado_Tipo_Entregado
ON Estado (esta_tipo)
WHERE esta_tipo = 'ENTREGADO';

CREATE NONCLUSTERED INDEX IX_Estado_Tipo_Cancelado
ON Estado (esta_tipo)
WHERE esta_tipo = 'CANCELADO';

CREATE NONCLUSTERED INDEX IX_Maestra_Optimizada 
ON GD1C2025.gd_esquema.Maestra (
    Pedido_Numero,                     -- utilizado en WHERE
    Cliente_Dni, Cliente_Nombre, Cliente_Apellido,  -- JOIN con Cliente
    Pedido_Estado,                    -- JOIN con Estado
    Sucursal_NroSucursal              -- JOIN con Sucursal
)
INCLUDE (Pedido_Fecha, Pedido_Total); -- columnas del SELECT

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
EXEC Migracion_Envio
GO
EXEC Migracion_Sucursal
GO
EXEC Migracion_Factura
GO
EXEC Migracion_Estado
GO
EXEC Migracion_Pedido
GO