USE GD1C2025;
GO

-- ==================
--     Schema
-- ==================

CREATE SCHEMA FORIF_ISTAS AUTHORIZATION dbo
GO
-- ==================
-- TABLA: Provincia
-- ==================

CREATE TABLE FORIF_ISTAS.Provincia (
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50)
)
GO

ALTER TABLE FORIF_ISTAS.Provincia ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Provincia (prov_nombre)
        SELECT DISTINCT Cliente_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL
        UNION
        SELECT DISTINCT Proveedor_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Proveedor_Provincia IS NOT NULL
        UNION
        SELECT DISTINCT Sucursal_Provincia FROM GD1C2025.gd_esquema.Maestra WHERE Sucursal_Provincia IS NOT NULL
END
GO

-- ==================
-- TABLA: Localidad
-- ==================

CREATE TABLE FORIF_ISTAS.Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT
)
GO

ALTER TABLE FORIF_ISTAS.Localidad ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo)
GO
ALTER TABLE FORIF_ISTAS.Localidad ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES FORIF_ISTAS.Provincia(prov_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Localidad
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Localidad (loca_nombre, loca_provincia)
    SELECT DISTINCT m.Cliente_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Cliente_Provincia
    WHERE m.Cliente_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Proveedor_Provincia
    WHERE m.Proveedor_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Sucursal_Provincia
    WHERE m.Sucursal_Localidad IS NOT NULL
END
GO

-- ==================
-- TABLA: Direccion
-- ==================

CREATE TABLE FORIF_ISTAS.Direccion (
    dire_codigo INT IDENTITY(1,1),
    dire_calle_altura VARCHAR(75),
    dire_localidad INT
)
GO

ALTER TABLE FORIF_ISTAS.Direccion ADD CONSTRAINT PK_Direccion PRIMARY KEY (dire_codigo)
GO
ALTER TABLE FORIF_ISTAS.Direccion ADD CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (dire_localidad) REFERENCES FORIF_ISTAS.Localidad(loca_codigo)
GO
CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_Direccion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Direccion (dire_calle_altura, dire_localidad)
    SELECT DISTINCT m.Cliente_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Localidad l ON l.loca_nombre = m.Cliente_Localidad
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Cliente_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Cliente_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Localidad l ON l.loca_nombre = m.Proveedor_Localidad
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Proveedor_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Proveedor_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Localidad l ON l.loca_nombre = m.Sucursal_Localidad
    JOIN FORIF_ISTAS.Provincia p ON p.prov_nombre = m.Sucursal_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Sucursal_Direccion IS NOT NULL
END
GO

-- ==================
-- TABLA: Cliente
-- ==================

CREATE TABLE FORIF_ISTAS.Cliente (
    clie_codigo INT IDENTITY(1,1),
    clie_nombre VARCHAR(50),
    clie_apellido VARCHAR(50),
    clie_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50)  TODO
    clie_fecha_nacimiento DATETIME2,
    clie_mail VARCHAR(100),
    clie_telefono CHAR(8), 
    clie_dni CHAR(8)
)

GO

ALTER TABLE FORIF_ISTAS.Cliente ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo)
GO

ALTER TABLE FORIF_ISTAS.Cliente ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion) REFERENCES FORIF_ISTAS.Direccion (dire_codigo)
GO
CREATE OR ALTER PROCEDURE FORIF_ISTAS.Migracion_Cliente
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Cliente (
        clie_nombre,
        clie_apellido,
        clie_direccion,
        clie_fecha_nacimiento,
        clie_mail,
        clie_telefono,
        clie_dni
    )
    SELECT DISTINCT 
        m.Cliente_Nombre, 
        m.Cliente_Apellido, 
        d.dire_codigo, 
        m.Cliente_FechaNacimiento, 
        m.Cliente_Mail, 
        m.Cliente_Telefono, 
        m.Cliente_Dni
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN FORIF_ISTAS.Direccion d ON d.dire_calle_altura = m.Cliente_Direccion
    JOIN FORIF_ISTAS.Localidad l ON l.loca_codigo = d.dire_localidad AND l.loca_nombre = m.Cliente_Localidad
    JOIN FORIF_ISTAS.Provincia p ON p.prov_codigo = l.loca_provincia
                    AND p.prov_nombre = m.Cliente_Provincia
