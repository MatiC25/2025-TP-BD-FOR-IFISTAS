---- PROVINCIA FUNCIONANDO ----

CREATE PROCEDURE Migracion_Provincia
AS
BEGIN
    SET NOCOUNT ON;

	INSERT INTO Provincia (prov_nombre)
        SELECT Cliente_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Cliente_Provincia IS NOT NULL
        UNION
        SELECT Proveedor_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Proveedor_Provincia IS NOT NULL
        UNION
        SELECT Sucursal_Provincia FROM GD1C2025.gd_esquema.Maestra
		WHERE Sucursal_Provincia IS NOT NULL
END;


---- LOCALIDAD A REVISAR ---- (Los puntos y comas de la cosas y la diferencia de espacios del mismo parametro)
---- Habría que delegar la funcion UPPER(LTRIM(RTRIM(REPLACE()))) a otra que tambien elimine los espacios adicionales
---- Sigue sin funcionar, sigue soltando las mismas 12368 filas
 
ALTER PROCEDURE Migracion_Localidad
AS
BEGIN   
    SET NOCOUNT ON;

    INSERT INTO Localidad (loca_nombre, loca_provincia)

    SELECT DISTINCT
        m.Cliente_Localidad,
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
        dbo.fn_NormalizarEspacios(p.prov_nombre) = dbo.fn_NormalizarEspacios(m.Cliente_Provincia)

    UNION

    SELECT DISTINCT
        m.Proveedor_Localidad, 
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
        dbo.fn_NormalizarEspacios(p.prov_nombre) = dbo.fn_NormalizarEspacios(m.Proveedor_Provincia)

    UNION

    SELECT DISTINCT
        m.Sucursal_Localidad, 
        p.prov_codigo
    FROM GD1C2025.gd_esquema.Maestra m
    JOIN Provincia p ON 
			dbo.fn_NormalizarEspacios(p.prov_nombre) = dbo.fn_NormalizarEspacios(m.Sucursal_Provincia);
END;

CREATE FUNCTION fn_NormalizarEspacios (@texto NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @resultado NVARCHAR(MAX)

    -- Eliminar todos los espacios (no solo múltiples o al principio/final)
    SET @resultado = REPLACE(@texto, ' ', '')

    -- Retornar en mayúsculas para comparar sin distinguir entre mayúsculas/minúsculas
    RETURN UPPER(@resultado)
END
