.iqd_env <- new.env(parent = emptyenv())

caminho_modelo <- function(modelo_chave) {
  file.path(
    APP_DIR,
    CFG$dados$raiz,
    CFG$dados$modelos[[modelo_chave]]
  ) |>
    normalizePath(winslash = "/", mustWork = FALSE)
}

listar_parquet <- function(pastas) {
  arquivos <- unlist(lapply(pastas, function(pasta) {
    list.files(
      pasta,
      pattern = "^part-.*\\.parquet$",
      full.names = TRUE,
      recursive = FALSE,
      ignore.case = TRUE
    )
  }), use.names = FALSE)
  arquivos[file.exists(arquivos)]
}

get_dataset <- function(modelos = NULL) {
  chaves <- names(CFG$dados$modelos)
  if (!is.null(modelos) && length(modelos) > 0) {
    mapa <- c("RIA-R" = "ria_r", "RA" = "ra", "REL" = "rel")
    chaves <- unname(mapa[modelos])
    chaves <- chaves[!is.na(chaves)]
  }
  chave_cache <- paste(chaves, collapse = "|")
  if (!is.null(.iqd_env$datasets[[chave_cache]])) {
    return(.iqd_env$datasets[[chave_cache]])
  }

  caminhos <- vapply(chaves, caminho_modelo, character(1))
  existentes <- caminhos[dir.exists(caminhos)]
  if (length(existentes) == 0) {
    stop("Nenhuma pasta Parquet encontrada. Verifique config/config.yml.")
  }

  # No Windows, open_dataset(pasta) tenta abrir o diretório como arquivo (erro 5).
  arquivos <- listar_parquet(existentes)
  if (length(arquivos) == 0) {
    stop("Nenhum arquivo .parquet encontrado nas pastas da base intermediária.")
  }

  ds <- arrow::open_dataset(arquivos, format = "parquet")
  if (is.null(.iqd_env$datasets)) .iqd_env$datasets <- list()
  .iqd_env$datasets[[chave_cache]] <- ds
  ds
}

filtrar_dataset <- function(ds, filtros, indicador_ids = NULL) {
  out <- ds

  if (!is.null(indicador_ids) && length(indicador_ids) > 0) {
    ids <- indicador_ids
    out <- dplyr::filter(out, .data$indicador_id %in% ids)
  }

  if (!is.null(filtros$modelo) && length(filtros$modelo) > 0) {
    mods <- filtros$modelo
    out <- dplyr::filter(out, .data$modelo_informacional %in% mods)
  }

  if (!is.null(filtros$ano) && length(filtros$ano) > 0) {
    anos <- as.integer(filtros$ano)
    out <- dplyr::filter(out, .data$ano %in% anos)
  }

  meses <- NULL
  if (!is.null(filtros$mes) && length(filtros$mes) > 0) {
    meses <- as.integer(filtros$mes)
  } else if (!is.null(filtros$semestre) && length(filtros$semestre) > 0) {
    meses <- meses_do_semestre(filtros$semestre)
  }
  if (!is.null(meses) && length(meses) > 0 && length(meses) < 12) {
    out <- dplyr::filter(out, .data$mes %in% meses)
  }

  if (!is.null(filtros$regiao) && length(filtros$regiao) > 0 && nzchar(filtros$regiao[1])) {
    regs <- filtros$regiao
    out <- dplyr::filter(out, .data$regiao_brasil %in% regs)
  }

  if (!is.null(filtros$uf) && length(filtros$uf) > 0 && nzchar(filtros$uf[1])) {
    ufs <- filtros$uf
    out <- dplyr::filter(out, .data$sg_uf %in% ufs)
  }

  if (!is.null(filtros$municipio) && length(filtros$municipio) > 0 && nzchar(filtros$municipio[1])) {
    muns <- filtros$municipio
    out <- dplyr::filter(out, .data$co_municipio_ocorrencia %in% muns)
  }

  if (!is.null(filtros$cnes) && length(filtros$cnes) > 0 && nzchar(filtros$cnes[1])) {
    cnes <- filtros$cnes
    out <- dplyr::filter(out, .data$co_cnes %in% cnes)
  }

  out
}

get_lookups <- function() {
  if (!is.null(.iqd_env$lookups)) return(.iqd_env$lookups)

  vazio <- list(
    geo = dplyr::tibble(
      regiao_brasil = character(),
      sg_uf = character(),
      co_municipio_ocorrencia = character(),
      no_municipio_ocorrencia = character()
    ),
    anos = integer(),
    meses = integer(),
    modelos = c("RIA-R", "RA", "REL"),
    atualizacao = NULL
  )

  ds <- com_erro(get_dataset())
  if (is.null(ds)) return(vazio)

  geo <- com_erro({
    ds |>
      dplyr::select(
        .data$regiao_brasil, .data$sg_uf,
        .data$co_municipio_ocorrencia, .data$no_municipio_ocorrencia
      ) |>
      dplyr::distinct() |>
      dplyr::collect()
  })

  tempo <- com_erro({
    ds |>
      dplyr::select(.data$ano, .data$mes) |>
      dplyr::distinct() |>
      dplyr::collect()
  })

  modelos <- com_erro({
    ds |>
      dplyr::select(.data$modelo_informacional) |>
      dplyr::distinct() |>
      dplyr::collect() |>
      dplyr::pull(.data$modelo_informacional)
  })

  atualizacao <- com_erro({
    ds |>
      dplyr::summarise(dt = max(.data$dt_processamento, na.rm = TRUE)) |>
      dplyr::collect() |>
      dplyr::pull(.data$dt)
  })

  if (is.null(geo)) geo <- dplyr::tibble()
  if (is.null(tempo)) tempo <- dplyr::tibble(ano = integer(), mes = integer())

  .iqd_env$lookups <- list(
    geo = geo,
    anos = sort(unique(tempo$ano)),
    meses = sort(unique(tempo$mes)),
    modelos = sort(unique(modelos %||% c("RIA-R", "RA", "REL"))),
    atualizacao = atualizacao
  )
  .iqd_env$lookups
}

