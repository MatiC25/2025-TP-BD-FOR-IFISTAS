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

/* 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

	-- == CLASE PREENCIAL ==
/*
11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.
*/

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

/*
13. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías
*/

alter function sumaSalariosEmpleadosACargo(@jefe numeric(6))
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


alter procedure ej13reglaSalario
AS
BEGIN
    declare @sumaSalario decimal(12,2), @salarioaux decimal(12,2), @emplaux numeric(6)
    declare c3 cursor for 
        SELECT dbo.sumaSalariosEmpleadosACargo(e1.empl_codigo) as sumaSalario , e1.empl_salario as Salario , e1.empl_codigo as Codigo FROM Empleado e1 WHERE (SELECT COUNT(*) FROM Empleado where e1.empl_codigo = empl_jefe) > 0

    open c3
    fetch next from c3 into @sumaSalario, @salarioaux, @emplaux
    WHILE @@FETCH_STATUS = 0
    BEGIN 
        if(@sumaSalario*0.20 < @salarioaux)
            print 'El empleado ' + CONVERT(varchar, @emplaux) + ' rompe con la regla'
        else 
            print 'Nadie rompe con la regla'
        fetch next from c3 into @sumaSalario, @salarioaux, @emplaux
    END
    close c3
    deallocate c3
END

exec dbo.ej13reglaSalario

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


/*15. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.
*/

create function sumaComponentes(@prod char(8))
returns decimal(12,2)
AS
BEGIN
	return (SELECT SUM(prod_precio*comp_cantidad) --SUM(prod_precio) 
	FROM Composicion
	JOIN Producto on prod_codigo = comp_componente 
	WHERE comp_producto = @prod)		
END

alter function ej15PrecioTotal(@prod char(8))
returns decimal(12,2)
AS
BEGIN
	declare @precioTotal decimal(12,2 )
	if((SELECT COUNT(*) FROM Composicion WHERE comp_producto = @prod) > 0) 
		set @precioTotal = dbo.sumaComponentes(@prod) 
	else 
		set @precioTotal = (select prod_precio FROM Producto WHERE prod_codigo = @prod)
	return @precioTotal
END

SELECT prod_codigo, prod_precio, dbo.ej15PrecioTotal(prod_codigo) as PrecioReal, (SELECT COUNT(*) FROM Composicion WHERE comp_producto = prod_codigo) as cantComponentes 
FROM Producto
order by 4 desc

/*
16. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.
*/

create trigger actualizarStock ON Item_factura AFTER INSERT
AS
BEGIN 
	declare @prodaux char(8), @cantaux decimal(12,2)
	declare c1 cursor for SELECT item_producto, item_cantidad FROM inserted
	open c1
	fetch next from c1 into @prodaux, @cantaux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		WHILE @cantaux > 0
		BEGIN
			declare @depo char(2), @stockActual decimal(12,2)
			SELECT TOP 1 @depo = stoc_deposito, 
						 @stockActual = stoc_deposito 
							FROM STOCK 
							WHERE stoc_producto = @prodaux order by stoc_cantidad desc
			
			if((@stockActual - @cantaux) >= 0  OR @stockActual = 0)  -- Si alcanza el stock o si el stock es cero
			BEGIN 
				UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cantaux
				WHERE stoc_producto = @prodaux AND stoc_deposito = @depo
				set @cantaux = 0
			END

			if(((@stockActual - @cantaux)) < 0) -- Si el stock no es suficiente y hay más depositos con ese producto
			BEGIN 
				set @cantaux = @cantaux - @stockActual
				UPDATE STOCK SET stoc_cantidad = 0
				WHERE stoc_producto = @prodaux AND stoc_deposito = @depo
			END
		END
		fetch next from c1 into @prodaux, @cantaux
	END
	close c1
	deallocate c1
END

