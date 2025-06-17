-- == TIEMPO == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.DimTiempo
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimTiempo (tiem_fecha, tiem_cuatri)

    SELECT DISTINCT
        fact_fecha_hora,
        DATEPART(QUARTER, fact_fecha_hora)
    
    FROM FORIF_ISTAS.Factura
    WHERE fact_fecha_hora IS NOT NULL

    UNION

    SELECT DISTINCT 
        pedi_fecha_hora,
        DATEPART(QUARTER, pedi_fecha_hora)
    
    FROM FORIF_ISTAS.Pedido
    WHERE pedi_fecha_hora IS NOT NULL

    UNION
    
    SELECT DISTINCT
        envi_fecha_programada,
        DATEPART(QUARTER, envi_fecha_programada)
    FROM FORIF_ISTAS.Envio
    WHERE envi_fecha_programada IS NOT NULL;
        
END
GO

ALTER TABLE DimTiempo ADD CONSTRAINT PK_DimTiempo PRIMARY KEY (tiem_id);


-- == UBICACION == --
CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimUbicacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DimUbicacion (
        ubic_provincia,
        ubic_localidad
    ) 
    SELECT DISTINCT
        prov_nombre,
        loca_nombre
    FROM PROVINCIA
    JOIN LOCALIDAD ON loca_provincia = prov_codigo
    
END
GO

ALTER TABLE DimUbicacion ADD CONSTRAINT PK_DimUbicacion PRIMARY KEY (ubic_id);

-- == RANGO ETARIO == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimRangoEtario
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimRangoEtario (rang_etario_inicio, rang_etario_fin)
    VALUES 
        (0, 24),
        (25, 35),
        (36, 50),
        (51, 150); 
END
GO


ALTER TABLE DimRangoEtario
ADD CONSTRAINT PK_DimRangoEtario PRIMARY KEY (rang_etario_id);


-- == TURNO VENTAS == --
CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimTurnoVentas
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FORIF_ISTAS.DimTurno (turn_hora_inicio, turn_hora_fin)
    VALUES 
        ('08:00', '14:00'),
        ('14:00', '20:00');
END
GO

ALTER TABLE DimTurnoVentas ADD CONSTRAINT PK_DimTurnoVentas PRIMARY KEY (turn_id);

-- == TIPO MATERIAL == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimTipoMaterial
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimTipoMaterial (
        tipo_material_id,
        tipo_material_nombre
    )
    
    SELECT DISTINCT (
        mate_tipo
    )
    FROM Material
    WHERE mate_tipo IS NOT NULL;

END
GO

ALTER TABLE DimTipoMaterial ADD CONSTRAINT PK_DimTipoMaterial PRIMARY KEY (tipo_material_id);

-- == MODELO SILLON == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimModeloSillon
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimModeloSillon(
        mode_sillon_nombre
    )

    SELECT DISTINCT (
        mode_descripcion
    )
    FROM Sillon
    JOIN Modelo ON mode_codigo = sill_modelo 
    WHERE mode_descripcion IS NOT NULL
    

END
GO

ALTER TABLE DimModeloSillon ADD CONSTRAINT PK_DimModeloSillon PRIMARY KEY (mode_sillon_id);


-- == ESTADO PEDIDO == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_DimEstadoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.DimEstadoPedido (
        esta_pedido_nombre
    )
    SELECT DISTINCT (
        pedi_estado
    )
    FROM Pedido
    WHERE pedi_estado IS NOT NULL

END
GO

ALTER TABLE DimEstadoPedido ADD CONSTRAINT PK_DimEstadoPedido PRIMARY KEY (esta_pedido_id);
GO

-- == HECHO VENTA == --

ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_rango_estario FOREIGN KEY (hecho_venta_rango_etario) REFERENCES FORIF_ISTAS.PK_DimRangoEtario (rang_etario_id)
GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_tiempo FOREIGN KEY (hecho_venta_tiempo) REFERENCES FORIF_ISTAS.DimTiempo (tiem_id)
GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_sucursal FOREIGN KEY (hecho_venta_ubicacion) REFERENCES FORIF_ISTAS.DimUbicacion (ubic_id)
GO
ALTER TABLE FORIF_ISTAS.HechoVenta ADD CONSTRAINT FK_hecho_venta_sillon FOREIGN KEY (hecho_venta_sillon) REFERENCES FORIF_ISTAS.DimModeloSillon (mode_sillon_id)
GO

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoVenta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoVenta (
        hecho_venta_rango_etario,
        hecho_venta_tiempo,
        hecho_venta_sucursal,
        hecho_venta_sillon,
        hecho_venta_total,
        hecho_venta_ubicacion,
        hecho_venta_numero
    )
    SELECT DISTINCT
        rang_etario_id,
        tiem_id,
        fact_sucursal,
        item_f_sillon,
        fact_total,
        ubic_id,
        fact_numeroo
    FROM Factura
    JOIN Item_Compra ON item_c_numero = fact_numero
    JOIN Cliente ON fact_cliente = clie_numero
    JOIN Direccion ON clie_direccion = dire_codigo
    JOIN Localidad ON dire_localidad = loca_codigo
    JOIN Provincia ON loca_provincia = prov_codigo
    JOIN DimUbicacion ON ubic_provincia = prov_nombre AND ubic_localidad = loca_nombre
    JOIN DimTiempo ON tiem_fecha = fact_fecha_hora
    JOIN DimRangoEtario ON rang_etario_inicio <= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora) AND rang_etario_fin >= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora)
