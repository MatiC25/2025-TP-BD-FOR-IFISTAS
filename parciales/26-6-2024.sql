-- ========== SQL ========== --

/* 1. Sabiendo que si un producto no es vendido en un deposito determinado entonces no posee
registros en él.
Se requiere una consulta sql que para todos los productos que se quedaron sin stock en un deposito (cantidad 0 o nula) y
poseen un stock con mayor al punto de reposicion en otro deposito devuelva:

    - Codigo de producto 
    - Detalle de producto 
    - Domicilio del depósito sin stock 
    - Cantidad de depositos con un stock superior al punto de reposicion

La consulta debe ser ordenada por el codigo de producto 
*/ 

SELECT s.stoc_producto, prod_detalle , d.depo_domicilio , d.depo_codigo, (SELECT COUNT(*) 
                                                                            FROM STOCK 
                                                                            WHERE s.stoc_producto = stoc_producto 
                                                                                    AND d.depo_codigo <> stoc_deposito 
                                                                                    AND stoc_cantidad > stoc_punto_reposicion) as depositosConStockSuperior
FROM STOCK s
JOIN Deposito d ON d.depo_codigo = stoc_deposito
JOIN Producto ON s.stoc_producto = prod_codigo
where 
    (stoc_cantidad is null OR stoc_cantidad = 0)
    AND
    (SELECT COUNT(distinct depo_codigo) 
    FROM STOCK 
    JOIN Deposito ON depo_codigo = stoc_deposito
    WHERE s.stoc_producto = stoc_producto AND d.depo_codigo <> depo_codigo AND stoc_cantidad > stoc_punto_reposicion) > 0
ORDER BY s.stoc_producto


-- ========== T-SQL ========== --

/* 2. Dado el contexto inflacionario se tieen que aplicar el control en el cual nunca se permita vender un producto
a un precio que no esté entre el 0%-5% del precio de venta del producto el mes anterior, ni tampoco que esté más de un 50%
el precio del mismo producto que hace 12 meses atrás. Aquellos productos nuevos, o que no estuvieron ventas en meses anteriores
no debe considerar esta regla ya que no hay precio de referencia
*/

CREATE TRIGGER contextoInflacionario ON Factura AFTER INSERT 
AS
BEGIN
    declare @num char(8), @prod char(8), @precioMesAnterior decimal(12, 2), @precioAnioAnterior decimal(12, 2)
    CREATE CURSOR c1 FOR SELECT fact_numero, i.item_producto, ISNULL((SELECT MAX(item_precio)
                                     FROM Factura
                                     JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                     WHERE YEAR(f.fact_fecha) - 1 = YEAR(fact_fecha) AND MONTH(f.fact_fecha) = MONTH(fact_fecha)), 0),
                                    ISNULL((SELECT MAX(item_precio)
                                       FROM Factura
                                       JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                       WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha) AND MONTH(f.fact_fecha) - 1 = MONTH(fact_fecha)), 0)
                            FROM INSERTED f
                            JOIN Item_Factura i ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero 
                            GROUP BY fact_numero, item_producto, YEAR(f.fact_fecha), MONTH(f.fact_fecha)
                        
    OPEN c1 
    fetch next from c1 into @num, @prod, @precioMesAnterior, @precioAnioAnterior
    WHILE @@FETCH_STATUS = 0
    BEGIN 
        if(@precioMesAnterior = 0 || @precioAnioAnterior = 0) fetch next from c1 into @num, @prod, @precioMesAnterior, @precioAnioAnterior
        if(@precioActual < @precioMesAnterior*1.05 || @precioActual > @precioAñoAnterior*1.5)
        BEGIN 
            ROLLBACK
            RAISERROR('No cumple con las reglas inflacionarias')
        END
    END
    close c1 
    deallocate c1
END


