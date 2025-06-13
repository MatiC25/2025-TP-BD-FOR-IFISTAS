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

CREATE TABLE Envio(
    envi_numero INT,
    envi_fecha_programada DATETIME2,
    envi_fecha_entrega DATETIME2, 
    envi_importe_traslado DECIMAL(10, 2),
    envi_importe_subida DECIMAL(10, 2)
)

CREATE TABLE Factura( 
    fact_numero INT,
    fact_sucursal INT, -- CODIGO asociado a la sucursal || VARCHAR(50)
    fact_cliente INT, -- CODIGO asociado al cliente || VARCHAR(50)
    fact_total DECIMAL(10, 2),
    fact_envio INT, -- Codigo asociado al envio
    fact_fecha_hora DATETIME2, -- DATETIME
)

CREATE TABLE Item_Factura(
    item_f_numero INT IDENTITY(1,1),
    item_f_numero_pedido INT,
    item_f_sillon INT, -- Codigo asociado al sillon
    item_f_sucursal INT,
    item_f_numero_factura INT,
    item_f_cantidad INT,
    item_f_precio DECIMAL(10, 2)
)

CREATE TABLE Direccion (
    direc_codigo INT IDENTITY(1,1), -- No sabemos si vamos a crear un codigo asociado a la direccion para no tener que comparar string
                                     -- con la direccion entre Sucursal, direccion y cliente || VARCHAR(100)
    direc_calle VARCHAR(100),
    direc_localidad INT, -- id de localidad
)

CREATE TABLE Localidad (
    loca_codigo INT IDENTITY(1,1),
    loca_nombre VARCHAR(50),
    loca_provincia INT,
)

CREATE TABLE Provincia(
    prov_codigo INT IDENTITY(1,1),
    prov_nombre VARCHAR(50),
)

CREATE TABLE Sucursal( 
    sucu_numero INT,
    sucu_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50) TODO
    sucu_telefono INT,
    sucu_mail VARCHAR(100),
)

CREATE TABLE Pedido(
    pedi_numero INT,
    pedi_sucursal INT,
    pedi_cliente INT,
    pedi_fecha_hora DATETIME2,
    pedi_total DECIMAL(10, 2),
    pedi_estado VARCHAR(20) -- 'Pendiente', 'Enviado', 'Entregado', 'Cancelado'
)

CREATE TABLE Item_Pedido(
    item_p_numero INT, -- Numero asociado al numero de pedido (pedi_numero)
    item_p_sillon INT, -- Numero asociado al numero de sillo (sill_codigo)
    item_p_precio DECIMAL(10, 2),
    item_p_cantidad INT,
)

CREATE TABLE Estado(
    esta_codigo INT IDENTITY(1,1),
    esta_nombre VARCHAR(20) -- 'Pendiente', 'Enviado', 'Entregado', 'Cancelado'
)

CREATE TABLE Pedido_Cancelacion(
    pedi_c_numero, -- Numero asociado al numero de pedido (pedi_numero)
    pedi_c_fecha DATETIME2,
    pedi_c_motivo VARCHAR(255)
)

CREATE TABLE Compra(
    comp_numero INT,
    comp_sucursal INT,
    comp_proveedor INT, -- Codigo asociado al proveedor
    comp_detalle VARCHAR(50),
    comp_total DECIMAL(10, 2)
)

CREATE TABLE Item_Compra(
    item_c_numero INT, -- Numero asociado al numero de compra (comp_numero)
    item_c_material INT, -- Codigo asociado al sillon
    item_c_precio DECIMAL(10, 2),
    item_c_cantidad INT,
)

CREATE TABLE Proveedor(
    prov_codigo INT IDENTITY(1,1),
    prov_provincia INT,
    prov_localidad INT,
    prov_razon_social VARCHAR(100),
    prov_cuit INT, -- CUIT del proveedor
    prov_direccion INT, -- CODIGO asiciado a la direccion || VARCHAR(50) TODO
    prov_telefono INT,
    prov_mail VARCHAR(100)
)

CREATE TABLE Sillon(
    sill_codigo INT,
    sill_modelo INT, -- CODIGO MODELO
    sill_medida INT -- CODIGO MEDIDAS
)

CREATE TABLE Modelo(
    mode_code INT, -- Codigo asociado de sill_modelo_codigo
    mode_descripcion VARCHAR(255)
)

CREATE TABLE Medida(
    medi_codigo INT IDENTITY(1,1),
    medi_alto DECIMAL(10, 2),
    medi_ancho DECIMAL(10, 2),
    medi_profundo DECIMAL(10, 2),
    medi_precio DECIMAL(10, 2)    
)

CREATE TABLE Sillon_Material(
    sill_mate_codigo INT, -- Codigo materia x sillon
    sill_mate_material INT -- Codigo material
)


-- VER COMO FUNCIONA LA HERENCIA DE MATERIAL CON LOS DIFERENTES TIPOS DE MATERIALES
CREATE TABLE Material(
    mate_codigo INT IDENTITY(1,1),-- Codigo material
    mate_nombre VARCHAR(100),
    mate_descipcion VARCHAR(255),
    mate_precio DECIMAL(10, 2)
)

CREATE TABLE Madera(
    made_codigo INT IDENTITY(1,1), -- Codigo madera
    made_color VARCHAR(50),
    made_dureza VARCHAR(50)
)

CREATE TABLE Tela(
    tela_codigo INT IDENTITY(1,1), -- Codigo tela
    tela_color VARCHAR(50),
    tela_textura VARCHAR(50)
)

CREATE TABLE Relleno(
    rell_codigo INT IDENTITY(1,1), -- Codigo relleno
    rell_densidad VARCHAR(50)
)