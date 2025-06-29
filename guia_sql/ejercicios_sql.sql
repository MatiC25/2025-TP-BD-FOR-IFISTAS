/* 1) Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente.
*/

select clie_codigo, clie_razon_social 
from Cliente
where clie_limite_credito > 1000
order by clie_codigo


/* 2) Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida.
*/

select  item_producto, prod_detalle
from item_factura join factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
join Producto on item_producto = prod_codigo 
where year(fact_fecha) = 2012
group by item_producto, prod_detalle
order by sum(item_cantidad) 

/* 3) Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.
*/

select prod_codigo, prod_detalle, sum(isnull(stoc_cantidad,0)) 
from Producto left join stock on prod_codigo = stoc_producto
group by prod_codigo, prod_detalle
order by 1

/* 4) Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.*/

select prod_codigo, prod_detalle, count(distinct comp_componente)
from producto left join Composicion on prod_codigo = comp_producto join stock on stoc_producto = prod_codigo
group by prod_codigo, prod_detalle
having avg(stoc_Cantidad) > 100

select prod_codigo, prod_detalle, count(comp_componente)
from producto left join Composicion on prod_codigo = comp_producto 
group by prod_codigo, prod_detalle
having prod_codigo in (select stoc_producto from stock group by stoc_producto having avg(stoc_Cantidad) > 100)


/* 5) Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.*/

select prod_codigo, prod_detalle, sum(item_cantidad)
from producto join item_factura on prod_codigo = item_producto join factura 
on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where year(fact_fecha) = 2012
group by prod_codigo, prod_detalle
having sum(item_cantidad) > (select sum(item_cantidad) from item_factura join factura 
    on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where year(fact_fecha) = 2011 and item_producto = prod_codigo) 
order by 1

/* 6) Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.*/

SELECT rubr_id, rubr_detalle, count(distinct prod_codigo), sum(isnull(stoc_cantidad,0))
FROM RUBRO left join Producto on prod_rubro = rubr_id and prod_codigo in (select stoc_producto from stock group by stoc_producto having sum(stoc_cantidad) >
(select isnull(stoc_cantidad,0) from stock where stoc_producto = '00000000' and stoc_deposito = '00'))
left join stock on prod_codigo = stoc_producto 
group by rubr_id, rubr_detalle
order by 4 

/* 7) Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock. */

select prod_codigo, prod_detalle, max(item_precio), min(item_precio), (max(item_precio) - min(item_precio))/min(item_precio)*100
from producto join item_factura on prod_codigo = item_producto join stock on stoc_producto = prod_codigo
group by prod_codigo, prod_detalle
having sum(stoc_cantidad) > 0
order by 1

select prod_codigo, prod_detalle, max(item_precio), min(item_precio), (max(item_precio) - min(item_precio))/min(item_precio)*100
from producto join item_factura on prod_codigo = item_producto 
where prod_codigo in (select stoc_producto from STOCK group by stoc_producto having sum(stoc_cantidad) > 0)
group by prod_codigo, prod_detalle
order by 1


/* 8)  Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene. */

select prod_detalle, max(stoc_cantidad)
from producto join stock on prod_codigo = stoc_producto
where stoc_cantidad > 0
group by prod_detalle 
having count(*) = (select count(*) from deposito)

/* 9)  Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.*/

select empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre), count(depo_codigo) 
from Empleado left join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre)

select empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre), count(depo_codigo)
from Empleado left join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre)


/* 10) Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo. */


select prod_codigo, prod_detalle, (select top 1 fact_cliente 
                   from factura join item_factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                   where prod_codigo = item_producto group by fact_cliente order by sum(item_cantidad) desc) 
 from producto
where prod_codigo in 
    (select top 10 item_producto
    from item_factura
    group by item_producto
    order by sum(item_cantidad) desc) 
or prod_codigo in 
    (select top 10 item_producto
    from item_factura
    group by item_producto
    order by sum(item_cantidad))

/* 11) Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012. */

select fami_detalle, count(distinct prod_codigo), sum(isnull(item_precio*item_cantidad,0))
from familia join Producto on fami_id = prod_familia join Item_Factura on prod_codigo = item_producto
where fami_id in 
(select prod_familia from producto join item_factura on item_producto = prod_codigo
                   join factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = 2012 
group by prod_familia
having sum(item_cantidad*item_precio) > 20000)
group by fami_id, fami_detalle
order by 2


