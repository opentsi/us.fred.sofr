library(deloRean)
library(opentimeseries)


## Step 1: Init Archive
# Already done — archive is initialised.
# archive_init("us.fred.sofr", parent_dir = "~/KOF_Lab/opentsi/")


## Step 2: Generate History

library(alfred)
library(data.table)
library(tsbox)

# SOFRINDEX: SOFR Index (Secured Overnight Financing Rate Index)
# Daily, Index, Not Seasonally Adjusted
# Full vintage history from ALFRED: https://alfred.stlouisfed.org/series?seid=SOFRINDEX

sofr <- get_alfred_series("SOFRINDEX", "sofr")
sofr_dt <- data.table::as.data.table(sofr)

# Get unique vintage (realtime) dates, sorted chronologically
vintage_dates <- sort(unique(sofr_dt$realtime_period))

# Build a named list: one tsbox-compatible data.table per vintage
tsl <- lapply(vintage_dates, function(vdate) {
  sofr_dt[realtime_period == vdate, .(time = date, value = sofr)]
})
names(tsl) <- rep("sofr", length(tsl))


## Step 3: Create vintages data.table
vintages_dt <- create_vintage_dt(vintage_dates, tsl)
head(vintages_dt)
# sanity check run: vintages_dt$data[1]


## Step 4: Import History to Archive
archive_import_history(vintages_dt, repository_path = ".")


## Step 5: Write Metadata
# Edit data-raw/metadata.yaml, then validate and render:
deloRean::render_metadata()
meta <- opentimeseries::read_meta(".")
deloRean::validate_metadata(meta)


## Step 6: Automation
# process_data() and generate_checksum_input() are implemented in R/
# After editing those files:
devtools::load_all()
devtools::check()
devtools::install()


## Step 7: Seal Archive
# Run after render_metadata() has produced inst/metadata.json
checksum_input <- us.fred.sofr:::generate_checksum_input()
archive_seal(checksum_input)
