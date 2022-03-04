## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 7,
  fig.height = 7,
  out.width  = "100%",
  dpi        = 300
)

## ----'setup', echo = FALSE----------------------------------------------------
library("popbayes")

## ---- echo = FALSE, out.width = "100%", fig.cap = "Framework of `popbayes`", fig.align = 'center'----
knitr::include_graphics("docs/popbayes-diagram.png")

## ----'load-data'--------------------------------------------------------------
## Define filename path ----
file_path <- system.file("extdata", "garamba_survey.csv", package = "popbayes")

## Read CSV file ----
garamba <- read.csv(file = file_path)

## ----'print-data', echo = FALSE-----------------------------------------------
knitr::kable(head(garamba, 20), caption = "The Garamba dataset (first 20 rows)", 
             align = c("c", "l", "c", "c", "c", "r", "r", "r", "c", "r", "r"))

## ----'load-data-2'------------------------------------------------------------
data("species_info")

## ----'print-data-2', echo = FALSE---------------------------------------------
knitr::kable(species_info[ , c(3, 6, 7, 8, 9)], 
             caption = "Species with count conversion information in popbayes", 
             align = c("l", "c", "c", "r", "r"))

## ----'create-info'------------------------------------------------------------
## Extract the relevant columns of the package table "species_info" ----
info_from_package <- species_info[ , c("species", "pref_field_method", "conversion_A2G", "rmax")]

## Add the new species ----
new_conversion_info <- data.frame("species"           = c("Taurotragus oryx","Taurotragus derbianus"),
                                  "pref_field_method" = "G",
                                  "conversion_A2G"    = 2.302,
                                  "rmax"              = 0.1500)

## Append the new species ----
info <- rbind(info_from_package, new_conversion_info)
info

## ----'check-location'---------------------------------------------------------
unique(garamba$"location")

sum(is.na(garamba$"location"))   # Are there any missing values?

## ----'check-species'----------------------------------------------------------
unique(garamba$"species")

sum(is.na(garamba$"species"))   # Are there any missing values?

## Are there species absent from the 'species_info' popbayes dataset?
garamba_species <- unique(garamba$"species")
garamba_species[which(!(garamba_species %in% species_info$"species"))]

## ----'check-date'-------------------------------------------------------------
is.numeric(garamba$"date")     # Are dates in a numerical format?

sum(is.na(garamba$"date"))     # Are there any missing values?

range(garamba$"date")          # What is the temporal extent?

## ----'convert-date'-----------------------------------------------------------
## Convert a character to a date object ----
x <- as.Date("2021/05/19")
x

## Convert a date to a numeric (number of days since 1970/01/01) ----
x <- as.numeric(x)
x

## Check ----
as.Date(x, origin = as.Date("1970/01/01"))

## ----'check-counts'-----------------------------------------------------------
is.numeric(garamba$"count")   # Are counts in a numerical format?

range(garamba$"count")        # What is the range of values?

sum(is.na(garamba$"count"))   # Are there any missing values?

## ----'check-stat'-------------------------------------------------------------
unique(garamba$"stat_method")

sum(is.na(garamba$"stat_method"))   # Are there any missing values?

## ----'check-field'------------------------------------------------------------
unique(garamba$"field_method")

sum(is.na(garamba$"field_method"))   # Are there any missing values?

## ----'define-path-1', eval = TRUE, echo = FALSE-------------------------------
path <- tempdir()

## ----'define-path-2', eval = FALSE, echo = TRUE-------------------------------
#  path <- "the_folder_to_store_outputs"

## ----'format-data'------------------------------------------------------------
garamba_formatted <- popbayes::format_data(data              = garamba, 
                                           path              = path,
                                           field_method      = "field_method",
                                           pref_field_method = "pref_field_method",
                                           conversion_A2G    = "conversion_A2G",
                                           rmax              = "rmax")

## ----'explore-series'---------------------------------------------------------
## Class of the object ----
class(garamba_formatted)

## Number of elements (i.e. number of count series) ----
length(garamba_formatted)

## Get series names ----
popbayes::list_series(path)

## ----'filter-series'----------------------------------------------------------
## Retrieve series by species and location ----
a_buselaphus <- popbayes::filter_series(data     = garamba_formatted, 
                                        species  = "Alcelaphus buselaphus",
                                        location = "Garamba")

## ----'print-series'-----------------------------------------------------------
print(a_buselaphus)

## ----'plot-series-1', fig.width=12, fig.height=6, out.width="100%"------------
popbayes::plot_series("garamba__alcelaphus_buselaphus", path = path)

## ----'list-folder-1', echo = TRUE, eval = FALSE-------------------------------
#  list.files(path, recursive = TRUE)

## ----'list-folder-2', echo = FALSE, eval = TRUE-------------------------------
list.files(path, recursive = TRUE, pattern = "^garamba__")

## ----'read-series', eval = FALSE----------------------------------------------
#  a_buselaphus <- popbayes::read_series("garamba__alcelaphus_buselaphus", path = path)

## ----'run-jags', eval = FALSE-------------------------------------------------
#  a_buselaphus_bugs <- popbayes::fit_trend(a_buselaphus, path = path)

## ----'read-bugs', eval = FALSE------------------------------------------------
#  a_buselaphus_bugs <- popbayes::read_bugs("garamba__alcelaphus_buselaphus", path = path)

## ----'diagnostic', eval = FALSE-----------------------------------------------
#  popbayes::diagnostic(a_buselaphus_bugs)
#  #> All models have converged.

## ----'re-run-jags', eval = FALSE----------------------------------------------
#  a_buselaphus_bugs <- popbayes::fit_trend(a_buselaphus, path = path, ni = 100000, nb = 20000)

## ----'plot-trend-1', fig.width=12, fig.height=6, out.width="100%", eval = FALSE, echo = TRUE----
#  popbayes::plot_trend("garamba__alcelaphus_buselaphus", path = path)

## ---- echo = FALSE, out.width = "100%", fig.align = 'center'------------------
knitr::include_graphics("docs/garamba__alcelaphus_buselaphus.png")