select fami_detalle, count(distinct prod_codigo), sum(isnull(item_precio*item_cantidad,0))
from familia join Producto on fami_id = prod_familia join Item_Factura on prod_codigo = item_producto
group by fami_id, fami_detalle
having fami_id in 
(select prod_familia from producto join item_factura on item_producto = prod_codigo
                   join factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = 2012 
group by prod_familia
having sum(item_cantidad*item_precio) > 20000)
order by 2


/* 12)  Mostrar nombre de producto, cantidad de clientes distintos que lo compraron importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

SELECT prod_detalle, COUNT(DISTINCT fact_cliente) AS clientes_que_compraron, AVG(item_precio) AS importe_promedio,
(SELECT COUNT(stoc_deposito) FROM STOCK WHERE stoc_producto = prod_Codigo) AS depositos_con_stock,
(SELECT SUM(stoc_cantidad) FROM STOCK WHERE stoc_producto = prod_codigo) AS stock_total FROM Producto
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
WHERE prod_codigo in (select item_producto from item_factura join factura 
        ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
        where year(fact_fecha) = 2012)
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_precio * item_cantidad) DESC

/* 13)  Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/


select p1.prod_detalle, p1.prod_precio, sum(p2.prod_precio*comp_cantidad)  
from composicion join producto p1 on p1.prod_codigo = comp_producto join producto p2 on p2.prod_codigo = comp_componente
group by p1.prod_detalle, p1.prod_precio
having count(*) >= 2
order by count(*) DESC


/* 14) Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:

Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año

Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna */

Select clie_codigo, count(fact_numero), avg(isnull(fact_total,0)), (select count(distinct item_producto) item_producto from item_factura join factura on item_tipo+item_sucursal+item_numero 
                                                                    = fact_tipo+fact_sucursal+fact_numero
                                                                    where fact_cliente =clie_codigo and year(fact_fecha) =
                                                                    (select max(year(fact_Fecha)) from Factura)),
    max(isnull(fact_total,0)) 
from cliente left join factura on fact_cliente = clie_codigo and 
year(fact_fecha) = (select max(year(fact_Fecha)) from Factura)
group by clie_codigo
order by 2


/* 15) Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.
Ejemplo de lo que retornaría la consulta:

PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2 */
9
select p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_Detalle, count(*)
from producto p1 join item_factura i1 on prod_codigo = item_producto join item_factura i2 
    on i1.item_tipo+i1.item_sucursal+i1.item_numero = i2.item_tipo+i2.item_sucursal+i2.item_numero 
    join producto p2 on p2.prod_codigo = i2.item_producto 
where p1.prod_codigo < p2.prod_codigo
group by p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_Detalle 
having count(*) > 500

/* 16)  Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas compras
son inferiores a 1/3 del monto de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.*/

select clie_razon_social, sum(isnull(item_cantidad,0)), isnull((select top 1 item_producto from item_factura join factura on 
                                                fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero   
                                                where clie_codigo = fact_cliente and year(fact_fecha) = 2012
                                                group by item_producto
                                                order by sum(item_cantidad) desc, item_producto), 'Ninguno')                     
from cliente join factura on clie_codigo = fact_cliente left join item_factura on 
    fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero and 
    year(fact_fecha) = 2012    
group by clie_razon_social, clie_codigo 
having isnull((select sum(fact_total - fact_total_impuestos) from factura where fact_cliente = clie_codigo),0) < (select top 1 sum(item_precio*item_cantidad) from item_factura join factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero   
                                                where year(fact_fecha) = 2012
                                                group by item_producto
                                                order by sum(item_cantidad) desc) / 3




/* 17) Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.

La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo
pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo*/


select str(year(f1.fact_fecha),4)+right('00'+ltrim(str(Month(f1.fact_fecha),2)),2), prod_codigo, prod_detalle, sum(item_cantidad), 
    (select sum(i2.item_cantidad) from factura f2 join item_factura i2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = i2.item_tipo+i2.item_sucursal+i2.item_numero
    where year(f2.fact_fecha) = year(f1.fact_fecha)-1 and month(f2.fact_fecha) = month(f1.fact_fecha) and prod_codigo = i2.item_producto),
    count(distinct item_tipo+item_sucursal+item_numero)
