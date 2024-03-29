#' Detect individual count series and create an unique identifier
#'
#' For internal use only.
#'
#' @param data a `data.frame`. 
#' 
#' @param quiet a `logical`. If `TRUE`, suppress messages.
#'
#' @return A `data.frame` with three columns:
#'   - `id` (a series unique identifier);
#'   - `location` (the series site);
#'   - `species` (the series species).
#' 
#' @noRd

get_series <- function(data, quiet = TRUE) {
  
  series_id <- unique(paste(data[ , "location"], data[ , "species"], 
                            sep = "__"))
  
  series_infos <- data.frame("id" = series_id)
  
  series_infos$"location" <- unlist(lapply(strsplit(series_id, "__"), 
                                           function(x) x[1]))
  
  series_infos$"species"  <- unlist(lapply(strsplit(series_id, "__"), 
                                           function(x) x[2]))
  
  series_infos <- series_infos[order(series_infos$"id", decreasing = FALSE), ]
  
  series_infos$"id" <- tolower(series_infos$"id")
  series_infos$"id" <- gsub("\\s{2,}", "", series_infos$"id")
  series_infos$"id" <- gsub("\\s", "_", series_infos$"id")
  series_infos$"id" <- gsub("[[:punct:]]", "_", series_infos$"id")
  
  if (!quiet)
    usethis::ui_done(paste0("Detecting {usethis::ui_value(nrow(series_infos))}",
                            " series with {usethis::ui_value(length(unique(",
                            "series_infos$location)))} location(s) and ",
                            "{usethis::ui_value(length(unique(",
                            "series_infos$species)))} species"))
  
  series_infos
}



#' Extract the count series corresponding to a location and/or a species
#' 
#' @description
#' This function identifies the count series relative to a species and/or
#' a location in a named list like the output of function [format_data()]. If 
#' both species and location are provided, the series of counts of the species 
#' at the specified location is extracted. Otherwise, all series corresponding
#' to the specified criterion (species or location) are extracted.
#' 
#' @param data a named `list`. The output of function [format_data()].
#' 
#' @param species a `character` string. A species name.
#' 
#' @param location a `character` string. A site name.
#'
#' @return A subset of `data`, i.e. a named `list`.
#' 
#' @export
#'
#' @examples
#' ## Load Garamba raw dataset ----
#' file_path <- system.file("extdata", "garamba_survey.csv", 
#'                          package = "popbayes")
#'                          
#' garamba <- read.csv(file = file_path)
#' 
#' ## Create temporary folder ----
#' temp_path <- tempdir()
#' 
#' ## Format dataset ----
#' garamba_formatted <- popbayes::format_data(
#'   data              = garamba, 
#'   path              = temp_path,
#'   field_method      = "field_method",
#'   pref_field_method = "pref_field_method",
#'   conversion_A2G    = "conversion_A2G",
#'   rmax              = "rmax")
#' 
#' ## Number of count series ----
#' length(garamba_formatted)
#' 
#' ## Retrieve count series names ----
#' popbayes::list_series(path = temp_path)
#' 
#' ## Get data for Alcelaphus buselaphus (at all sites) ----
#' x <- popbayes::filter_series(garamba_formatted, 
#'                              species = "Alcelaphus buselaphus")
#' 
#' ## Get data at Garamba (for all species) ----
#' x <- popbayes::filter_series(garamba_formatted, 
#'                              location = "Garamba")
#' 
#' ## Get data for Alcelaphus buselaphus at Garamba only ----
#' x <- popbayes::filter_series(garamba_formatted, 
#'                              location = "Garamba",
#'                              species  = "Alcelaphus buselaphus")

