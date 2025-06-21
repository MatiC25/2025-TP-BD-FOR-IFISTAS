-- ========== SQL ========== --

/* 1. Consulta SQL para analizar clientes con patrones de cmpra especificos

Se debe identificar clientes que realizarion una compra inicial y luego volvieron a 
comprar despues de 5 meses o más 

La consulta debe mostrar 
    - El numero de fila: identificador secuencial del resultado
    - el codigo del cliente id unico del cliente
    - el nombre del cliente: nombre asociado al cliente 
    - cantidad total comprada: total de productos distintos adquiridos por el cliente
    - total facturado: importe total factura al cliente 
El resultado debe estsr ordenado de forma descendente por la cantidad de productos 
adquiridos por cada cliente
*/ 


-- ========== T-SQL ========== --

/* 2. Se detectó un error en el proceso de registro de ventas, donde se almacenaron productos compuestos
en lugar de sus componentes individuales. Para solucionar este problema, se debe:

    1. Diseñar e implmenetar los objetos necesarios para reoganizar las ventas tal como están registradas actualmente 
    2. Desagregar los productos compuestos vendidos en sus componenetes individuales, asegurando
    que cada venta refleje correctamente los elementos que la compronen
    3. Garantizar que la base de datos quede consistente y alineada con las especificaciones requeridas para el manejo de poductos
*/

CREATE TRIGGER EJ2 ON Item_factura AFTER, UPDATE 
AS 
BEGIN 
    DECLARE C1 CURSOR FOR SELECT item_tipo, item_sucursal, item_numero, item_producto 
                                FROM INSERT 
                                GROUP BY item_tipo, item_sucursal, item_numero, item_producto 
                                HAVING item_producto IN (SELECT comp_producto FROM Composicion)
    open c1 
    fetch next from c1 into @tipo, @sucu, @num, @prod
    WHILE @@FETCH_STATUS = 0
    BEGIN 
        DECLARE C2 CURSOR FOR SELECT comp_componente, comp_cantidad, prod_precio FROM Composicion
                                JOIN Producto ON prod_codigo = comp_componente
                                WHERE comp_producto = @prod
                                GROUP BY comp_componente, comp_cantidad, prod_precio
        open c2 
        fetch next from c2 into @compProd, @cant, @precio
        WHILE @@FETCH_STATUS = 0
        BEGIN 
            INSERT INTO Item_factura VALUES(@tipo, @sucu, @num, @compProd, @cant, @precio*@cant)
            fetch next from c2 into @compProd, @cant, @precio
        END
            DELETE FROM Item_factura 
                WHERE item_tipo+item_sucursal+item_numero=@tipo+@sucu+@num AND item_producto = @prod
        close c2 
        DEALLOCATE c2
    END
    fetch next from c1 into @tipo, @sucu, @num, @prod
    close c1 
    DEALLOCATE c1 
END