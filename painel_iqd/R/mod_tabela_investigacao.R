mod_tabela_investigacao_ui <- function(id) {
  ns <- NS(id)
  div(class = "iqd-card full", h3("Tabela para investigação"), uiOutput(ns("conteudo")))
}

mod_tabela_investigacao_server <- function(id, tabela, implementada) {
  moduleServer(id, function(input, output, session) {
    output$conteudo <- renderUI({
      if (!isTRUE(implementada())) return(ui_estado_definicao())
      reactableOutput(session$ns("tabela"))
    })

    output$tabela <- renderReactable({
      dados <- tabela()
      if (is.null(dados) || nrow(dados) == 0) {
        return(reactable::reactable(dplyr::tibble(mensagem = "Não há dados disponíveis para os filtros selecionados.")))
      }

      exibir <- dados |>
        dplyr::transmute(
          indicador = .data$indicador_id,
          local = .data$local,
          numerador = .data$numerador,
          denominador = .data$denominador,
          percentual = .data$percentual
        )

      reactable::reactable(
        exibir,
        searchable = TRUE,
        filterable = TRUE,
        pagination = TRUE,
        defaultPageSize = 10,
        highlight = TRUE,
        compact = TRUE,
        defaultSorted = list(percentual = "asc"),
        columns = list(
          indicador = colDef(name = "Indicador", minWidth = 80),
          local = colDef(name = "Local / estabelecimento", minWidth = 160),
          numerador = colDef(name = "Numerador", cell = function(value) formatar_inteiro(value), minWidth = 100),
          denominador = colDef(name = "Denominador", cell = function(value) formatar_inteiro(value), minWidth = 110),
          percentual = colDef(
            name = "Resultado (%)",
            cell = function(value) formatar_percentual(value),
            minWidth = 110
          )
        ),
        language = reactableLang(
          searchPlaceholder = "Pesquisar",
          noData = "Não há dados disponíveis para os filtros selecionados.",
          pageInfo = "{rowStart}–{rowEnd} de {rows} linhas"
        )
      )
    })
  })
}