END
GO



-- == HECHO COMPRA == --
CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoCompra
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoCompra (
        hecho_compra_tiempo,
        hecho_compra_ubicacion, -- ToDo
        hecho_compra_tipo_material,
        hecho_compra_total
    )
    
    SELECT DISTINCT
        tiem_id,
        ubic_id,
        tipo_material_id,
        SUM(ISNULL(comp_total, 0))
    FROM Compra
    JOIN Sucursal ON comp_sucursal = sucu_numero
    JOIN Direccion ON dire_codigo = sucu_direccion
    JOIN Localidad ON dire_localidad = loca_codigo
    JOIN Provincia ON loca_provincia = prov_codigo
    JOIN DimUbicacion ON ubic_localidad = loca_nombre AND ubic_provincia = prov_nombre
    JOIN Item_Compra ON comp_numero = item_c_numero
    JOIN Material ON item_c_material = mate_codigo
    JOIN DimTiempo ON tiem_fecha = comp_fecha
    JOIN DimTipoMaterial ON tipo_material_nombre = mate_tipo
    GROUP BY tiem_id, ubic_id, tipo_material_id

END
GO

ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_tiempo FOREIGN KEY (hecho_compra_tiempo) REFERENCES FORIF_ISTAS.DimTiempo
GO
ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_sucursal FOREIGN KEY (hecho_compra_ubicacion) REFERENCES FORIF_ISTAS.DimUbicacion
GO
ALTER TABLE FORIF_ISTAS.HechoCompra ADD CONSTRAINT FK_hecho_compra_tipo_material FOREIGN KEY (hecho_compra_tipo_material) REFERENCES FORIF_ISTAS.DimTipoMaterial
GO

-- == HECHO ENVIO == --

CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoEnvio
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoEnvio (
        hecho_envio_tiempo,
        hecho_envio_ubicacion,
        hecho_envio_porcentaje
    )
    
    SELECT DISTINCT
        tiem_id,
        ubic_id,
        COUNT(CASE WHEN envi_fecha_entrega = envi_fecha_programada THEN 1 END) * 100.0 / COUNT(*)

    FROM Envio 
    JOIN Factura ON fact_envio = envi_numero -- A chequear
    JOIN Cliente ON  fact_cliente = clie_codigo
    JOIN Direccion ON clie_direccion =  dire_codigo
    JOIN Localidad ON dire_localidad = loca_codigo
    JOIN Provincia ON loca_provincia = prov_codigo
    JOIN DimTiempo ON tiem_fecha = envi_fecha_programada
    JOIN DimUbicacion ON ubic_provincia = prov_nombre and ubic_localidad = loca_nombreac
    GROUP BY tiem_id, ubic_id -- A chequear
 
END
GO 

ALTER TABLE FORIF_ISTAS.HechoEnvio ADD CONSTRAINT FK_hecho_compra_tiempo FOREIGN KEY (hecho_compra_tiempo) REFERENCES FORIF_ISTAS.DimTiempo
GO
ALTER TABLE FORIF_ISTAS.HechoEnvio ADD CONSTRAINT FK_hecho_compra_t FOREIGN KEY (hecho_compra_tiempo) REFERENCES FORIF_ISTAS.DimTiempo
GO



CREATE ALTER PROCEDURE FORIF_ISTAS.Migracion_HechoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoPedido (
        hecho_pedido_estado,
        hecho_pedido_sucursal,
        hecho_pedido_turno,
        hecho_pedido_tiempo,
        hecho_pedido_numero
    )
    
    SELECT DISTINCT (
        esta_pedido_id,
        pedi_sucursal,
        turn_id,
        tiem_id,
        COUNT(*)
    )
    FROM Pedido
    JOIN DimTurnoVentas ON turn_hora_inicio <= pedi_fecha_hora AND turn_hora_fin > pedi_fecha_hora
    JOIN DimEstadoPedido ON pedi_estado = esta_pedido_nombre
    JOIN DimTiempo ON pedi_fecha_hora = tiem_fecha
    GROUP BY esta_pedido_id, pedi_sucursal, turn_id, tiem_id -- A chequear
    
END






    
    