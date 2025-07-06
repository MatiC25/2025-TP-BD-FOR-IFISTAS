--- == LEO == --
-- -- == Vista Ganancias == --
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

-- -- == Vista Facturación Promedio Mensual == --
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

-- -- == Vista Rendimiento de Modelos == --
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

--- == MATI == -- 
-- == Vista 4,5,6 == --
/*
4. VolumenDePedidos: Cantidad de pedidos registrados por turno, por sucursal
según el mes del año 
*/

CREATE VIEW FORIF_ISTAS.VolumenDePedidos AS
SELECT turn_id, ubic_id, tiem_mes as Mes, tiem_año as Año, COUNT(*) as Volumen
FROM FORIF_ISTAS.HechoPedido
JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
JOIN FORIF_ISTAS.DimTurnoVentas ON hecho_pedido_turno = turn_id
JOIN FORIF_ISTAS.DimUbicacion ON hecho_pedido_ubicacion = ubic_id
GROUP BY turn_id, ubic_id, tiem_mes, tiem_año
GO

/*
5. ConversionDePedidos: Porcentaje de pedidos según estado, por cuatrimestre y sucursal
*/

CREATE VIEW FORIF_ISTAS.ConversionDePedidos AS
SELECT 
    CAST(COUNT(*) AS FLOAT) / 
   (SELECT COUNT(*)
    FROM FORIF_ISTAS.HechoPedido                
    JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
    WHERE hecho_pedido_ubicacion = p.hecho_pedido_ubicacion 
        AND tiem_cuatrimestre = t.tiem_cuatrimestre
    GROUP BY hecho_pedido_ubicacion, tiem_cuatrimestre) * 100, 
    p.hecho_pedido_ubicacion as Porcentaje, 
    esta_pedido_nombre, 
    t.tiem_cuatrimestre
FROM FORIF_ISTAS.HechoPedido p
JOIN FORIF_ISTAS.DimEstadoPedido e ON hecho_pedido_estado = esta_pedido_id
JOIN FORIF_ISTAS.DimTiempo t ON hecho_pedido_tiempo = tiem_id
GROUP BY hecho_pedido_ubicacion, esta_pedido_nombre, tiem_cuatrimestre
GO
/*
6. TiempoPromedioDeFabricacion: tiempo promedio que tarda cada sucursal entre que se registra un pedido
y registra la factura para el mismo. Por cuatrimestre 
*/

CREATE VIEW FORIF_ISTAS.TiempoPromedioDeFabricacion AS
SELECT 
    CAST(SUM(hecho_venta_tiempo_promedio * hecho_venta_cantidad) AS FLOAT) / SUM(hecho_venta_cantidad) as cant_dias_promedia,
    hecho_venta_ubicacion,
    tiem_cuatrimestre
FROM FORIF_ISTAS.HechoVenta
JOIN FORIF_ISTAS.DimTiempo ON hecho_venta_tiempo = tiem_id
GROUP BY hecho_venta_ubicacion, tiem_cuatrimestre
GO


--- == NICO == -- 
 -- == vista 7 == --
-- Promedio de Compras: importe promedio de compras por mes
CREATE OR ALTER VIEW FORIF_ISTAS.vw_promedio_compras_mes AS
SELECT 
    tiem_mes AS mes,
    SUM(hecho_compra_precio_material) / SUM(hecho_compra_cantidad)
FROM FORIF_ISTAS.HechoCompra
JOIN FORIF_ISTAS.DimTiempo ON HechoCompra.hecho_compra_tiempo = DimTiempo.tiem_id
GROUP BY tiem_mes
GO


-- == VISTA 9 == --
-- Porcentaje de los cumplimientos de envios en los tiempos programados por mes 
-- Se calcula teniendo en cuenta los envios cumplidos en fecha sobnre el total de envios para el periodo

CREATE VIEW FORIF_ISTAS.vw_porcentaje_envios_cumplidos AS
SELECT 
    tiem_mes AS mes,
    CAST(SUM(hecho_envio_cantidad_en_forma) AS FLOAT) / SUM(hecho_envio_cantidad_total) * 100 AS porcentaje_cumplidos
FROM FORIF_ISTAS.HechoEnvio
JOIN FORIF_ISTAS.DimTiempo ON HechoEnvio.hecho_envio_tiempo = DimTiempo.tiem_id
GROUP BY tiem_mes
GO


--- == FACU == --
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

-- == vista 10 == --
-- localidades que pagan mayor costo de envio. Las 3 localidades (tomando la
-- localidad del cliente) con mayor promedio de costo de envio (total).

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



