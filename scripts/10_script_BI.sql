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


IF OBJECT_ID('FORIF_ISTAS.Ganancias') IS NOT NULL DROP VIEW FORIF_ISTAS.Ganancias;
IF OBJECT_ID('FORIF_ISTAS.Factura_Promedio') IS NOT NULL DROP VIEW FORIF_ISTAS.Factura_Promedio;
IF OBJECT_ID('FORIF_ISTAS.VistaTopModelosPorSegmento') IS NOT NULL DROP VIEW FORIF_ISTAS.VistaTopModelosPorSegmento;
IF OBJECT_ID('FORIF_ISTAS.VolumenDePedidos') IS NOT NULL DROP VIEW FORIF_ISTAS.VolumenDePedidos;
IF OBJECT_ID('FORIF_ISTAS.ConversionDePedidos') IS NOT NULL DROP VIEW FORIF_ISTAS.ConversionDePedidos;
IF OBJECT_ID('FORIF_ISTAS.TiempoPromedioDeFabricacion') IS NOT NULL DROP VIEW FORIF_ISTAS.TiempoPromedioDeFabricacion;
IF OBJECT_ID('FORIF_ISTAS.vw_promedio_compras_mes') IS NOT NULL DROP VIEW FORIF_ISTAS.vw_promedio_compras_mes;
IF OBJECT_ID('FORIF_ISTAS.compras_por_tipo') IS NOT NULL DROP VIEW FORIF_ISTAS.compras_por_tipo;
IF OBJECT_ID('FORIF_ISTAS.vw_porcentaje_envios_cumplidos') IS NOT NULL DROP VIEW FORIF_ISTAS.vw_porcentaje_envios_cumplidos;
IF OBJECT_ID('FORIF_ISTAS.mayor_costo_envio') IS NOT NULL DROP VIEW FORIF_ISTAS.mayor_costo_envio;


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
    hecho_venta_sillon_modelo INT NOT NULL, -- FOREIGN KEY REFERENCES DimModeloSillon(mode_sillon_id)
    hecho_venta_total DECIMAL(10, 2) NOT NULL,
    hecho_venta_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_venta_ubicacion INT NOT NULL, -- FOREIGN KEY REFERENCES DimUbicacion(ubicacion_id)
    hecho_venta_rango_etario INT NOT NULL, -- FOREIGN KEY REFERENCES DimRangoEtario(rang_etario_id)
    hecho_venta_tiempo_promedio INT NOT NULL,
    hecho_venta_cantidad INT NOT NULL
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
        hecho_venta_cantidad,
        hecho_venta_tiempo_promedio
    )
        SELECT
			rang_etario_id,
			tiem_id,
			mode_sillon_id, 
			ISNULL(SUM(item_f_cantidad * item_f_precio), 0) AS total_factura,
			ubic_id,
			COUNT(distinct pedi_numero) AS cant_pedidos,
            AVG(DATEDIFF(DAY, pedi_fecha_hora, fact_fecha_hora))
			--SUM(DATEDIFF(DAY, pedi_fecha_hora, fact_fecha_hora)) / COUNT(*)
		FROM FORIF_ISTAS.Factura
		RIGHT JOIN FORIF_ISTAS.DimTiempo ON tiem_año = YEAR(fact_fecha_hora) AND tiem_mes = MONTH(fact_fecha_hora)
		JOIN FORIF_ISTAS.Item_Factura ON item_f_numero_factura = fact_numero
		JOIN FORIF_ISTAS.Sillon ON item_f_sillon = sill_codigo
		JOIN FORIF_ISTAS.Modelo ON mode_code = sill_modelo
		JOIN FORIF_ISTAS.Cliente ON fact_cliente = clie_codigo
		JOIN FORIF_ISTAS.Sucursal ON sucu_numero = fact_sucursal
		JOIN FORIF_ISTAS.Direccion ON sucu_direccion = dire_codigo
		JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
		JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
		JOIN FORIF_ISTAS.DimUbicacion ON ubic_provincia = prov_nombre AND ubic_localidad = loca_nombre
		JOIN FORIF_ISTAS.DimRangoEtario ON rang_etario_inicio <= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora) AND rang_etario_fin >= DATEDIFF(YEAR, clie_fecha_nacimiento, fact_fecha_hora)
		JOIN FORIF_ISTAS.DimModeloSillon ON mode_sillon_nombre = mode_descripcion
		JOIN FORIF_ISTAS.pedido on pedi_numero = item_f_numero_pedido
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
    hecho_compra_cantidad INT
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
        hecho_compra_precio_material,
        hecho_compra_cantidad
    )
    
    SELECT DISTINCT 
        tiem_id,
        ubic_id,
        tipo_material_id,
        ISNULL(SUM(item_c_cantidad * item_c_precio), 0),
        COUNT(*)
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
    GROUP BY tiem_id, ubic_id, tipo_material_id
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
    hecho_pedido_ubicacion INT NOT NULL,
    hecho_pedido_cantidad INT NOT NULL
)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_estado FOREIGN KEY (hecho_pedido_estado) REFERENCES FORIF_ISTAS.DimEstadoPedido (esta_pedido_id)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_tiempo FOREIGN KEY (hecho_pedido_tiempo) REFERENCES FORIF_ISTAS.DimTiempo (tiem_id)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_turno FOREIGN KEY (hecho_pedido_turno) REFERENCES FORIF_ISTAS.DimTurnoVentas (turn_id)
GO
ALTER TABLE FORIF_ISTAS.HechoPedido ADD CONSTRAINT FK_hecho_pedido_ubicacion FOREIGN KEY (hecho_pedido_ubicacion) REFERENCES FORIF_ISTAS.DimUbicacion (ubic_id)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_HechoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.HechoPedido (
        hecho_pedido_estado,
        hecho_pedido_turno,
        hecho_pedido_tiempo,
        hecho_pedido_ubicacion,
        hecho_pedido_cantidad
    )
    SELECT DISTINCT 
        esta_pedido_id,
        turn_id,
        tiem_id,
        ubic_id,    
        COUNT(*) as cantidad
    FROM FORIF_ISTAS.Pedido
    JOIN FORIF_ISTAS.Sucursal ON sucu_numero = pedi_sucursal
    JOIN FORIF_ISTAS.Direccion ON dire_codigo = sucu_direccion
    JOIN FORIF_ISTAS.Localidad ON dire_localidad = loca_codigo
    JOIN FORIF_ISTAS.Provincia ON loca_provincia = prov_codigo
    JOIN FORIF_ISTAS.DimUbicacion ON ubic_localidad = loca_nombre AND ubic_provincia = prov_nombre
    JOIN FORIF_ISTAS.DimTurnoVentas ON CAST(pedi_fecha_hora AS TIME) >= turn_hora_inicio AND CAST(pedi_fecha_hora AS TIME) <= turn_hora_fin
    JOIN FORIF_ISTAS.DimEstadoPedido ON pedi_estado = esta_pedido_nombre
    JOIN FORIF_ISTAS.DimTiempo ON year(pedi_fecha_hora) = tiem_año AND month(pedi_fecha_hora) = tiem_mes
    GROUP BY esta_pedido_id,
             turn_id,
             tiem_id,
             ubic_id
             
