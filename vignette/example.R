library(grib2nc)
library(glue)
library(R.utils)

directorioBase <- "D:/INIA/ICON/prueba_2/20240125/12"
rutas <- list.files(directorioBase, full.names = TRUE, recursive = TRUE)

#Filtrar rutas .bz2 y extraer en paralelo
rutas_bz2 <- rutas[grepl("\\.bz2$", rutas)]
extraerBZ2(rutas = rutas_bz2, parallel = TRUE, ncores = 8)


#Actualizar rutas después de la extracción
rutas <- list.files(directorioBase, full.names = TRUE, recursive = TRUE)
rutas_grib2 <- rutas[grepl("\\.grib2$", rutas)]

#Preparar las rutas de salida .nc correspondientes
rutass_nc <- gsub("\\.grib2$", ".nc", rutas_grib2)

ruta_script_wsl = "/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh"


Grib2ANetCDF(ruta_in = rutas_grib2, ruta_out = rutass_nc, parallel = T,verbose = T,ruta_script = ruta_script_wsl)
