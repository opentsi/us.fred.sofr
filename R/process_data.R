#' Process SOFRINDEX Data into series.csv
#'
#' Fetches the most recent vintage of the SOFR Index (SOFRINDEX)
#' from FRED and writes it to \code{data-raw/sofr/series.csv}.
#'
#' @importFrom alfred get_fred_series
#' @param key Directory name under \code{data-raw/} where the CSV is written.
#'   Defaults to \code{"sofr"}.
#' @return Invisibly returns the output file path.
#' @export
process_data <- function(key = "sofr") {
  ts_data <- alfred::get_fred_series("SOFRINDEX", "sofr")

  ts_df <- data.frame(
    time  = as.Date(ts_data$date),
    value = ts_data$sofr
  )

  output_path <- file.path(".", "data-raw/csv","idx.csv")
  write.csv(ts_df, file = output_path, row.names = FALSE)
  message(sprintf("Latest vintage of SOFRINDEX written to %s", output_path))

  invisible(output_path)
}
