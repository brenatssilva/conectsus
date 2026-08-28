mod_series_temporais_ui <- function(id) {
  ns <- NS(id)
  div(class = "iqd-card full", h3("Série histórica"), uiOutput(ns("conteudo")))
}

mod_series_temporais_server <- function(id, serie, implementada) {
  moduleServer(id, function(input, output, session) {
    output$conteudo <- renderUI({
      if (!isTRUE(implementada())) return(ui_estado_definicao())
      plotlyOutput(session$ns("grafico"), height = "280px")
    })

    output$grafico <- renderPlotly({
      dados <- serie()
      if (is.null(dados)) return(plotly_vazio("erro"))
      if (nrow(dados) == 0) return(plotly_vazio("vazio"))

      n_periodos <- dplyr::n_distinct(dados$periodo)
      mostrar_marcador <- n_periodos <= 24

      hover <- paste0(
        dados$indicador_id, "<br>", dados$periodo,
        "<br>", formatar_percentual(dados$percentual),
        "<br>Numerador: ", formatar_inteiro(dados$numerador),
        "<br>Denominador: ", formatar_inteiro(dados$denominador)
      )

      p <- plot_ly(
        dados,
        x = ~periodo,
        y = ~percentual,
        color = ~indicador_id,
        colors = c(IQD_CORES$primary, IQD_CORES$accent, IQD_CORES$text_secondary),
        type = "scatter",
        mode = if (mostrar_marcador) "lines+markers" else "lines",
        text = hover,
        hoverinfo = "text"
      )
      plotly_layout_padrao(p, legend = TRUE) |>
        layout(yaxis = list(ticksuffix = "%", rangemode = "tozero"))
    })
  })
}

plotly_vazio <- function(tipo = "vazio") {
  msg <- if (identical(tipo, "erro")) {
    "Não foi possível carregar esta visualização."
  } else {
    "Não há dados disponíveis para os filtros selecionados."
  }
  plot_ly() |>
    layout(annotations = list(text = msg, showarrow = FALSE, font = list(color = IQD_CORES$text_secondary))) |>
    plotly_layout_padrao()
}
