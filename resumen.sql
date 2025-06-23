---------------
-- == SQL == --
---------------

/* Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock. */

SELECT 
    prod_codigo, 
    prod_detalle, 
    max(item_precio), 
    min(item_precio), 
    (max(item_precio) - min(item_precio))/min(item_precio)*100
FROM Producto 
JOIN item_factura ON prod_codigo = item_producto 
JOIN stock ON stoc_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle
HAVING sum(stoc_cantidad) > 0
ORDER BY 1

/* Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo. */


SELECT 
    prod_codigo, 
    prod_detalle, 
    (SELECT TOP 1 fact_cliente 
        FROM Factura JOIN Item_factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
        WHERE prod_codigo = item_producto 
        GROUP BY fact_cliente 
        ORDER BY SUM(item_cantidad) DESC) 
FROM Producto
WHERE prod_codigo in 
    (SELECT TOP 10 item_producto
    FROM item_factura
    GROUP BY item_producto
    ORDER BY SUM(item_cantidad) DESC) 
or prod_codigo in 
    (SELECT TOP 10 item_producto
    FROM item_factura
    GROUP BY item_producto
    ORDER BY sum(item_cantidad))


    /* 25. Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia.
f. El código de cliente que más compro productos de esa familia.
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente. */

SELECT 
	YEAR(f.fact_fecha),
	p.prod_familia,
	COUNT(DISTINCT prod_rubro),
	(SELECT COUNT (*) 
	FROM Composicion 
	WHERE comp_producto = (SELECT TOP 1 item_producto 
							FROM Item_Factura
							JOIN Producto ON item_producto = prod_codigo
							WHERE prod_familia = p.prod_familia
							GROUP BY item_producto
							ORDER BY SUM(item_cantidad) DESC)),
	COUNT(DISTINCT fact_tipo+fact_sucursal+fact_numero),
	(SELECT TOP 1 fact_cliente
	FROM Factura
	JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
	JOIN Producto ON item_producto = prod_codigo
	WHERE prod_familia = p.prod_familia AND YEAR(fact_fecha) = YEAR(f.fact_fecha)
	GROUP BY fact_cliente
	ORDER BY SUM(item_cantidad*item_precio) DESC),
	AVG(item_cantidad * item_precio)
FROM Factura f 
JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
JOIN Producto p ON item_producto = prod_codigo
GROUP BY YEAR(f.fact_fecha), prod_familia
HAVING prod_familia IN (SELECT TOP 1 prod_familia
	FROM Factura
    JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
    JOIN Producto ON item_producto = prod_codigo
    WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha)
    GROUP BY prod_familia
    ORDER BY COUNT(fact_numero) DESC)

 
----------------
-- == TSQL == --
----------------

-- Devuelve la sumatoria de su precio con los precios de los productos compuestos 
create function sumatoria_precio_compuesto(@prod char(8))
returns decimal(12,2)
as
BEGIN
    declare @comp char(8), @cantidad decimal(12,2), @precio_producto decimal(12,2)
    if(select count(*) from Composicion where comp_producto = @prod) = 0
        select @precio_producto = (select prod_precio from Producto where prod_codigo = @prod)
    ELSE
    BEGIN
        declare compo cursor for SELECT comp_componente, comp_cantidad FROM Composicion
                                        JOIN Producto ON prod_codigo = comp_componente
                                        WHERE comp_producto = @prod
        OPEN compo
        fetch next from compo into @comp, @cantidad
		SET @precio_producto = 0
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @precio_producto = @precio_producto + @cantidad * dbo.precio_compuesto(@comp)
            fetch next from compo into @comp, @cantidad
        END
        close compo
        deallocate compo
    END
    return @precio_producto
END

-- == Cantidad de empleados a cargo
create function cantEmpleadosACargo(@empleado numeric(6))
returns decimal(12,2)
as
BEGIN
	declare @cant decimal(12,2), @emplaux numeric(6)
	declare empl_cur cursor for select empl_codigo from Empleado where empl_jefe > @empleado
																
	open empl_cur
	fetch next from empl_cur into @emplaux
	select @cant = 0
	WHILE @@FETCH_STATUS = 0
		BEGIN
			select @cant = @cant + 1 + dbo.cantEmpleadosACargo(@emplaux)
			fetch next from empl_cur into @emplaux
		END
	close empl_cur
	deallocate empl_cur
	return @cant
END

-- == Salarios de los empleados a cargo
create function sumaSalariosEmpleadosACargo(@jefe numeric(6))
returns decimal(12,2)
AS
BEGIN
	declare @salarioTotal decimal(12,2), @emplaux numeric(6)
	declare c1 cursor for SELECT empl_codigo FROM Empleado WHERE empl_jefe = @jefe
	open c1
	fetch next from c1 into @emplaux

	SELECT @salarioTotal = 0
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @salarioaux decimal(12,2)
		SELECT @salarioaux = (SELECT empl_salario FROM Empleado WHERE empl_codigo = @emplaux)
		SELECT @salarioTotal = @salarioTotal + @salarioaux  + dbo.sumaSalariosEmpleadosACargo(@emplaux)
		fetch next from c1 into @emplaux
	END
	close c1 
	deallocate c1
	return @salarioTotal
END


