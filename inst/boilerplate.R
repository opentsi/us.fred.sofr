library(deloRean)
library(opentimeseries)
## Step 2: Generate History

library(alfred)
library(data.table)
library(tsbox)

# SOFRINDEX: SOFR Index (Secured Overnight Financing Rate Index)
# Daily, Index, Not Seasonally Adjusted
# Full vintage history from ALFRED: https://alfred.stlouisfed.org/series?seid=SOFRINDEX

sofr <- get_alfred_series("SOFRINDEX", "sofr")
sofr_dt <- data.table::as.data.table(sofr)
head(sofr_dt)
# Get unique vintage (realtime) dates, sorted chronologically
vintage_dates <- sort(unique(sofr_dt$realtime_period))

# Build a named list: one tsbox-compatible data.table per vintage
tsl <- lapply(vintage_dates, function(vdate) {
  sofr_dt[realtime_period == vdate, .(time = date, value = sofr)]
})
names(tsl) <- rep("idx", length(tsl))


## Step 3: Create vintages data.table
vintages_dt <- create_vintage_dt(vintage_dates, tsl)
head(vintages_dt)
# sanity check run: vintages_dt$data[1]


## Step 4: Import History to Archive
# setwd...
archive_import_history(vintages_dt, repository_path = ".")

## Step 5: Write & Validate Metadata

# check if info is available via api
render_metadata()
meta <- read_meta(".")
validate_metadata(meta) # TRUE


## Step 6: Seal Archive
devtools::load_all()
library(digest)
checksum_input <- generate_checksum_input()
archive_seal(checksum_input)


## Step 7: Final Checks & Automation
devtools::load_all()
handle_update()

library(devtools)
check()
install()


