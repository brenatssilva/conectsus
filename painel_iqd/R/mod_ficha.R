mostrar_ficha <- function(indicador_id) {
  meta <- indicador_por_id(indicador_id)
  if (is.null(meta) || is.null(meta$ficha)) {
    showModal(modalDialog(
      title = "Sobre o indicador",
      p("Indicador em definição."),
      easyClose = TRUE,
      footer = modalButton("Fechar")
    ))
    return(invisible())
  }

  ficha <- meta$ficha
  secao <- function(titulo, conteudo) {
    if (is.null(conteudo) || length(conteudo) == 0) return(NULL)
    div(
      class = "ficha-secao",
      h4(titulo),
      if (is.list(conteudo) || length(conteudo) > 1) tags$ul(lapply(conteudo, tags$li)) else p(conteudo)
    )
  }

  showModal(modalDialog(
    title = paste("Sobre o indicador —", meta$id),
    size = "l",
    h4(meta$nome),
    secao("Conceituação", ficha$conceituacao),
    secao("Interpretação", ficha$interpretacao),
    secao("Usos", ficha$usos),
    secao("Limitações", ficha$limitacoes),
    secao("Fonte", ficha$fonte),
    secao("Método de cálculo", ficha$metodo_calculo),
    secao("Categorias sugeridas para análise", ficha$categorias),
    easyClose = TRUE,
    footer = modalButton("Fechar")
  ))
}

mod_ficha_ui <- function(id) {
  NULL
}

mod_ficha_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    invisible(NULL)
  })
}