END
GO
EXEC FORIF_ISTAS.Migracion_HechoPedido
GO

-- -- == Vista 1: Ganancias == --
CREATE VIEW FORIF_ISTAS.Ganancias
AS
SELECT T.tiem_mes AS Mes,
       V.hecho_venta_ubicacion AS Direccion_Sucursal,
       SUM(V.hecho_venta_total) - SUM(ISNULL(C.hecho_compra_precio_material, 0)) AS Total_Ganancia
FROM FORIF_ISTAS.HechoVenta V
LEFT JOIN FORIF_ISTAS.HechoCompra C ON V.hecho_venta_ubicacion = C.hecho_compra_ubicacion
LEFT JOIN FORIF_ISTAS.DimTiempo T ON V.hecho_venta_tiempo = T.tiem_id
LEFT JOIN FORIF_ISTAS.DimTiempo T2 ON C.hecho_compra_tiempo = T2.tiem_id
LEFT JOIN FORIF_ISTAS.DimUbicacion U ON V.hecho_venta_ubicacion = U.ubic_id 
	AND T.tiem_mes = T2.tiem_mes
GROUP BY T.tiem_mes, V.hecho_venta_ubicacion
GO

-- -- == Vista 2: Facturación Promedio Mensual == --
CREATE VIEW FORIF_ISTAS.Factura_Promedio
AS
SELECT tiem_año AS Año,
	   T.tiem_cuatrimestre AS Cuatrimestre, 
	   U.ubic_provincia AS Provincia,
	   SUM(V.hecho_venta_total) / SUM(V.hecho_venta_cantidad) AS Promedio
