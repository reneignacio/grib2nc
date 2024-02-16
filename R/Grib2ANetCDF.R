#' Convertir archivos .grib2 a .nc
#'
#' Esta función convierte archivos de formato .grib2 a formato .nc (NetCDF) utilizando
#' una llamada al sistema para ejecutar un script de bash en WSL. La función puede
#' operar en modo secuencial o paralelo.
#'
#' @param ruta_in Vector de caracteres con las rutas de los archivos de entrada .grib2.
#' @param ruta_out Vector de caracteres con las rutas de destino para los archivos .nc.
#' @param parallel Lógico, indica si la conversión debe realizarse en paralelo. Por defecto es `FALSE`.
#' @param ncores Entero, número de núcleos a utilizar para la conversión en paralelo. Solo aplica si `parallel` es `TRUE`. Por defecto, usa todos los núcleos disponibles menos uno.
#' @param verbose Lógico, indica si la función debe imprimir mensajes sobre el progreso de la conversión. Por defecto es `TRUE`.
#'
#' @details
#' Para el funcionamiento en modo paralelo, esta función depende del paquete `doSNOW` y
#' configura un clúster SOCK para la ejecución paralela de las conversiones. La conversión
#' de rutas de Windows a WSL se realiza mediante la función `convertirRutaWindowsAWSL`,
#' que debe estar definida previamente o ser parte del mismo paquete.
#'
#' La barra de progreso y el cálculo del tiempo estimado se añaden para mejorar la
#' interacción del usuario con la función, especialmente útil para conversiones de
#' larga duración.
#'
#' @return
#' La función no retorna un objeto. Los archivos .nc son escritos en las rutas especificadas
#' por `ruta_out`.
#'
#' @examples
#' \dontrun{
#' ruta_in <- c("/path/to/input/file1.grib2", "/path/to/input/file2.grib2")
#' ruta_out <- c("/path/to/output/file1.nc", "/path/to/output/file2.nc")
#' Grib2ANetCDF(ruta_in, ruta_out, parallel = TRUE, verbose = TRUE)
#' }
#'
#' @export
#' @importFrom glue glue
#' @import doSNOW
#' @import pbapply
#' @import R.utils

Grib2ANetCDF <- function(ruta_in, ruta_out, parallel = FALSE, ncores = detectCores() - 3, verbose = TRUE) {
  tiempo_inicio <- Sys.time() # Para estimar el tiempo total

  if(!parallel) {
    if (verbose) cat(glue("Iniciando la conversión de {length(ruta_in)} archivo(s) de .grib2 a .nc...\n"))

    pbar <- pbapply::pbsetup(length(ruta_in)) # Configurar la barra de progreso

    for (i in seq_along(ruta_in)) {
      if (verbose) cat(glue("Procesando {ruta_in[i]}...\n"))

      rutaWSL_in <- convertirRutaWindowsAWSL(ruta_in[i])
      rutaWSL_out <- convertirRutaWindowsAWSL(ruta_out[i])
      comando <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in} {rutaWSL_out}'")
      system(comando)

      pbapply::pbstep() # Avanzar la barra de progreso
    }
    if (verbose) cat("Conversión completada.\n")
  } else {
    if (verbose) cat(glue("Iniciando la conversión paralela de {length(ruta_in)} archivo(s) de .grib2 a .nc utilizando {ncores} núcleos...\n"))
    cl <- makeCluster(ncores, type = "SOCK")
    registerDoSNOW(cl)

    clusterExport(cl, varlist = c("convertirRutaWindowsAWSL", "glue","rutas_nc"))
    clusterEvalQ(cl, {
      library(glue)
      library(R.utils)
      library(pbapply)
    })

    # Usar pbapply en lugar de foreach para la barra de progreso
    resultados <- pbapply::pblapply(1:length(ruta_in), function(i) {
      rutaWSL_in_i <- convertirRutaWindowsAWSL(ruta_in[i])
      rutaWSL_out_i <- convertirRutaWindowsAWSL(ruta_out[i])
      comando_i <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in_i} {rutaWSL_out_i}'")
      system(comando_i)
      if (verbose) glue("Archivo {ruta_in[i]} procesado.\n") else NULL
    }, cl = cl)

    stopCluster(cl)
    if (verbose) cat("Conversión paralela completada.\n")
  }

  tiempo_fin <- Sys.time() # Tiempo final
  tiempo_total <- tiempo_fin - tiempo_inicio # Calcular el tiempo total de ejecución
  if (verbose) cat(glue("Tiempo total de ejecución: {round(tiempo_total, 2)} segundos\n"))
}

