
---
## 💾 Datos conseguidos con select tabla maestra
---

####  Provincias: 24
```sql
> select DISTINCT Cliente_Provincia from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Provincia from GD1C2025.gd_esquema.Maestra
> select DISTINCT  Proveedor_Provincia from GD1C2025.gd_esquema.Maestra
```

####  Localidades: 12268
```sql
> select DISTINCT Cliente_Localidad from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Localidad from GD1C2025.gd_esquema.Maestra
> select DISTINCT  Proveedor_Localidad from GD1C2025.gd_esquema.Maestra
```

#### Direcciones: 20528
```sql
> select DISTINCT Cliente_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Proveedor_Direccion from GD1C2025.gd_esquema.Maestra
```

#### Cliente: 20510 
```sql
> select DISTINCT Cliente_Nombre,Cliente_Apellido,Cliente_Dni from GD1C2025.gd_esquema.Maestra
```

#### Envios: 17408
```sql
> select distinct Envio_Numero, Envio_Fecha_Programada, Envio_Fecha, Envio_ImporteTraslado, Envio_ImporteSubida
from gd_esquema.Maestra
where Envio_Numero is not null
```

#### Sucursal: 9 
```sql
> select DISTINCT Sucursal_NroSucursal from GD1C2025.gd_esquema.Maestra
```

#### Factura: 17408
```sql
> select DISTINCT Factura_Numero from GD1C2025.gd_esquema.Maestra
WHERE Factura_Numero  IS NOT NULL 
```

#### Pedidos Estados: 280691
```sql
> SELECT Pedido_Estado FROM gd_esquema.Maestra
WHERE Pedido_Estado IS NOT NULL
```

#### Pedidos : 20509
```sql
> select DISTINCT Pedido_Numero FROM GD1C2025.gd_esquema.Maestra
where Pedido_Numero IS NOT NULL 
```

#### Pedidos Cancelacion : 3101
```sql
> select Pedido_Cancelacion_Motivo, Pedido_Cancelacion_Fecha from gd_esquema.Maestra
where Pedido_Cancelacion_Motivo IS NOT NULL OR Pedido_Cancelacion_Motivo IS NOT NULL
```

#### Provedor : 10
```sql
> SELECT DISTINCT Proveedor_Cuit FROM GD1C2025.gd_esquema.Maestra
WHERE Proveedor_Cuit IS NOT NULL 
```

#### Madera : 2
```sql
> SELECT DISTINCT Madera_Color FROM GD1C2025.gd_esquema.Maestra
WHERE Madera_Color IS NOT NULL
```

#### Tela : 3
```sql
> SELECT DISTINCT Tela_Color FROM GD1C2025.gd_esquema.Maestra
WHERE Tela_Color IS NOT NULL
```

#### Relleno : 3
```sql
> SELECT DISTINCT Relleno_Densidad FROM GD1C2025.gd_esquema.Maestra
WHERE Relleno_Densidad IS NOT NULL
```

#### Material : 9
```sql
> SELECT DISTINCT Material_Nombre FROM GD1C2025.gd_esquema.Maestra
WHERE Material_Nombre IS NOT NULL
```

#### Modelo : 7
```sql
> SELECT DISTINCT Sillon_Modelo_Codigo FROM GD1C2025.gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL
```

#### Medidas : 4
```sql
> SELECT DISTINCT Sillon_Medida_Alto, Sillon_Medida_Ancho, Sillon_Medida_Profundidad, Sillon_Medida_Precio FROM GD1C2025.gd_esquema.Maestra
WHERE Sillon_Medida_Alto IS NOT NULL AND Sillon_Medida_Ancho IS NOT NULL AND Sillon_Medida_Profundidad IS NOT NULL AND Sillon_Medida_Precio IS NOT NULL
```

#### Sillon : 72166
```sql
> SELECT DISTINCT Sillon_Codigo FROM GD1C2025.gd_esquema.Maestra
WHERE Sillon_Codigo IS NOT NULL AND Sillon_Modelo_Codigo IS NOT NULL
```
---
### 📌 Anotraciones extras 
* 	Eliminamos los NULS ya que no tiene sentido que algunos campos sean NULL como:
    *   Provincia 
    *	Localidad 
    *	Direccion
    *   Envio_Numero
    *   Sucursal_NroSucursal
    *   Estado_Pedido
    *   Factura_Numero
    *   Pedido_Numero
    *   Pedi_Cancelacion_Numero
    *   Pedido_Cancelacion_Fecha
    *   Pedido_Cancelacion_Motivo
    *   Proveedor_RazonSocial
    *   Madera_Color
    *   Tela_Color
    *   Relleno_Debsudad
    *   Material_Nombre
    *   Sillon_Modelo_Codigo
    *   Sillon_Medida_Alto
    *   Sillon_Medida_Ancho
    *   Sillon_Medida_Profundidad
    *   Sillon_Medida_Precio
    *   Sillon_Codigo
    *   Sillon_Modelo_Codigo




--- 
### ▶️ Como ejecutar el SCRIPT
ver despues
