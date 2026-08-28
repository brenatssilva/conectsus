mod_cnes_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "iqd-card full",
    h3("Análise por CNES (i001)"),
    p(
      class = "text-secondary",
      style = "font-size: 0.82rem; margin-top: -0.4rem;",
      "Barras dos estabelecimentos com menor percentual de CNES estruturalmente válido. Treemap foi descartado pela cardinalidade elevada."
    ),
    uiOutput(ns("conteudo"))
  )
}

mod_cnes_server <- function(id, cnes, implementada) {
  moduleServer(id, function(input, output, session) {
    output$conteudo <- renderUI({
      if (!isTRUE(implementada())) return(ui_estado_definicao())
      plotlyOutput(session$ns("barras"), height = "320px")
    })

    output$barras <- renderPlotly({
      dados <- cnes()
      if (is.null(dados)) return(plotly_vazio("erro"))
      dados <- dplyr::filter(dados, .data$indicador_id == "i001")
      if (nrow(dados) == 0) return(plotly_vazio("vazio"))

      dados <- dplyr::arrange(dados, .data$percentual)
      hover <- paste0(
        "CNES ", dados$co_cnes, "<br>", formatar_percentual(dados$percentual),
        "<br>", formatar_inteiro(dados$numerador), " / ", formatar_inteiro(dados$denominador)
      )
      p <- plot_ly(
        dados,
        x = ~percentual,
        y = ~reorder(co_cnes, percentual),
        type = "bar",
        orientation = "h",
        marker = list(color = IQD_CORES$primary_dark),
        text = hover,
        hoverinfo = "text"
      )
      plotly_layout_padrao(p) |>
        layout(xaxis = list(ticksuffix = "%"), yaxis = list(title = ""))
    })
  })
}
