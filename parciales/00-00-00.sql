-- == SQL == --
/*
La empresa esta muy comprometida con el desarrollo sustentbale y como consecuencia de ello propone cambiar 
los envases de sus productos por envases reciclados. Si bien entiende la importancia de este cambio, tambien es consciente
de los costos que esto conlleva por lo cual se realizará de manera paulatina

Por tal motivo se solicita un listado con los 5 productos más vendidos y los 5
productos menos vendidos durante 2012. Comparar la cantidad vendida de cada uno de estos productos 
con la cantidad vendida del año anterior e indicar el string 'Más ventas' o 'Menos Ventas' según corresponda.
Además indicar envase 

A) Producto 
B) Comparacion año anterior
C) Detalle del envase 
*/

SELECT 
    p.prod_codigo,    
    CASE WHEN 
        (SELECT COUNT(*)
        FROM Item_Factura 
        LEFT JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
        WHERE YEAR(fact_fecha) = 2012 AND item_producto = p.prod_codigo) > (SELECT COUNT(*)
        FROM Item_Factura 
        LEFT JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
        WHERE YEAR(fact_fecha) = 2011 AND item_producto = p.prod_codigo) THEN 'Menos Ventas'
        ELSE 'Más Ventas' END
    enva_detalle
FROM Producto p
JOIN Envases ON enva_codigo = p.prod_envase
WHERE prod_codigo IN
(SELECT TOP 5 prod_codigo
FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
LEFT JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo
ORDER BY COUNT(*) DESC)
OR prod_codigo IN
(SELECT TOP 5 prod_codigo
FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
LEFT JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo
ORDER BY COUNT(*) ASC)


-- == TSQL == --

/*La compañia cumple años y decidio repartir algunas sorpresas entre sus clientes. Se pide el/los objetos necesarios
para que se imprima un cupón con la leyenda "Recuerde solicitar su regalo sorpresa en su proxima compra" a los clientes
que, entre los productos comprados, hayan adquirido algún producto de los siguientes rubros: PILAS Y PASTILLAS y tengan un 
limite crediticio menor a los $15000*/

CREATE PROCEDURE ejparcial00
AS
BEGIN 
    declare @clie char(6)
    declare c1 cursor for 
    SELECT clie_codigo FROM Cliente 
    JOIN Factura ON clie_vendedor = fact_vendedor
    JOIN Item_factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
    WHERE clie_limite_credito < 15000 AND item_producto IN (SELECT prod_producto FROM Producto 
                            JOIN Envases on enva_codigo = prod_envase 
                            WHERE enva_detalle = 'PILAS' OR enva_detalle = 'PASTILLAS')
    
    open c1 
    fetch next from c1 into @clie 
    WHILE @@FETCH_STATUS = 0
    BEGIN 
        PRINT 'Recuerde ' + @clie +  ' solicitar su regalo sorpresa en su proxima compra'
        fetch next from c1 into @clie 
    END 
    close c1 
    deallocate c1 
END