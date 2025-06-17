-- ========== SQL ========== --

/* 1. Diseñar una consulta SQL que identificque a los vendedores cuya suma de ventas durantes los ultimos dos meses
consecuetivos ha sido inferior a la suma de ventas en los mismos dos meses consecutivos de la años anterior

    - el numero de fila
    - el nombre del vendedor
    - la cantidad de empleados a cargo de cada vendedor
    - la cantidad de clientes a los que vendio en total

El resultado debe estar ordenado en forma descendente segun el monto total de ventas 
del vendedor (de mayor a menor)

*/ 

SELECT 
    e.empl_nombre, 
    e.empl_apellido,
    (SELECT COUNT(*) FROM Empleado WHERE empl_jefe = e.empl_codigo) AS subordinados,
    COUNT(DISTINCT c.clie_codigo) AS clientes
FROM Empleado e
JOIN Cliente c ON c.clie_vendedor = e.empl_codigo
WHERE 
    (
        SELECT SUM(fact_total)
        FROM Factura
        WHERE fact_vendedor = e.empl_codigo
          AND YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
          AND MONTH(fact_fecha) > ((
                SELECT MAX(MONTH(fact_fecha))
                FROM Factura
                WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
            ) - 2) 
    ) < (
        SELECT SUM(fact_total)
        FROM Factura
        WHERE fact_vendedor = e.empl_codigo
          AND YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura) - 1
          AND MONTH(fact_fecha) > ((
                SELECT MAX(MONTH(fact_fecha))
                FROM Factura
                WHERE YEAR(fact_fecha) = ((SELECT MAX(YEAR(fact_fecha)) FROM Factura) - 1)
            ) - 2)
    )
GROUP BY e.empl_nombre, e.empl_apellido, e.empl_codigo
ORDER BY e.empl_nombre DESC

-- ========== T-SQL ========== --

/* 2. Se requiere diseñar e implemetar los objetos necesarios para crear una regla que detecte inconsistencias en
las ventas en linea. En caso de detectar una incosistencia, deberá registrarse el detalle correspondiente en una estructura
adicional. POr el contrario, si no se encuentra ninguna incosistencia, se deberá registrar que la factura ha sido validada

Inconsistencias a considerar:
    1. Que el valor de fact_total no coincida con la suma de los precios multiplicados por la cantidades que los articulos
    2. Que se genere una factura con una fecha anterior al día actual
    3. Que se intente eliminar algun registro de una venta
*/

CREATE TABLE Regla(
    rg_clave_fact char(13),
    rg_validacion char(50)
)

CREATE TRIGGER reglaInconsistencia ON Factura AFTER INSERT
AS
BEGIN 
    DECLARE @fact_total decimal(12,2), @factClave char(13), @fecha SMALLDATETIME
    DECLARE C1 CURSOR FOR SELECT fact_total, fact_tipo+fact_sucursal+fact_numero, fact_fecha
                                    FROM INSERTED 
                                    JOIN Item_factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
    OPEN C1
    FETCH NEXT FROM C1 INTO @factTotal, @factClave, @fecha
    WHILE @@FETCH_STATUS = 0
    BEGIN
        if(@fac_total <> (SELECT SUM(item_cantidad*item_precio)
                                    FROM Factura
                                    JOIN Item_factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                                    WHERE fact_tipo+fact_sucursal+fact_numero = @factClave)
            OR DAY(@fecha) = DAY(GETDATE()) - 1)
        BEGIN
            INSERT INTO REGLA(rg_clave_fact, rg_validacion)VALUES(@factClave, 'INCONSISTENCIA') 
        END
        ELSE 
        BEGIN 
            INSERT INTO REGLA(rg_clave_fact, rg_validacion)VALUES(@factClave, 'VALIDADA') 
        END
        FETCH NEXT FROM C1 INTO @factTotal, @factClave, @fecha
    END
    CLOSE C1
    DEALLOCATE C1
END
