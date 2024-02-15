Grib2ANetCDF <- function(ruta_in, ruta_out, parallel = FALSE, ncores = detectCores() - 1, verbose = TRUE) {
  if(!parallel) {
    if (verbose) cat(glue("Iniciando la conversión de {length(ruta_in)} archivo(s) de .grib2 a .nc...\n"))
    for (i in seq_along(ruta_in)) {
      if (verbose) cat(glue("Procesando {ruta_in[i]}...\n"))
      rutaWSL_in <- convertirRutaWindowsAWSL(ruta_in[i])
      rutaWSL_out <- convertirRutaWindowsAWSL(ruta_out[i])
      comando <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in} {rutaWSL_out}'")
      system(comando)
    }
    if (verbose) cat("Conversión completada.\n")
  } else {
    if (verbose) cat(glue("Iniciando la conversión paralela de {length(ruta_in)} archivo(s) de .grib2 a .nc utilizando {ncores} núcleos...\n"))
    cl <- makeCluster(ncores, type = "SOCK")
    registerDoSNOW(cl)

    # Asegurarse de exportar y cargar las funciones necesarias en cada nodo
    clusterExport(cl, varlist = c("convertirRutaWindowsAWSL", "glue"))
    clusterEvalQ(cl, {
      library(glue)
      library(R.utils)
    })

    # Ejecución paralela
    resultados <- foreach(i = 1:length(ruta_in), .packages = c("glue", "R.utils")) %dopar% {
      rutaWSL_in_i <- convertirRutaWindowsAWSL(ruta_in[i])
      rutaWSL_out_i <- convertirRutaWindowsAWSL(ruta_out[i])
      comando_i <- glue("wsl bash -c '/home/inia/ICON/triangular_a_lat_lon/0125/transform_0125.sh {rutaWSL_in_i} {rutaWSL_out_i}'")
      system(comando_i)
      if (verbose) glue("Archivo {ruta_in[i]} procesado.\n") else NULL
    }

    # Cerrar el clúster
    stopCluster(cl)
    if (verbose) cat("Conversión paralela completada.\n")
  }
}
