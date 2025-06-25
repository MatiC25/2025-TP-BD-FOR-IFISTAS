USE GD1C2025
GO 

IF OBJECT_ID('FORIF_ISTAS.DimEstadoPedido') IS NOT NULL DROP TABLE FORIF_ISTAS.DimEstadoPedido;
IF OBJECT_ID('FORIF_ISTAS.DimModeloSillon') IS NOT NULL DROP TABLE FORIF_ISTAS.DimModeloSillon;
IF OBJECT_ID('FORIF_ISTAS.DimTipoMaterial') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTipoMaterial;
IF OBJECT_ID('FORIF_ISTAS.DimTurnoVentas') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTurnoVentas;
IF OBJECT_ID('FORIF_ISTAS.DimRangoEtario') IS NOT NULL DROP TABLE FORIF_ISTAS.DimRangoEtario;
IF OBJECT_ID('FORIF_ISTAS.DimUbicacion') IS NOT NULL DROP TABLE FORIF_ISTAS.DimUbicacion;
IF OBJECT_ID('FORIF_ISTAS.DimTiempo') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTiempo;

IF OBJECT_ID('FORIF_ISTAS.Migracion_DimEstadoPedido') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimEstadoPedido;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimModeloSillon') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimModeloSillon;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimTipoMaterial') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimTipoMaterial;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimTurnoVentas') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimTurnoVentas;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimRangoEtario') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimRangoEtario;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimUbicacion') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimUbicacion;
IF OBJECT_ID('FORIF_ISTAS.Migracion_DimTiempo') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_DimTiempo;


-- == Tiempo == --

CREATE TABLE FORIF_ISTAS.DimTiempo (
    tiem_id INT IDENTITY(1,1), --PRIMARY KEY,
    tiem_mes INT NOT NULL,
    tiem_anio INT NOT NULL,
    tiem_cuatrimestre INT NOT NULL
)
GO
ALTER TABLE FORIF_ISTAS.DimTiempo ADD CONSTRAINT PK_DimTiempo PRIMARY KEY (tiem_id);
GO
CREATE PROCEDURE FORIF_ISTAS.Migracion_DimTiempo
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimTiempo (tiem_mes, tiem_anio, tiem_cuatrimestre)

    SELECT DISTINCT
        MONTH(fact_fecha_hora),
        YEAR(fact_fecha_hora),
        DATEPART(QUARTER, fact_fecha_hora)
    
    FROM FORIF_ISTAS.Factura
    WHERE fact_fecha_hora IS NOT NULL

    UNION

    SELECT DISTINCT 
        MONTH(pedi_fecha_hora),
        YEAR(pedi_fecha_hora),
        DATEPART(QUARTER, pedi_fecha_hora)
    
    FROM FORIF_ISTAS.Pedido
    WHERE pedi_fecha_hora IS NOT NULL

    UNION
    
    SELECT DISTINCT
        MONTH(envi_fecha_programada),
        YEAR(envi_fecha_programada),
        DATEPART(QUARTER, envi_fecha_programada)
    FROM FORIF_ISTAS.Envio
    WHERE envi_fecha_programada IS NOT NULL

    UNION
    
    SELECT DISTINCT
        MONTH(envi_fecha_entrega),
        YEAR(envi_fecha_entrega),
        DATEPART(QUARTER, envi_fecha_entrega)
    FROM FORIF_ISTAS.Envio
    WHERE envi_fecha_entrega IS NOT NULL

    UNION
    
    SELECT DISTINCT
        MONTH(comp_fecha),
        YEAR(comp_fecha),
        DATEPART(QUARTER, comp_fecha)
    FROM FORIF_ISTAS.Compra
    WHERE comp_fecha IS NOT NULL;
        
END
GO
EXEC FORIF_ISTAS.Migracion_DimTiempo
GO


-- == Ubicacion == --

CREATE TABLE FORIF_ISTAS.DimUbicacion (
    ubic_id INT IDENTITY(1,1), -- PRIMARY KEY
    ubic_provincia VARCHAR(50),
    ubic_localidad VARCHAR(50)
)
GO
ALTER TABLE FORIF_ISTAS.DimUbicacion ADD CONSTRAINT PK_DimUbicacion PRIMARY KEY (ubic_id);

GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimUbicacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimUbicacion (
        ubic_provincia,
        ubic_localidad
    ) 
    SELECT DISTINCT
        prov_nombre,
        loca_nombre
    FROM FORIF_ISTAS.Provincia
    JOIN FORIF_ISTAS.Localidad ON loca_provincia = prov_codigo
    