/* 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

create trigger ej10 on Producto AFTER DELETE 
AS 
BEGIN
	if((SELECT COUNT(*) FROM Deleted JOIN STOCK ON stoc_producto = producto WHERE stoc_cantidad > 0) > 0)
	BEGIN
		ROLLBACK
		RAISERROR('No se pueden deletear productos con STOCK')
	END
END

/* Si queremos borrar los que se puedan borrar */

create trigger ej10 on Producto AFTER DELETE 
AS 
BEGIN
	DELETE FROM Producto WHERE prod_codigo IN (SELECT prod_codigo FROM Deleted NOT IN (SELECT DISTINCT stoc_producto FROM STOCK WHERE stoc_cantidad > 0))
END

/* Si queremos borrar los que se puedan e informar los que no borre*/

create trigger ej10 on Producto AFTER DELETE 
AS 
BEGIN
	declare @prod char(8)
	DELETE FROM Producto WHERE prod_codigo IN (SELECT prod_codigo FROM Deleted NOT IN (SELECT DISTINCT stoc_producto FROM STOCK WHERE stoc_cantidad > 0))
	declare c1 cursor for SELECT DISTINCT stoc_producto FROM Deleted JOIN STOCK ON stoc_producto = prod_codigo WHERE stoc_cantidad > 0
	open c1
	fetch next from c1 into @prod
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		PRINT ('El producto' + @prod + 'no se puede borrar dado que tiene stock')
		fetch next from c1 into @prod
	END
	close c1 
	deallocate c1

END


-- == EJEMPLO INSTEAD OF == --

/* 14. Agregar el/los objetos necesarios para que si un cliente compra un producto
compuesto a un precio menor que la suma de los precios de sus componentes
que imprima la fecha, que cliente, que productos y a qué precio se realizó la
compra. No se deberá permitir que dicho precio sea menor a la mitad de la suma
de los componentes.*/

create trigger compraProducto on Item_factura instead of insert
as
BEGIN 
	declare @prodaux char(8)
	declare c1 cursor for SELECT item_producto from inserted
	open c1
	fetch next from c1 into @prodaux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @fecha smalldatetime, @clie char(6), @prod1 char(8), @prec decimal(12,2)
		declare @precio decimal(12,2)
		SELECT @precio = (SELECT prod_precio FROM Producto where prod_codigo = @prodaux)
		if(@precio <= dbo.sumaComponentes(@prodaux)/2) 
			print 'Estas robando, no se inserto'
		else if(@precio < dbo.sumaComponentes(@prodaux))
			BEGIN
				INSERT INTO Item_Factura (
					item_tipo,
					item_sucursal,
					item_numero,
					item_producto,
					item_cantidad,
				item_precio
			)
			(SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio FROM Inserted JOIN Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
																									WHERE item_producto = @prodaux)
			(SELECT 
					 @fecha = fact_fecha, 
					 @clie = fact_cliente, 
					 @prod1 = item_producto, 
					 @prec = item_precio
					 FROM Inserted 
					 JOIN Factura ON item_tipo + item_sucursal + item_numero = fact_tipo + fact_sucursal + fact_numero WHERE item_producto = @prodaux)
				print 'Fecha: ' + @fecha + '  Cliente: ' + @clie + ' Producto: ' + @prod1 + ' Precio: ' + @prec 
			END
			else
			BEGIN
				INSERT INTO Item_Factura (
					item_tipo,
					item_sucursal,
					item_numero,
					item_producto,
					item_cantidad,
					item_precio
							)
					(SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio FROM Inserted JOIN Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
																				WHERE item_producto = @prodaux)
			END
		fetch next from c1 into @prodaux
		close c1
		deallocate c1
	END
END

-- == RACHAS DE VENTAS == --

CREATE FUNCTION sellStreak(@prod char(8), @fecha SMALLDATETIME) 
RETURNS INT
AS
BEGIN
    DECLARE @fechaPivot SMALLDATETIME, @fechaAUX SMALLDATETIME
    DECLARE @cant INT = 0
    DECLARE @maxCant INT = 0

    SELECT @fechaPivot = (
        SELECT MIN(fact_fecha)
        FROM Factura 
        JOIN Item_Factura ON item_tipo + item_sucursal + item_numero = fact_tipo + fact_sucursal + fact_numero
        WHERE item_producto = @prod AND fact_fecha >= @fecha
    )

    IF @fechaPivot IS NULL
        RETURN 0

    DECLARE c1 CURSOR FOR
        SELECT DISTINCT fact_fecha
        FROM Factura 
        JOIN Item_Factura ON item_tipo + item_sucursal + item_numero = fact_tipo + fact_sucursal + fact_numero
        WHERE item_producto = @prod AND fact_fecha >= @fechaPivot
        ORDER BY 1

    OPEN c1
    FETCH NEXT FROM c1 INTO @fechaAUX

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @fechaAUX = DATEADD(DAY, @cant, @fechaPivot)
        BEGIN
            SET @cant = @cant + 1
        END
        ELSE
        BEGIN
            SET @fechaPivot = @fechaAUX
            SET @cant = 1
        END

        IF @cant > @maxCant
            SET @maxCant = @cant

        FETCH NEXT FROM c1 INTO @fechaAUX
    END

    CLOSE c1
    DEALLOCATE c1

    RETURN @maxCant
END