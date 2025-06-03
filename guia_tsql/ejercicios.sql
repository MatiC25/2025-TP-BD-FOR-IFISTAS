/*
1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.
*/

create function ej1 (@articulo char(8), @deposito char(2))
returns varchar(40)
as 
BEGIN
    declare @stocK numeric(12,2), @maximo numeric(12,2)
    select @stock=isnull(stoc_cantidad,0), @maximo=isnull(stoc_stock_maximo,0)
    from stock
    where stoc_producto = @articulo and stoc_deposito = @deposito and stoc_cantidad > 0
    if (@stocK >= @maximo or @maximo = 0)
        return 'DEPOSITO COMPLETO'
    RETURN 'OCUPACION DEL DEPOSITO '+@deposito+' '+STR(@stock/@maximo*100,5,2)+'%'    
END
GO

/*
2. Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha
*/

/*
3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/

create procedure ej3 @cantidad int OUTPUT
as 
begin 
    declare @jefe numeric(6)
    select @jefe = (select Top 1 empl_codigo from empleado where empl_jefe is null 
                                    order by empl_salario desc, empl_ingreso asc)
    select @cantidad = count(*) from Empleado where empl_jefe is null
    print @cantidad
    if @cantidad > 1
        update empleado set empl_jefe = @jefe where empl_jefe is null and empl_codigo <> @jefe 
    return
end 
go 


begin 
declare @cant INT
select @cant = 0
exec dbo.ej3 @cant 
print @cant 
end 

select count(*) from empleado where empl_jefe is NULL

update empleado set empl_jefe = null where empl_jefe = 1 

/*
4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.
*/

create procedure ej4 @empl_codigo numeric(6) OUTPUT
AS
BEGIN 
    declare empl_cursor cursor for SELECT empl_codigo FROM Empleado, @empleado numeric(6)
    open empl_cursor
    fetch next from empl_cursor into @empleado
    WHILE @@FETCH_STATUS = 0
        BEGIN
            select @montoActual = 0
            @montoActual = dbo.sumatoria_total_vendido(@empleado)
            update Empleado set empl_comision = empl_comision + @montoActual
        END
        return (SELECT TOP 1 empl_codigo FROM Empleado
                ORDER BY empl_comision DESC)
END

GO
alter procedure ej4
AS
BEGIN 
    update Empleado set empl_comision = dbo.sumatoria_total_vendido_ultimo_anio(empl_codigo)
        return SELECT TOP 1 empl_codigo FROM Empleado
                ORDER BY empl_comision DESC
END

create function sumatoria_total_vendido_ultimo_anio(@empleado numeric(6)) -- empl_codigo
returns decimal(12,2)
AS
BEGIN 
    declare @montoTotal decimal(12,2)
    SELECT @montoTotal = (SELECT SUM(fact_total) AS total_vendido
                            FROM Factura 
                            WHERE fact_vendedor = @empleado AND 
                                year(fact_fecha) = (SELECT TOP 1 year(fact_fecha) FROM Factura ORDER BY 1 DESC)
                            )
    return @montoTotal
END

--muybien10

/*
5. Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)
*/

create procedure ej5
as
    INSERT INTO Fact_table()


Create table Fact_table
(anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2))

Alter table Fact_table
Add constraint primary key(anio, mes, familia, rubro, zona, cliente, producto)

/*
6. Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.
*/


/*
7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock generados por
las ventas entre esas fechas. La tabla se encuentra creada y vacía.
*/

/*
8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:
*/


-- Devuelve la sumatoria de su precio con los precios de los productos compuestos 
create function precio_compuesto(@prod char(8))
returns decimal(12,2)
as
BEGIN
    declare @comp char(8), @cantidad decimal(12,2), @precio_producto decimal(12,2)
    if(select count(*) from Composicion where comp_producto = @prod) = 0
        select @precio_producto = (select prod_precio from Producto where prod_codigo = @prod)
    else
    BEGIN
        declare compo cursor for select comp_componente, comp_cantidad from Composicion
                                        join Producto on prod_codigo = comp_componente
                                        where comp_producto = @prod
        open compo
        fetch next from compo into @comp, @cantidad
		select @precio_producto = 0
        while @@FETCH_STATUS = 0
        BEGIN
            select @precio_producto = @precio_producto + @cantidad * dbo.precio_compuesto(@comp)
            fetch next from compo into @comp, @cantidad
        END
        close compo
        deallocate compo
    END
    return @precio_producto
END


create procedure ej8 
as 
BEGIN
    insert diferencias 
    (select prod_codigo, prod_detalle, (select count(*) from composicion where comp_producto = prod_codigo), dbo.precio_compuesto(item_producto), item_precio
    from Item_Factura join producto on prod_codigo = item_producto 
    where item_producto in (select comp_producto from composicion) and item_precio <> dbo.precio_compuesto(item_producto)
    group by prod_codigo, item_producto, prod_detalle, item_precio)
    return 
end

/*
9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.
*/


	-- == CLASE PREENCIAL ==
/*
Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.
*/
GO
alter function cantEmpleadosACargo(@empleado numeric(6))
returns decimal(12,2)
as
BEGIN
	declare @cant decimal(12,2), @emplaux numeric(6)
	declare empl_cur cursor for select empl_codigo from Empleado where empl_jefe = @empleado
																
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

select count(*) from Empleado where empl_jefe = 3
GO
BEGIN TRANSACTION
select cantidadACargo = dbo.cantEmpleadosACargo(1)
rollback transaction
 select count (*), empl_codigo from Empleado where empl_jefe = 3
																group by empl_codigo

/*12. Cree el/los objetos de base de datos necesarios para que nunca un producto
p
ueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/

go
create trigger noCompuesto on Composicion after insert 
AS
BEGIN 
	if((select SUM(dbo.esComponente(comp_producto, comp_componente)) from inserted) > 0) ROLLBACK
END
 
GO
create function esComponente(@prod1 char(8), @prod2 char(8))
returns BIGINT 
as
BEGIN
	if(@prod1 = @prod2) RETURN 1
	ELSE
		BEGIN
		declare @prod_aux char(8)
		declare c1 cursor for SELECT comp_componente FROM Composicion where comp_producto = @prod2								
		open c1
		fetch next from c1 into @prod_aux
		WHILE @@FETCH_STATUS = 0
		if(dbo.esComponente(@prod1, @prod_aux) = 1) return 1
		fetch next from c1 into @prod_aux
		END
	return 0
END	

/*Agregar el/los objetos necesarios para que si un cliente compra un producto
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



create function sumaComponentes(@prod char(8))
returns decimal(12,2)
AS
BEGIN
	return (SELECT SUM(prod_precio*comp_cantidad) --SUM(prod_precio) 
	FROM Composicion
	JOIN Producto on prod_codigo = comp_componente 
	WHERE comp_producto = @prod
	GROUP BY @prod)		
END
GO
create procedure guardarItemFactura(@prodaux char(8))
as
BEGIN
INSERT INTO Item_Factura (
			item_tipo,
			item_sucursal,
			item_numero,
			item_producto,
			item_cantidad,
			item_precio
			)
			(SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio FROM Item_Factura JOIN Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
																				WHERE item_producto = @prodaux)
END