END
GO
EXEC FORIF_ISTAS.Migracion_DimUbicacion
GO


-- == Rango Etario == --

CREATE TABLE FORIF_ISTAS.DimRangoEtario (
    rang_etario_id INT IDENTITY(1,1), -- PRIMARY KEY}
    rang_etario_inicio INT NOT NULL,
    rang_etario_fin INT NOT NULL
)

GO
ALTER TABLE FORIF_ISTAS.DimRangoEtario ADD CONSTRAINT PK_DimRangoEtario PRIMARY KEY (rang_etario_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimRangoEtario
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimRangoEtario (rang_etario_inicio, rang_etario_fin)
    VALUES 
        (0, 24),
        (25, 35),
        (36, 50),
        (51, 150)
END
GO
EXEC FORIF_ISTAS.Migracion_DimRangoEtario
GO

-- == Turno Ventas == --

CREATE TABLE FORIF_ISTAS.DimTurnoVentas (
    turn_id INT IDENTITY(1,1), -- PRIMARY KEY
    turn_hora_inicio TIME NOT NULL,
    turn_hora_fin TIME NOT NULL
)

GO
ALTER TABLE FORIF_ISTAS.DimTurnoVentas ADD CONSTRAINT PK_DimTurnoVentas PRIMARY KEY (turn_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimTurnoVentas
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FORIF_ISTAS.DimTurnoVentas (turn_hora_inicio, turn_hora_fin)
    VALUES 
        ('08:00', '13:59'),
        ('14:00', '20:00');
END
GO
EXEC FORIF_ISTAS.Migracion_DimTurnoVentas
GO
-- == Tipo Material == --

CREATE TABLE FORIF_ISTAS.DimTipoMaterial (
    tipo_material_id INT IDENTITY(1,1), -- PRIMARY KEY
    tipo_material_nombre VARCHAR(20) NOT NULL
)
GO
ALTER TABLE FORIF_ISTAS.DimTipoMaterial ADD CONSTRAINT PK_DimTipoMaterial PRIMARY KEY (tipo_material_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimTipoMaterial
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimTipoMaterial (
        tipo_material_nombre
    )
    
    SELECT DISTINCT 
        mate_tipo
    FROM FORIF_ISTAS.Material
    WHERE mate_tipo IS NOT NULL;

END
GO
EXEC FORIF_ISTAS.Migracion_DimTipoMaterial
GO

-- == Modelo Sillon == --

CREATE TABLE FORIF_ISTAS.DimModeloSillon (
    mode_sillon_id INT IDENTITY(1,1), -- PRIMARY KEY
    mode_sillon_nombre VARCHAR(255) NOT NULL
)
GO

ALTER TABLE FORIF_ISTAS.DimModeloSillon ADD CONSTRAINT PK_DimModeloSillon PRIMARY KEY (mode_sillon_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimModeloSillon
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimModeloSillon(
        mode_sillon_nombre
    )

    SELECT DISTINCT
        mode_descripcion
    FROM FORIF_ISTAS.Sillon
    JOIN FORIF_ISTAS.Modelo ON mode_code = sill_modelo 
    WHERE mode_descripcion IS NOT NULL
    
END
GO
EXEC FORIF_ISTAS.Migracion_DimModeloSillon
GO

-- == Estado Pedido == --

CREATE TABLE FORIF_ISTAS.DimEstadoPedido (
    esta_pedido_id INT IDENTITY(1,1), -- PRIMARY KEY
    esta_pedido_nombre VARCHAR(20) NOT NULL
)
GO

ALTER TABLE FORIF_ISTAS.DimEstadoPedido ADD CONSTRAINT PK_DimEstadoPedido PRIMARY KEY (esta_pedido_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimEstadoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimEstadoPedido (
        esta_pedido_nombre
    )
    SELECT DISTINCT 
        pedi_estado
    FROM FORIF_ISTAS.Pedido
    WHERE pedi_estado IS NOT NULL

END
GO
EXEC FORIF_ISTAS.Migracion_DimEstadoPedido
GO
 
-- == Sucursal == --
CREATE TABLE FORIF_ISTAS.DimSucursal (
    sucu_id INT IDENTITY(1,1), -- PRIMARY KEY
    sucu_ubicacion INT NOT NULL
)

