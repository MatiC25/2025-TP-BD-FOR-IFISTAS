USE GD1C2025
GO 

IF OBJECT_ID('FORIF_ISTAS.HechoPedido') IS NOT NULL DROP TABLE FORIF_ISTAS.HechoPedido;
IF OBJECT_ID('FORIF_ISTAS.HechoEnvio') IS NOT NULL DROP TABLE FORIF_ISTAS.HechoEnvio;
IF OBJECT_ID('FORIF_ISTAS.HechoCompra') IS NOT NULL DROP TABLE FORIF_ISTAS.HechoCompra;
IF OBJECT_ID('FORIF_ISTAS.HechoVenta') IS NOT NULL DROP TABLE FORIF_ISTAS.HechoVenta;
IF OBJECT_ID('FORIF_ISTAS.DimEstadoPedido') IS NOT NULL DROP TABLE FORIF_ISTAS.DimEstadoPedido;
IF OBJECT_ID('FORIF_ISTAS.DimModeloSillon') IS NOT NULL DROP TABLE FORIF_ISTAS.DimModeloSillon;
IF OBJECT_ID('FORIF_ISTAS.DimTipoMaterial') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTipoMaterial;
IF OBJECT_ID('FORIF_ISTAS.DimTurnoVentas') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTurnoVentas;
IF OBJECT_ID('FORIF_ISTAS.DimRangoEtario') IS NOT NULL DROP TABLE FORIF_ISTAS.DimRangoEtario;
IF OBJECT_ID('FORIF_ISTAS.DimUbicacion') IS NOT NULL DROP TABLE FORIF_ISTAS.DimUbicacion;
IF OBJECT_ID('FORIF_ISTAS.DimTiempo') IS NOT NULL DROP TABLE FORIF_ISTAS.DimTiempo;

IF OBJECT_ID('FORIF_ISTAS.Migracion_HechoPedido') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_HechoPedido;
IF OBJECT_ID('FORIF_ISTAS.Migracion_HechoEnvio') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_HechoEnvio;
IF OBJECT_ID('FORIF_ISTAS.Migracion_HechoCompra') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_HechoCompra;
IF OBJECT_ID('FORIF_ISTAS.Migracion_HechoVenta') IS NOT NULL DROP PROCEDURE FORIF_ISTAS.Migracion_HechoVenta;
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
    tiem_cuatrimestre INT NOT NULL,
    tiem_año INT NOT NULL
)
GO
ALTER TABLE FORIF_ISTAS.DimTiempo ADD CONSTRAINT PK_DimTiempo PRIMARY KEY (tiem_id);
GO
CREATE PROCEDURE FORIF_ISTAS.Migracion_DimTiempo
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimTiempo (tiem_mes, tiem_cuatrimestre, tiem_año)

    SELECT DISTINCT
        DATEPART(MONTH, fact_fecha_hora),
        ((MONTH(fact_fecha_hora) - 1) / 4) + 1,
        DATEPART(YEAR, fact_fecha_hora)
    
    FROM FORIF_ISTAS.Factura
    WHERE fact_fecha_hora IS NOT NULL

    UNION

    SELECT DISTINCT 
        DATEPART(MONTH, pedi_fecha_hora),
        ((MONTH(pedi_fecha_hora) - 1) / 4) + 1,
        DATEPART(YEAR, pedi_fecha_hora)
    
    FROM FORIF_ISTAS.Pedido
    WHERE pedi_fecha_hora IS NOT NULL

    UNION
    
    SELECT DISTINCT
        DATEPART(MONTH, envi_fecha_programada),
        ((MONTH(envi_fecha_programada) - 1) / 4) + 1,
        DATEPART(YEAR, envi_fecha_programada)
    FROM FORIF_ISTAS.Envio
    WHERE envi_fecha_programada IS NOT NULL

    UNION
    
    SELECT DISTINCT
        DATEPART(MONTH, envi_fecha_entrega),
        ((MONTH(envi_fecha_entrega) - 1) / 4) + 1,
        DATEPART(YEAR, envi_fecha_entrega)
    FROM FORIF_ISTAS.Envio
    WHERE envi_fecha_entrega IS NOT NULL

    UNION
    
    SELECT DISTINCT
        DATEPART(MONTH, comp_fecha),
        ((MONTH(comp_fecha) - 1) / 4) + 1,
        DATEPART(YEAR, comp_fecha)
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


GO


-- == Hecho Venta == --

CREATE TABLE FORIF_ISTAS.HechoVenta (
    hecho_venta_cantidad INT NOT NULL,
    hecho_venta_sillon_modelo INT NOT NULL, -- FOREIGN KEY REFERENCES DimModeloSillon(mode_sillon_id)
    hecho_venta_total DECIMAL(10, 2) NOT NULL,
    hecho_venta_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_venta_ubicacion INT NOT NULL, -- FOREIGN KEY REFERENCES DimUbicacion(ubicacion_id)
    hecho_venta_rango_etario INT NOT NULL -- FOREIGN KEY REFERENCES DimRangoEtario(rang_etario_id)
) 

GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_rango_estario FOREIGN KEY (hecho_venta_rango_etario) REFERENCES FORIF_ISTAS.DimRangoEtario (rang_etario_id)
GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_tiempo FOREIGN KEY (hecho_venta_tiempo) REFERENCES FORIF_ISTAS.DimTiempo (tiem_id)
GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_sillon_modelo FOREIGN KEY (hecho_venta_sillon_modelo) REFERENCES FORIF_ISTAS.DimModeloSillon (mode_sillon_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoVenta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoVenta (
        hecho_venta_rango_etario,
        hecho_venta_tiempo,
        hecho_venta_sillon_modelo,
        hecho_venta_total,
        hecho_venta_ubicacion,
        hecho_venta_cantidad
    )
        SELECT
        rang_etario_id,
        tiem_id,
        mode_sillon_id, 
        SUM(ISNULL(fact_total, 0)) AS total_factura,
        ubic_id,
        COUNT(*) AS cant_facturas
    FROM FORIF_ISTAS.Factura
    JOIN FORIF_ISTAS.Item_Factura ON item_f_numero_factura = fact_numero
    JOIN FORIF_ISTAS.Sillon ON item_f_sillon = sill_codigo
    JOIN FORIF_ISTAS.Modelo ON mode_code = sill_modelo
    JOIN FORIF_ISTAS.Cliente ON fact_cliente = clie_codigo
    JOIN FORIF_ISTAS.Sucursal ON sucu_numero = fact_sucursal
    JOIN FORIF_ISTAS.Direccion ON sucu_direccion = dire_codigo
    JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
    JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
    JOIN FORIF_ISTAS.DimUbicacion ON ubic_provincia = prov_nombre AND ubic_localidad = loca_nombre
    JOIN FORIF_ISTAS.DimTiempo ON tiem_año = YEAR(fact_fecha_hora) AND tiem_mes = MONTH(fact_fecha_hora)
    JOIN FORIF_ISTAS.DimRangoEtario ON rang_etario_inicio <= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora) AND rang_etario_fin >= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora)
    JOIN FORIF_ISTAS.DimModeloSillon ON mode_sillon_nombre = mode_descripcion
    GROUP BY rang_etario_id,
             tiem_id,
             mode_sillon_id, 
             ubic_id

END
GO
EXEC FORIF_ISTAS.Migracion_HechoVenta
GO



-- == Hecho Compra == --

CREATE TABLE FORIF_ISTAS.HechoCompra (
    hecho_compra_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_compra_ubicacion INT NOT NULL,
    hecho_compra_tipo_material INT NOT NULL, -- FOREIGN KEY REFERENCES DimTipoMaterial(tipo_material_id)
    hecho_compra_precio_material DECIMAL(10, 2) NOT NULL,
)
GO

ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_tiempo FOREIGN KEY (hecho_compra_tiempo) REFERENCES FORIF_ISTAS.DimTiempo
GO
ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_ubicacion FOREIGN KEY (hecho_compra_ubicacion) REFERENCES FORIF_ISTAS.DimUbicacion
GO
ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_tipo_material FOREIGN KEY (hecho_compra_tipo_material) REFERENCES FORIF_ISTAS.DimTipoMaterial
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoCompra
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoCompra (
        hecho_compra_tiempo,
        hecho_compra_ubicacion,
        hecho_compra_tipo_material,
        hecho_compra_precio_material
    )
    
    SELECT DISTINCT 
        tiem_id,
        ubic_id,
        tipo_material_id,
        mate_precio
    FROM FORIF_ISTAS.Compra
    JOIN FORIF_ISTAS.Sucursal ON comp_sucursal = sucu_numero
    JOIN FORIF_ISTAS.Direccion ON dire_codigo = sucu_direccion
    JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
    JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
    JOIN FORIF_ISTAS.DimUbicacion ON ubic_localidad = loca_nombre AND ubic_provincia = prov_nombre
    JOIN FORIF_ISTAS.Item_Compra ON comp_numero = item_c_numero
    JOIN FORIF_ISTAS.Material ON item_c_material = mate_codigo
    JOIN FORIF_ISTAS.DimTiempo ON tiem_año = YEAR(comp_fecha) AND tiem_mes = MONTH(comp_fecha)
    JOIN FORIF_ISTAS.DimTipoMaterial ON tipo_material_nombre = mate_tipo

END
GO
EXEC FORIF_ISTAS.Migracion_HechoCompra
GO


-- -- == Hecho Envio == --

CREATE TABLE FORIF_ISTAS.HechoEnvio (
    hecho_envio_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_envio_ubicacion INT NOT NULL, -- FOREIGN KEY REFERENCES DimUbicacion(ubicacion_id)
    hecho_envio_cantidad_total INT NOT NULL,
    hecho_envio_cantidad_en_forma INT NOT NULL
)