END
GO

-- ==================
-- TABLA: Envio
-- ==================

CREATE TABLE FORIF_ISTAS.Envio(
    envi_numero INT NOT NULL,
    envi_fecha_programada DATETIME2,
    envi_fecha_entrega DATETIME2, 
    envi_importe_traslado DECIMAL(10, 2),
    envi_importe_subida DECIMAL(10, 2)
)
GO

ALTER TABLE FORIF_ISTAS.Envio ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_numero)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Envio
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Envio (
        envi_numero,
        envi_fecha_programada,
        envi_fecha_entrega,
        envi_importe_traslado,
        envi_importe_subida
    )
    SELECT DISTINCT
        tm.Envio_Numero,
        tm.Envio_Fecha_Programada,
        tm.Envio_Fecha,
        tm.Envio_ImporteTraslado,
        tm.Envio_ImporteSubida
        from GD1C2025.gd_esquema.Maestra tm
        where tm.Envio_Numero IS NOT NULL
END
GO

-- ==================
-- TABLA: Sucursal
-- ==================

CREATE TABLE FORIF_ISTAS.Sucursal( 
    sucu_numero INT NOT NULL,
    sucu_direccion INT,
    sucu_telefono INT,
    sucu_mail VARCHAR(100)
)
GO

ALTER TABLE FORIF_ISTAS.Sucursal ADD CONSTRAINT PK_Sucursal_Numero PRIMARY KEY (sucu_numero)
GO

