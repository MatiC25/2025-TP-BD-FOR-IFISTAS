## Datos conseguidos con select tabal maestra
---
####  Provincias: 24
```
> select DISTINCT Cliente_Provincia from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Provincia from GD1C2025.gd_esquema.Maestra
> select DISTINCT  Proveedor_Provincia from GD1C2025.gd_esquema.Maestra
```

####  Localidades: 12268
```
> select DISTINCT Cliente_Localidad from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Localidad from GD1C2025.gd_esquema.Maestra
> select DISTINCT  Proveedor_Localidad from GD1C2025.gd_esquema.Maestra
```

#### Direcciones: 20528
```
SELECT DISTINCT Cliente_Direccion, Cliente_Localidad, Cliente_Provincia
FROM GD1C2025.gd_esquema.Maestra
WHERE Cliente_Direccion IS NOT NULL
UNION
SELECT DISTINCT Sucursal_Direccion, Sucursal_Localidad, Sucursal_Provincia
FROM GD1C2025.gd_esquema.Maestra
WHERE Sucursal_Direccion IS NOT NULL
UNION
SELECT DISTINCT Proveedor_Direccion, Proveedor_Localidad, Proveedor_Provincia
FROM GD1C2025.gd_esquema.Maestra
WHERE Proveedor_Direccion IS NOT NULL

```

#### Cliente: 
```
> select DISTINCT Cliente_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Proveedor_Direccion from GD1C2025.gd_esquema.Maestra
```

---
### Anotraciones extras 
* 	Eliminamos los NULS ya que no tiene sentido que algunos campos sean NULL como:
    * Provincia 
    *	Localidad 
    *	Direccion
* En el caso de Direccion nos **40206**  ya que pueden existir la misma calle_altura con diferente localidades 


--- 
### Como ejecutar el SCRIPT
ver despues
