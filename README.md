
# grib2nc

`grib2nc` es una herramienta diseñada para facilitar la utilización y transformación de datos meteorológicos del modelo DWD ICON, los cuales están disponibles en formato grib2. Este paquete permite convertir archivos grib2 a formato NetCDF (.nc) para su fácil uso en análisis y aplicaciones de ciencia de datos, así como extraer archivos .bz2, tanto de forma secuencial como paralela, optimizando el manejo de grandes volúmenes de datos.

## Características

- **Conversión de Grib2 a NetCDF**: Transforma datos grib2 a formato NetCDF para su análisis y procesamiento.
- **Extracción de archivos BZ2**: Soporte para extracción secuencial y paralela de archivos .bz2, permitiendo un procesamiento eficiente de grandes datasets.
- **Optimización de Procesos**: Ejecución paralela para aprovechar al máximo los recursos de hardware disponibles.
- **Fácil de Usar**: Interfaces sencillas para usuarios de todos los niveles.

## Instalación WSL

```bash
wsl --install
```

Reiniciar y luego:

```bash
sudo apt update && sudo apt upgrade
```

```bash
apt-get install cdo
```

instalar dependencias necesarias:

```bash
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install libgdal-dev libgeos-dev libproj-dev 
sudo apt-get install libnetcdf-dev libhdf5-dev 
sudo apt install gdal-bin

```
debes copiar el contenido de  'ICON_0125.rar" dentro de una carpeta en wsl (home/...)
Para descargar el archivo `ICON_0125.rar`, haz clic [aquí](https://github.com/reneignacio/grib2nc/raw/main/ICON_0125.rar).

ejecutar chmod +x a archivo en consola, para dar permisos:
ejemplo:
```bash
chmod +x /home/inia/ICON_0125/transform_0125.sh
```



## Instalación Paquete R
Puedes instalar `grib2nc` desde GitHub usando `devtools`:

```r
# instalar devtools si aún no lo has hecho
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")

# instalar grib2nc
devtools::install_github("reneignacio/grib2nc")
```

## Uso

### Convertir Grib2 a NetCDF

Para convertir archivos grib2 a formato NetCDF:

```r
library(grib2nc)

ruta_in <- c("/ruta/a/tu/archivo1.grib2", "/ruta/a/tu/archivo2.grib2")
ruta_out <- c("/ruta/a/tu/archivo1.nc", "/ruta/a/tu/archivo2.nc")

Grib2ANetCDF(ruta_in, ruta_out, parallel = TRUE, ncores = 2)
```

### Extraer archivos BZ2

Para extraer archivos .bz2, ya sea de forma secuencial o paralela:

```r
extraerBZ2(c("/ruta/a/tu/archivo1.bz2", "/ruta/a/tu/archivo2.bz2"), parallel = TRUE, ncores = 2)
```

## Contribuciones

Las contribuciones a `grib2nc` son bienvenidas. Si deseas contribuir, por favor haz un fork del repositorio y envía un pull request.

## Licencia

Este paquete está bajo la licencia MIT. Ver el archivo LICENSE para más detalles.

## Contacto

Si tienes preguntas o comentarios sobre `grib2nc`, por favor, no dudes en [abrir un issue](https://github.com/reneignacio/grib2nc/issues) en nuestro repositorio de GitHub.
