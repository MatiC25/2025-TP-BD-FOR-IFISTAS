CREATE TABLE GestionPedido (

)

CREATE TABLE GestionVenta (

)

CREATE TABLE GestionCompra (

)

CREATE TABLE GestionEnvio (

)

CREATE TABLE DimTiempo (
    tiempo_id INT IDENTITY(1,1), --PRIMARY KEY,
    tiempo_fecha SMALLDATETIME NOT NULL,
    tiempo_cuatri INT NOT NULL,
)

CREATE TABLE DimUbicacion (
    ubicacion_id INT IDENTITY(1,1), -- PRIMARY KEY
    ubic_provincia,
    ubic_localidad 
)

CREATE TABLE DimRangoEtario (
    rang_etario_id INT IDENTITY(1,1), -- PRIMARY KEY
)

CREATE TABLE DimTurno (
    turn_id INT IDENTITY(1,1), -- PRIMARY KEY
    turn_hora_inicio SMALLDATETIME NOT NULL,
    turn_hora_fin SMALLDATETIME NOT NULL,
)

CREATE TABLE DimTipoMaterial (
    tipo_material_id INT IDENTITY(1,1), -- PRIMARY KEY
    tipo_material_nombre VARCHAR(20) NOT NULL
)

CREATE TABLE DimModeloSillon (
    modelo_sillon_id INT IDENTITY(1,1), -- PRIMARY KEY
    modelo_sillon_precio DECIMAL(10, 2) NOT NULL
)

CREATE TABLE DimEstadoPedido (
    estado_pedido_id INT IDENTITY(1,1), -- PRIMARY KEY
    estado_pedido_nombre VARCHAR(20) NOT NULL
)

-- Sucursal