FROM FORIF_ISTAS.HechoVenta V
JOIN FORIF_ISTAS.DimUbicacion U ON U.ubic_id = V.hecho_venta_ubicacion
JOIN FORIF_ISTAS.DimTiempo T ON T.tiem_id = V.hecho_venta_tiempo
GROUP BY T.tiem_cuatrimestre, tiem_año, U.ubic_provincia
GO

-- -- == Vista 3: Rendimiento de Modelos == --
CREATE VIEW FORIF_ISTAS.VistaTopModelosPorSegmento AS
WITH VentasConRanking AS (
    SELECT 
        T.tiem_año AS Año,
        T.tiem_cuatrimestre AS Cuatrimestre,
        U.ubic_localidad AS Localidad,
        V.hecho_venta_rango_etario AS Rango_Etario,
        M.mode_sillon_nombre AS Modelo,
        SUM(V.hecho_venta_cantidad) AS TotalVentas,
        ROW_NUMBER() OVER (
            PARTITION BY T.tiem_año, T.tiem_cuatrimestre, U.ubic_localidad, V.hecho_venta_rango_etario
            ORDER BY SUM(V.hecho_venta_cantidad) DESC
        ) AS PosicionRanking
    FROM FORIF_ISTAS.HechoVenta V
    JOIN FORIF_ISTAS.DimModeloSillon M ON M.mode_sillon_id = V.hecho_venta_sillon_modelo
    JOIN FORIF_ISTAS.DimTiempo T ON T.tiem_id = V.hecho_venta_tiempo
    JOIN FORIF_ISTAS.DimUbicacion U ON U.ubic_id = V.hecho_venta_ubicacion
    GROUP BY 
        T.tiem_año, T.tiem_cuatrimestre, U.ubic_localidad, 
        V.hecho_venta_rango_etario, M.mode_sillon_nombre
)
SELECT *
FROM VentasConRanking
WHERE PosicionRanking <= 3
GO

-- == Vista 4: VolumenDePedidos== --

CREATE VIEW FORIF_ISTAS.VolumenDePedidos AS
SELECT turn_id, ubic_id, tiem_mes as Mes, tiem_año as Año, COUNT(*) as Volumen
FROM FORIF_ISTAS.HechoPedido
JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
JOIN FORIF_ISTAS.DimTurnoVentas ON hecho_pedido_turno = turn_id
JOIN FORIF_ISTAS.DimUbicacion ON hecho_pedido_ubicacion = ubic_id
GROUP BY turn_id, ubic_id, tiem_mes, tiem_año
GO

-- == Vista 5: ConversionDePedidos == --

CREATE VIEW FORIF_ISTAS.ConversionDePedidos AS
SELECT 
    CAST(COUNT(*) AS FLOAT) / 
   (SELECT COUNT(*)
    FROM FORIF_ISTAS.HechoPedido                
    JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
    WHERE hecho_pedido_ubicacion = p.hecho_pedido_ubicacion 
        AND tiem_cuatrimestre = t.tiem_cuatrimestre
    GROUP BY hecho_pedido_ubicacion, tiem_cuatrimestre) * 100 as Porcentaje, 
    p.hecho_pedido_ubicacion as Sucursal, 
    esta_pedido_nombre, 
    t.tiem_cuatrimestre