from factura f1 join item_factura on f1.fact_tipo+f1.fact_sucursal+f1.fact_numero = item_tipo+item_sucursal+item_numero join Producto on prod_codigo = item_producto
group by year(f1.fact_fecha),Month(f1.fact_fecha), prod_codigo, prod_detalle
order by 1, prod_codigo 




/*18)Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.*/

SELECT rubr_detalle, SUM(item_cantidad*item_precio) as VENTAS,
(SELECT TOP 1 p2.prod_codigo
FROM Producto p2
WHERE p2.prod_rubro = rubr_id
GROUP BY p2.prod_codigo
ORDER BY count(*) DESC) AS PROD1,
(SELECT TOP 1 p4.prod_codigo
FROM Producto p4
WHERE p4.prod_rubro = rubr_id and p4.prod_codigo <> (SELECT TOP 1 p2.prod_codigo
FROM Producto p2
WHERE p2.prod_rubro = rubr_id
GROUP BY p2.prod_codigo										ORDER BY count(*) DESC)
GROUP BY p4.prod_codigo
ORDER BY count(*) DESC) as PROD2,
isnull((SELECT TOP 1 clie_codigo
FROM Cliente
JOIN Factura on fact_cliente = clie_codigo
JOIN Item_Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
JOIN Producto p3 on p3.prod_codigo = item_producto
WHERE p3.prod_rubro = rubr_id
GROUP BY clie_codigo
ORDER BY COUNT(distinct item_producto) DESC),'Nadie') AS clienteMasCompro
FROM Rubro
LEFT JOIN Producto on prod_rubro = rubr_id
LEFT JOIN Item_Factura on item_producto = prod_codigo
GROUP BY rubr_detalle, rubr_id
ORDER BY COUNT(distinct item_producto)


/*19) En virtud de una recategorizacion de productos referida a la familia de los mismos se
solicita que desarrolle una consulta sql que retorne para todos los productos:
Codigo de producto
Detalle del producto
Codigo de la familia del producto
Detalle de la familia actual del producto
Codigo de la familia sugerido para el producto
Detalla de la familia sugerido para el producto
La familia sugerida para un producto es la que poseen la mayoria de los productos cuyo
detalle coinciden en los primeros 5 caracteres.
En caso que 2 o mas familias pudieran ser sugeridas se debera seleccionar la de menor
codigo. Solo se deben mostrar los productos para los cuales la familia actual sea
diferente a la sugerida
Los resultados deben ser ordenados por detalle de producto de manera ascendente
*/

SELECT p1.prod_codigo, p1.prod_detalle, p1.prod_familia, f1.fami_detalle, (SELECT TOP 1 f2.fami_detalle
																		FROM Producto p2
																		LEFT JOIN Familia f2 ON f2.fami_id = p2.prod_familia
																		WHERE SUBSTRING(p1.prod_detalle, 0, 6) = SUBSTRING(f2.fami_detalle, 0, 6)
																		GROUP BY f2.fami_detalle, f2.fami_id
																		ORDER BY f2.fami_id) as familiaSugerida,
																		(SELECT TOP 1 f2.fami_id
																		FROM Producto p2
																		LEFT JOIN Familia f2 ON f2.fami_id = p2.prod_familia
																		WHERE SUBSTRING(p1.prod_detalle, 0, 6) = SUBSTRING(f2.fami_detalle, 0, 6)
																		GROUP BY f2.fami_detalle, f2.fami_id
																		ORDER BY f2.fami_id) as CodigoFamiliaSugerida
FROM Producto p1
LEFT JOIN Familia f1 ON f1.fami_id = p1.prod_familia
WHERE f1.fami_detalle <>  (SELECT TOP 1 f2.fami_detalle
																		FROM Producto p2
																		LEFT JOIN Familia f2 ON f2.fami_id = p2.prod_familia
																		WHERE SUBSTRING(p1.prod_detalle, 0, 6) = SUBSTRING(f2.fami_detalle, 0, 6)
																		GROUP BY f2.fami_detalle, f2.fami_id
																		ORDER BY f2.fami_id)
