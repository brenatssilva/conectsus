# Carregado automaticamente pelo Shiny (R/*.R) antes de app.R.

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(bsicons)
  library(dplyr)
  library(tidyr)
  library(arrow)
  library(purrr)
  library(rlang)
  library(stringr)
  library(lubridate)
  library(scales)
  library(plotly)
  library(leaflet)
  library(reactable)
  library(htmltools)
  library(config)
  library(yaml)
})

APP_DIR <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)

CFG <- config::get(
  file = file.path(APP_DIR, "config", "config.yml"),
  use_parent = FALSE
)

CATALOGO <- yaml::read_yaml(
  file.path(APP_DIR, "config", "catalogo.yml"),
  readLines.warn = FALSE
)

options(shiny.sanitize.errors = TRUE)
try(arrow::set_cpu_count(1L), silent = TRUE)
