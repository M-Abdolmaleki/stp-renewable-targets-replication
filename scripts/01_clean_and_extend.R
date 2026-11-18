# scripts/01_clean_and_extend.R
# Purpose: Load STP Zenodo v2 baseline dataset and append verified 2024 Final NECP policy extensions

library(tidyverse)

# 1. Load unmodified Zenodo v2 baseline
raw_df <- read_csv("data/raw/Renewable_target_ver2_eu countries_jan26.csv", show_col_types = FALSE) |>
  mutate(
    Miscellaneous = as.character(Miscellaneous),
    Dataset_wave  = "Baseline (Zenodo v2, 2001-2023)"
  )

# 2. Construct verified 2024 Final Updated NECP extension rows matching exact schema
# Sources: European Commission Assessment of Final Updated NECPs (2024/2025) & National Laws
extension_rows <- tribble(
  ~ISO_code, ~Country,  ~Year_decision, ~Year_first_decision, ~Year_target, ~Target_minimum, ~Target_maximum, ~Target_consistent, ~Unit,     ~Target_type,   ~Renewable_technology, ~Miscellaneous,                                      ~Source,
  # Germany: EEG 2023 (enacted 2022/effective 2023) & Final Updated NECP (2024)
  "DEU",     "Germany", 2023,           2004,                 2030,         NA,              80.0,            80.0,               "Percent", "Electricity",  "All technologies",    "EEG 2023 statutory target; confirmed in 2024 NECP", "https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en",
  "DEU",     "Germany", 2024,           2006,                 2030,         NA,              41.0,            41.0,               "Percent", "Final energy", "All technologies",    "Updated Final NECP 2021-2030 (submitted Aug 2024)", "https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en",
  # Spain: Final Updated PNIEC / NECP 2023-2030 (approved Sept 2024)
  "ESP",     "Spain",   2024,           2009,                 2030,         NA,              81.0,            81.0,               "Percent", "Electricity",  "All technologies",    "Final Updated NECP 2023-2030 (approved Sept 2024)",  "https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en",
  "ESP",     "Spain",   2024,           2009,                 2030,         NA,              48.0,            48.0,               "Percent", "Final energy", "All technologies",    "Final Updated NECP 2023-2030 (approved Sept 2024)",  "https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en",
  # France: Final Updated NECP (submitted July 2024)
  "FRA",     "France",  2024,           2009,                 2030,         NA,              41.3,            41.3,               "Percent", "Final energy", "All technologies",    "Final Updated NECP (submitted July 2024)",            "https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en",
  # Austria: Final Updated NECP (submitted Dec 2024)
  "AUT",     "Austria", 2024,           2001,                 2030,         NA,              100.0,           100.0,              "Percent", "Electricity",  "All technologies",    "100% national balance target confirmed in 2024 NECP","https://energy.ec.europa.eu/topics/energy-strategy/national-energy-and-climate-plans-necps_en"
) |>
  mutate(Dataset_wave = "Extension (2024 Final NECPs)")

# 3. Combine baseline + extension and save processed dataset
combined_df <- bind_rows(raw_df, extension_rows) |>
  arrange(ISO_code, Target_type, Year_target, Year_decision)

write_csv(combined_df, "data/processed/eu_renewable_targets_extended.csv")

cat("Saved processed dataset with", nrow(combined_df), "total rows (",
    nrow(raw_df), "baseline +", nrow(extension_rows), "new 2024 NECP observations).\n")A