CREATE TABLE HechoPedido (
    hecho_pedido_estado INT NOT NULL, 
    hecho_pedido_sucursal INT NOT NULL,
    hecho_pedido_turno INT NOT NULL, -- FOREIGN KEY REFERENCES DimTurnoVentas(turn_id)
    hecho_pedido_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_pedido_numero INT NOT NULL,

)

CREATE TABLE HechoVenta (
    hecho_venta_numero INT NOT NULL,
    hecho_venta_cliente INT NOT NULL, 
    hecho_venta_sucursal INT NOT NULL, 
    hecho_venta_sillon_modelo INT NOT NULL, -- FOREIGN KEY REFERENCES DimModeloSillon(mode_sillon_id)
    hecho_venta_total DECIMAL(10, 2) NOT NULL,
    hecho_venta_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_venta_ubicacion INT NOT NULL, -- FOREIGN KEY REFERENCES DimUbicacion(ubicacion_id)
    hecho_venta_rango_etario INT NOT NULL, -- FOREIGN KEY REFERENCES DimRangoEtario(rang_etario_id)
    hecho_venta_sillon INT NOT NULL
) 

CREATE TABLE HechoCompra (
    hecho_compra_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_compra_sucursal INT NOT NULL,
    hecho_compra_tipo_material INT NOT NULL, -- FOREIGN KEY REFERENCES DimTipoMaterial(tipo_material_id)
    hecho_compra_total DECIMAL(10, 2) NOT NULL,
)

CREATE TABLE HechoEnvio (
    hecho_envio_tiempo INT NOT NULL, -- FOREIGN KEY REFERENCES DimTiempo(tiem_id)
    hecho_envio_ubicacion INT NOT NULL, -- FOREIGN KEY REFERENCES DimUbicacion(ubicacion_id)
    hecho_envio_porcentaje DECIMAL(5, 2) NOT NULL
)

CREATE TABLE DimTiempo (
    tiem_id INT IDENTITY(1,1), --PRIMARY KEY,
    tiem_fecha DATETIME2 NOT NULL,
    tiem_cuatri INT NOT NULL
)

CREATE TABLE DimUbicacion (
    ubic_id INT IDENTITY(1,1), -- PRIMARY KEY
    ubic_provincia VARCHAR(50),
    ubic_localidad VARCHAR(50)
)

CREATE TABLE DimRangoEtario (
    rang_etario_id INT IDENTITY(1,1), -- PRIMARY KEY}
    rang_etario_inicio INT NOT NULL,
    rang_etario_fin INT NOT NULL
)

CREATE TABLE DimTurnoVentas (
    turn_id INT IDENTITY(1,1), -- PRIMARY KEY
    turn_hora_inicio TIME NOT NULL,
    turn_hora_fin TIME NOT NULL
)

CREATE TABLE DimTipoMaterial (
    tipo_material_id INT IDENTITY(1,1), -- PRIMARY KEY
    tipo_material_nombre VARCHAR(20) NOT NULL
)

CREATE TABLE DimModeloSillon (
    mode_sillon_id INT IDENTITY(1,1), -- PRIMARY KEY
    mode_sillon_nombre VARCHAR(255) NOT NULL
)

CREATE TABLE DimEstadoPedido (
    esta_pedido_id INT IDENTITY(1,1), -- PRIMARY KEY
    esta_pedido_nombre VARCHAR(20) NOT NULL
)
