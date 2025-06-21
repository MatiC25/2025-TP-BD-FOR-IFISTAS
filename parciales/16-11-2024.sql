-- ========== SQL ========== --

/* 1. Realizar una consulta SQL que muestre la siguiente informacion para los clientes que hayan
comprado productos en mpas de tres rubros diferentes en 2012 y que no compro en años impares   
    - El numero de fila
    - El codigo del cliente 
    - el nombre del cliente
    - la cantidad total comprada por el cliente
    - la categoria en la que más compro en 2012
El resultado debe estar ordenado por la cantidad total comprada de mayor a menor 
*/ 

SELECT 
    c.clie_codigo,
    clie_razon_social,
    SUM(fact_total),
    (SELECT TOP 1 prod_familia FROM Factura 
                                JOIN Item_factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                                JOIN Producto on item_producto = prod_codigo
                                WHERE fact_cliente = c.clie_codigo AND YEAR(fact_fecha) = 2012
                                GROUP BY prod_familia
                                ORDER BY COUNT(*) DESC)
FROM Cliente c
JOIN Factura on clie_codigo = fact_cliente
GROUP BY clie_codigo, clie_razon_social
HAVING c.clie_codigo IN (SELECT fact_cliente
                            FROM Factura 
                            JOIN Item_factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                            JOIN Producto ON item_producto = prod_codigo
                            JOIN Rubro ON prod_rubro = rubr_id
							GROUP BY fact_cliente
                            HAVING COUNT(DISTINCT rubr_id) > 3 AND fact_cliente NOT IN (SELECT fact_cliente FROM Factura
                                                                                            WHERE YEAR(fact_fecha) % 2 = 0))

-- ========== T-SQL ========== --

/* 2. Implementar los objetos necesarios para registrar, en tiempo real, los 10 productos
más vendidos por año en una tabla especifica. Esta tabla debe contener exclusivamente la info requerida
sin incluir filas adicionales. Los más vendidos se define como aquellos productos con el mayor
numero de unidades vendidas.
*/

CREATE TABLE TopProductos(
    prod_codigo char(8),
    cant_vendida decimal(12,2),
    año_venta SMALLDATETIME
)

CREATE TRIGGER EJ2 ON Item_factura AFTER INSERT 
AS 
BEGIN 
    
END
