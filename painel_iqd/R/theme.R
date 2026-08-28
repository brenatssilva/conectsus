IQD_CORES <- list(
  primary = "#1B7A4E",
  primary_dark = "#145C3B",
  primary_light = "#E8F5EE",
  background = "#F4F6F5",
  surface = "#FFFFFF",
  text_primary = "#1C2B24",
  text_secondary = "#5C6B64",
  border = "#E2E8E4",
  accent = "#2B6A8C",
  grid = "#EEF1EF"
)

iqd_theme <- function() {
  bslib::bs_theme(
    version = 5,
    bootswatch = NULL,
    bg = IQD_CORES$background,
    fg = IQD_CORES$text_primary,
    primary = IQD_CORES$primary,
    base_font = bslib::font_google("Source Sans 3"),
    heading_font = bslib::font_google("Source Sans 3"),
    "border-radius" = "0.6rem",
    "font-size-base" = "0.95rem"
  )
}
