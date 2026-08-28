`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || (length(x) == 1 && is.na(x))) y else x
}

formatar_inteiro <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("—")
  prettyNum(round(x), big.mark = ".", decimal.mark = ",", scientific = FALSE)
}

formatar_percentual <- function(x, digits = 1) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("—")
  paste0(formatC(x, format = "f", digits = digits, decimal.mark = ","), "%")
}

ui_estado_vazio <- function(mensagem = "Não há dados disponíveis para os filtros selecionados.") {
  div(
    class = "iqd-estado",
    bsicons::bs_icon("inbox", size = "1.4em"),
    p(mensagem)
  )
}

ui_estado_definicao <- function(mensagem = "Indicador em definição.") {
  div(
    class = "iqd-estado iqd-estado--definicao",
    bsicons::bs_icon("hourglass-split", size = "1.4em"),
    p(mensagem)
  )
}

ui_estado_erro <- function() {
  div(
    class = "iqd-estado iqd-estado--erro",
    bsicons::bs_icon("exclamation-triangle", size = "1.4em"),
    p("Não foi possível carregar esta visualização. Tente novamente ou ajuste os filtros.")
  )
}

ui_skeleton <- function() {
  div(class = "iqd-skeleton", aria_hidden = "true")
}

com_erro <- function(expr) {
  tryCatch(
    expr,
    error = function(e) {
      message("[painel_iqd] ", conditionMessage(e))
      NULL
    }
  )
}

catalogo_dimensao <- function(id) {
  purrr::detect(CATALOGO$dimensoes, ~ .x$id == id)
}

catalogo_indicadores <- function(dimensao_id = NULL) {
  inds <- CATALOGO$indicadores
  if (is.null(dimensao_id)) return(inds)
  purrr::keep(inds, ~ .x$dimensao_id == dimensao_id)
}

indicador_por_id <- function(id) {
  purrr::detect(CATALOGO$indicadores, ~ .x$id == id)
}

plotly_layout_padrao <- function(p, legend = FALSE) {
  plotly::layout(
    p,
    font = list(family = "Source Sans 3, sans-serif", color = IQD_CORES$text_primary, size = 12),
    paper_bgcolor = "rgba(0,0,0,0)",
    plot_bgcolor = "rgba(0,0,0,0)",
    margin = list(l = 48, r = 16, t = 8, b = 40),
    xaxis = list(
      showgrid = FALSE,
      zeroline = FALSE,
      tickfont = list(size = 11, color = IQD_CORES$text_secondary)
    ),
    yaxis = list(
      showgrid = TRUE,
      gridcolor = IQD_CORES$grid,
      zeroline = FALSE,
      tickfont = list(size = 11, color = IQD_CORES$text_secondary)
    ),
    showlegend = legend,
    hoverlabel = list(bgcolor = IQD_CORES$surface, font = list(size = 12), bordercolor = IQD_CORES$border)
  ) |>
    plotly::config(displayModeBar = FALSE, locale = "pt-BR")
}

meses_do_semestre <- function(semestre) {
  if (is.null(semestre) || length(semestre) == 0) return(1:12)
  meses <- integer()
  if ("1" %in% as.character(semestre) || 1 %in% semestre) meses <- c(meses, 1:6)
  if ("2" %in% as.character(semestre) || 2 %in% semestre) meses <- c(meses, 7:12)
  unique(meses)
}

rotulo_periodo <- function(ano, mes = NULL, granularidade = "mes") {
  if (identical(granularidade, "ano")) {
    as.character(ano)
  } else if (identical(granularidade, "semestre")) {
    sem <- ifelse(mes <= 6, 1, 2)
    paste0(ano, ".", sem)
  } else {
    sprintf("%d-%02d", ano, mes)
  }
}
