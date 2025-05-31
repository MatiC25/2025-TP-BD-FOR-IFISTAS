-- =========================
-- ELIMINAR SI EXISTE (SAFE)
-- =========================

IF OBJECT_ID('Sillon') IS NOT NULL DROP TABLE Sillon;
IF OBJECT_ID('Medida') IS NOT NULL DROP TABLE Medida;
IF OBJECT_ID('Modelo') IS NOT NULL DROP TABLE Modelo;
IF OBJECT_ID('Relleno') IS NOT NULL DROP TABLE Relleno;
IF OBJECT_ID('Tela') IS NOT NULL DROP TABLE Tela;
IF OBJECT_ID('Madera') IS NOT NULL DROP TABLE Madera;
IF OBJECT_ID('Material') IS NOT NULL DROP TABLE Material;
IF OBJECT_ID('Proveedor') IS NOT NULL DROP TABLE Proveedor;
IF OBJECT_ID('Pedido_Cancelacion') IS NOT NULL DROP TABLE Pedido_Cancelacion;
IF OBJECT_ID('Pedido') IS NOT NULL DROP TABLE Pedido;
IF OBJECT_ID('Factura') IS NOT NULL DROP TABLE Factura;
IF OBJECT_ID('Sucursal') IS NOT NULL DROP TABLE Sucursal;
IF OBJECT_ID('Envio') IS NOT NULL DROP TABLE Envio;
IF OBJECT_ID('Cliente') IS NOT NULL DROP TABLE Cliente;
IF OBJECT_ID('Direccion') IS NOT NULL DROP TABLE Direccion;
IF OBJECT_ID('Localidad') IS NOT NULL DROP TABLE Localidad;
IF OBJECT_ID('Provincia') IS NOT NULL DROP TABLE Provincia;

IF OBJECT_ID('Migracion_Direccion') IS NOT NULL DROP PROCEDURE Migracion_Direccion;
IF OBJECT_ID('Migracion_Localidad') IS NOT NULL DROP PROCEDURE Migracion_Localidad;
IF OBJECT_ID('Migracion_Provincia') IS NOT NULL DROP PROCEDURE Migracion_Provincia;
IF OBJECT_ID('Migracion_Cliente') IS NOT NULL DROP PROCEDURE Migracion_Cliente;
IF OBJECT_ID('Migracion_Envio') IS NOT NULL DROP PROCEDURE Migracion_Envio;
IF OBJECT_ID('Migracion_Sucursal') IS NOT NULL DROP PROCEDURE Migracion_Sucursal;
IF OBJECT_ID('Migracion_Factura') IS NOT NULL DROP PROCEDURE Migracion_Factura;
IF OBJECT_ID('Migracion_Pedido') IS NOT NULL DROP PROCEDURE Migracion_Pedido;
IF OBJECT_ID('Migracion_Pedido_Cancelacion') IS NOT NULL DROP PROCEDURE Migracion_Pedido_Cancelacion;
IF OBJECT_ID('Migracion_Proveedor') IS NOT NULL DROP PROCEDURE Migracion_Proveedor;
IF OBJECT_ID('Migracion_Madera') IS NOT NULL DROP PROCEDURE Migracion_Madera;
IF OBJECT_ID('Migracion_Tela') IS NOT NULL DROP PROCEDURE Migracion_Tela;
IF OBJECT_ID('Migracion_Relleno') IS NOT NULL DROP PROCEDURE Migracion_Relleno;
IF OBJECT_ID('Migracion_Material') IS NOT NULL DROP PROCEDURE Migracion_Material;
IF OBJECT_ID('Migracion_Modelo') IS NOT NULL DROP PROCEDURE Migracion_Modelo;
IF OBJECT_ID('Migracion_Medida') IS NOT NULL DROP PROCEDURE Migracion_Medida;
IF OBJECT_ID('Migracion_Sillon') IS NOT NULL DROP PROCEDURE Migracion_Sillon;
GO

-- ==================
-- TABLA: Provincia
-- ==================

