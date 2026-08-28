mod_dimensao_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("cabecalho")),
    conditionalPanel(
      condition = "output.is_implementada",
      ns = ns,
      mod_filters_ui(ns("filtros"))
    ),
    mod_kpis_ui(ns("kpis")),
    div(class = "iqd-viz-grid",
      mod_series_temporais_ui(ns("serie")),
      mod_comparacao_geo_ui(ns("geo")),
      mod_cnes_ui(ns("cnes")),
      mod_mapa_ui(ns("mapa")),
      mod_tabela_investigacao_ui(ns("tabela"))
    )
  )
}

mod_dimensao_server <- function(id, dimensao_id, lookups, pagina) {
  moduleServer(id, function(input, output, session) {
    dim <- catalogo_dimensao(dimensao_id)
    implementada <- reactive(isTRUE(dim$implementada))
    visivel <- reactive(identical(pagina(), dimensao_id))
    output$is_implementada <- reactive(implementada())
    outputOptions(output, "is_implementada", suspendWhenHidden = FALSE)

    if (isTRUE(dim$implementada)) {
      filtros_mod <- mod_filters_server("filtros", lookups)
      filtros <- filtros_mod$filtros
    } else {
      filtros <- reactive(filtros_padrao())
    }

    ids <- reactive({
      if (!implementada()) return(character())
      indicadores_disponiveis(filtros()$modelo)
    })

    kpis <- reactive({
      req(visivel(), implementada())
      get_kpis(filtros(), ids())
    }) |> bindCache(dimensao_id, filtros(), ids())

    n_abs <- reactive({
      req(visivel(), implementada())
      dados <- get_kpis(filtros(), "i001")
      if (is.null(dados) || nrow(dados) == 0) {
        dplyr::tibble(denominador = NA_real_)
      } else {
        dados
      }
    })

    serie <- reactive({
      req(visivel(), implementada())
      get_serie_temporal(filtros(), ids(), filtros()$granularidade %||% "mes")
    }) |> bindCache(dimensao_id, filtros(), ids())

    geo <- reactive({
      req(visivel(), implementada())
      get_resultado_geografico(filtros(), ids())
    }) |> bindCache(dimensao_id, filtros(), ids())

    referencia <- reactive({
      req(visivel(), implementada())
      get_brasil_referencia(filtros(), "i001")
    }) |> bindCache(filtros()$ano, filtros()$mes, filtros()$semestre, filtros()$modelo)

    cnes <- reactive({
      req(visivel(), implementada())
      get_analise_cnes(filtros(), "i001")
    }) |> bindCache(filtros())

    tabela <- reactive({
      req(visivel(), implementada())
      get_registros_investigacao(filtros(), ids())
    }) |> bindCache(filtros(), ids())

    output$cabecalho <- renderUI({
      div(
        class = "iqd-page-head",
        div(class = "breadcrumb", paste("Painel /", dim$nome)),
        h2(dim$nome),
        p(dim$descricao)
      )
    })

    mod_kpis_server("kpis", kpis, n_abs, implementada)
    mod_series_temporais_server("serie", serie, implementada)
    mod_comparacao_geo_server("geo", geo, referencia, implementada)
    mod_cnes_server("cnes", cnes, implementada)
    mod_mapa_server("mapa", implementada)
    mod_tabela_investigacao_server("tabela", tabela, implementada)
  })
}
