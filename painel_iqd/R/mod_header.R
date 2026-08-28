mod_header_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "iqd-header",
    div(
      class = "iqd-brand",
      h1(CFG$app$nome),
      p(CFG$app$subtitulo)
    ),
    div(
      class = "iqd-header-meta",
      uiOutput(ns("atualizacao"), inline = TRUE),
      actionButton(
        ns("metodologia"),
        label = tagList(bsicons::bs_icon("info-circle"), "Metodologia"),
        class = "btn btn-sm btn-outline-primary"
      )
    )
  )
}

mod_header_server <- function(id, lookups) {
  moduleServer(id, function(input, output, session) {
    output$atualizacao <- renderUI({
      dt <- lookups()$atualizacao
      texto <- if (is.null(dt) || length(dt) == 0 || is.na(dt[1])) {
        "Atualização não disponível"
      } else {
        paste("Atualizado em", format(as.POSIXct(dt[1]), "%d/%m/%Y"))
      }
      span(class = "iqd-chip", bsicons::bs_icon("calendar3"), texto)
    })

    observeEvent(input$metodologia, {
      showModal(modalDialog(
        title = "Metodologia",
        tags$p("Os indicadores usam numerador e denominador aditivos da base intermediária. O percentual é sempre SUM(numerador) / SUM(denominador) × 100."),
        tags$p("O Índice de Qualidade de Dados (IQD) composto e as faixas qualitativas ainda não possuem regra formal nos materiais deste repositório."),
        tags$p("A dimensão Consistência é a única demonstrada com dados reais nesta versão (i001, i002 e i018 no RIA-R)."),
        easyClose = TRUE,
        footer = modalButton("Fechar")
      ))
    })
  })
}
