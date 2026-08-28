mod_kpis_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("kpis"))
}

mod_kpis_server <- function(id, kpis, n_absoluto, dimensao_implementada) {
  moduleServer(id, function(input, output, session) {
    ids_ficha <- purrr::map_chr(catalogo_indicadores("consistencia"), "id")
    purrr::walk(ids_ficha, function(ind) {
      observeEvent(input[[paste0("ficha_", ind)]], {
        mostrar_ficha(ind)
      }, ignoreInit = TRUE)
    })

    output$kpis <- renderUI({
      if (!isTRUE(dimensao_implementada())) {
        return(div(
          class = "iqd-kpis",
          div(
            class = "iqd-kpi",
            div(class = "kpi-label", "Dimensão de qualidade"),
            div(class = "kpi-value", "—"),
            div(class = "kpi-meta", "Indicador em definição.")
          )
        ))
      }

      dados <- kpis()
      cards <- list(
        div(
          class = "iqd-kpi",
          div(class = "kpi-label", "Nº absoluto"),
          div(class = "kpi-value", formatar_inteiro(n_absoluto()$denominador)),
          div(class = "kpi-meta", "Registros finais (denominador i001)")
        ),
        div(
          class = "iqd-kpi",
          div(class = "kpi-label", "Dimensão de qualidade"),
          div(class = "kpi-value", "—"),
          div(class = "kpi-meta", "Indicador em definição.")
        )
      )

      if (is.null(dados)) {
        return(div(class = "iqd-kpis", cards, ui_estado_erro()))
      }
      if (nrow(dados) == 0) {
        return(div(class = "iqd-kpis", cards, ui_estado_vazio()))
      }

      extras <- lapply(seq_len(nrow(dados)), function(i) {
        linha <- dados[i, ]
        meta <- indicador_por_id(linha$indicador_id)
        nome <- if (is.null(meta)) linha$indicador_id else meta$nome_curto
        div(
          class = "iqd-kpi",
          div(
            class = "kpi-label",
            nome,
            actionLink(
              session$ns(paste0("ficha_", linha$indicador_id)),
              label = span(bsicons::bs_icon("info-circle")),
              title = "Sobre o indicador",
              style = "margin-left: 0.35rem;"
            )
          ),
          div(class = "kpi-value", formatar_percentual(linha$percentual)),
          div(
            class = "kpi-meta",
            paste0(formatar_inteiro(linha$numerador), " / ", formatar_inteiro(linha$denominador))
          )
        )
      })

      div(class = "iqd-kpis", cards, extras)
    })
  })
}
