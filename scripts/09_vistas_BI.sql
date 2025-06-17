-- -- == Vistas == --
-- Ganancias: total de ingresos (facturacion) - total de egresos (compras), por cada mes y por cada sucursal
CREATE VIEW FORIF_ISTAS.Ganancias
AS
SELECT MONTH(V.hecho_venta_tiempo) AS Mes,
       V.hecho_venta_sucursal AS Sucursal,
       SUM(V.hecho_venta_total) AS Total_Ventas,
	   SUM(ISNULL(C.hecho_compra_precio_material, 0)) AS Total_Costos
FROM FORIF_ISTAS.HechoVenta V
LEFT JOIN FORIF_ISTAS.HechoCompra C ON V.hecho_venta_sucursal = C.hecho_compra_sucursal 
	AND MONTH(V.hecho_venta_tiempo) = MONTH(C.hecho_compra_tiempo)
GROUP BY MONTH(V.hecho_venta_tiempo),
         V.hecho_venta_sucursal
GO
-- No usamos una vista materializada ya que ésta no acepta funciones de agrupación como SUM ni RIGHT/LEFT JOINs