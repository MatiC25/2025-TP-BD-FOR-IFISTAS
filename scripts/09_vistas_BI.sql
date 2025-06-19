--- == LEO == --
-- -- == Vista Ganancias == --
CREATE VIEW FORIF_ISTAS.Ganancias
AS
SELECT MONTH(T.tiem_fecha) AS Mes,
       V.hecho_venta_sucursal AS Sucursal,
       SUM(V.hecho_venta_total) AS Total_Ventas,
	   SUM(ISNULL(C.hecho_compra_precio_material, 0)) AS Total_Costos
FROM FORIF_ISTAS.HechoVenta V
JOIN FORIF_ISTAS.DimTiempo T ON V.hecho_venta_tiempo = T.tiem_id
LEFT JOIN FORIF_ISTAS.HechoCompra C ON V.hecho_venta_sucursal = C.hecho_compra_sucursal 
	AND MONTH(V.hecho_venta_tiempo) = MONTH(C.hecho_compra_tiempo)
GROUP BY MONTH(T.tiem_fecha),
         V.hecho_venta_sucursal
GO

-- -- == Vista Facturación Promedio Mensual == --
CREATE VIEW FORIF_ISTAS.Factura_Promedio
AS
SELECT YEAR(T.tiem_fecha) AS Año,
	   T.tiem_cuatri AS Cuatrimestre, 
	   U.ubic_localidad AS Localidad,
	   SUM(V.hecho_venta_total) / V.hecho_venta_cantidad AS Promedio
FROM FORIF_ISTAS.HechoVenta V
JOIN FORIF_ISTAS.DimUbicacion U ON U.ubic_id = V.hecho_venta_ubicacion
JOIN FORIF_ISTAS.DimTiempo T ON T.tiem_id = V.hecho_venta_tiempo
GROUP BY T.tiem_cuatri, YEAR(T.tiem_fecha), U.ubic_localidad, V.hecho_venta_cantidad

-- -- == Vista Rendimiento de Modelos == --
CREATE VIEW FORIF_ISTAS.Rendimiento_Modelos
AS
SELECT T.tiem_cuatri AS Cuatrimestre, 
	   YEAR(T.tiem_fecha) AS Año, 
	   U.ubic_localidad AS Localidad,  
	   v.hecho_venta_rango_etario AS Rango_Etario,
	   M.mode_sillon_nombre AS Modelo
FROM FORIF_ISTAS.HechoVenta V
JOIN FORIF_ISTAS.DimModeloSillon M ON M.mode_sillon_id = V.hecho_venta_sillon_modelo
JOIN FORIF_ISTAS.DimTiempo T ON T.tiem_id = V.hecho_venta_tiempo
JOIN FORIF_ISTAS.DimUbicacion U ON U.ubic_id = V.hecho_venta_ubicacion
WHERE M.mode_sillon_id IN (SELECT TOP 3 hecho_venta_sillon_modelo
						   FROM FORIF_ISTAS.HechoVenta V2
						   WHERE V2.hecho_venta_tiempo = t.tiem_id AND V2.hecho_venta_ubicacion = V.hecho_venta_ubicacion
						   GROUP BY hecho_venta_sillon_modelo
						   ORDER BY SUM(hecho_venta_cantidad) DESC)
GROUP BY T.tiem_cuatri, YEAR(T.tiem_fecha), U.ubic_localidad, v.hecho_venta_rango_etario, M.mode_sillon_nombre
GO

--- == MATI == -- 
-- == Vista 4,5,6 == --
/*
4. VolumenDePedidos: Cantidad de pedidos registrados por turno, por sucursal
según el mes del año 
*/

SELECT turn_id, hecho_pedido_sucursal, MONTH(tiem_fecha) as Mes, YEAR(tiem_fecha) as Año, COUNT(*) as Volumen
FROM FORIF_ISTAS.HechoPedido
JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
JOIN FORIF_ISTAS.DimTurnoVentas ON hecho_pedido_turno = turn_id
GROUP BY turn_id, hecho_pedido_sucursal, MONTH(tiem_fecha), YEAR(tiem_fecha)


/*
5. ConversionDePedidos: Porcentaje de pedidos según estado, por cuatrimestre y sucursal
*/

SELECT 
    CAST(COUNT() AS DECIMAL) / (SELECT COUNT()
                        FROM FORIF_ISTAS.HechoPedido                
                        JOIN FORIF_ISTAS.DimTiempo ON hecho_pedido_tiempo = tiem_id
                        WHERE hecho_pedido_sucursal = p.hecho_pedido_sucursal 
								AND tiem_cuatri = t.tiem_cuatri
                        GROUP BY hecho_pedido_sucursal, tiem_cuatri) * 100 AS Porcentaje, 
    p.hecho_pedido_sucursal, 
    esta_pedido_nombre, 
    t.tiem_cuatri
