# CONSIDERACIONES 
> El alumno deberá diseñar el modelo de datos correspondiente y desarrollar un script de base de datos SQL Server que realice la creación de su modelo de datos transaccional y la migración de los datos de la tabla maestra a su propio modelo. 
> El alumno deberá crear un modelo de datos que organice y normalice los datos de la única tabla provista por la cátedra. 
- Se debe incluir: 
  - Creación de nuevas tablas. 
  - Creación de claves primarias y foráneas para relacionar estas tablas. 
  - Creación de constraints y triggers sobre estas tablas cuando fuese necesario. Creación de los índices para acceder a los datos de estas tablas de manera eficiente.   
  - Migración de datos: Se deberán cargar todas las tablas creadas en el nuevo modelo utilizando la totalidad de los datos entregados por la cátedra en la única tabla del modelo anterior. 
    Para realizar este punto deberán utilizarse Stored Procedures. 
  - Creación de su propio esquema con el nombre del grupo elegido 

> El alumno deberá entregar el DER del modelo transaccional y un único archivo de Script que al ejecutar realice todos los pasos mencionados anteriormente, 
> en el orden correcto. Todo el modelo de datos confeccionado por el alumno deberá ser creado y cargado correctamente ejecutando este Script una única vez.

# IMPLEMENTACION
## Condiciones de Evaluación y Aprobación 
### Testing de Scripts 
> El alumno entregará a lo largo del TP dos scripts: 
  - Script de base de datos transaccional (script_creacion_inicial.sql) con todo lo necesario para crear su modelo transaccional y cargarlo con los datos correspondientes. 
  - Script de base de datos BI (script_creacion_BI.sql) con todo lo necesario para crear el modelo de BI, poblarlo correctamente y crear las vistas solicitadas sobre 
  el mismo. 
  - La cátedra probará el Trabajo Práctico en el siguiente orden: 
      1. Se dispondrá de una base de datos limpia igual a la original entregada a los 
      alumnos. 
      2. Se ejecutará el archivo script_creacion_inicial.sql. proporcionado por el alumno. Este archivo deberá tener absolutamente todo lo necesario para crear y cargar el modelo de datos correspondiente. Toda la ejecución deberá realizarse en orden y sin ningún tipo de error ni warning. 
      3. Se ejecutará el archivo script_creacion_BI.sql proporcionado por el alumno. Este archivo deberá tener absolutamente todo lo necesario para crear y cargar el modelo de BI. Toda la ejecución deberá realizarse en orden y sin ningún tipo de error ni warning. 

Los archivos "script_creacion_inicial.sql" y "script_creacion_BI.sql" deben contener todo lo necesario para crear el modelo de datos correspondiente y cargarlo con los datos. 
Si el alumno utiliza alguna herramienta auxiliar o programa customizado, el mismo no será utilizado por la cátedra. 
Si en su ejecución se produjeran errores, el trabajo práctico será rechazado sin continuar su evaluación. 
Todos los objetos de base de datos creados por el usuario deben pertenecer al esquema de base de datos creado con el nombre del grupo. Si esta restricción no se cumple el trabajo práctico será rechazado sin continuar su evaluación. 
También deberán ser considerados criterios de performance a la hora de crear relaciones e índices en las tablas. 