/*
17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/

create trigger checkStock ON STOCK AFTER INSERT
AS
BEGIN 
	declare @stocProdAux char(8), @depoAux char(2)
	declare c1 cursor for SELECT stoc_producto, stoc_deposito FROM inserted 
	open c1
	fetch next from c1 into @stocProdAux, @depoAux 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		declare @stockActual decimal(12,2), @puntoRepo decimal(12,2), @puntoMax decimal(12,2)
		SELECT @stockActual = stoc_cantidad, @puntoRepo = stoc_punto_reposicion, @puntoMax = stoc_stock_maximo FROM STOCK 
													WHERE stoc_producto = @stocProdAux AND stoc_deposito = @depoAux 
		if(@stockActual < @puntoRepo ) print 'Es hora de una reposicion'

		if(@stockActual > @puntoMax)
		BEGIN 
			declare @dif decimal(12,2)
			set @dif = @stockActual - @puntoMax
			print 'Se excedió del stock maximo'

			update STOCK set stoc_cantidad = stoc_stock_maximo
			WHERE stoc_producto = @stocProdAux AND stoc_deposito = @depoAux 

			declare @otroDeposito CHAR(2)

			SELECT TOP 1 @otroDeposito = stoc_deposito 
			FROM STOCK 
			WHERE stoc_producto = @stocProdAux AND stoc_deposito <> @depoAux 
			ORDER BY stoc_cantidad ASC -- El depo que menos stock tenga

			if(@otroDeposito IS NOT NULL) -- Checkeamos que haya otro deposito para ese producto 
			BEGIN
				update STOCK 
				set stoc_cantidad = stoc_cantidad + @dif
				WHERE stoc_producto = @stocProdAux AND stoc_deposito = @otroDeposito
			END
		END
		FETCH NEXT FROM c1 INTO @stocProdAux, @depoAux
	END
	close c1
	deallocate c1
END

/*
18. Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas
*/

create trigger checkLimiteMax ON Factura INSTEAD OF INSERT
AS
BEGIN 
	declare @fact_id char(13), @facTotalAux decimal(12,2), @clieAux char(6), @fechaAux smalldatetime
	declare c1 cursor for SELECT fact_tipo+fact_sucursal+fact_numero , fact_total, fact_cliente, fact_fecha FROM inserted 
	open c1 
	fetch next from c1 into @fact_id, @facTotalAux, @clieAux, @fechaAux

	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @checkLimite decimal(12,2), @limiteMax decimal(12,2)
		SELECT @checkLimite = SUM(fact_total) FROM Factura
														WHERE fact_cliente = @clieAux AND MONTH(fact_fecha) = MONTH(@fechaAux) -- Checkeamos que sea del ultimo mes, 
																															   -- no comparo por año xq se supone que las facturas nuevas son del año actual
		SELECT @limiteMax = clie_limite_credito FROM Cliente WHERE clie_codigo = @clieAux
		if(@checkLimite + @facTotalAux <= @limiteMax) -- Si la suma de la factura actual y todas las anterios está dentro del limite 
		BEGIN 
			INSERT INTO Factura (
				fact_tipo, fact_sucursal, fact_numero, fact_fecha, 
				fact_vendedor, fact_total, fact_total_impuestos, fact_cliente
			)
			SELECT fact_tipo, fact_sucursal, fact_numero, fact_fecha, 
				   fact_vendedor, fact_total, fact_total_impuestos, fact_cliente
			FROM inserted
			WHERE fact_tipo+fact_sucursal+fact_numero = @fact_id -- Para buscar los datos que se estaba insertando necesitamos un id
																 -- en el cursor se pueden guardar los 3 parametros x separado
																 -- pero para simplificar lo guardé en uno 
		END
		ELSE
		BEGIN 
			print 'El cliente ' + @clieAux  + ' se pasó del limite'
		END
	END
	close c1
	deallocate c1
END

/*
19. Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.
*/


/*
20. Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.
*/

/*
21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.
*/
/*
22. Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada.
*/
/*
23. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.
*/
/*
24. Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.
*/
/*
25. Desarrolle el/los elementos de base de datos necesarios para que no se permita
que la composición de los productos sea recursiva, o sea, que si el producto A
compone al producto B, dicho producto B no pueda ser compuesto por el
producto A, hoy la regla se cumple.
*/
/*
26. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

/*
27. Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.
*/
/*
28. Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes el vendedor que le corresponda, entendiendo que el vendedor que le
corresponde es aquel que le vendió más facturas a ese cliente, si en particular un
cliente no tiene facturas compradas se le deberá asignar el vendedor con más
venta de la empresa, o sea, el que en monto haya vendido más.
*/
/*
29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de diferentes productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/
/*
30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/
/*
31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
asignarle se le deberá colocar como jefe al gerente general que es aquel que no
tiene jefe.*/