filter_series <- function(data, species = NULL, location = NULL) {
  
  if (!is.list(data)) {
    stop("Argument 'data' must be an output of format_data().")
  }
  
  if (!("data_converted" %in% names(data[[1]]))) {
    stop("Argument 'data' must be an output of format_data().")
  }
  
  
  ## No filter methods ----
  
  if (is.null(species) && is.null(location)) {
    
    usethis::ui_oops(paste0("No species nor location provided to filter ", 
                            "series."))
    
    return(NULL)
  }
  
  
  ## Find series by species ----
  
  if (!is.null(species)) {
    
    if (!is.character(species)) {
      stop("Argument 'species' must be a character string.")
    }
    
    if (length(species) > 1) {
      stop("Argument 'species' must be a character string.")
    }
    
    species_detected <- unlist(lapply(data, function(x, species) 
      ifelse(x$"species" == species, TRUE, FALSE), species = species))
    
    if (sum(species_detected) == 0) {
      stop("Wrong species spelling.")
    }
  }
  
  
  ## Find series by locations ----
  
  if (!is.null(location)) {
    
    if (!is.character(location)) {
      stop("Argument 'location' must be a character string.")
    }
    
    if (length(location) > 1) {
      stop("Argument 'location' must be a character string.")
    }
    
    location_detected <- unlist(lapply(data, function(x, location) 
      ifelse(x$"location" == location, TRUE, FALSE), location = location))
    
    if (sum(location_detected) == 0) {
      stop("Wrong location spelling.")
    }
  }
  
  
  ## Find intersection ----
  
  if (!is.null(species) && !is.null(location)) {
    
    series_match <- which(species_detected & location_detected)
    
    if (length(series_match)) {
      usethis::ui_done(paste0("Found {usethis::ui_value(length(", 
                              "series_match))} series with ", 
                              "{usethis::ui_value(species)} and ", 
                              "{usethis::ui_value(location)}."))
    } else {
      
      usethis::ui_oops(paste0("No series found with ", 
                              "{usethis::ui_value(species)} and ", 
                              "{usethis::ui_value(location)}."))
      
      return(NULL)
    }
  }
  
  
  ## Otherwise ----
  
  if (!is.null(species) && is.null(location)) {
    
    series_match <- species_detected
    
    usethis::ui_done(paste0("Found {usethis::ui_value(",
                            "sum(species_detected))} ",
                            "series with {usethis::ui_value(species)}."))
  }
  
  if (is.null(species) && !is.null(location)) {
    
    series_match <- location_detected
    
    usethis::ui_done(paste0("Found {usethis::ui_value(",
                            "sum(location_detected))} ",
                            "series with {usethis::ui_value(location)}."))
  }
  
  data[series_match]
}



#' Extract original/converted count series data from a list
#'
#' @description
#' From the output of the function [format_data()] (or [filter_series()]), this
#' function extracts `data.frame` containing converted counts 
#' (`converted = TRUE`) or original counts (`converted = FALSE`) for one, 
#' several, or all count series.
#' 
#' The resulting `data.frame` has no particular use in `popbayes` but it can be
#' useful for users.
#'
#' @param data a named `list`. The output of [format_data()] or 
#'   [filter_series()].
#' 
#' @param converted a `logical`. If `TRUE` (default) extracts converted counts,
#'   otherwise returns original counts.
#'
#' @return A `data.frame`.
#' 
#' @export
#'
#' @examples
#' ## Load Garamba raw dataset ----
#' file_path <- system.file("extdata", "garamba_survey.csv", 
#'                          package = "popbayes")
#'                          
#' garamba <- read.csv(file = file_path)
#' 
#' ## Create temporary folder ----
#' temp_path <- tempdir()
#' 
#' ## Format dataset ----
#' garamba_formatted <- popbayes::format_data(
#'   data              = garamba, 
#'   path              = temp_path,
#'   field_method      = "field_method",
#'   pref_field_method = "pref_field_method",
#'   conversion_A2G    = "conversion_A2G",
#'   rmax              = "rmax")
#' 
#' ## Extract converted count data ----
#' converted_data <- popbayes::series_to_df(garamba_formatted, 
#'                                          converted = TRUE)
#' 
#' ## Extract original count data ----
#' original_data <- popbayes::series_to_df(garamba_formatted, 
#'                                         converted = FALSE)
#' 
#' dim(converted_data)
#' dim(original_data)
#' dim(garamba)

series_to_df <- function(data, converted = TRUE) {
  
  if (!is.list(data)) {
    stop("Argument 'data' must be an output of format_data().")
  }
  
  if (!("data_converted" %in% names(data[[1]]))) {
    stop("Argument 'data' must be an output of format_data().")
  }
  
  if (!is.logical(converted)) {
    stop("Argument 'converted' must be TRUE or FALSE.")
  }
  
  if (length(converted) != 1) {
    stop("Argument 'converted' must be TRUE or FALSE.")
  }
  
  element <- ifelse(converted, "data_converted", "data_original")
  
  data <- lapply(data, function(x) x[[element]])
  data <- do.call(rbind.data.frame, data)
  rownames(data) <- NULL
  
  data
}