GO
ALTER TABLE FORIF_ISTAS.HechoEnvio ADD CONSTRAINT FK_hecho_envio_tiempo FOREIGN KEY (hecho_envio_tiempo) REFERENCES FORIF_ISTAS.DimTiempo (tiem_id)
GO
ALTER TABLE FORIF_ISTAS.HechoEnvio ADD CONSTRAINT FK_hecho_envio_ubicacion FOREIGN KEY (hecho_envio_ubicacion) REFERENCES FORIF_ISTAS.DimUbicacion (ubic_id)
GO


CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoEnvio
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoEnvio (
        hecho_envio_tiempo,
        hecho_envio_ubicacion,
        hecho_envio_cantidad_total,
        hecho_envio_cantidad_en_forma
    )
    
    SELECT DISTINCT
        t.tiem_id,
        u.ubic_id,
        COUNT(*) as cantTotal,
        ISNULL((SELECT COUNT(*) 
        FROM FORIF_ISTAS.Envio 
        JOIN FORIF_ISTAS.Factura ON fact_envio = envi_numero 
        JOIN FORIF_ISTAS.Cliente ON  fact_cliente = clie_codigo
        JOIN FORIF_ISTAS.Direccion ON clie_direccion =  dire_codigo
        JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
        JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
        JOIN FORIF_ISTAS.DimTiempo ON tiem_año = year(envi_fecha_programada) AND tiem_mes = month(envi_fecha_programada) 
                                    OR tiem_año = year(envi_fecha_entrega) AND tiem_mes = month(envi_fecha_entrega) 
        JOIN FORIF_ISTAS.DimUbicacion ON ubic_provincia = prov_nombre AND ubic_localidad = loca_nombre
        WHERE envi_fecha_entrega <= envi_fecha_programada AND tiem_id = t.tiem_id AND ubic_id = u.ubic_id
        GROUP BY tiem_id, ubic_id), 0) as cantEnForma
    FROM FORIF_ISTAS.Envio 
    JOIN FORIF_ISTAS.Factura ON fact_envio = envi_numero 
    JOIN FORIF_ISTAS.Cliente ON  fact_cliente = clie_codigo
    JOIN FORIF_ISTAS.Direccion ON clie_direccion =  dire_codigo
    JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
    JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
    JOIN FORIF_ISTAS.DimTiempo t ON (t.tiem_año = YEAR(envi_fecha_programada) AND t.tiem_mes = MONTH(envi_fecha_programada)) 
        OR (t.tiem_año = YEAR(envi_fecha_entrega) AND t.tiem_mes = MONTH(envi_fecha_entrega))
    JOIN FORIF_ISTAS.DimUbicacion u ON u.ubic_provincia = prov_nombre AND u.ubic_localidad = loca_nombre
    GROUP BY t.tiem_id, u.ubic_id
END
GO 
EXEC FORIF_ISTAS.Migracion_HechoEnvio
GO

-- -- == Hecho Pedido == --

CREATE TABLE FORIF_ISTAS.HechoPedido (
    hecho_pedido_estado INT NOT NULL, -- FOREIGN KEY REFERENCES DimEstadoPedido(esta_pedido_id)
    hecho_pedido_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_pedido_turno INT NOT NULL, -- FOREIGN KEY REFERENCES DimTurnoVentas(turn_id)
    hecho_pedido_cantidad INT NOT NULL
)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_estado FOREIGN KEY (hecho_pedido_estado) REFERENCES FORIF_ISTAS.DimEstadoPedido (esta_pedido_id)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_tiempo FOREIGN KEY (hecho_pedido_tiempo) REFERENCES FORIF_ISTAS.DimTiempo (tiem_id)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_turno FOREIGN KEY (hecho_pedido_turno) REFERENCES FORIF_ISTAS.DimTurnoVentas (turn_id)
GO


CREATE PROCEDURE FORIF_ISTAS.Migracion_HechoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoPedido (
        hecho_pedido_estado,
        hecho_pedido_turno,
        hecho_pedido_tiempo,
        hecho_pedido_cantidad
    )
    SELECT DISTINCT 
        esta_pedido_id,
        turn_id,
        tiem_id,    
        COUNT(*) as cantidad
    FROM FORIF_ISTAS.Pedido
    JOIN FORIF_ISTAS.DimTurnoVentas ON CAST(pedi_fecha_hora AS TIME) >= turn_hora_inicio AND CAST(pedi_fecha_hora AS TIME) <= turn_hora_fin
    JOIN FORIF_ISTAS.DimEstadoPedido ON pedi_estado = esta_pedido_nombre
    JOIN FORIF_ISTAS.DimTiempo ON year(pedi_fecha_hora) = tiem_año and month(pedi_fecha_hora) = tiem_mes
    GROUP BY esta_pedido_id,
             turn_id,
             tiem_id
END
GO
EXEC FORIF_ISTAS.Migracion_HechoPedido
GO

