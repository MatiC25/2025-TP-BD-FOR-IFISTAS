-- ADD CONSTRAINT uq_dni UNIQUE (dni);
-- ADD CONSTRAINT ck_precio CHECK (precio > 0);
-- ADD CONSTRAINT ck_fechas CHECK (fecha_inicio < fecha_fin);
-- ALTER COLUMN nombre SET NOT NULL;
-- ALTER COLUMN activo SET DEFAULT true;
-- ADD CONSTRAINT ck_dni_largo CHECK (char_length(dni) = 8);
-- ADD CONSTRAINT ck_dni_formato CHECK (dni ~ '^[0-9]{8}$');
-- CHECK (dni BETWEEN 10000000 AND 99999999)

-- == CLIENTE == --
ALTER TABLE Cliente
ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo)
ADD CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (clie_direccion) REFERENCES Direccion(direc_codigo);

ADD CONSTRAINT uq_dni UNIQUE (clie_dni) -- El dni debe ser unico
ADD CONSTRAINT ck_dni CHECK (char_length(clie_dni) = 8); -- El dni debe tener 8 digitos
ADD CONSTRAINT ck_fecha_nacimiento CHECK (clie_fecha_nacimiento < GETDATE()); -- La fecha de nacimiento debe ser menor a la fecha actual
ADD CONSTRAINT uq_mail UNIQUE (clie_mail);

-- == ENVIO == --
ALTER TABLE Envio
ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_numero);

-- == FACTRURA == --
ALTER TABLE Factura
ADD CONSTRAINT PK_Fact_Numero PRIMARY KEY (fact_numero);
ADD CONSTRAINT PK_Fact_Sucursal PRIMARY KEY (fact_sucursal);
ADD CONSTRAINT FK_FACT_Envio FOREIGN KEY (fact_envio) REFERENCES Envio(envi_numero);

ADD CONSTRAINT ck_fact_total CHECK (fact_total > 0)

-- == ITEM_FACTURA == --
ALTER TABLE Item_Factura
ADD CONSTRAINT PK_Item_Factura PRIMARY KEY (item_f_numero);
ADD CONSTRAINT FK_Item_Factura_Numero_Pedido FOREIGN KEY (item_f_numero_pedido) REFERENCES Item_Pedido(item_p_numero);
ADD CONSTRAINT FK_Item_Factura_Sillon FOREIGN KEY (item_f_sillon) REFERENCES Sillon(sill_codigo);
ADD CONSTRAINT FK_Item_Factura_Sucursal FOREIGN KEY (item_f_sucursal) REFERENCES Sucursal(sucu_numero);
ADD CONSTRAINT FK_Item_Factura_Numero_Factura FOREIGN KEY (item_f_numero_factura) REFERENCES Factura(fact_numero);

-- == DIRECCION == --
ALTER TABLE Direccion;
ADD CONSTRAINT PK_Direccion PRIMARY KEY (direc_codigo);
ADD CONSTRAINT FK_Direccion_Localidad FOREIGN KEY (direc_localidad) REFERENCES Localidad(loca_codigo);

-- == LOCALIDAD == --
ALTER TABLE Localidad;
ADD CONSTRAINT PK_Localidad PRIMARY KEY (loca_codigo);
ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (loca_provincia) REFERENCES Provincia(prov_codigo);

-- == PROVINCIA == --
ALTER TABLE Provincia;
ADD CONSTRAINT PK_Provincia PRIMARY KEY (prov_codigo);

-- == Sucursal == -- 
ALTER TABLE Sucursal
ADD CONSTRAINT PK_Sucursal_Numero PRIMARY KEY (sucu_numero)
ADD CONSTRAINT FK_Sucursal_Direccion FOREIGN KEY (sucu_direccion) REFERENCES Direccion(direc_codigo)

ADD CONSTRAINT uq_sucu_numero UNIQUE (sucu_numero) -- El numero de la sucursal debe ser unico
ADD CONSTRAINT uq_sucu_mail UNIQUE (sucu_mail) -- El mail de la sucursal debe ser unico