ALTER TABLE FORIF_ISTAS.Sucursal ADD CONSTRAINT FK_Sucursal_Direccion FOREIGN KEY (sucu_direccion) REFERENCES FORIF_ISTAS.Direccion (dire_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Sucursal
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Sucursal(
        sucu_numero,
        sucu_direccion,
        sucu_telefono,
        sucu_mail
    )
    SELECT DISTINCT
        tm.Sucursal_NroSucursal,
        d.dire_codigo,
        tm.Sucursal_telefono,
        tm.Sucursal_mail
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Direccion d ON d.dire_calle_altura = tm.Sucursal_Direccion
        JOIN FORIF_ISTAS.Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN FORIF_ISTAS.Provincia p ON p.prov_codigo = l.loca_provincia
                            AND p.prov_nombre = tm.Sucursal_Provincia
                            AND l.loca_nombre = tm.Sucursal_Localidad
        WHERE tm.Sucursal_NroSucursal IS NOT NULL
END
GO

-- ==================
-- TABLA: Factura
-- ==================

CREATE TABLE FORIF_ISTAS.Factura( 
    fact_numero INT NOT NULL,
    fact_sucursal INT NOT NULL, -- CODIGO asociado a la sucursal || VARCHAR(50)
    fact_cliente INT, -- CODIGO asociado al cliente || VARCHAR(50)
    fact_total DECIMAL(10, 2),
    fact_envio INT, -- Codigo asociado al envio
    fact_fecha_hora DATETIME2 -- DATETIME
)
GO

ALTER TABLE FORIF_ISTAS.Factura ADD CONSTRAINT PK_Fact_Numero PRIMARY KEY (fact_numero, fact_sucursal)
GO  

ALTER TABLE FORIF_ISTAS.Factura ADD CONSTRAINT FK_FACT_Envio FOREIGN KEY (fact_envio) REFERENCES FORIF_ISTAS.Envio (envi_numero)
GO
ALTER TABLE FORIF_ISTAS.Factura ADD CONSTRAINT FK_Fact_cliente FOREIGN KEY (fact_cliente) REFERENCES FORIF_ISTAS.Cliente (clie_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Factura
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Factura(
        fact_numero,
        fact_sucursal, --> Numero de sucursal asociado
        fact_cliente, --> Numero de cleinte asociado
        fact_total,
        fact_envio, --> Numero de Envio asociado
        fact_fecha_hora
    )
    SELECT DISTINCT
        tm.Factura_Numero,
        s.sucu_numero,
        c.clie_codigo,
        tm.Factura_Total,
        e.envi_numero,
        tm.Factura_Fecha
        FROM GD1C2025.gd_esquema.Maestra tm
        LEFT JOIN FORIF_ISTAS.Sucursal s on tm.Sucursal_NroSucursal = s.sucu_numero
        JOIN FORIF_ISTAS.Cliente c ON tm.Cliente_Dni = c.clie_dni 
                        AND tm.Cliente_Nombre = c.clie_nombre 
                        AND tm.Cliente_Apellido = c.clie_apellido
        JOIN FORIF_ISTAS.Envio e ON tm.Envio_Numero = e.envi_numero
        WHERE tm.Factura_Numero IS NOT NULL
END
GO


-- ==================
-- TABLA: Pedido
-- ==================

CREATE TABLE FORIF_ISTAS.Pedido (
    pedi_numero INT NOT NULL,
    pedi_sucursal INT, --> codigo asociado a la Sucursal
    pedi_cliente INT, --> codigo asociado al Cliente
    pedi_fecha_hora DATETIME2,
    pedi_total DECIMAL(10, 2),
    pedi_estado VARCHAR(10) --> Codigo asociado al Estado 
)
GO

ALTER TABLE FORIF_ISTAS.Pedido ADD CONSTRAINT PK_Pedido_Numero PRIMARY KEY (pedi_numero)
GO
ALTER TABLE FORIF_ISTAS.Pedido ADD CONSTRAINT FK_Pedido_Clinete FOREIGN KEY (pedi_cliente) REFERENCES FORIF_ISTAS.Cliente(clie_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Pedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Pedido (
        pedi_numero,
        pedi_sucursal,
        pedi_cliente,
        pedi_fecha_hora,
        pedi_total,
        pedi_estado
    )

    SELECT DISTINCT
        tm.Pedido_Numero,
        tm.Sucursal_NroSucursal,
        c.clie_codigo,
        tm.Pedido_Fecha,
        tm.Pedido_Total,
        tm.Pedido_Estado
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN FORIF_ISTAS.Cliente c ON tm.Cliente_Nombre = c.clie_nombre AND tm.Cliente_Apellido = c.clie_apellido AND tm.Cliente_Dni = c.clie_dni
    JOIN FORIF_ISTAS.Sucursal s ON tm.Sucursal_NroSucursal = s.sucu_numero
    WHERE tm.Pedido_Numero IS NOT NULL
END
GO

-- ==================
-- TABLA: Pedido Cancelacion
-- ==================

CREATE TABLE FORIF_ISTAS.Pedido_Cancelacion (
    pedi_c_numero INT NOT NULL, -- Numero asociado al numero de pedido (pedi_numero)
    pedi_c_fecha DATETIME2 NOT NULL,
    pedi_c_motivo VARCHAR(255) NOT NULL
) 
GO
ALTER TABLE FORIF_ISTAS.Pedido_Cancelacion ADD CONSTRAINT FK_Pedido_Cancelacion_Numero FOREIGN KEY (pedi_c_numero) REFERENCES FORIF_ISTAS.Pedido(pedi_numero)
GO
CREATE PROCEDURE FORIF_ISTAS.Migracion_Pedido_Cancelacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Pedido_Cancelacion (
        pedi_c_numero,
        pedi_c_fecha,
        pedi_c_motivo
    )

    SELECT DISTINCT
        p.pedi_numero,
        tm.Pedido_Cancelacion_Fecha,
        tm.Pedido_Cancelacion_Motivo
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Pedido p on p.pedi_numero = tm.Pedido_Numero
        WHERE tm.Pedido_Numero IS NOT NULL AND tm.Pedido_Cancelacion_Fecha IS NOT NULL AND tm.Pedido_Cancelacion_Motivo IS NOT NULL 
END
GO

-- ==================
-- TABLA: Proveedor
-- ==================

CREATE TABLE FORIF_ISTAS.Proveedor(
    prov_codigo INT IDENTITY(1,1),
    prov_razon_social VARCHAR(100) NOT NULL,
    prov_cuit VARCHAR(20), -- CUIT del proveedor
    prov_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50) TODO
    prov_telefono INT,
    prov_mail VARCHAR(100),

)
GO
ALTER TABLE FORIF_ISTAS.Proveedor ADD CONSTRAINT PK_Proveedor PRIMARY KEY(prov_codigo)
GO
ALTER TABLE FORIF_ISTAS.Proveedor ADD CONSTRAINT FK_Proveedor FOREIGN KEY(prov_direccion) REFERENCES FORIF_ISTAS.Direccion(dire_codigo)
GO
CREATE PROCEDURE FORIF_ISTAS.Migracion_Proveedor
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Proveedor (
        prov_razon_social,
        prov_cuit,
        prov_direccion,
        prov_telefono,
        prov_mail
    )

    SELECT DISTINCT 
        tm.Proveedor_RazonSocial,
        tm.Proveedor_Cuit,
        d.dire_codigo,
        tm.Proveedor_Telefono,
        tm.Proveedor_Mail
    FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Direccion d ON d.dire_calle_altura = tm.Proveedor_Direccion
        JOIN FORIF_ISTAS.Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN FORIF_ISTAS.Provincia p ON p.prov_codigo = l.loca_provincia
                            AND p.prov_nombre = tm.Proveedor_Provincia
                            AND l.loca_nombre = tm.Proveedor_Localidad
    WHERE tm.Proveedor_RazonSocial IS NOT NULL
END
GO

-- ==================
-- TABLA: Material
-- ==================

-- TODO: Ver como funciona el tema de la herencia hay que agregar uan FK para el tema de los poder entrar a el Material?? 
CREATE TABLE FORIF_ISTAS.Material(
    mate_codigo INT IDENTITY(1,1),-- Codigo material
    mate_nombre VARCHAR(100),
    mate_descipcion VARCHAR(255),
    mate_precio DECIMAL(10, 2),
    mate_tipo VARCHAR(20)
)
GO

ALTER TABLE FORIF_ISTAS.Material ADD CONSTRAINT PK_Material_Codigo PRIMARY KEY (mate_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Material
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Material(
        mate_nombre,
        mate_descipcion,
        mate_precio,
        mate_tipo
    )
    SELECT DISTINCT
        tm.Material_Nombre,
        tm.Material_Descripcion,
        tm.Material_Precio,
        tm.Material_Tipo
        FROM GD1C2025.gd_esquema.Maestra tm
        WHERE tm.Material_Nombre IS NOT NULL AND tm.Material_Tipo IS NOT NULL
END
GO


-- ==================
-- TABLA: Madera
-- ==================

CREATE TABLE FORIF_ISTAS.Madera(
    made_codigo INT NOT NULL,
    made_tipo VARCHAR(20),
    made_color VARCHAR(20),
    made_dureza VARCHAR(20)
)
GO

ALTER TABLE FORIF_ISTAS.Madera ADD CONSTRAINT FK_Madera_Codigo FOREIGN KEY (made_codigo) REFERENCES FORIF_ISTAS.Material (mate_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Madera
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Madera(
        made_codigo,
        made_tipo,
        made_color,
        made_dureza      
    )
    SELECT DISTINCT
        m.mate_codigo,
        tm.Material_Tipo,
        tm.Madera_Color,
        tm.Madera_Dureza
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Material m on tm.Material_Tipo = m.mate_tipo AND m.mate_nombre = tm.Material_Nombre
        WHERE tm.Madera_Color IS NOT NULL AND tm.Madera_Dureza IS NOT NULL
END
GO

-- ==================
-- TABLA: Tela
-- ==================

CREATE TABLE FORIF_ISTAS.Tela(
    tela_codigo INT NOT NULL,
    tela_tipo VARCHAR(20),
    tela_color VARCHAR(20),
    tela_textura VARCHAR(20)
)
GO

ALTER TABLE FORIF_ISTAS.Tela ADD CONSTRAINT FK_Tela_Codigo FOREIGN KEY (tela_codigo) REFERENCES FORIF_ISTAS.Material (mate_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Tela
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Tela(
        tela_codigo,
        tela_tipo,
        tela_color,
        tela_textura
    )
    SELECT DISTINCT
        m.mate_codigo,
        tm.Material_Tipo,
        tm.Tela_Color,
        tm.Tela_Textura
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Material m ON tm.Material_Tipo = m.mate_tipo AND m.mate_nombre = tm.Material_Nombre
        WHERE tm.Tela_Color IS NOT NULL AND tm.Tela_Textura IS NOT NULL
END
GO

-- ==================
-- TABLA: Relleno
-- ==================

CREATE TABLE FORIF_ISTAS.Relleno(
    rell_codigo INT NOT NULL,
    rell_tipo VARCHAR(20),
    rell_densidad DECIMAL(10,2)
    )
GO

ALTER TABLE FORIF_ISTAS.Relleno ADD CONSTRAINT PK_Relleno_Codigo FOREIGN KEY (rell_codigo) REFERENCES FORIF_ISTAS.Material (mate_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Relleno
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Relleno(
        rell_codigo,
        rell_tipo,
        rell_densidad
    )
    SELECT DISTINCT
        m.mate_codigo,
        tm.Material_Tipo,
        tm.Relleno_Densidad
        FROM GD1C2025.gd_esquema.Maestra tm
        join FORIF_ISTAS.Material m on tm.material_tipo = m.mate_tipo AND m.mate_nombre = tm.Material_Nombre
        WHERE tm.Relleno_Densidad IS NOT NULL
END
GO


-- ==================
-- TABLA: Modelo
-- ==================

CREATE TABLE FORIF_ISTAS.Modelo(
    mode_code INT NOT NULL, -- Codigo asociado de sill_modelo_codigo
    mode_descripcion VARCHAR(255)
)
GO

ALTER TABLE FORIF_ISTAS.Modelo ADD CONSTRAINT PK_Modelo PRIMARY KEY (mode_code)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Modelo
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Modelo(
        mode_code,
        mode_descripcion
    )
    SELECT DISTINCT
        tm.Sillon_Modelo_Codigo,
        tm.Sillon_Modelo_Descripcion
        FROM GD1C2025.gd_esquema.Maestra tm
        WHERE tm.Sillon_Modelo_Codigo IS NOT NULL
END
GO

-- ==================
-- TABLA: Medidas
-- ==================

CREATE TABLE FORIF_ISTAS.Medida(
    medi_codigo INT IDENTITY(1,1),
    medi_alto DECIMAL(10, 2),
    medi_ancho DECIMAL(10, 2),
    medi_profundo DECIMAL(10, 2),
    medi_precio DECIMAL(10, 2)    
)
GO

ALTER TABLE FORIF_ISTAS.Medida ADD CONSTRAINT PK_Medida PRIMARY KEY (medi_codigo);
GO 

CREATE PROCEDURE FORIF_ISTAS.Migracion_Medida
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Medida(
        medi_alto,
        medi_ancho,
        medi_profundo,
        medi_precio
    )
    SELECT DISTINCT
        tm.Sillon_Medida_Alto,
        tm.Sillon_Medida_Ancho,
        tm.Sillon_Medida_Profundidad,
        tm.Sillon_Medida_Precio
        FROM GD1C2025.gd_esquema.Maestra tm
        WHERE tm.Sillon_Medida_Alto IS NOT NULL AND tm.Sillon_Medida_Ancho IS NOT NULL AND tm.Sillon_Medida_Profundidad IS NOT NULL AND tm.Sillon_Medida_Precio IS NOT NULL
END
GO

-- ==================
-- TABLA: Sillon
-- ==================

CREATE TABLE FORIF_ISTAS.Sillon(
    sill_codigo INT NOT NULL,
    sill_modelo INT, -- CODIGO MODELO
    sill_medida INT -- CODIGO MEDIDAS (Auto Incremental)
)
GO
-- == Sillon == -- 
ALTER TABLE FORIF_ISTAS.Sillon ADD CONSTRAINT PK_Sillon PRIMARY KEY (sill_codigo)
GO
ALTER TABLE FORIF_ISTAS.Sillon ADD CONSTRAINT FK_Sillon_Modelo_Codigo FOREIGN KEY (sill_modelo) REFERENCES FORIF_ISTAS.Modelo(mode_code)
GO
ALTER TABLE FORIF_ISTAS.Sillon ADD CONSTRAINT FK_Sillon_Medida FOREIGN KEY (sill_medida) REFERENCES FORIF_ISTAS.Medida(medi_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Sillon
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Sillon(
        sill_codigo,
        sill_modelo,
        sill_medida
    )
    SELECT DISTINCT
        tm.Sillon_Codigo,
        tm.Sillon_Modelo_Codigo,
		m.medi_codigo
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Medida m on tm.Sillon_Medida_Alto = m.medi_alto AND
                         tm.Sillon_Medida_Ancho = m.medi_ancho AND
                         tm.Sillon_Medida_Profundidad = m.medi_profundo AND
                         tm.Sillon_Medida_Precio = m.medi_precio
        WHERE tm.Sillon_Codigo IS NOT NULL AND tm.Sillon_Modelo_Codigo IS NOT NULL
END
GO

-- ==================
-- TABLA: Sillon_Material
-- ==================

CREATE TABLE FORIF_ISTAS.Sillon_Material(
    sill_mate_codigo INT NOT NULL, -- Codigo materia x sillon
    sill_mate_material INT NOT NULL-- Codigo material
)
GO

ALTER TABLE FORIF_ISTAS.Sillon_Material ADD CONSTRAINT FK_Sillon_Material FOREIGN KEY (sill_mate_codigo) REFERENCES FORIF_ISTAS.Sillon(sill_codigo)
GO
ALTER TABLE FORIF_ISTAS.Sillon_Material ADD CONSTRAINT FK_Sillon_Material_Material FOREIGN KEY (sill_mate_material) REFERENCES FORIF_ISTAS.Material(mate_codigo);
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Sillon_Material
AS
BEGIN
    SET NOCOUNT ON;
        
    INSERT INTO FORIF_ISTAS.Sillon_Material(
        sill_mate_codigo,
        sill_mate_material
    )
    SELECT DISTINCT
        s.sill_codigo,
        m.mate_codigo
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN FORIF_ISTAS.Sillon s ON s.sill_codigo = tm.Sillon_Codigo AND s.sill_modelo = tm.Sillon_Modelo_Codigo
    JOIN FORIF_ISTAS.Material m ON m.mate_descipcion = tm.Material_Descripcion
END
GO

-- ==================
-- TABLA: Compra
-- ==================

CREATE TABLE FORIF_ISTAS.Compra(
    comp_numero INT NOT NULL,
    comp_sucursal INT, --> codigo asociado a la sucursal
    comp_proveedor INT, --> Codigo asociado al proveedor
    comp_fecha DATETIME2,
    comp_total DECIMAL(10, 2)
)
GO

ALTER TABLE FORIF_ISTAS.Compra ADD CONSTRAINT PK_Compra_ PRIMARY KEY (comp_numero)
GO
ALTER TABLE FORIF_ISTAS.Compra ADD CONSTRAINT FK_Compra_Sucursal FOREIGN KEY (comp_sucursal) REFERENCES FORIF_ISTAS.Sucursal(sucu_numero)
GO
ALTER TABLE FORIF_ISTAS.Compra ADD CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (comp_proveedor) REFERENCES FORIF_ISTAS.Proveedor(prov_codigo)
GO
ALTER TABLE FORIF_ISTAS.Compra ADD CONSTRAINT ck_compra_total CHECK (comp_total > 0)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Compra
AS
BEGIN
    SET NOCOUNT ON;
        
    INSERT INTO FORIF_ISTAS.Compra(
        comp_numero,
        comp_sucursal,
        comp_proveedor,
        comp_fecha,
        comp_total
    )
    SELECT DISTINCT
    tm.Compra_Numero,
    s.sucu_numero,
    p.prov_codigo,
    tm.Compra_Fecha,
    tm.Compra_Total
    FROM GD1C2025.gd_esquema.Maestra tm
    JOIN FORIF_ISTAS.Sucursal s ON s.sucu_numero = tm.Sucursal_NroSucursal
    JOIN FORIF_ISTAS.Proveedor p ON p.prov_cuit = tm.Proveedor_Cuit 
END
GO

-- ==================
-- TABLA: Item_Compra
-- ==================

CREATE TABLE FORIF_ISTAS.Item_Compra(
    item_c_numero INT NOT NULL, --> Numero asociado al numero de compra (comp_numero)
    item_c_material INT NOT NULL,  --> Codigo asociado al sillon
    item_c_precio DECIMAL(10, 2),
    item_c_cantidad INT,
)
GO

ALTER TABLE FORIF_ISTAS.Item_Compra ADD CONSTRAINT FK_Item_Compra FOREIGN KEY (item_c_numero) REFERENCES FORIF_ISTAS.Compra(comp_numero)
GO
ALTER TABLE FORIF_ISTAS.Item_Compra ADD CONSTRAINT FK_Item_Compra_Material FOREIGN KEY (item_c_material) REFERENCES FORIF_ISTAS.Material(mate_codigo)
GO
CREATE PROCEDURE FORIF_ISTAS.Migracion_Item_Compra
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Item_Compra(
        item_c_numero,
        item_c_material,
        item_c_precio,
        item_c_cantidad
    )
    SELECT DISTINCT 
        c.comp_numero,
        m.mate_codigo,
        tm.Detalle_Compra_Precio,
        tm.Detalle_Compra_Cantidad
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Compra c ON c.comp_numero = tm.Compra_Numero
        JOIN FORIF_ISTAS.Material m ON tm.Material_Descripcion = m.mate_descipcion
END
GO

-- ==================
-- TABLA: Item_Pedido
-- ==================

CREATE TABLE FORIF_ISTAS.Item_Pedido(
    item_p_numero INT NOT NULL, -- Numero asociado al numero de pedido (pedi_numero)
    item_p_sillon INT NOT NULL, -- Numero asociado al numero de sillo (sill_codigo)
    item_p_precio DECIMAL(10, 2),
    item_p_cantidad INT,
)
GO
ALTER TABLE FORIF_ISTAS.Item_Pedido ADD CONSTRAINT PK_Item_Pedido PRIMARY KEY (item_p_numero, item_p_sillon)
GO
ALTER TABLE FORIF_ISTAS.Item_Pedido ADD CONSTRAINT FK_Item_Pedido_Numero FOREIGN KEY (item_p_numero) REFERENCES FORIF_ISTAS.Pedido(pedi_numero)
GO
ALTER TABLE FORIF_ISTAS.Item_Pedido ADD CONSTRAINT FK_Item_Pedido_Sillon FOREIGN KEY (item_p_sillon) REFERENCES FORIF_ISTAS.Sillon(sill_codigo)
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Item_Pedido
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO FORIF_ISTAS.Item_Pedido(
        item_p_numero,
        item_p_sillon,
        item_p_precio,
        item_p_cantidad
    )
    SELECT DISTINCT 
        p.pedi_numero,
        s.sill_codigo,
        tm.Detalle_Pedido_Precio,
        tm.Detalle_Pedido_Cantidad
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Pedido p ON p.pedi_numero = tm.Pedido_Numero
        JOIN FORIF_ISTAS.Sillon s ON s.sill_codigo = tm.Sillon_Codigo 
        WHERE tm.Detalle_Pedido_Precio IS NOT NULL AND tm.Detalle_Pedido_Cantidad IS NOT NULL
END
GO

-- ==================
-- TABLA: Item_Pedido
-- ==================

CREATE TABLE FORIF_ISTAS.Item_Factura(
    item_f_numero INT IDENTITY(1,1),
    item_f_numero_pedido INT NOT NULL,
    item_f_sillon INT NOT NULL, -- Codigo asociado al sillon
    item_f_sucursal INT NOT NULL,
    item_f_numero_factura INT NOT NULL,
    item_f_cantidad INT,
    item_f_precio DECIMAL(10, 2)
)
GO

ALTER TABLE FORIF_ISTAS.Item_Factura ADD CONSTRAINT PK_Item_Factura PRIMARY KEY (item_f_numero);
GO
ALTER TABLE FORIF_ISTAS.Item_Factura ADD CONSTRAINT FK_Item_Factura_Numero_Pedido FOREIGN KEY (item_f_numero_pedido, item_f_sillon) REFERENCES FORIF_ISTAS.Item_Pedido(item_p_numero, item_p_sillon);
GO
ALTER TABLE FORIF_ISTAS.Item_Factura ADD CONSTRAINT FK_Item_Factura_Numero_Factura FOREIGN KEY (item_f_numero_factura, item_f_sucursal) REFERENCES FORIF_ISTAS.Factura(fact_numero, fact_sucursal);
GO

CREATE PROCEDURE FORIF_ISTAS.Migracion_Item_Factura
AS
BEGIN   
    SET NOCOUNT ON;

    INSERT INTO FORIF_ISTAS.Item_Factura(
        item_f_numero_pedido, --> Codigo asociado al pedido
        item_f_sillon, --> Codigo asociado al sillon
        item_f_sucursal, --> Codigo asociado a la sucursal
        item_f_numero_factura, --> Codigo asociado a item factura
        item_f_cantidad,
        item_f_precio
    )
    SELECT DISTINCT
        ip.item_p_numero,
        ip.item_p_sillon,
        f.fact_sucursal,
        f.fact_numero,
        ip.item_p_cantidad,
        ip.item_p_precio
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN FORIF_ISTAS.Item_Pedido ip ON ip.item_p_sillon = tm.Sillon_Codigo AND ip.item_p_numero = tm.Pedido_Numero
        JOIN FORIF_ISTAS.Pedido p ON p.pedi_numero = ip.item_p_numero
        JOIN FORIF_ISTAS.Factura f ON p.pedi_cliente = f.fact_cliente AND f.fact_sucursal = tm.Sucursal_NroSucursal
END
GO

-- ==================
-- EJECUTAR MIGRACIONES
-- ==================
 
EXEC FORIF_ISTAS.Migracion_Provincia
GO
EXEC FORIF_ISTAS.Migracion_Localidad
GO
EXEC FORIF_ISTAS.Migracion_Direccion
GO
EXEC FORIF_ISTAS.Migracion_Cliente
GO
EXEC FORIF_ISTAS.Migracion_Envio
GO
EXEC FORIF_ISTAS.Migracion_Sucursal
GO
EXEC FORIF_ISTAS.Migracion_Factura
GO
EXEC FORIF_ISTAS.Migracion_Pedido
GO
EXEC FORIF_ISTAS.Migracion_Pedido_Cancelacion
GO
EXEC FORIF_ISTAS.Migracion_Proveedor
GO
EXEC FORIF_ISTAS.Migracion_Material
GO
EXEC FORIF_ISTAS.Migracion_Madera
GO
EXEC FORIF_ISTAS.Migracion_Tela
GO
EXEC FORIF_ISTAS.Migracion_Relleno
GO
EXEC FORIF_ISTAS.Migracion_Modelo
GO
EXEC FORIF_ISTAS.Migracion_Medida
GO
EXEC FORIF_ISTAS.Migracion_Sillon
GO
EXEC FORIF_ISTAS.Migracion_Sillon_Material
GO
EXEC FORIF_ISTAS.Migracion_Compra
GO
EXEC FORIF_ISTAS.Migracion_Item_Compra
GO
EXEC FORIF_ISTAS.Migracion_Item_Pedido
GO
EXEC FORIF_ISTAS.Migracion_Item_Factura
GO

