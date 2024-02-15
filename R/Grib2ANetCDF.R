library(glue)
library(parallel)
library(doSNOW)

#' Transforma archivos .grib2 a .nc
#'
#' @param ruta_in Ruta del archivo de entrada `.grib2` o un vector de rutas si se ejecuta en paralelo.
#' @param ruta_out Ruta del archivo de salida `.nc` o un vector de rutas de salida si se ejecuta en paralelo.
#' @param parallel Lógico que indica si se debe ejecutar en paralelo (TRUE) o secuencialmente (FALSE).
#' @param ncores Número de núcleos a utilizar para la ejecución paralela, solo relevante si parallel = TRUE.
#'
#' @details Esta función requiere que el Subsistema de Windows para Linux (WSL) esté instalado
#' y configurado correctamente en el sistema, y que el script de shell `transform_0125.sh`
#' esté disponible en la ruta especificada dentro de WSL.
#'
#' @return No devuelve un valor explícitamente, pero ejecuta un comando en el
#' sistema que transforma el archivo y lo guarda en la ubicación especificada.
#' @examples
#' Grib2ANetCDF("C:/path/to/input/file.grib2", "C:/path/to/output/file.nc")
#' @export
#' @importFrom glue glue

Grib2ANetCDF <- function(ruta_in, ruta_out, parallel = FALSE, ncores = detectCores() - 1) {
  if(!parallel) {
    # Ejecución secuencial
    rutaWSL_in <- convertirRutaWindowsAWSL(ruta_in)
    rutaWSL_out <- convertirRutaWindowsAWSL(ruta_out)
    comando <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in} {rutaWSL_out}'")
    system(comando)
  } else {
    # Configuración para ejecución paralela
    cl <- makeCluster(ncores, type = "SOCK")
    registerDoSNOW(cl)

    # Asegurarse de exportar y cargar las funciones necesarias en cada nodo
    clusterExport(cl, varlist = c("convertirRutaWindowsAWSL"))
    clusterEvalQ(cl, library(glue))

    # Ejecución paralela
    resultados <- foreach(i = 1:length(ruta_in), .packages = c("glue")) %dopar% {
      rutaWSL_in_i <- convertirRutaWindowsAWSL(ruta_in[i])
      rutaWSL_out_i <- convertirRutaWindowsAWSL(ruta_out[i])
      comando_i <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in_i} {rutaWSL_out_i}'")
      system(comando_i)
    }

    # Cerrar el clúster
    stopCluster(cl)
  }
}
