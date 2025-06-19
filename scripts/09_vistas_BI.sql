-- Vista BI Materializadas 
-- Vista 7 
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

-- Vista 9 
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
