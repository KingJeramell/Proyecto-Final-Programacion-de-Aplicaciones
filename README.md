Instrucciones de Instalación y Ejecución

Proyecto Final – Aplicación con Base de Datos

1. Requisitos del sistema

Para ejecutar correctamente el proyecto, el equipo debe contar con los siguientes componentes instalados:

Sistema operativo Windows

Visual Studio 2019 o superior

SQL Server (Express o superior)

SQL Server Management Studio (SSMS)

.NET Framework compatible con el proyecto

2. Obtención del proyecto

Descargar el proyecto desde el repositorio proporcionado o copiar la carpeta completa del proyecto.

Guardar el proyecto en cualquier ubicación del equipo (por ejemplo: Documentos\ProyectoFinal).

Abrir el archivo de solución:

ProyectoFinal.sln


utilizando Visual Studio.

3. Preparación del proyecto en Visual Studio

Esperar a que Visual Studio cargue completamente la solución.

En caso de que se solicite, restaurar los paquetes NuGet automáticamente.

Compilar la solución desde el menú:

Build → Build Solution


Verificar que la compilación finalice sin errores.

4. Creación de la base de datos

Abrir SQL Server Management Studio (SSMS).

Conectarse al servidor local:

(local) o .


Abrir el archivo de script:

BD.sql


Ejecutar el script completo para crear la base de datos, tablas y registros necesarios.

Confirmar que la base de datos se haya creado correctamente.

5. Configuración de la cadena de conexión

En Visual Studio, abrir el archivo:

App.config


Localizar la sección de cadenas de conexión, por ejemplo:

<connectionStrings>
  <add name="Conexion"
       connectionString="Data Source=.;Initial Catalog=NombreBD;Integrated Security=True"/>
</connectionStrings>


Verificar que:

Data Source corresponda al servidor SQL del equipo.

Initial Catalog coincida exactamente con el nombre de la base de datos creada.

Guardar los cambios realizados.

6. Ejecución del proyecto

Ejecutar la aplicación desde Visual Studio presionando:

F5


o seleccionando el botón Iniciar.

La interfaz gráfica se abrirá automáticamente.

El sistema quedará completamente funcional con la base de datos conectada.

7. Consideraciones importantes

El proyecto se entrega completamente terminado y funcional.

No es necesario realizar modificaciones al código fuente.

La aplicación está diseñada para ejecutarse correctamente en cualquier equipo que cumpla con los requisitos indicados.

En caso de cambio de equipo, únicamente debe verificarse la cadena de conexión a la base de datos.

8. Solución de posibles inconvenientes

En caso de presentarse algún error, verificar lo siguiente:

Que el servicio de SQL Server esté activo.

Que la base de datos haya sido creada correctamente.

Que la cadena de conexión esté correctamente configurada.

Que el proyecto compile sin errores en Visual Studio.

9. Resultado esperado

La aplicación inicia correctamente.

La interfaz se muestra de forma adecuada.

La base de datos se conecta sin errores.

El sistema permite gestionar la información según lo diseñado.