GROUP BY p1.prod_codigo, p1.prod_detalle, p1.prod_familia, f1.fami_detalle
ORDER BY p1.prod_detalle DESC




/*20). Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012 Se debera retornar legajo, 
nombre y apellido, anio de ingreso, puntaje 2011, puntaje 2012. El puntaje de cada empleado se calculara de la siguiente manera: 
para los que hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas que superen los 100 
pesos que haya vendido en el año, para los que tengan menos de 50 facturas en el año el calculo del puntaje 
sera el 50% de cantidad de facturas realizadas por sus subordinados directos en dicho año */

SELECT 
	empl_codigo, 
	empl_nombre, 
	empl_apellido, 
	YEAR(empl_ingreso)as anioIgreso, 
	(SELECT 
	CASE WHEN COUNT(*) > 50 
	THEN (SELECT COUNT(*)
			FROM Factura f1
			WHERE f1.fact_total > 100 AND f1.fact_vendedor = empl_codigo)
			ELSE (SELECT COUNT(*)/2
					FROM Empleado e1
					JOIN Factura f3 ON f3.fact_vendedor = e1.empl_codigo
					WHERE e1.empl_jefe = empl_codigo)
					END AS Puntaje
	FROM Factura
	WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2012
	GROUP BY fact_vendedor) as puntaje1, 
	(SELECT 
	CASE WHEN COUNT(*) > 50 
	THEN (SELECT COUNT(*)
			FROM Factura f1
			WHERE f1.fact_total > 100 AND f1.fact_vendedor = empl_codigo)
			ELSE (SELECT COUNT(*)/2
					FROM Empleado e1
					JOIN Factura f3 ON f3.fact_vendedor = e1.empl_codigo
					WHERE e1.empl_jefe = empl_codigo)
			END AS Puntaje
	FROM Factura
	WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2011
	GROUP BY fact_vendedor) as puntaje2
FROM Empleado


/*21). Escriba una consulta sql que retorne para todos los años, en los cuales se haya hecho al
menos una factura, la cantidad de clientes a los que se les facturo de manera incorrecta
al menos una factura y que cantidad de facturas se realizaron de manera incorrecta. Se
considera que una factura es incorrecta cuando la diferencia entre el total de la factura
menos el total de impuesto tiene una diferencia mayor a $ 1 respecto a la sumatoria de
los costos de cada uno de los items de dicha factura. Las columnas que se deben mostrar
son:
Año
Clientes a los que se les facturo mal en ese año
Facturas mal realizadas en ese año
*/

SELECT distinct YEAR(fact_fecha), COUNT(distinct fact_cliente) as cantClientes, count(fact_numero) as cantFacturas
FROM Factura
WHERE ABS(ABS(fact_total - fact_total_impuestos) - (SELECT SUM(item_cantidad*item_precio)
												FROM Item_Factura
												WHERE item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero)) > 1
group by YEAR(fact_fecha)

/*22) Escriba una consulta sql que retorne una estadistica de venta para todos los rubros por
trimestre contabilizando todos los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
Detalle del rubro
Numero de trimestre del año (1 a 4)
Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
Cantidad de productos diferentes del rubro vendidos en el trimestre

El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.
No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.
En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica.*/

SELECT 
	rubr_detalle,  
	DATEPART(QUARTER, fact_fecha) as Trimestre,
	COUNT(fact_numero) AS cantFacturas,
FROM Rubro
LEFT JOIN Producto ON prod_rubro = rubr_id
JOIN Item_Factura on prod_codigo = item_producto
JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero














SELECT rubr_detalle, YEAR(fact_fecha), DATEPART(QUARTER, fact_fecha) as Trimestre, COUNT(fact_numero) AS cantFacturas, COUNT(distinct prod_codigo) as cantProductosDistintos
FROM Rubro
LEFT JOIN Producto ON prod_rubro = rubr_id
JOIN Item_Factura on prod_codigo = item_producto
JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
GROUP BY rubr_detalle, YEAR(fact_fecha), DATEPART(QUARTER, fact_fecha)
HAVING COUNT(fact_numero) > 100
ORDER BY rubr_detalle