FROM FORIF_ISTAS.HechoPedido p
JOIN FORIF_ISTAS.DimEstadoPedido e ON hecho_pedido_estado = esta_pedido_id
JOIN FORIF_ISTAS.DimTiempo t ON hecho_pedido_tiempo = tiem_id
GROUP BY hecho_pedido_ubicacion, esta_pedido_nombre, tiem_cuatrimestre
GO

-- == Vista 6: TiempoPromedioDeFabricacion == --

CREATE VIEW FORIF_ISTAS.TiempoPromedioDeFabricacion AS
SELECT 
    CAST(SUM(hecho_venta_tiempo_promedio * hecho_venta_cantidad) AS FLOAT) / SUM(hecho_venta_cantidad) as cant_dias_promedia,
    hecho_venta_ubicacion,
    tiem_cuatrimestre
FROM FORIF_ISTAS.HechoVenta
JOIN FORIF_ISTAS.DimTiempo ON hecho_venta_tiempo = tiem_id
GROUP BY hecho_venta_ubicacion, tiem_cuatrimestre
GO


 -- == VISTA 7: Promedio de Compras == --

CREATE OR ALTER VIEW FORIF_ISTAS.vw_promedio_compras_mes AS
SELECT 
    tiem_mes AS Mes,
    SUM(hecho_compra_precio_material) / SUM(hecho_compra_cantidad) as Promedio
FROM FORIF_ISTAS.HechoCompra
JOIN FORIF_ISTAS.DimTiempo ON HechoCompra.hecho_compra_tiempo = DimTiempo.tiem_id
GROUP BY tiem_mes
GO


-- == VISTA 8 == --
-- Compras por  Tipo de Material. Importe total gastado por tipo de material, sucursal y cuatrimestre
CREATE VIEW FORIF_ISTAS.compras_por_tipo
AS
SELECT 
    tipo_material_nombre AS TipoMaterial,
    hecho_compra_ubicacion AS Sucursal,
    tiem_cuatrimestre AS Cuatrimestre,
    SUM(hecho_compra_precio_material) AS ImporteTotal
FROM FORIF_ISTAS.HechoCompra
JOIN FORIF_ISTAS.DimTiempo ON hecho_compra_tiempo = tiem_id
JOIN FORIF_ISTAS.DimUbicacion ON hecho_compra_ubicacion = ubic_id
JOIN FORIF_ISTAS.DimTipoMaterial ON hecho_compra_tipo_material = tipo_material_id
GROUP BY tipo_material_nombre , hecho_compra_ubicacion, tiem_cuatrimestre
GO

-- == VISTA 9: PorcentajeEnviosCumplidos == --


CREATE VIEW FORIF_ISTAS.vw_porcentaje_envios_cumplidos AS
SELECT 
    tiem_mes AS mes,
    CAST(SUM(hecho_envio_cantidad_en_forma) AS FLOAT) / SUM(hecho_envio_cantidad_total) * 100 AS porcentaje_cumplidos
FROM FORIF_ISTAS.HechoEnvio
JOIN FORIF_ISTAS.DimTiempo ON HechoEnvio.hecho_envio_tiempo = DimTiempo.tiem_id
GROUP BY tiem_mes
GO


-- == VISTA 10 Localidades == --

CREATE VIEW FORIF_ISTAS.mayor_costo_envio
AS
SELECT TOP 3
	ubic_localidad,
	AVG(hecho_envio_cantidad_en_forma) AS promedio_Costo_Envio
FROM FORIF_ISTAS.HechoEnvio
JOIN FORIF_ISTAS.DimTiempo ON hecho_envio_tiempo = tiem_id
JOIN FORIF_ISTAS.DimUbicacion ON hecho_envio_ubicacion = ubic_id
GROUP BY ubic_localidad
ORDER BY AVG(hecho_envio_cantidad_en_forma) DESC
GO





