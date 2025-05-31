@echo off
setlocal EnableDelayedExpansion

echo.
echo +------------------------------------------------+
echo ^|             FORIFISTAS MIGRACION              ^|
echo +------------------------------------------------+
echo.

echo +-----------------------------------------------+
echo ^|   Ejecutando migracion de base de datos...    ^|
echo +-----------------------------------------------+
echo.

set SERVER=localhost
set SCRIPT=MigracionSQL.sql

sqlcmd -S %SERVER% -E -i %SCRIPT%

IF %ERRORLEVEL% EQU 0 (
    echo +-----------------------------------------------+
    echo ^|      MIGRACION COMPLETADA CON EXITO.         ^|
    echo +-----------------------------------------------+
) ELSE (
    echo +--------------------------------------------------------+
    echo ^|   ERROR durante la migracion. Codigo: %ERRORLEVEL%   ^|
    echo +--------------------------------------------------------+
)