/* 23. Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente.
*/

SELECT 
	YEAR(f.fact_fecha),
	(SELECT TOP 1 item_producto 
	FROM Item_Factura
	JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	JOIN Composicion ON item_producto = comp_producto
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha)
	GROUP BY item_producto 
	ORDER BY SUM(item_cantidad) DESC),
	(SELECT COUNT(*) FROM Composicion
	WHERE comp_producto = (SELECT TOP 1 item_producto 
							FROM Item_Factura
							JOIN Composicion ON item_producto = comp_producto
							GROUP BY item_producto 
							ORDER BY SUM(item_cantidad) DESC)),
	(SELECT COUNT(distinct fact_tipo+fact_sucursal+fact_numero) 
	FROM Factura
	JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND item_producto = (SELECT TOP 1 item_producto 
																	FROM Item_Factura
																	JOIN Composicion ON item_producto = comp_producto
																	GROUP BY item_producto 
																	ORDER BY SUM(item_cantidad) DESC)),
	(SELECT TOP 1 fact_cliente 
	FROM Factura
	JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE item_producto = (SELECT TOP 1 item_producto 
							FROM Item_Factura
							JOIN Composicion ON item_producto = comp_producto
							GROUP BY item_producto 
							ORDER BY SUM(item_cantidad) DESC) AND YEAR(fact_fecha) = YEAR(f.fact_fecha)
	GROUP BY fact_cliente
	ORDER BY SUM(item_cantidad)),
	(SELECT SUM(item_cantidad*item_precio) 
	FROM Item_Factura
	JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND item_producto = (SELECT TOP 1 item_producto 
							FROM Item_Factura
							JOIN Composicion ON item_producto = comp_producto
							GROUP BY item_producto 
							ORDER BY SUM(item_cantidad) DESC )) * 100 / SUM(fact_total)
FROM Factura f
GROUP BY YEAR(f.fact_fecha)

-- Otra Solución más limpia --

SELECT 
	YEAR(f.fact_fecha),
	i.item_producto, 
	COUNT(DISTINCT comp_producto),
	COUNT(DISTINCT fact_tipo+fact_sucursal+fact_numero),
	(SELECT TOP 1 fact_cliente 
	FROM Factura
	JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE item_producto = i.item_producto AND YEAR(f.fact_fecha) = YEAR(fact_fecha)
	GROUP BY fact_cliente
	ORDER BY SUM(item_cantidad)),
	AVG(item_cantidad * item_precio)
FROM Factura f
JOIN Item_Factura i ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
JOIN Producto ON item_producto = prod_codigo 
JOIN Composicion ON comp_producto = prod_codigo
GROUP BY YEAR(f.fact_fecha), item_producto
HAVING item_producto IN (SELECT TOP 1 item_producto 
							FROM Item_Factura
							JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
							JOIN Composicion ON item_producto = comp_producto
							WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha)
							GROUP BY item_producto 
							ORDER BY SUM(item_cantidad) DESC)



/* 24. Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
 Código de Producto
 Nombre del Producto
 Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente. */

SELECT prod_codigo, prod_detalle, SUM(item_cantidad) as unidadesFacturadas
FROM Factura
JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero 
AND  
fact_vendedor IN (SELECT TOP 2 empl_codigo
					FROM Empleado
					order by empl_comision desc)
JOIN Producto on item_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle
HAVING COUNT(fact_numero) > 5


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

-- La solución del profe: --

