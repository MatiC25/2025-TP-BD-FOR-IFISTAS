

/*Realizar una consulta SQL que retorne para todas las zonas que tengan
3 (tres) o más depósitos.
    1) Detalle Zona
    2) Cantidad de Depósitos x Zona
    3) Cantidad de Productos distintos compuestos en sus depósitos
    4) Producto mas vendido en el año 2012 que tenga stock en al menos
    uno de sus depósitos.
    5) Mejor encargado perteneciente a esa zona (El que mas vendió en la
        historia).
El resultado deberá ser ordenado por monto total vendido del encargado
descendiente.
NOTA: No se permite el uso de sub-selects en el FROM ni funciones
definidas por el usuario para este punto.
*/

SELECT 
    z.zona_detalle,
    COUNT(distinct depo_codigo),
    (SELECT COUNT(distinct stoc_producto) 
        FROM Stock
        JOIN Deposito ON depo_codigo = stoc_deposito
		WHERE depo_codigo IN (SELECT depo_codigo 
									FROM Deposito
                                    WHERE depo_zona = z.zona_codigo)
                AND
                stoc_producto IN (SELECT comp_producto FROM Composicion) 
        GROUP BY depo_zona),
    (SELECT TOP 1 item_producto 
            FROM Factura 
            JOIN Item_factura ON fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
            WHERE YEAR(fact_fecha) = 2012 AND item_producto IN (SELECT stoc_producto FROM Stock 
                                                                    JOIN Deposito ON stoc_deposito = depo_codigo
                                                                    WHERE depo_zona = z.zona_codigo AND stoc_cantidad > 0
                                                                )
        GROUP BY item_producto
        ORDER BY SUM(item_cantidad) desc),
        (SELECT TOP 1 empl_codigo FROM Empleado
        JOIN Factura ON fact_vendedor = empl_codigo
        WHERE empl_departamento IN (SELECT depa_codigo FROM Departamento WHERE depa_zona = z.zona_codigo)
        GROUP BY empl_codigo
        ORDER BY SUM(fact_total) DESC)
FROM Zona z
JOIN Deposito ON depo_zona = z.zona_codigo
GROUP BY zona_detalle, zona_codigo

/*2. la Actualmente el campo fact_vendedor representa al empleado que vendió
la factura. Implementar el/los objetos necesarios para respetar
integridad referenciales de dicho campo suponiendo que no existe una
foreign key entre ambos.

NOTA: No se puede usar una foreign key para el ejercicio, deberá buscar
otro método */

CREATE TRIGGER ej1 ON Factura AFTER INSERT 
AS 
BEGIN
    IF EXISTS (SELECT fact_cliente FROM INSERTED
                WHERE fact_cliente NOT IN (SELECT empl_codigo FROM Empleado))
    BEGIN 
        RAISERROR('La factura fue realizada por un vendedor inexistente')
        ROLLBACK
    END
END