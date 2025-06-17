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