SELECT 
	YEAR(f.fact_fecha),
	(SELECT TOP 1 prod_familia
	FROM Factura f1
    JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
    JOIN Producto ON item_producto = prod_codigo
    WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)
    GROUP BY prod_familia
    ORDER BY COUNT(fact_numero) DESC),

	(SELECT COUNT(distinct prod_rubro)
    FROM Producto
    WHERE prod_familia = ((SELECT TOP 1 prod_familia
                            FROM Factura f1
                            JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
                        	JOIN Producto ON item_producto = prod_codigo
                            WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)
                            GROUP BY prod_familia
                            ORDER BY SUM(item_cantidad) DESC))) as CantRubros ,

	(SELECT COUNT(*) FROM Composicion 
	JOIN Producto ON comp_producto = prod_codigo
	WHERE comp_producto = (SELECT TOP 1 prod_codigo FROM Producto 
							JOIN Item_Factura ON item_producto = prod_codigo
							WHERE prod_familia = (SELECT TOP 1 prod_familia
                            						FROM Factura f1
                           	 						JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
                        							JOIN Producto ON item_producto = prod_codigo
                            						WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)
                            						GROUP BY prod_familia
                            						ORDER BY SUM(item_cantidad)  DESC)
							GROUP BY prod_codigo
							ORDER BY SUM(item_cantidad))) AS CantComponentes,
	(SELECT COUNT(distinct fact_tipo+fact_sucursal+fact_numero) 
	FROM Factura f1
	JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
	JOIN Producto ON prod_codigo = item_producto
	WHERE YEAR(f.fact_fecha) = YEAR(f1.fact_fecha) AND prod_familia = (SELECT TOP 1 prod_familia
                            FROM Factura f1
                           	JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
                        	JOIN Producto ON item_producto = prod_codigo
                            WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)
                            GROUP BY prod_familia
                            ORDER BY SUM(item_cantidad)  DESC)) AS CantFacturas,
	(SELECT TOP 1 fact_cliente 
	FROM Factura
	JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
	JOIN Producto ON prod_codigo = item_producto
	WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha) AND prod_familia = (SELECT TOP 1 prod_familia
                            FROM Factura f1
                           	JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
                        	JOIN Producto ON item_producto = prod_codigo
                            WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)
                            GROUP BY fact_cliente, prod_familia
                            ORDER BY SUM(item_cantidad) DESC)) as ClienteQueMasCompro ,
	(SELECT SUM(item_cantidad*item_precio) 
	FROM Factura
	JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
	JOIN Producto ON prod_codigo = item_producto
	WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha) AND prod_familia = (SELECT TOP 1 prod_familia
                            FROM Factura f1
                           	JOIN Item_Factura ON f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=item_tipo+item_sucursal+item_numero
                        	JOIN Producto ON item_producto = prod_codigo
                            WHERE YEAR(f1.fact_fecha) = YEAR(f.fact_fecha)))* 100 / SUM(fact_total) as Porcentaje                          
FROM Factura f 
GROUP BY YEAR(f.fact_fecha)

/* 26. Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
 Empleado
 Depósitos que tiene a cargo
 Monto total facturado en el año corriente
 Codigo de Cliente al que mas le vendió
 Producto más vendido
 Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor. */

SELECT 
empl_codigo, 

(SELECT COUNT(*) FROM Deposito 
WHERE depo_encargado = empl_codigo) AS depoACargo,

SUM(fact_total) as montoTotal,

(SELECT TOP 1 fact_cliente FROM Factura
WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha)
															FROM Factura
															GROUP BY YEAR(fact_fecha)
															ORDER BY MAX(fact_fecha) DESC)
GROUP BY fact_cliente
ORDER BY SUM(fact_total) DESC) as clienteAlQueMasLeVendio,

(SELECT TOP 1 item_producto FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha)
							FROM Factura
							GROUP BY YEAR(fact_fecha)
							ORDER BY MAX(fact_fecha) DESC)
GROUP BY item_producto
ORDER BY SUM(item_cantidad) DESC),

SUM(fact_total) * 100 / (SELECT SUM(fact_total) FROM Factura
WHERE YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha)
							FROM Factura
							GROUP BY YEAR(fact_fecha)
							ORDER BY MAX(fact_fecha) DESC))
FROM Empleado
LEFT JOIN Factura ON fact_vendedor = empl_codigo
WHERE YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha)
							FROM Factura
							GROUP BY YEAR(fact_fecha)
							ORDER BY MAX(fact_fecha) DESC)
GROUP BY empl_codigo


/* 27. Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor */

/* 28. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.*/