CREATE TABLE Provincia (
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50)
)
GO

ALTER TABLE Provincia ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo)
GO

CREATE PROCEDURE Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Provincia (prov_nombre)
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

CREATE TABLE Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT
)
GO

ALTER TABLE Localidad ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo)
GO
ALTER TABLE Localidad ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES Provincia(prov_codigo)
GO

CREATE PROCEDURE Migracion_Localidad
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Localidad (loca_nombre, loca_provincia)
    SELECT DISTINCT m.Cliente_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Cliente_Provincia
    WHERE m.Cliente_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Proveedor_Provincia
    WHERE m.Proveedor_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Localidad, p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON p.prov_nombre = m.Sucursal_Provincia
    WHERE m.Sucursal_Localidad IS NOT NULL
END
GO

-- ==================
-- TABLA: Direccion
-- ==================

CREATE TABLE Direccion (
    dire_codigo INT IDENTITY(1,1),
    dire_calle_altura VARCHAR(75),
    dire_localidad INT
)
GO

ALTER TABLE Direccion ADD CONSTRAINT PK_Direccion PRIMARY KEY (dire_codigo)
GO
ALTER TABLE Direccion ADD CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (dire_localidad) REFERENCES Localidad(loca_codigo)
GO
CREATE OR ALTER PROCEDURE Migracion_Direccion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Direccion (dire_calle_altura, dire_localidad)
    SELECT DISTINCT m.Cliente_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Cliente_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Cliente_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Cliente_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Proveedor_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Proveedor_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Proveedor_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Proveedor_Direccion IS NOT NULL

    UNION

    SELECT DISTINCT m.Sucursal_Direccion, l.loca_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Localidad l ON l.loca_nombre = m.Sucursal_Localidad
    JOIN Provincia p ON p.prov_nombre = m.Sucursal_Provincia
        AND p.prov_codigo = l.loca_provincia
    WHERE m.Sucursal_Direccion IS NOT NULL
END
GO

-- ==================
-- TABLA: Cliente
-- ==================

CREATE TABLE Cliente (
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

ALTER TABLE Cliente ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo)
GO

ALTER TABLE Cliente ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion) REFERENCES Direccion (dire_codigo)
GO
CREATE OR ALTER PROCEDURE Migracion_Cliente
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Cliente (
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
    JOIN Direccion d ON d.dire_calle_altura = m.Cliente_Direccion
    JOIN Localidad l ON l.loca_codigo = d.dire_localidad AND l.loca_nombre = m.Cliente_Localidad
    JOIN Provincia p ON p.prov_codigo = l.loca_provincia
                    AND p.prov_nombre = m.Cliente_Provincia
END
GO

-- ==================
-- TABLA: Envio
-- ==================

CREATE TABLE Envio(
    envi_numero INT NOT NULL,
    envi_fecha_programada DATETIME2,
    envi_fecha_entrega DATETIME2, 
    envi_importe_traslado DECIMAL(10, 2),
    envi_importe_subida DECIMAL(10, 2)
)
GO

ALTER TABLE Envio ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_numero)
GO

CREATE PROCEDURE Migracion_Envio
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

CREATE TABLE Sucursal( 
    sucu_numero INT NOT NULL,
    sucu_direccion INT,
    sucu_telefono INT,
    sucu_mail VARCHAR(100)
)
GO

ALTER TABLE Sucursal ADD CONSTRAINT PK_Sucursal_Numero PRIMARY KEY (sucu_numero)
GO

ALTER TABLE Sucursal ADD CONSTRAINT FK_Sucursal_Direccion FOREIGN KEY (sucu_direccion) REFERENCES Direccion (dire_codigo)
GO

