filtros_padrao <- function() {
  list(
    ano = NULL,
    mes = NULL,
    semestre = NULL,
    regiao = NULL,
    uf = NULL,
    municipio = NULL,
    cnes = NULL,
    modelo = NULL,
    granularidade = "mes"
  )
}

rotulo_geo_na <- function(x, fallback = "Não identificado") {
  dplyr::if_else(is.na(x) | x %in% c("", "NI", "Nao identificado", "Não identificado"), fallback, as.character(x))
}

grain_geografico <- function(filtros) {
  if (!is.null(filtros$municipio) && nzchar(filtros$municipio)) return("cnes")
  if (!is.null(filtros$uf) && nzchar(filtros$uf)) return("municipio")
  if (!is.null(filtros$regiao) && nzchar(filtros$regiao)) return("uf")
  "regiao"
}
