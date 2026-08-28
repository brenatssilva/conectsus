mod_filters_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "iqd-card",
    style = "margin-bottom: 1rem;",
    div(
      class = "iqd-toolbar",
      h3(style = "margin: 0;", "Filtros"),
      actionButton(ns("limpar"), "Limpar filtros", class = "btn btn-sm btn-outline-secondary"),
      actionButton(ns("aplicar"), "Aplicar filtros", class = "btn btn-sm btn-primary")
    ),
    uiOutput(ns("chips")),
    layout_column_wrap(
      width = 1 / 4,
      selectizeInput(ns("modelo"), "Modelo informacional", choices = NULL, multiple = TRUE),
      selectizeInput(ns("ano"), "Ano", choices = NULL, multiple = TRUE),
      selectizeInput(ns("semestre"), "Semestre", choices = c("1º" = "1", "2º" = "2"), multiple = TRUE),
      selectizeInput(ns("mes"), "Mês", choices = NULL, multiple = TRUE),
      selectizeInput(ns("regiao"), "Região", choices = NULL, multiple = FALSE),
      selectizeInput(ns("uf"), "UF", choices = NULL, multiple = FALSE),
      selectizeInput(ns("municipio"), "Município", choices = NULL, multiple = FALSE),
      selectizeInput(ns("cnes"), "CNES", choices = NULL, multiple = FALSE, options = list(placeholder = "Selecione UF ou município"))
    ),
    radioButtons(
      ns("granularidade"),
      "Granularidade da série",
      choices = c("Mês" = "mes", "Semestre" = "semestre", "Ano" = "ano"),
      selected = "mes",
      inline = TRUE
    )
  )
}