#' Import a list of count series previously exported
#'
#' @description 
#' This function imports a list of count series data previously exported by 
#' [format_data()]. Users can import one, several, or all count series data.
#'
#' @param series a vector of `character` strings. One or several count series
#'   names to be imported. If `NULL` (default), all available count series 
#'   will be imported.
#'    
#' @param path a `character` string. The directory in which count series have
#'   been saved by the function [format_data()].
#'
#' @return An n-element `list` (where `n` is the number of count series). See
#'   [format_data()] for further information.
#' 
#' @export
#'
#' @examples
#' ## Load Garamba raw dataset ----
#' file_path <- system.file("extdata", "garamba_survey.csv", 
#'                          package = "popbayes")
#'                          
#' garamba <- read.csv(file = file_path)
#' 
#' ## Create temporary folder ----
#' temp_path <- tempdir()
#' 
#' ## Format dataset ----
#' garamba_formatted <- popbayes::format_data(
#'   data              = garamba, 
#'   path              = temp_path,
#'   field_method      = "field_method",
#'   pref_field_method = "pref_field_method",
#'   conversion_A2G    = "conversion_A2G",
#'   rmax              = "rmax")
#' 
#' ## Import all count series ----
#' count_series <- popbayes::read_series(path = temp_path)
#' 
#' ## Import one count series ----
#' a_bus <- popbayes::read_series(series = "garamba__alcelaphus_buselaphus",
#'                                path   = temp_path)

read_series <- function(series = NULL, path = ".") {
  
  
  if (!dir.exists(path)) {
    stop("The directory '", path, "' does not exist.")
  }
  
  filenames <- list.files(path, recursive = TRUE, pattern = "_data\\.RData")
  
  if (length(filenames) == 0) {
    stop("No count series can be found.")  
  }
  
  
  ## All available series names ----
  
  series_names <- strsplit(filenames, .Platform$"file.sep")
  series_names <- unlist(lapply(series_names, function(x) x[length(x)]))
  series_names <- gsub("_data\\.RData", "", series_names)

  
  if (!is.null(series)) {
    
    if (!is.character(series)) {
      stop("Argument 'series' must be a character (series name(s)).")
    }
    
    if (any(!(series %in% series_names))) {
      stop("Some count series cannot be found.")
    } 
    
    series_names <- series
  }

  data_series <- list()
  
  for (series in series_names) {
    
    data_series <- c(data_series, get(load(file.path(path, series, 
                                                     paste0(series, 
                                                            "_data.RData")))))
  }
  
  data_series
}



#' Retrieve the count series names
#'
#' @description This function retrieves the count series names generated by
#' the function [format_data()].
#'
#' @param path a `character` string. The directory in which count series have 
#'   been saved by the function [format_data()].
#'
#' @return A vector of count series names (`character` strings).
#' 
#' @export
#'
#' @examples
#' ## Load Garamba raw dataset ----
#' file_path <- system.file("extdata", "garamba_survey.csv", 
#'                          package = "popbayes")
#'                          
#' garamba <- read.csv(file = file_path)
#' 
#' ## Create temporary folder ----
#' temp_path <- tempdir()
#' 
#' ## Format dataset ----
#' garamba_formatted <- popbayes::format_data(
#'   data              = garamba, 
#'   path              = temp_path,
#'   field_method      = "field_method",
#'   pref_field_method = "pref_field_method",
#'   conversion_A2G    = "conversion_A2G",
#'   rmax              = "rmax")
#' 
#' ## Retrieve count series names ----
#' popbayes::list_series(path = temp_path)

list_series <- function(path = ".") {
  
  if (!dir.exists(path)) {
    stop("The directory '", path, "' does not exist.")
  }
  
  filenames <- list.files(path, recursive = TRUE, pattern = "_data\\.RData")
  
  if (length(filenames) == 0) {
    stop("No count series can be found.")  
  }
  
  
  ## All available series names ----
  
  series_names <- strsplit(filenames, .Platform$"file.sep")
  series_names <- unlist(lapply(series_names, function(x) x[length(x)]))
  series_names <- gsub("_data\\.RData", "", series_names)
  
  series_names
}