CREATE PROCEDURE Migracion_Sucursal
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sucursal(
        sucu_numero,
        sucu_direccion,
        sucu_telefono,
        sucu_mail
    )
    SELECT DISTINCT
        tm.Sucursal_NroSucursal,
        d.dire_codigo,
        tm.Sucursal_telefono,
        Sucursal_mail
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN Direccion d ON d.dire_calle_altura = tm.Sucursal_Direccion
        JOIN Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN Provincia p ON p.prov_codigo = l.loca_provincia
                            AND p.prov_nombre = tm.Sucursal_Provincia
                            AND l.loca_nombre = tm.Sucursal_Localidad
        WHERE tm.Sucursal_NroSucursal IS NOT NULL
END
GO

-- ==================
-- TABLA: Factura
-- ==================

CREATE TABLE Factura( 
    fact_numero INT NOT NULL,
    fact_sucursal INT NOT NULL, -- CODIGO asociado a la sucursal || VARCHAR(50)
    fact_cliente INT, -- CODIGO asociado al cliente || VARCHAR(50)
    fact_total DECIMAL(10, 2),
    fact_envio INT, -- Codigo asociado al envio
    fact_fecha_hora DATETIME2 -- DATETIME
)
GO

ALTER TABLE Factura ADD CONSTRAINT PK_Fact_Numero PRIMARY KEY (fact_numero, fact_sucursal)
GO  

ALTER TABLE Factura ADD CONSTRAINT FK_FACT_Envio FOREIGN KEY (fact_envio) REFERENCES Envio (envi_numero)
GO
ALTER TABLE Factura ADD CONSTRAINT FK_Fact_cliente FOREIGN KEY (fact_cliente) REFERENCES Cliente (clie_codigo)
GO

