mod_mapa_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "iqd-card full",
    h3("Mapa"),
    uiOutput(ns("conteudo"))
  )
}

mod_mapa_server <- function(id, implementada) {
  moduleServer(id, function(input, output, session) {
    output$conteudo <- renderUI({
      tagList(
        ui_estado_definicao("Indicador em definição."),
        p(
          style = "font-size: 0.82rem; color: var(--text-secondary); text-align: center; margin-top: -1rem;",
          "Para ativar o mapa são necessárias malhas IBGE (UF e município) e o relacionamento com co_municipio_ocorrencia (IBGE 6 dígitos). Esses arquivos não estão neste repositório."
        ),
        leafletOutput(session$ns("mapa"), height = "220px")
      )
    })

    output$mapa <- renderLeaflet({
      leaflet() |>
        addProviderTiles("CartoDB.Positron") |>
        setView(lng = -54, lat = -15, zoom = 3.5)
    })
  })
}
