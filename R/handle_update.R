#' Handle Data Update
#'
#' Orchestrates the update process: checks if update is needed,
#' processes data, writes output, and stores the new checksum.
#'
#' @importFrom opentimeseries is_update_needed update_checksum
#' @importFrom digest digest
#' @export
handle_update <- function() {

  checksum_input <- generate_checksum_input()

  if (!is_update_needed(checksum_input)) {
    message("No update needed, series up-to-date.")
    return(invisible(NULL))
  }

  new_hash <- digest::digest(checksum_input, algo = "sha256")

  upd <- update_checksum(new_hash)
  if (upd) {
    process_data()
  } else {
    message("Checksum initialized. Data untouched.")
  }
  message("Update complete, checksum stored.")
}


#' User Written Function to Create Input for Checksum Comparison
#'
#' Fetches the most recent vintage of SOFRINDEX from FRED. Because all
#' observations in the dataset share a single publication date, a change
#' in this series signals that the archive needs updating.
#'
#' @importFrom alfred get_fred_series
generate_checksum_input <- function() {
  ts_data <- alfred::get_fred_series("SOFRINDEX", "sofr")
  return(ts_data)
}
