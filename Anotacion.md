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

#### Direcciones: 20269
```
> select DISTINCT Cliente_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Sucursal_Direccion from GD1C2025.gd_esquema.Maestra
> select DISTINCT Proveedor_Direccion from GD1C2025.gd_esquema.Maestra
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
