mod_nav_ui <- function(id) {
  ns <- NS(id)
  dimensoes <- CATALOGO$dimensoes
  tagList(
    actionButton(
      ns("nav_home"),
      label = tagList(span(class = "nav-icon", bsicons::bs_icon("house")), "Visão Geral"),
      class = "iqd-nav-item is-active"
    ),
    lapply(dimensoes, function(d) {
      actionButton(
        ns(paste0("nav_", d$id)),
        label = tagList(span(class = "nav-icon", bsicons::bs_icon(d$icone)), d$nome),
        class = "iqd-nav-item"
      )
    })
  )
}

mod_nav_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    pagina <- reactiveVal("home")
    ns <- session$ns

    ids <- c("home", purrr::map_chr(CATALOGO$dimensoes, "id"))

    marcar_ativo <- function(atual) {
      for (item in ids) {
        session$sendCustomMessage("iqd-nav-active", list(
          id = ns(paste0("nav_", item)),
          active = identical(item, atual)
        ))
      }
    }

    observeEvent(input$nav_home, pagina("home"))
    purrr::walk(CATALOGO$dimensoes, function(d) {
      observeEvent(input[[paste0("nav_", d$id)]], pagina(d$id), ignoreInit = TRUE)
    })

    observeEvent(pagina(), marcar_ativo(pagina()), ignoreInit = FALSE)

    list(
      pagina = pagina,
      ir_para = function(destino) pagina(destino)
    )
  })
}