CREATE TRIGGER contextoInflacionario ON Factura AFTER INSERT 
AS
BEGIN
    IF EXISTS (SELECT distinct f.fact_numero
                FROM Inserted f
                JOIN Item_Factura i ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                GROUP BY fact_numero, YEAR(f.fact_fecha), MONTH(f.fact_fecha), i.item_precio, i.item_producto
                HAVING i.item_precio > (ISNULL((SELECT MAX(item_precio)
                                FROM Factura
                                JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                WHERE YEAR(f.fact_fecha) - 1 = YEAR(fact_fecha) AND MONTH(f.fact_fecha) = MONTH(fact_fecha)), 0)*1.5) 
                                AND
                                ISNULL((SELECT MAX(item_precio)
                                FROM Factura
                                JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                WHERE YEAR(f.fact_fecha) - 1 = YEAR(fact_fecha) AND MONTH(f.fact_fecha) = MONTH(fact_fecha)), 0) > 0
                        OR
                       i.item_precio < (ISNULL((SELECT MAX(item_precio)
                                       FROM Factura
                                       JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                       WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha) AND MONTH(f.fact_fecha) - 1 = MONTH(fact_fecha)), 0)*1.05)
                                       AND
                                       ISNULL((SELECT MAX(item_precio)
                                       FROM Factura
                                       JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero AND item_producto = i.item_producto
                                       WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha) AND MONTH(f.fact_fecha) - 1 = MONTH(fact_fecha)), 0) > 0)
                                       
    BEGIN
        ROLLBACK
        RAISERROR('No cumple con las reglas inflacionarias')
    END
END 

-- == Resolución con NOTA 9 == --

CREATE TRIGGER unTrigger ON Item_Factura
FOR insert
AS BEGIN
    DECLARE @PROD char(6), @FECHA SMALLDATETIME, @PRECIO decimal(12,2), 
	@SUCURSAL char(4), @NUM char(8), @TIPO char(1)
    DECLARE c1 CURSOR FOR
	select fact_numero, fact_sucursal, fact_tipo from inserted 
	join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo

	OPEN c1
	FETCH NEXT FROM c1 INTO  @NUM, @SUCURSAL ,@TIPO

	WHILE @@FETCH_STATUS = 0
	BEGIN


	    DECLARE c2 CURSOR FOR 
		select item_producto, fact_fecha, item_precio from inserted
		join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		where fact_numero+fact_sucursal+fact_tipo = @NUM + @SUCURSAL + @TIPO

		OPEN c2
		FETCH NEXT FROM c2 INTO @PROD, @FECHA, @PRECIO

		WHILE @@FETCH_STATUS = 0
		BEGIN


		      IF EXISTS(select 1 from Item_Factura where item_producto = @PROD 
			  and item_numero+item_sucursal+item_tipo <> @NUM+@SUCURSAL+@TIPO)
			  BEGIN 
			        IF EXISTS( select 1 from Item_Factura 
		            join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		            where item_producto = @PROD and DATEDIFF(MONTH, @FECHA, fact_fecha) = 1 and @PRECIO > item_precio * 1.05)
	                BEGIN 
		               Delete Item_Factura
			           where item_numero = @NUM and item_sucursal = @SUCURSAL and item_tipo = @TIPO

			           Delete Factura
			           where fact_numero = @NUM and fact_sucursal = @SUCURSAL and fact_tipo = @TIPO

				    CLOSE c2
				    DEALLOCATE c2
			        END

			       IF EXISTS( select 1 from Item_Factura 
		           join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		           where item_producto = @PROD and DATEDIFF(YEAR, @FECHA, fact_fecha) = 1 and @PRECIO > item_precio * 1.5)
	               BEGIN 
		              Delete Item_Factura
			          where item_numero = @NUM and item_sucursal = @SUCURSAL and item_tipo = @TIPO

			          Delete Factura
			          where fact_numero = @NUM and fact_sucursal = @SUCURSAL and fact_tipo = @TIPO

				   CLOSE c2
				   DEALLOCATE c2
			       END
			  END

		      FETCH NEXT FROM c2 INTO @PROD, @FECHA, @PRECIO
		END
		
	    FETCH NEXT FROM c1 INTO @PROD, @FECHA, @PRECIO, @NUM, @SUCURSAL ,@TIPO   
	END

	CLOSE c1
	DEALLOCATE c1
END