-- == Pedido == --
ALTER TABLE Pedido
ADD CONSTRAINT PK_Pedido_Numero PRIMARY KEY (pedi_numero)
ADD CONSTRAINT FK_Pedido_Clinete FOREIGN KEY (pedi_cliente) REFERENCES Cliente(clie_codigo)
ADD CONSTRAINT FK_Pedido_Estado FOREIGN KEY (pedi_estado) REFERENCES Estado(esta_codigo)

-- == ITEM_PEDIDO == --
ALTER TABLE Item_Pedido
ADD CONSTRAINT FK_Item_Pedido_Numero FOREIGN KEY (item_p_numero_pedido) REFERENCES Pedido(pedi_numero)
ADD CONSTRAINT FK_Item_Pedido_Sillon FOREIGN KEY (item_p_sillon) REFERENCES Sillon(sill_codigo)

-- == ESTADO == --
ALTER TABLE Estado
ADD CONSTRAINT PK_Estado PRIMARY KEY (esta_codigo);


-- == PEDIDO_CANCELACION == -- 
ALTER TABLE Pedido_Cancelacion
ADD CONSTRAINT FK_Pedido_Cancelacion_Numero FOREIGN KEY (pedi_c_numero) REFERENCES Pedido(pedi_numero)


-- == Compra == --
ALTER TABLE Compra
ADD CONSTRAINT PK_Compra_ PRIMARY KEY (comp_numero)
ADD CONSTRAINT FK_Compra_Sucursal FOREIGN KEY (comp_sucursal) REFERENCES Sucursal(sucu_numero)
ADD CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (comp_proveedor) REFERENCES Proveedor(prov_codigo)

ADD CONSTRAINT ck_compra_total CHECK (comp_total > 0)

-- == ITEM_COMPRA == --
ALTER TABLE Item_Compra
ADD CONSTRAINT FK_Item_Compra FOREIGN KEY (item_c_numero) REFERENCES Compra(comp_numero)
ADD CONSTRAINT FK_Item_Compra_Material FOREIGN KEY (item_c_material) REFERENCES Material(mate_codigo)

-- === PROVEEDOR == --
ALTER TABLE Proveedor
ADD CONSTRAINT PK_Proveedor PRIMARY KEY (prov_codigo)

-- == Sillon == -- 
ALTER TABLE Sillon
ADD CONSTRAINT PK_Sillon PRIMARY KEY (sill_codigo)
ADD CONSTRAINT FK_Sillon_Modelo_Codigo FOREIGN KEY (sill_modelo) REFERENCES Modelo(mode_code)
ADD CONSTRAINT FK_Sillon_Medida FOREIGN KEY (sill_medida) REFERENCES MEDIDAS(medi_codigo)

-- == Modelo == --
ALTER TABLE Modelo
ADD CONSTRAINT PK_Modelo PRIMARY KEY (mode_codigo)

-- == Medida == --
ALTER TABLE Medida
ADD CONSTRAINT PK_Medida PRIMARY KEY (medi_codigo);

-- == Sillon_Material == --
ALTER TABLE Sillon_Material
ADD CONSTRAINT FK_Sillon_Material FOREIGN KEY (sill_mate_codigo) REFERENCES Sillon(sill_codigo)
ADD CONSTRAINT FK_Sillon_Material_Material FOREIGN KEY (sill_mate_material) REFERENCES Material(mate_codigo);

-- == Material == -- 
ALTER TABLE Material
ADD CONSTRAINT PK_Material_Codigo PRIMARY KEY (mate_codigo)

-- == Madera == --
ALTER TABLE Madera
ADD CONSTRAINT PK_Madera_Codigo PRIMARY KEY (made_codigo)

-- == Tela == --
ALTER TABLE Tela
ADD CONSTRAINT PK_Tela PRIMARY KEY (tela_codigo)

-- == Relleno == --
ALTER TABLE Relleno
ADD CONSTRAINT PK_Relleno PRIMARY KEY (rell_codigo)