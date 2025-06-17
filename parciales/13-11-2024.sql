-- ========== SQL ========== --

/* 1. Realizar una consulta que muestre, para los clientes que compraron 
únicamente en años pares, la siguiente información: 
    - El numero de fila
    - el codigo de cliente
    - el nombre del producto más comprado por el cliente
    - la cantidad total comprada por el cliente en el último año

El resultado debe estar ordenado en función de la cantidad máxima comprada por cliente
de mayor a menor    
*/ 

SELECT f.fact_cliente, 
    (SELECT TOP 1 item_producto FROM Factura
        JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
        WHERE fact_cliente = f.fact_cliente 
        ORDER BY SUM(item_cantidad) DESC ),
    (SELECT prod_detalle FROM Producto
        WHERE prod_codigo = (SELECT TOP 1 item_producto FROM Factura
                            JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                            WHERE fact_cliente = f.fact_cliente 
                            ORDER BY SUM(item_cantidad) DESC )),
    (SELECT SUM(item_cantidad) 
        FROM Factura f
        JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
        WHERE fact_cliente = f.fact_cliente AND item_producto = (SELECT TOP 1 item_producto FROM Factura
                            JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                            WHERE fact_cliente = f.fact_cliente 
                            ORDER BY SUM(item_cantidad) DESC ))
FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
WHERE YEAR(fact_fecha) MOD 2 = 0 


-- ========== T-SQL ========== --

/*
Implementar un sistema de auditoria para registrar cada operacion realizada en la tabla 
cliente. El sistema debera almacenar, como minimo, los valores(campos afectados), el tipo 
de operacion a realizar, y la fecha y hora de ejecucion. SOlo se permitiran operaciones individuales
(no masivas) sobre los registros, pero el intento de realizar operaciones masivas deberá ser registrado
en el sistema de auditoria
*/

CREATE TABLE AUDITORIA(
    audi_operacion char(100),
    audi_codigo char(6),
    audi_razon_social char(10),
    audi_telefono char(100),
    audi_domicilio char(100),
    audi_limite_credito decimal(12, 2),
    audi_vendedor numeric(6)
)

CREATE TRIGGER auditoria ON Cliente AFTER INSERT
AS
BEGIN 
    
    IF((SELECT COUNT(*) FROM Cliente) > 1)
    BEGIN 
        print 'Se intentó realizar una operacion masiva'
        INSERT INTO AUDITORIA(audi_operacion) VALUES('INSERCION MASIVA')
    END
    ELSE
    BEGIN
        INSERT INTO AUDITORIA(
            audi_operacion,
            audi_codigo,
            audi_razon_social,
            audi_telefono, 
            audi_domicilio,
            audi_limite_credito, 
            audi_vendedor 
        )
        SELECT 'AFTER', clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor
        FROM INSERTED 

    END
END 

-- PRUEBA INSERCION MASIVA --
BEGIN TRANSACTION 
INSERT INTO Cliente(
            clie_codigo, 
			clie_razon_social, 
			clie_telefono, 
			clie_domicilio, 
			clie_limite_credito, 
			clie_vendedor) 
			VALUES
			('999999', 'HOLAAAAAAA', '23666145', 'CALLE SIEMPRE VIVA', 99999999, 1),
			('9999', 'HO+AAA', '23666145', 'CAL SIEMPRE VIVA', 99999999, 2)
ROLLBACK TRANSACTION

-- PRUEBA INSERCION NO MASIVA --
BEGIN TRANSACTION 
INSERT INTO Cliente(
            clie_codigo, 
			clie_razon_social, 
			clie_telefono, 
			clie_domicilio, 
			clie_limite_credito, 
			clie_vendedor) 
			VALUES
			('999999', 'HOLAAAAAAA', '23666145', 'CALLE SIEMPRE VIVA', 99999999, 1)
ROLLBACK TRANSACTION