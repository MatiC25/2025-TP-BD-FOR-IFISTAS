-- == SQL == --

/* 1. El objetivo es realizar una consulta sql que indentifique a los vendedores que durante los ultimos
tres años consecutivos, incrementaron sus ventas en un 100% cada año respecto al año anterior

    1) El numero de fila 
    2) El nombre del vendedor 
    3) La cantidad de empleados a cargo de cada vendedor 
    4) La cantidad de clientes a los que vendió en total

El resultado debe estar ordenado en forma descendente segun el monto total de ventas del vendedor (de mayor a menor)
*/

SELECT 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    e.empl_nombre,
    (SELECT COUNT(*) 
	FROM Empleado 
	WHERE empl_jefe = e.empl_codigo) AS genteACargo,
    COUNT(distinct fact_cliente) as ClientesDiferentes
FROM Empleado e
LEFT JOIN Factura f0 ON e.empl_codigo = fact_vendedor
GROUP BY e.empl_nombre, e.empl_codigo, YEAR(f0.fact_fecha)
HAVING e.empl_codigo IN (
    SELECT empl_codigo
        FROM Empleado
        JOIN Factura f1 ON f1.fact_vendedor = empl_codigo
        JOIN Factura f2 ON f2.fact_vendedor = empl_codigo
		WHERE YEAR(f0.fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha) FROM Factura ORDER BY 1 DESC)
			AND YEAR(f1.fact_fecha) = YEAR(f0.fact_fecha) - 1 
			AND YEAR(f2.fact_fecha) = YEAR(f1.fact_fecha) - 1 
		GROUP BY empl_codigo, YEAR(f1.fact_fecha), YEAR(f2.fact_fecha)
        HAVING SUM(f0.fact_total) >= 2 * SUM(f1.fact_total)
            AND SUM(f1.fact_total) >= 2 * SUM(f2.fact_total)
)

-- == TSQL == --

/*2) Se requiere diseñar e implementar los objetos necesarios para gestionar un sistema
de comisiones de vendedores, La lógica debe contemplar los siguientes aspectos:

    1) Registro de comisiones:
        Se debe almacenar la comision correspondiente a cada vendedor por cada factura emitidas
        El porcentaje de comision se obtiene de la tabla empl_comisionm que refleja el porcentaje
        asignado al vendedor en ese momento 
    2) Manejo de cambios en el porcentaje de comision:
        El porcentaje de comision puede variar a lo largo del tiempo 
        Sin embargo, dentro de un mismo mes, todas las facturas deben aplicar el mismo porcentaje
        de comision vigente para ese mes (que es el ultimo cargado)
    3) Visualizacion dinamica
        La Visualizacion de la informacion debe ser dinámica y generarse en cualquier momento a partir 
        de las estructuras estáticas de datos
        El sistema debe permitir consultar:
            El porcentaje de comision y el monto correspondiente factura por factura
            El acumulado mensual de las comisiones para cada vendedor, reflejando los valores
            calculados en base a las reglas establecidas
*/