SELECT 
	YEAR(f.fact_fecha) AS ANIO,
	f.fact_vendedor,
	empl_nombre,
	COUNT(distinct fact_tipo+fact_sucursal+fact_numero) AS cantFacturas,
	COUNT(distinct fact_cliente) cantClientes,
	(SELECT COUNT(distinct item_producto) FROM Item_Factura 
	JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND fact_vendedor = f.fact_vendedor AND (SELECT COUNT(*) FROM Composicion WHERE comp_producto = item_producto) > 0) AS cantProdConCompo,
	(SELECT COUNT(distinct item_producto) FROM Item_Factura 
	JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND fact_vendedor = f.fact_vendedor AND (SELECT COUNT(*) FROM Composicion WHERE comp_producto = item_producto) = 0) AS cantProdSinCompo,
	SUM(item_precio*item_cantidad) AS MontoTotal
FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Empleado ON fact_vendedor = empl_codigo
GROUP BY fact_vendedor, empl_nombre, YEAR(f.fact_fecha)
ORDER BY YEAR(f.fact_fecha), SUM(item_precio*item_cantidad) DESC



/* 29. Se solicita que realice una estadística de venta por producto para el año 2011, solo para
los productos que pertenezcan a las familias que tengan más de 20 productos asignados
a ellas, la cual deberá devolver las siguientes columnas:
a. Código de producto
b. Descripción del producto
c. Cantidad vendida
d. Cantidad de facturas en la que esta ese producto
e. Monto total facturado de ese producto
Solo se deberá mostrar un producto por fila en función a los considerandos establecidos
antes. El resultado deberá ser ordenado por el la cantidad vendida de mayor a menor. */

SELECT prod_codigo, prod_detalle, SUM(item_cantidad), COUNT(fact_numero), SUM(fact_total)
FROM Producto
JOIN Item_Factura on item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
group by prod_codigo, prod_detalle
order by 3

/* 30. Se desea obtener una estadistica de ventas del año 2012, para los empleados que sean
jefes, o sea, que tengan empleados a su cargo, para ello se requiere que realice la
consulta que retorne las siguientes columnas:
 Nombre del Jefe
 Cantidad de empleados a cargo
 Monto total vendido de los empleados a cargo
 Cantidad de facturas realizadas por los empleados a cargo
 Nombre del empleado con mejor ventas de ese jefe
Debido a la perfomance requerida, solo se permite el uso de una subconsulta si fuese
necesario.
Los datos deberan ser ordenados por de mayor a menor por el Total vendido y solo se
deben mostrarse los jefes cuyos subordinados hayan realizado más de 10 facturas. */


/* 31. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor. */

/* 32. Se desea conocer las familias que sus productos se facturaron juntos en las mismas
facturas para ello se solicita que escriba una consulta sql que retorne los pares de
familias que tienen productos que se facturaron juntos. Para ellos deberá devolver las
siguientes columnas:
 Código de familia
 Detalle de familia
 Código de familia
 Detalle de familia
 Cantidad de facturas
 Total vendido
Los datos deberan ser ordenados por Total vendido y solo se deben mostrar las familias
que se vendieron juntas más de 10 veces. */


/* 33. Se requiere obtener una estadística de venta de productos que sean componentes. Para
ello se solicita que realiza la siguiente consulta que retorne la venta de los
componentes del producto más vendido del año 2012. Se deberá mostrar:
a. Código de producto
b. Nombre del producto
c. Cantidad de unidades vendidas
d. Cantidad de facturas en la cual se facturo
e. Precio promedio facturado de ese producto.
f. Total facturado para ese producto
El resultado deberá ser ordenado por el total vendido por producto para el año 2012. */

/* 34. Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
facturadas por cada mes del año 2011 Se considera que una factura es incorrecta cuando
en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
mal hechas se debe retornar 0. Las columnas que se deben mostrar son:
1- Codigo de Rubro
2- Mes
3- Cantidad de facturas mal realizadas. */

/* 35. Se requiere realizar una estadística de ventas por año y producto, para ello se solicita
que escriba una consulta sql que retorne las siguientes columnas:
 Año
 Codigo de producto
 Detalle del producto
 Cantidad de facturas emitidas a ese producto ese año
 Cantidad de vendedores diferentes que compraron ese producto ese año.
 Cantidad de productos a los cuales compone ese producto, si no compone a ninguno
se debera retornar 0.
 Porcentaje de la venta de ese producto respecto a la venta total de ese año.
Los datos deberan ser ordenados por año y por producto con mayor cantidad vendida */