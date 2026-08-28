mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "iqd-page-head",
      div(class = "breadcrumb", "Painel / Visão geral"),
      h2("Mapa da qualidade dos dados"),
      p("O IQD composto ainda não possui regra formal. A dimensão Consistência já reúne indicadores calculados na base intermediária; as demais dimensões permanecem em definição.")
    ),
    uiOutput(ns("mapa_qualidade"))
  )
}

mod_home_server <- function(id, filtros, ir_para) {
  moduleServer(id, function(input, output, session) {
    kpis_cons <- reactive({
      ids <- indicadores_disponiveis(filtros()$modelo)
      get_kpis(filtros(), ids)
    })

    purrr::walk(CATALOGO$dimensoes, function(d) {
      observeEvent(input[[paste0("abrir_", d$id)]], {
        ir_para(d$id)
      }, ignoreInit = TRUE)
    })

    output$mapa_qualidade <- renderUI({
      dims <- CATALOGO$dimensoes
      cons <- kpis_cons()
      cards_esq <- lapply(dims[1:4], function(d) card_dimensao(session$ns, d, cons))
      cards_dir <- lapply(dims[5:9], function(d) card_dimensao(session$ns, d, cons))

      div(
        class = "iqd-home-map",
        cards_esq,
        div(
          class = "iqd-iqd",
          div(
            class = "iqd-ring",
            strong("IQD"),
            span("Índice de Qualidade de Dados")
          ),
          p(style = "margin: 0; color: var(--text-secondary); font-size: 0.85rem;", "Indicador em definição.")
        ),
        cards_dir
      )
    })
  })
}

card_dimensao <- function(ns, d, cons) {
  if (isTRUE(d$implementada) && !is.null(cons) && nrow(cons) > 0) {
    linhas <- lapply(seq_len(nrow(cons)), function(i) {
      meta <- indicador_por_id(cons$indicador_id[i])
      nome <- if (is.null(meta)) cons$indicador_id[i] else meta$nome_curto
      div(
        style = "font-size: 0.78rem; color: var(--text-secondary);",
        paste0(nome, ": ", formatar_percentual(cons$percentual[i]))
      )
    })
    valor <- NULL
    status <- linhas
  } else if (isTRUE(d$implementada) && (is.null(cons) || nrow(cons) == 0)) {
    valor <- div(class = "dim-valor", "—")
    status <- div(class = "dim-status", "Não há dados disponíveis para os filtros selecionados.")
  } else {
    valor <- NULL
    status <- div(class = "dim-status", "Indicadores em definição")
  }

  actionButton(
    ns(paste0("abrir_", d$id)),
    label = tagList(
      div(class = "dim-nome", d$nome),
      valor,
      status
    ),
    class = "iqd-dim-card"
  )
}
