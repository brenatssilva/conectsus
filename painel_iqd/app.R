ui <- bslib::page_fillable(
  title = CFG$app$nome,
  theme = iqd_theme(),
  padding = 0,
  gap = 0,
  lang = "pt-BR",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('iqd-nav-active', function(msg) {
        var el = document.getElementById(msg.id);
        if (!el) return;
        if (msg.active) { el.classList.add('is-active'); }
        else { el.classList.remove('is-active'); }
      });
    "))
  ),
  mod_header_ui("header"),
  bslib::layout_sidebar(
    fillable = TRUE,
    sidebar = bslib::sidebar(
      id = "sidebar_nav",
      title = "Navegação",
      width = 250,
      open = "desktop",
      mod_nav_ui("nav")
    ),
    div(
      style = "padding: 1rem 1.15rem 1.5rem;",
      do.call(
        tabsetPanel,
        c(
          list(id = "main_pages", type = "hidden", selected = "home"),
          list(tabPanel(title = "home", value = "home", mod_home_ui("home"))),
          lapply(CATALOGO$dimensoes, function(d) {
            tabPanel(title = d$nome, value = d$id, mod_dimensao_ui(d$id))
          })
        )
      )
    )
  )
)

server <- function(input, output, session) {
  lookups <- reactive(get_lookups())

  nav <- mod_nav_server("nav")
  mod_header_server("header", lookups)
  mod_home_server("home", reactive(filtros_padrao()), nav$ir_para)

  purrr::walk(CATALOGO$dimensoes, function(d) {
    mod_dimensao_server(d$id, d$id, lookups, nav$pagina)
  })

  observeEvent(nav$pagina(), {
    updateTabsetPanel(session, "main_pages", selected = nav$pagina())
  }, ignoreInit = FALSE)
}

shinyApp(ui, server)