mod_filters_server <- function(id, lookups) {
  moduleServer(id, function(input, output, session) {
    applied <- reactiveVal(filtros_padrao())
    initialized <- reactiveVal(FALSE)
    observeEvent(lookups(), {
      lk <- lookups()
      if (is.null(lk) || is.null(lk$geo) || isTRUE(initialized())) return()
      updateSelectizeInput(session, "modelo", choices = lk$modelos, selected = character())
      updateSelectizeInput(session, "ano", choices = lk$anos, selected = character())
      updateSelectizeInput(
        session, "mes",
        choices = stats::setNames(lk$meses, sprintf("%02d", lk$meses)),
        selected = character()
      )
      regioes <- sort(unique(stats::na.omit(lk$geo$regiao_brasil)))
      updateSelectizeInput(
        session, "regiao",
        choices = c("Brasil (todas)" = "", regioes),
        selected = ""
      )
      initialized(TRUE)
    }, ignoreNULL = TRUE)

    observeEvent(list(input$regiao, lookups()), {
      lk <- lookups()
      if (is.null(lk) || is.null(lk$geo) || nrow(lk$geo) == 0) return()
      geo <- lk$geo
      dados <- geo
      if (!is.null(input$regiao) && nzchar(input$regiao)) {
        dados <- dplyr::filter(dados, .data$regiao_brasil == input$regiao)
      }
      ufs <- sort(unique(na.omit(dados$sg_uf)))
      ufs <- ufs[!ufs %in% c("NI")]
      updateSelectizeInput(
        session, "uf",
        choices = c("Todas" = "", ufs),
        selected = ""
      )
    }, ignoreInit = FALSE)

    observeEvent(list(input$uf, input$regiao, lookups()), {
      lk <- lookups()
      if (is.null(lk) || is.null(lk$geo) || nrow(lk$geo) == 0) return()
      geo <- lk$geo
      dados <- geo
      if (!is.null(input$regiao) && nzchar(input$regiao)) {
        dados <- dplyr::filter(dados, .data$regiao_brasil == input$regiao)
      }
      if (!is.null(input$uf) && nzchar(input$uf)) {
        dados <- dplyr::filter(dados, .data$sg_uf == input$uf)
      }
      muns <- dados |>
        dplyr::filter(!is.na(.data$co_municipio_ocorrencia)) |>
        dplyr::distinct(.data$co_municipio_ocorrencia, .data$no_municipio_ocorrencia) |>
        dplyr::arrange(.data$no_municipio_ocorrencia)
      choices <- c("Todos" = "")
      if (nrow(muns) > 0) {
        extra <- stats::setNames(muns$co_municipio_ocorrencia, muns$no_municipio_ocorrencia)
        choices <- c(choices, extra)
      }
      updateSelectizeInput(session, "municipio", choices = choices, selected = "")
    }, ignoreInit = FALSE)

    observeEvent(list(input$uf, input$municipio), {
      tem_geo <- (!is.null(input$uf) && nzchar(input$uf)) ||
        (!is.null(input$municipio) && nzchar(input$municipio))
      if (!tem_geo) {
        updateSelectizeInput(session, "cnes", choices = c("Selecione UF ou município" = ""), selected = "")
        return()
      }
      rascunho <- list(
        modelo = input$modelo,
        ano = input$ano,
        mes = input$mes,
        semestre = input$semestre,
        regiao = empty_to_null(input$regiao),
        uf = empty_to_null(input$uf),
        municipio = empty_to_null(input$municipio),
        cnes = NULL
      )
      opcoes <- get_opcoes_cnes(rascunho)
      updateSelectizeInput(
        session, "cnes",
        choices = c("Todos" = "", opcoes %||% character()),
        selected = "",
        server = TRUE
      )
    }, ignoreInit = TRUE)

    ler_filtros <- function() {
      list(
        ano = empty_to_null(input$ano),
        mes = empty_to_null(input$mes),
        semestre = empty_to_null(input$semestre),
        regiao = empty_to_null(input$regiao),
        uf = empty_to_null(input$uf),
        municipio = empty_to_null(input$municipio),
        cnes = empty_to_null(input$cnes),
        modelo = empty_to_null(input$modelo),
        granularidade = input$granularidade %||% "mes"
      )
    }

    observeEvent(input$aplicar, applied(ler_filtros()))
    observeEvent(input$granularidade, {
      atual <- applied()
      atual$granularidade <- input$granularidade %||% "mes"
      applied(atual)
    }, ignoreInit = TRUE)

    observeEvent(input$limpar, {
      lk <- lookups()
      updateSelectizeInput(session, "modelo", selected = character())
      updateSelectizeInput(session, "ano", selected = character())
      updateSelectizeInput(session, "mes", selected = character())
      updateSelectizeInput(session, "semestre", selected = character())
      updateSelectizeInput(session, "regiao", selected = "")
      updateSelectizeInput(session, "uf", selected = "")
      updateSelectizeInput(session, "municipio", selected = "")
      updateSelectizeInput(session, "cnes", selected = "")
      updateRadioButtons(session, "granularidade", selected = "mes")
      applied(filtros_padrao())
    })

    output$chips <- renderUI({
      f <- applied()
      chips <- c()
      if (!is.null(f$modelo)) chips <- c(chips, paste("MI:", paste(f$modelo, collapse = ", ")))
      if (!is.null(f$ano)) chips <- c(chips, paste("Ano:", paste(f$ano, collapse = ", ")))
      if (!is.null(f$semestre)) chips <- c(chips, paste("Semestre:", paste(f$semestre, collapse = ", ")))
      if (!is.null(f$mes)) chips <- c(chips, paste("Mês:", paste(f$mes, collapse = ", ")))
      if (!is.null(f$regiao)) chips <- c(chips, paste("Região:", f$regiao))
      if (!is.null(f$uf)) chips <- c(chips, paste("UF:", f$uf))
      if (!is.null(f$municipio)) chips <- c(chips, paste("Município:", f$municipio))
      if (!is.null(f$cnes)) chips <- c(chips, paste("CNES:", f$cnes))
      if (length(chips) == 0) {
        span(class = "iqd-chip", "Filtros ativos: Brasil, todos os períodos e modelos")
      } else {
        div(lapply(chips, function(x) span(class = "iqd-chip", x)))
      }
    })

    list(filtros = reactive(applied()))
  })
}

empty_to_null <- function(x) {
  if (is.null(x)) return(NULL)
  x <- x[!(is.na(x) | x == "")]
  if (length(x) == 0) NULL else x
}
