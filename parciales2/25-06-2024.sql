-- == SQL == --
/* Dada la crisis que atraviesa la empresa, el directorio solicia un informe especial para poder analizar y definir
la nueva estrategia a adoptar
Este informe consta de un listado de aquellos productos cuyas ventas de lo que va del año 2012 fueron superiores
al 15% del promedio de ventas de los productos vendidos entre los años 2010 y 2011
En base a lo solicitado, armar una consulta SQL que retorne la siguiente informacion:
    1) Detalle producto 
    2) Mostrar la leyenda "Popular" si dicho producto figura en más de 100 facturas realizadas en el 2012. Caso 
        contrario, mostrar la leyenda "SIN INTERES"
    3) Cantidad de facturas en las que aparece el producto en el año 2012
    4) Codigo del cliente que más compro dicho producto en el año 2012 (en caso de existi más de un cliente
     mostrar solamente el de menor codigo)
*/

SELECT 
    prod_codigo,
    CASE WHEN COUNT(distinct fact_tipo+fact_sucursal+fact_numero) > 100 THEN 'Popular' ELSE 'SIN INTERES' END as DATO,
    COUNT(distinct fact_tipo+fact_sucursal+fact_numero) AS CantFacturas,
    (SELECT TOP 1 fact_cliente FROM Factura JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
        WHERE YEAR(fact_fecha) = 2012 AND item_producto = prod_codigo
		GROUP BY fact_cliente
        ORDER BY SUM(item_cantidad))
FROM Producto
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo
HAVING prod_codigo IN (SELECT item_producto FROM Item_Factura JOIN Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                        WHERE YEAR(fact_fecha) = 2012 
                        GROUP BY item_producto
                        HAVING SUM(item_cantidad*item_precio) > 0.15*((SELECT SUM(item_cantidad*item_precio) 
                                                                                    FROM Item_Factura JOIN Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                                                                                    WHERE YEAR(fact_fecha) = 2011) + (SELECT SUM(item_cantidad*item_precio) 
                                                                                    FROM Item_Factura JOIN Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                                                                                    WHERE YEAR(fact_fecha) = 2010))/ 2)


-- == TSQL == --
/*
Realizar el o los objetos de base de datos necesarios para que dado un codigo de producto y una fecha devuelva
la mayor cantidad de dias consecutivos a partir de esa fecha que el producto tuvo al menos la venta de una unidad en el dia, 
el sistema de ventas on line esta habilitado 24-7 por lo que se deben evaluar tidos los dias incluyendo domingos y feriados
*/

CREATE FUNCTION sellStreak(@prod char(8), @fecha SMALLDATETIME)
RETURNS decimal(12,2)
AS
BEGIN
    declare @fechaPivot SMALLDATETIME, @fechaAUX SMALLDATETIME, @cantGanadora decimal(12,2)
    SELECT @cantGanadora = 0
    SELECT @fechaPivot = (SELECT top 1 fact_fecha
    FROM Factura 
    JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
    WHERE fact_fecha >= @fecha AND item_producto = @prod)

    declare c1 CURSOR FOR SELECT fact_fecha
                            FROM Factura 
                            JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                            WHERE fact_fecha >= @fecha AND item_producto = @prod
    OPEN C1 
    FETCH NEXT FROM C1 INTO @fechaAUX
    WHILE @@FETCH_STATUS = 0
    BEGIN
        declare @cant decimal(12,2)
        set @cant = 0
        WHILE (DATEDIFF(DAY, @fechaPivot, @fechaAUX) - @cant) = 1
        BEGIN 
            set @cant = @cant + 1 
            FETCH NEXT FROM C1 INTO @fechaAUX
        END

        if(@cant > @cantGanadora) 
        BEGIN
        set @cantGanadora = @cant
        END
    END
    declare @ultimaFecha SMALLDATETIME
    SELECT @ultimaFecha = @fechaAUX

    if(@cantGanadora < dbo.sellStreak(@prod, @ultimaFecha)) 
    BEGIN
        SET @cantGanadora = dbo.sellStreak(@prod, @ultimaFecha)
    END

    return @cantGanadora
END