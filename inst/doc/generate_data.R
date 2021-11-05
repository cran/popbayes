## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)

## ----'rmax'-------------------------------------------------------------------
species_name <- c("Impala", "Tiang", "Blue wildebeest", "Roan", "Buffalo", 
                  "Eland", "Giraffe", "Elephant")

adult_female_body_mass <- c(55, 127, 230, 250, 400, 450, 702, 2873)

species <- data.frame(adult_female_body_mass, row.names = species_name)

species$rmax <- 1.375 * adult_female_body_mass ^ (-0.315)
species["Eland", "rmax"]    <- 0.150                 # Sinclair (1996)
species["Elephant", "rmax"] <- 0.07                  # Foley & Faust (2010)
species["Giraffe", "rmax"]  <- 0.125                 # Suraud et al. (2012)

species

## ----'conversion_fact'--------------------------------------------------------
categories <- c("Medium light and brown species (20-150kg)",
                "Large light and brown species (>150kg)",
                "Large dark (>150kg)", "Giraffe", "Elephant")

short_names        <- c("MLB", "LLB", "LD", "Giraffe", "Elephant")
conversion_facts   <- c(6.747, 2.302, 0.561, 3.011, 0.659)
pref_field_methods <- c("G", "G", "A", "A", "A")

category_info <- data.frame("category"          = categories,
                            "acronym"           = short_names,
                            "conversion_fact"   = conversion_facts, 
                            "pref_field_method" = pref_field_methods)
category_info

## -----------------------------------------------------------------------------
species$"category" <- c("MLB", "MLB", "LLB", "LLB", "LD", "LLB", "Giraffe", 
                        "Elephant")
species