coletar_agregado <- function(filtros, indicador_ids, grupos = character()) {
  com_erro({
    ds <- filtrar_dataset(get_dataset(filtros$modelo), filtros, indicador_ids)
    keys <- c("indicador_id", grupos)
    agrupado <- ds |>
      dplyr::group_by(!!!rlang::syms(keys)) |>
      dplyr::summarise(
        numerador = sum(.data$numerador, na.rm = TRUE),
        denominador = sum(.data$denominador, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::collect()

    agrupado |>
      dplyr::mutate(
        percentual = dplyr::if_else(
          .data$denominador > 0,
          .data$numerador / .data$denominador * 100,
          NA_real_
        )
      )
  })
}

get_kpis <- function(filtros, indicador_ids) {
  coletar_agregado(filtros, indicador_ids, grupos = character())
}

get_serie_temporal <- function(filtros, indicador_ids, granularidade = "mes") {
  grupos <- switch(
    granularidade,
    ano = "ano",
    semestre = c("ano", "mes"),
    c("ano", "mes")
  )
  dados <- coletar_agregado(filtros, indicador_ids, grupos = grupos)
  if (is.null(dados) || nrow(dados) == 0) return(dados)

  if (identical(granularidade, "semestre")) {
    dados <- dados |>
      dplyr::mutate(semestre = dplyr::if_else(.data$mes <= 6, 1L, 2L)) |>
      dplyr::group_by(.data$indicador_id, .data$ano, .data$semestre) |>
      dplyr::summarise(
        numerador = sum(.data$numerador, na.rm = TRUE),
        denominador = sum(.data$denominador, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::mutate(
        percentual = dplyr::if_else(
          .data$denominador > 0,
          .data$numerador / .data$denominador * 100,
          NA_real_
        ),
        periodo = paste0(.data$ano, ".", .data$semestre)
      )
  } else if (identical(granularidade, "ano")) {
    dados <- dados |>
      dplyr::mutate(periodo = as.character(.data$ano))
  } else {
    dados <- dados |>
      dplyr::mutate(periodo = sprintf("%d-%02d", .data$ano, .data$mes))
  }
  dplyr::arrange(dados, .data$periodo, .data$indicador_id)
}

get_resultado_geografico <- function(filtros, indicador_ids) {
  grain <- grain_geografico(filtros)
  grupos <- switch(
    grain,
    cnes = c("co_cnes"),
    municipio = c("co_municipio_ocorrencia", "no_municipio_ocorrencia", "sg_uf"),
    uf = c("sg_uf", "regiao_brasil"),
    c("regiao_brasil")
  )
  dados <- coletar_agregado(filtros, indicador_ids, grupos = grupos)
  if (is.null(dados) || nrow(dados) == 0) return(dados)

  dados$local <- switch(
    grain,
    "cnes" = dados$co_cnes,
    "municipio" = rotulo_geo_na(dados$no_municipio_ocorrencia),
    "uf" = rotulo_geo_na(dados$sg_uf, "NI"),
    rotulo_geo_na(dados$regiao_brasil)
  )
  attr(dados, "grain") <- grain
  dados
}

get_analise_cnes <- function(filtros, indicador_ids, n = NULL) {
  n <- n %||% CFG$consultas$top_cnes
  dados <- coletar_agregado(filtros, indicador_ids, grupos = "co_cnes")
  if (is.null(dados) || nrow(dados) == 0) return(dados)
  dados |>
    dplyr::filter(.data$denominador > 0) |>
    dplyr::arrange(.data$percentual, dplyr::desc(.data$denominador)) |>
    dplyr::group_by(.data$indicador_id) |>
    dplyr::slice_head(n = n) |>
    dplyr::ungroup()
}

get_registros_investigacao <- function(filtros, indicador_ids, n = NULL) {
  n <- n %||% CFG$consultas$max_tabela
  dados <- get_resultado_geografico(filtros, indicador_ids)
  if (is.null(dados) || nrow(dados) == 0) return(dados)
  dados |>
    dplyr::filter(.data$denominador > 0) |>
    dplyr::arrange(.data$percentual, dplyr::desc(.data$denominador)) |>
    dplyr::slice_head(n = n)
}

get_opcoes_cnes <- function(filtros, limite = 400) {
  com_erro({
    ds <- filtrar_dataset(get_dataset(filtros$modelo), filtros, indicador_ids = "i001")
    ds |>
      dplyr::select(.data$co_cnes) |>
      dplyr::distinct() |>
      dplyr::head(limite) |>
      dplyr::collect() |>
      dplyr::pull(.data$co_cnes) |>
      sort()
  })
}

get_brasil_referencia <- function(filtros, indicador_ids) {
  filtros_br <- filtros
  filtros_br$regiao <- NULL
  filtros_br$uf <- NULL
  filtros_br$municipio <- NULL
  filtros_br$cnes <- NULL
  get_kpis(filtros_br, indicador_ids)
}
