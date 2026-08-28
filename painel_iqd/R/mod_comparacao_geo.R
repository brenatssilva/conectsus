mod_comparacao_geo_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "full iqd-viz-grid",
    div(class = "iqd-card", h3("Comparação geográfica (i001)"), uiOutput(ns("conteudo"))),
    div(class = "iqd-card", h3("Distribuição por indicador"), uiOutput(ns("dist")))
  )
}

mod_comparacao_geo_server <- function(id, geo, referencia, implementada) {
  moduleServer(id, function(input, output, session) {
    output$conteudo <- renderUI({
      if (!isTRUE(implementada())) return(ui_estado_definicao())
      plotlyOutput(session$ns("barras"), height = "320px")
    })

    output$dist <- renderUI({
      if (!isTRUE(implementada())) return(ui_estado_definicao())
      plotlyOutput(session$ns("barras_ind"), height = "320px")
    })

    output$barras <- renderPlotly({
      dados <- geo()
      if (is.null(dados)) return(plotly_vazio("erro"))
      if (nrow(dados) == 0) return(plotly_vazio("vazio"))

      resumo <- dados |>
        dplyr::filter(.data$indicador_id == "i001") |>
        dplyr::filter(!is.na(.data$percentual)) |>
        dplyr::arrange(.data$percentual) |>
        dplyr::slice_head(n = CFG$consultas$max_barras_geo)

      if (nrow(resumo) == 0) return(plotly_vazio("vazio"))

      hover <- paste0(
        resumo$local, "<br>", formatar_percentual(resumo$percentual),
        "<br>", formatar_inteiro(resumo$numerador), " / ", formatar_inteiro(resumo$denominador)
      )

      p <- plot_ly(
        resumo,
        x = ~percentual,
        y = ~reorder(local, percentual),
        type = "bar",
        orientation = "h",
        marker = list(color = IQD_CORES$primary),
        text = hover,
        hoverinfo = "text"
      )

      ref <- referencia()
      if (!is.null(ref) && nrow(ref) > 0) {
        ref_i001 <- dplyr::filter(ref, .data$indicador_id == "i001")
        ref_val <- if (nrow(ref_i001) == 0) NA_real_ else ref_i001$percentual[1]
        if (!is.na(ref_val)) {
          p <- p |>
            layout(shapes = list(list(
              type = "line", x0 = ref_val, x1 = ref_val, y0 = 0, y1 = 1, yref = "paper",
              line = list(color = IQD_CORES$accent, dash = "dot", width = 1)
            )))
        }
      }

      plotly_layout_padrao(p) |>
        layout(xaxis = list(ticksuffix = "%", rangemode = "tozero"), yaxis = list(title = ""))
    })

    output$barras_ind <- renderPlotly({
      dados <- geo()
      if (is.null(dados) || nrow(dados) == 0) return(plotly_vazio("vazio"))

      tot <- dados |>
        dplyr::group_by(.data$indicador_id) |>
        dplyr::summarise(
          numerador = sum(.data$numerador, na.rm = TRUE),
          denominador = sum(.data$denominador, na.rm = TRUE),
          .groups = "drop"
        ) |>
        dplyr::mutate(
          percentual = dplyr::if_else(.data$denominador > 0, .data$numerador / .data$denominador * 100, NA_real_)
        )

      hover <- paste0(tot$indicador_id, "<br>", formatar_percentual(tot$percentual))
      p <- plot_ly(
        tot,
        x = ~percentual,
        y = ~indicador_id,
        type = "bar",
        orientation = "h",
        marker = list(color = IQD_CORES$accent),
        text = hover,
        hoverinfo = "text"
      )
      plotly_layout_padrao(p) |>
        layout(xaxis = list(ticksuffix = "%"), yaxis = list(title = ""))
    })
  })
}