FROM FORIF_ISTAS.HechoPedido p
JOIN FORIF_ISTAS.DimEstadoPedido e ON hecho_pedido_estado = esta_pedido_id
JOIN FORIF_ISTAS.DimTiempo t ON hecho_pedido_tiempo = tiem_id
GROUP BY hecho_pedido_sucursal, esta_pedido_nombre, tiem_cuatri


/*
6. TiempoPromedioDeFabricacion: tiempo promedio que tarda cada sucursal entre que se registra un pedido
y registra la factura para el mismo. Por cuatrimestre 
*/

SELECT 
    ABS(AVG(DATEDIFF(DAY, hp.hecho_pedido_tiempo, hv.hecho_venta_tiempo))), 
    hv.hecho_venta_sucursal, 
    tp.tiem_cuatri
FROM FORIF_ISTAS.HechoVenta hv
JOIN FORIF_ISTAS.HechoPedido hp ON hv.hecho_venta_sucursal = hp.hecho_pedido_sucursal
JOIN FORIF_ISTAS.DimTiempo tv ON hv.hecho_venta_tiempo = tv.tiem_id
JOIN FORIF_ISTAS.DimTiempo tp ON hp.hecho_pedido_tiempo = tp.tiem_id and tv.tiem_cuatri = tp.tiem_cuatri
GROUP BY hv.hecho_venta_sucursal, tp.tiem_cuatri



--- == NICO == -- 

-- == vista 7 == --
-- Promedio de Compras: importe promedio de compras por mes
CREATE OR ALTER VIEW FORIF_ISTAS.mv_prom_compras_mes
(  
	anio, 
    mes, 
    suma_precio,
    cantidad
)
WITH SCHEMABINDING
AS
SELECT 
    YEAR(tiem_fecha) AS anio,
    MONTH(tiem_fecha) AS mes,
    SUM(hecho_compra_precio_material) AS suma_precio,
    COUNT_BIG(*) AS cantidad
FROM FORIF_ISTAS.HechoCompra
JOIN FORIF_ISTAS.DimTiempo ON FORIF_ISTAS.HechoCompra.hecho_compra_tiempo = FORIF_ISTAS.DimTiempo.tiem_id
GROUP BY YEAR(tiem_fecha), MONTH(tiem_fecha)
GO

CREATE UNIQUE CLUSTERED INDEX IX_mv_prom_compras_mes
ON FORIF_ISTAS.mv_prom_compras_mes (anio, mes)
GO



-- == vista 9 == --
-- Porcentaje de los cumplimientos de envios en los tiempos programados por mes 
-- Se calcula teniendo en cuenta los envios cumplidos en fecha sobnre el total de envios para el periodo

CREATE OR ALTER VIEW FORIF_ISTAS.mv_prom_envios_cumplidos
(
    anio,
    mes,
    suma_envios_totales,
    suma_envios_en_forma
)
WITH SCHEMABINDING
AS
SELECT 
    YEAR(tiem_fecha) AS anio,
    MONTH(tiem_fecha) AS mes,
    COUNT_BIG(*) AS suma_envios_totales,
    SUM(hecho_envio_cantidad_en_forma) AS suma_envios_en_forma
FROM FORIF_ISTAS.HechoEnvio
JOIN FORIF_ISTAS.DimTiempo 
    ON FORIF_ISTAS.HechoEnvio.hecho_envio_tiempo = FORIF_ISTAS.DimTiempo.tiem_id
GROUP BY YEAR(tiem_fecha), MONTH(tiem_fecha)
GO


CREATE UNIQUE CLUSTERED INDEX IX_mv_prom_envios_cumplidos
ON FORIF_ISTAS.mv_prom_envios_cumplidos (anio, mes)
GO


-- == PRUEBAS == --
-- PRUEBAS DE LAS VISTAS
-- Prueba de la vista
SELECT anio, mes, suma_precio /cantidad as promedio_de_compras
FROM FORIF_ISTAS.mv_prom_compras_mes

-- select que la contrasta
-- Prueba de porcetajes de compras por mes (DA IGUAL) 
SELECT 
    YEAR(tiem_fecha) AS anio,
    MONTH(tiem_fecha) AS mes,
    SUM(hecho_compra_precio_material) AS suma_precio,
    COUNT_BIG(*) AS cantidad,
    AVG(CAST(hecho_compra_precio_material AS FLOAT)) AS promedio_precio_directo
FROM FORIF_ISTAS.HechoCompra
JOIN FORIF_ISTAS.DimTiempo ON FORIF_ISTAS.HechoCompra.hecho_compra_tiempo = FORIF_ISTAS.DimTiempo.tiem_id
GROUP BY YEAR(tiem_fecha), MONTH(tiem_fecha)
ORDER BY anio, mes


-- Utilizo el cast porque sino no me pasa a FLOAT y me da un valor entero 
SELECT anio, mes, (CAST(suma_envios_en_forma AS FLOAT) /suma_envios_totales) * 100 AS promedio_envios_cumplidos
FROM FORIF_ISTAS.mv_prom_envios_cumplidos



--- == FACU == --


