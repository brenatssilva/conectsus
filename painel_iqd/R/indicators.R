calcular_indicador <- function(data, numerador = "numerador", denominador = "denominador") {
  if (is.null(data) || nrow(data) == 0) {
    return(dplyr::tibble(
      numerador = NA_real_,
      denominador = NA_real_,
      percentual = NA_real_
    ))
  }

  num <- sum(data[[numerador]], na.rm = TRUE)
  den <- sum(data[[denominador]], na.rm = TRUE)

  percentual <- if (is.na(den) || den <= 0) {
    NA_real_
  } else {
    (num / den) * 100
  }

  dplyr::tibble(
    numerador = num,
    denominador = den,
    percentual = percentual
  )
}

agregar_indicador <- function(data, grupos = character()) {
  if (is.null(data) || nrow(data) == 0) {
    return(dplyr::tibble())
  }

  if (length(grupos) == 0) {
    return(calcular_indicador(data))
  }

  data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grupos))) |>
    dplyr::summarise(
      numerador = sum(.data$numerador, na.rm = TRUE),
      denominador = sum(.data$denominador, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      percentual = dplyr::if_else(
        .data$denominador > 0,
        .data$numerador / .data$denominador * 100,
        NA_real_
      )
    )
}

indicadores_disponiveis <- function(modelo) {
  inds <- catalogo_indicadores("consistencia")
  if (is.null(modelo) || length(modelo) == 0) {
    return(purrr::map_chr(inds, "id"))
  }
  purrr::keep(inds, function(ind) {
    any(ind$modelos %in% modelo)
  }) |>
    purrr::map_chr("id")
}
