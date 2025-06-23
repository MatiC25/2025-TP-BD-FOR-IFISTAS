/*
Realizar una consulta SQL que muestre aquellos productos que tengan
3 componentes a nivel producto y cuyos componentes tengan 2 rubros
distintos.
De estos productos mostrar:
    i) El código de producto.
    ii) El nombre del producto.
    iii) La cantidad de veces que fueron vendidos sus componentes en el 2012.
    iv) Monto total vendido del producto.

El resultado deberá ser ordenado por cantidad de facturas del 2012 en
las cuales se vendieron los componentes.
Nota: No se permiten select en el from, es decir, select... from (select ...) as T....
*/

SELECT 
    prod_codigo,
    prod_detalle,
    (SELECT SUM(item_cantidad) 
        FROM Item_Factura
        JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
        WHERE YEAR(fact_fecha) = 2012 AND item_producto IN (SELECT comp_componente FROM Composicion WHERE comp_producto = prod_codigo)
    ),
    (SELECT SUM(item_cantidad*item_precio) FROM Item_Factura WHERE item_producto = prod_codigo)
FROM Producto
GROUP BY prod_codigo, prod_detalle
HAVING prod_codigo IN (SELECT prod_codigo FROM Producto 
                                            JOIN Rubro ON rubr_id = prod_rubro 
                                            JOIN Composicion ON comp_producto = prod_codigo
                                            GROUP BY prod_codigo
                                            HAVING COUNT(comp_componente) = 3 AND COUNT(distinct rubr_id) >= 2)


/*
1. Implementar una regla de negocio en linea donde se valide que nuncа
un producto compuesto pueda estar compuesto por componentes de rubros distintos a el.
*/

CREATE TRIGGER compuestosRubros ON Composicion AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN Producto compuesto ON i.comp_producto = compuesto.prod_codigo
        JOIN Producto componente ON i.comp_componente = componente.prod_codigo
        WHERE compuesto.prod_rubro <> componente.prod_rubro
    )
    BEGIN
        RAISERROR('No se puede tener un producto compuesto por componentes con rubros distintos a él', 16, 1)
        ROLLBACK TRANSACTION
    END
END

