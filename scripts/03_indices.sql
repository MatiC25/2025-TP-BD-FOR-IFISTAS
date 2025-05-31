


CREATE INDEX IX_Cliente_Dni_NombreApellido ON Cliente (clie_dni, clie_nombre, clie_apellido);

CREATE INDEX IX_Estado_Tipo ON Estado (esta_tipo);

CREATE INDEX IX_Sucursal_Numero ON Sucursal (sucu_numero);

CREATE INDEX IX_Maestra_Join ON Maestra (Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Pedido_Estado, Sucursal_NroSucursal)

CREATE INDEX IX_Maestra_Pedido ON GD1C2025.gd_esquema.Maestra (Pedido_Numero, Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Pedido_Estado, Sucursal_NroSucursal);