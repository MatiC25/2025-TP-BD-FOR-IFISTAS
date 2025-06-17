/*Armar una consulta que muestre para todos los productos:

Producto

Detalle del producto

Detalle composiciOn (si no es compuesto un string SIN COMPOSICION,, si es compuesto un string CON COMPOSICION

Cantidad de Componentes (si no es compuesto, tiene que mostrar 0)

Cantidad de veces que fue comprado por distintos clientes

Nota: No se permiten sub select en el FROM.*/


SELECT prod_codigo, 
       prod_detalle, 
       CASE 
            WHEN (SELECT COUNT(*) FROM COMPOSICION 
                    WHERE comp_producto = prod_codigo) > 0
                    THEN 'COMPOSICION'
                    ELSE 'SIN COMPOSICION' 
					END AS dato,
        ISNULL((SELECT COUNT(*) FROM Composicion WHERE comp_producto = prod_codigo), 0) as cantComponentes,
        COUNT(distinct fact_cliente) as clientesCompraron
FROM Producto 
LEFT JOIN Item_Factura ON prod_codigo = item_producto
LEFT JOIN Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
GROUP BY prod_codigo, prod_detalle


-- == RESOLUCION CON 8 == --

select p.prod_codigo, 
       p.prod_detalle,
	   (SELECT CASE 
		WHEN ((SELECT comp_producto FROM COMPOSICION inner join Producto p1 on comp_producto = p1.prod_codigo where comp_producto = p.prod_codigo) <> NULL) THEN 'CON COMPOSICI�N'
		ELSE 'SIN COMPOSICI�N'
		END) AS DetalleComposicion,
		ISNULL((select count(comp_componente) from Composicion where comp_producto = p.prod_codigo), 0) AS CantidadComponentes,
		COUNT(DISTINCT fact_cliente) AS CantidadCompradores
	   from Producto p
	   INNER JOIN Item_Factura ON item_producto = p.prod_codigo 
	   INNER JOIN FACTURA ON fact_numero + fact_sucursal + fact_tipo = item_numero + item_sucursal + item_tipo
	   group by p.prod_codigo, p.prod_detalle

-- == TSQL == --

/*Implementar el/los objetos necesarios para implementar la siguiente restriccion en linea:
Cuando se inserta en una venta un COMBO, nunca se debera guardar el producto COMBO, sino, la descomposicion de sus componentes.
 Nota: Se sabe que actualmente todos los articulos guardados de ventas estan descompuestos en sus componentes.*/

--== RESOLUCION MATI (AFTER) -> EL RESULTADO DA CORRECTO 

ALTER TRIGGER descomposicionDeCombos ON Item_factura AFTER INSERT
AS
BEGIN
    declare @clave char(13), @prodCompuesto char(8)
    declare c1 cursor for SELECT item_tipo+item_sucursal+item_numero, item_producto 
                                    FROM INSERTED 
                                    WHERE (SELECT COUNT(*) FROM Composicion
                                            WHERE item_producto = comp_producto) > 0 
    open c1
    fetch next from c1 into @clave, @prodCompuesto

    WHILE @@FETCH_STATUS = 0
    BEGIN 
        declare @prodComponente char(8), @cant decimal(12,2), @precio decimal(12,2)
        declare c2 cursor for SELECT comp_componente, comp_cantidad, prod_precio
                                FROM Composicion
                                JOIN Producto ON comp_componente = prod_codigo
                                WHERE comp_producto = @prodCompuesto
        open c2
        fetch next from c2 into @prodComponente, @cant, @precio
        WHILE @@FETCH_STATUS = 0
        BEGIN 
                INSERT INTO Item_Factura(
                    item_tipo, 
                    item_sucursal, 
                    item_numero, 
                    item_producto, 
                    item_cantidad, 
                    item_precio
                )
                SELECT item_tipo, item_sucursal, item_numero, @prodComponente, @cant, @cant*@precio
                FROM INSERTED 
                WHERE item_tipo+item_sucursal+item_numero = @clave

                fetch next from c2 into @prodComponente, @cant, @precio
        END

		DELETE FROM Item_factura where item_producto = @prodCompuesto AND @clave = item_tipo+item_sucursal+item_numero
        fetch next from c1 into @clave, @prodCompuesto

        close c2 
        deallocate c2
        
    END
    close c1
    deallocate c1 

END

-- == RESOLUCION CON 9 == --

 CREATE TRIGGER changeComboiTemForComponents ON item_Factura INSTEAD OF INSERT 
 as
 BEGIN
	DECLARE @PRECIO DECIMAL(12,2)
	DECLARE @ITEMCANT DECIMAL(12,2)
	DECLARE @PRODUCTOID CHAR(8)
	DECLARE @FACTURAID CHAR(8)
	DECLARE @TIPO CHAR(1)
	DECLARE @SUCURSAL CHAR(4)

	DECLARE NUEVOS CURSOR FOR SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio FROM inserted

	OPEN NUEVOS
	
	FETCH NEXT FROM NUEVOS INTO @TIPO, @SUCURSAL, @FACTURAID, @PRODUCTOID, @ITEMCANT, @PRECIO

	WHILE @@FETCH_STATUS = 0
	BEGIN
	 if (exists(select 1 FROM COMPOSICION where comp_producto = @PRODUCTOID)) --ES COMBO
		INSERT INTO Item_Factura SELECT @TIPO, @SUCURSAL, @FACTURAID, c1.comp_componente, c1.comp_cantidad, prod_precio FROM COMPOSICION C1
			inner join Producto on prod_codigo = comp_componente where c1.comp_producto = @PRODUCTOID
		
	ELSE
		INSERT INTO Item_Factura VALUES(@TIPO, @SUCURSAL, @FACTURAID, @PRODUCTOID, @ITEMCANT, @PRECIO)


	FETCH NEXT FROM NUEVOS INTO @TIPO, @SUCURSAL, @FACTURAID, @PRODUCTOID, @ITEMCANT, @PRECIO
	END

	CLOSE NUEVOS
	DEALLOCATE NUEVOS
END

--PRUEBA, EL '00001104' ES UN COMBO DE 2 PRODUCTOS
  INSERT INTO Item_Factura VALUES ('A', '0003', '00089605', '00001104', 1, 100)


--EN SU LUGAR SE DEBEN INSERTAR LOS PRODUCTOS '00001109' Y '00001123'
 SELECT * FROM Item_Factura  WHERE ITEM_NUMERO = '00089605' ORDER BY item_numero

 --Efectivamente, a los 3 registros previos con esa factura se le agregan los 2 nuevos productos mencionados.
			