CREATE PROCEDURE Migracion_Factura
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Factura(
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
        LEFT JOIN Sucursal s on tm.Sucursal_NroSucursal = s.sucu_numero
        JOIN Cliente c ON tm.Cliente_Dni = c.clie_dni 
                        AND tm.Cliente_Nombre = c.clie_nombre 
                        AND tm.Cliente_Apellido = c.clie_apellido
        JOIN Envio e ON tm.Envio_Numero = e.envi_numero
        WHERE tm.Factura_Numero IS NOT NULL
END
GO


-- ==================
-- TABLA: Pedido
-- ==================

CREATE TABLE Pedido (
    pedi_numero INT NOT NULL,
    pedi_sucursal INT, --> codigo asociado a la Sucursal
    pedi_cliente INT, --> codigo asociado al Cliente
    pedi_fecha_hora DATETIME2,
    pedi_total DECIMAL(10, 2),
    pedi_estado VARCHAR(10) --> Codigo asociado al Estado 
)
GO

ALTER TABLE Pedido ADD CONSTRAINT PK_Pedido_Numero PRIMARY KEY (pedi_numero)
GO
ALTER TABLE Pedido ADD CONSTRAINT FK_Pedido_Clinete FOREIGN KEY (pedi_cliente) REFERENCES Cliente(clie_codigo)
GO

CREATE PROCEDURE Migracion_Pedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pedido (
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
    JOIN Cliente c ON tm.Cliente_Nombre = c.clie_nombre AND tm.Cliente_Apellido = c.clie_apellido AND tm.Cliente_Dni = c.clie_dni
    JOIN Sucursal s ON tm.Sucursal_NroSucursal = s.sucu_numero
    WHERE tm.Pedido_Numero IS NOT NULL
END
GO

-- ==================
-- TABLA: Pedido Cancelacion
-- ==================

CREATE TABLE Pedido_Cancelacion (
    pedi_c_numero INT NOT NULL, -- Numero asociado al numero de pedido (pedi_numero)
    pedi_c_fecha DATETIME2 NOT NULL,
    pedi_c_motivo VARCHAR(255) NOT NULL
) 
GO
ALTER TABLE Pedido_Cancelacion ADD CONSTRAINT FK_Pedido_Cancelacion_Numero FOREIGN KEY (pedi_c_numero) REFERENCES Pedido(pedi_numero)
GO
CREATE PROCEDURE Migracion_Pedido_Cancelacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pedido_Cancelacion (
        pedi_c_numero,
        pedi_c_fecha,
        pedi_c_motivo
    )

    SELECT DISTINCT
        p.pedi_numero,
        tm.Pedido_Cancelacion_Fecha,
        tm.Pedido_Cancelacion_Motivo
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN Pedido p on p.pedi_numero = tm.Pedido_Numero
        WHERE tm.Pedido_Numero IS NOT NULL AND tm.Pedido_Cancelacion_Fecha IS NOT NULL AND tm.Pedido_Cancelacion_Motivo IS NOT NULL 
END
GO

-- ==================
-- TABLA: Proveedor
-- ==================

CREATE TABLE Proveedor(
    prov_codigo INT IDENTITY(1,1),
    prov_razon_social VARCHAR(100) NOT NULL,
    prov_cuit VARCHAR(20), -- CUIT del proveedor
    prov_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50) TODO
    prov_telefono INT,
    prov_mail VARCHAR(100),

)
GO
ALTER TABLE Proveedor ADD CONSTRAINT PK_Proveedor PRIMARY KEY(prov_codigo)
GO
ALTER TABLE Proveedor ADD CONSTRAINT FK_Proveedor FOREIGN KEY(prov_direccion) REFERENCES Direccion(dire_codigo)
GO
CREATE PROCEDURE Migracion_Proveedor
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Proveedor (
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
        JOIN Direccion d ON d.dire_calle_altura = tm.Proveedor_Direccion
        JOIN Localidad l ON l.loca_codigo = d.dire_localidad
        JOIN Provincia p ON p.prov_codigo = l.loca_provincia
                            AND p.prov_nombre = tm.Proveedor_Provincia
                            AND l.loca_nombre = tm.Proveedor_Localidad
    WHERE tm.Proveedor_RazonSocial IS NOT NULL
END
GO

-- ==================
-- TABLA: Material
-- ==================

-- TODO: Ver como funciona el tema de la herencia hay que agregar uan FK para el tema de los poder entrar a el Material?? 
CREATE TABLE Material(
    mate_codigo INT IDENTITY(1,1),-- Codigo material
    mate_nombre VARCHAR(100),
    mate_descipcion VARCHAR(255),
    mate_precio DECIMAL(10, 2),
    mate_tipo VARCHAR(20)
)
GO

ALTER TABLE Material ADD CONSTRAINT PK_Material_Codigo PRIMARY KEY (mate_codigo)
GO

CREATE PROCEDURE Migracion_Material
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Material(
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

CREATE TABLE Madera(
    made_codigo INT NOT NULL,
    made_tipo VARCHAR(20),
    made_color VARCHAR(20),
    made_dureza VARCHAR(20)
)
GO

ALTER TABLE Madera ADD CONSTRAINT FK_Madera_Codigo FOREIGN KEY (made_codigo) REFERENCES Material (mate_codigo)
GO

CREATE PROCEDURE Migracion_Madera
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Madera(
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
        JOIN Material m on tm.Material_Tipo = m.mate_tipo
        WHERE tm.Madera_Color IS NOT NULL AND tm.Madera_Dureza IS NOT NULL
END
GO

-- ==================
-- TABLA: Tela
-- ==================

CREATE TABLE Tela(
    tela_codigo INT NOT NULL,
    tela_tipo VARCHAR(20),
    tela_color VARCHAR(20),
    tela_textura VARCHAR(20)
)
GO

ALTER TABLE Tela ADD CONSTRAINT FK_Tela_Codigo FOREIGN KEY (tela_codigo) REFERENCES Material (mate_codigo)
GO

CREATE PROCEDURE Migracion_Tela
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Tela(
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
        join Material m on tm.Material_Tipo = m.mate_tipo
        WHERE tm.Tela_Color IS NOT NULL AND tm.Tela_Textura IS NOT NULL
END
GO

-- ==================
-- TABLA: Relleno
-- ==================

CREATE TABLE Relleno(
    rell_codigo INT NOT NULL,
    rell_tipo VARCHAR(20),
    rell_densidad DECIMAL(10,2)
    )
GO

ALTER TABLE Relleno ADD CONSTRAINT PK_Relleno_Codigo FOREIGN KEY (rell_codigo) REFERENCES Material (mate_codigo)
GO

CREATE PROCEDURE Migracion_Relleno
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Relleno(
        rell_codigo,
        rell_tipo,
        rell_densidad
    )
    SELECT DISTINCT
        m.mate_codigo,
        tm.Material_Tipo,
        tm.Relleno_Densidad
        FROM GD1C2025.gd_esquema.Maestra tm
        join Material m on tm.material_tipo = m.mate_tipo
        WHERE tm.Relleno_Densidad IS NOT NULL
END
GO


-- ==================
-- TABLA: Modelo
-- ==================

CREATE TABLE Modelo(
    mode_code INT NOT NULL, -- Codigo asociado de sill_modelo_codigo
    mode_descripcion VARCHAR(255)
)
GO

ALTER TABLE Modelo ADD CONSTRAINT PK_Modelo PRIMARY KEY (mode_code)
GO

CREATE PROCEDURE Migracion_Modelo
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Modelo(
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

CREATE TABLE Medida(
    medi_codigo INT IDENTITY(1,1),
    medi_alto DECIMAL(10, 2),
    medi_ancho DECIMAL(10, 2),
    medi_profundo DECIMAL(10, 2),
    medi_precio DECIMAL(10, 2)    
)
GO

ALTER TABLE Medida ADD CONSTRAINT PK_Medida PRIMARY KEY (medi_codigo);
GO 

CREATE PROCEDURE Migracion_Medida
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Medida(
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

CREATE TABLE Sillon(
    sill_codigo INT NOT NULL,
    sill_modelo INT, -- CODIGO MODELO
    sill_medida INT -- CODIGO MEDIDAS (Auto Incremental)
)
GO
-- == Sillon == -- 
ALTER TABLE Sillon ADD CONSTRAINT PK_Sillon PRIMARY KEY (sill_codigo)
GO
ALTER TABLE Sillon ADD CONSTRAINT FK_Sillon_Modelo_Codigo FOREIGN KEY (sill_modelo) REFERENCES Modelo(mode_code)
GO
ALTER TABLE Sillon ADD CONSTRAINT FK_Sillon_Medida FOREIGN KEY (sill_medida) REFERENCES Medida(medi_codigo)
GO

CREATE PROCEDURE Migracion_Sillon
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sillon(
        sill_codigo,
        sill_modelo,
        sill_medida
    )
    SELECT DISTINCT
        tm.Sillon_Codigo,
        tm.Sillon_Modelo_Codigo,
		m.medi_codigo
        FROM GD1C2025.gd_esquema.Maestra tm
        JOIN Medida m on tm.Sillon_Medida_Alto = m.medi_alto AND
                         tm.Sillon_Medida_Ancho = m.medi_ancho AND
                         tm.Sillon_Medida_Profundidad = m.medi_profundo AND
                         tm.Sillon_Medida_Precio = m.medi_precio
        WHERE tm.Sillon_Codigo IS NOT NULL AND tm.Sillon_Modelo_Codigo IS NOT NULL
END
GO

-- ==================
-- TABLA: Sillon_Material
-- ==================

-- ==================
-- EJECUTAR MIGRACIONES
-- ==================
 
EXEC Migracion_Provincia
GO
EXEC Migracion_Localidad
GO
EXEC Migracion_Direccion
GO
EXEC Migracion_Cliente
GO
EXEC Migracion_Envio
GO
EXEC Migracion_Sucursal
GO
EXEC Migracion_Factura
GO
EXEC Migracion_Pedido
GO
EXEC Migracion_Pedido_Cancelacion
GO
EXEC Migracion_Proveedor
GO
EXEC Migracion_Material
GO
EXEC Migracion_Madera
GO
EXEC Migracion_Tela
GO
EXEC Migracion_Relleno
GO
EXEC Migracion_Modelo
GO
EXEC Migracion_Medida
GO
EXEC Migracion_Sillon
GO