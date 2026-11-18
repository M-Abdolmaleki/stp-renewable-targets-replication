# scripts/02_generate_outputs.R
# Purpose: Replicate STP Chair descriptive figures and export LaTeX summary table

library(tidyverse)

# Ensure output directories exist
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)

df <- read_csv("data/processed/eu_renewable_targets_extended.csv", show_col_types = FALSE)

# Clean academic theme matching STP / European energy policy reports
theme_stp <- theme_minimal(base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold", size = 12, color = "#1B365D"),
    plot.subtitle    = element_text(size = 9.5, color = "#4A5568", margin = margin(b = 10)),
    plot.caption     = element_text(size = 8, color = "#718096", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom",
    legend.title     = element_blank(),
    strip.text       = element_text(face = "bold", size = 10)
  )

# ==============================================================================
# FIGURE 1: Temporal Escalation of 2030 Renewable Targets (Selected Major EU States)
# ==============================================================================
focus_countries <- c("DEU", "ESP", "FRA", "ITA", "POL", "AUT", "DNK", "SWE")

fig1_data <- df |>
  filter(
    Year_target == 2030,
    ISO_code %in% focus_countries,
    Target_type %in% c("Electricity", "Final energy")
  )

fig1 <- ggplot(fig1_data, aes(x = Year_decision, y = Target_consistent, color = Country)) +
  geom_line(linewidth = 0.8, alpha = 0.85) +
  geom_point(aes(shape = Dataset_wave), size = 2.6) +
  facet_wrap(~ Target_type, scales = "free_y") +
  scale_x_continuous(breaks = seq(2008, 2024, by = 4)) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 105)) +
  scale_shape_manual(values = c(16, 17)) +
  labs(
    title    = "Ratcheting Ambition: Evolution of 2030 Renewable Energy Targets (2009–2024)",
    subtitle = "Comparison of STP Zenodo v2 baseline (circles) and 2024 Final NECP extensions (triangles)",
    x        = "Year of Policy Decision",
    y        = "Harmonized Target Share (%)",
    caption  = "Source: Author replication & extension of Chaianong et al. (2026), Zenodo DOI: 10.5281/zenodo.18482541."
  ) +
  theme_stp

ggsave("output/figures/fig1_eu27_target_escalation.png", fig1, width = 8.5, height = 4.6, dpi = 300)
ggsave("output/figures/fig1_eu27_target_escalation.pdf", fig1, width = 8.5, height = 4.6)

# ==============================================================================
# FIGURE 2: Latest 2030 Renewable Targets Across EU Member States (Electricity vs. Final Energy)
# ==============================================================================
latest_2030 <- df |>
  filter(Year_target == 2030, Target_type %in% c("Electricity", "Final energy")) |>
  group_by(ISO_code, Country, Target_type) |>
  slice_max(order_by = Year_decision, n = 1, with_ties = FALSE) |>
  ungroup()

# Order countries by latest Final Energy target
country_order <- latest_2030 |>
  filter(Target_type == "Final energy") |>
  arrange(Target_consistent) |>
  pull(Country)

fig2_data <- latest_2030 |>
  filter(Country %in% country_order) |>
  mutate(Country = factor(Country, levels = country_order))

fig2 <- ggplot(fig2_data, aes(x = Target_consistent, y = Country, color = Target_type, shape = Dataset_wave)) +
  geom_line(aes(group = Country), color = "#CBD5E0", linewidth = 0.7) +
  geom_point(size = 2.8) +
  scale_x_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 105)) +
  scale_color_manual(values = c("Electricity" = "#1B365D", "Final energy" = "#D97706")) +
  scale_shape_manual(values = c(16, 17)) +
  labs(
    title    = "Latest 2030 EU-27 Renewable Targets: Electricity vs. Gross Final Energy",
    subtitle = "Most recent enacted target per country; triangles denote 2024 Final NECP updates added in extension",
    x        = "Harmonized 2030 Target Share (%)",
    y        = NULL,
    caption  = "Source: Author replication & extension of Chaianong et al. (2026), Zenodo DOI: 10.5281/zenodo.18482541."
  ) +
  theme_stp

ggsave("output/figures/fig2_sector_comparison_2030.png", fig2, width = 8.2, height = 6.5, dpi = 300)
ggsave("output/figures/fig2_sector_comparison_2030.pdf", fig2, width = 8.2, height = 6.5)

# ==============================================================================
# TABLE 1: Export LaTeX Summary Table (Booktabs Format)
# ==============================================================================
summary_tbl <- df |>
  filter(Year_target %in% c(2010, 2020, 2030, 2050)) |>
  group_by(Target_type, Year_target) |>
  summarise(
    N_Obs       = n(),
    N_Countries = n_distinct(ISO_code),
    Mean_Target = sprintf("%.1f\\%%", mean(Target_consistent, na.rm = TRUE)),
    Median_Tgt  = sprintf("%.1f\\%%", median(Target_consistent, na.rm = TRUE)),
    Min_Max     = sprintf("%.0f--%.0f\\%%", min(Target_consistent, na.rm = TRUE), max(Target_consistent, na.rm = TRUE)),
    .groups     = "drop"
  ) |>
  arrange(Target_type, Year_target)

tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary of Harmonized EU-27 Renewable Energy Targets (Baseline + 2024 Extension)}",
  "\\label{tab:summary_targets}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  "Sector Scope & Target Year & Obs. ($N$) & Countries & Mean & Median & Range \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(summary_tbl))) {
  r <- summary_tbl[i, ]
  tex_lines <- c(
    tex_lines,
    sprintf("%s & %d & %d & %d & %s & %s & %s \\\\",
            r$Target_type, r$Year_target, r$N_Obs, r$N_Countries,
            r$Mean_Target, r$Median_Tgt, r$Min_Max)
  )
}

tex_lines <- c(
  tex_lines,
  "\\bottomrule",
  "\\multicolumn{7}{l}{\\footnotesize \\textit{Notes:} Combines STP Zenodo v2 (217 obs.) with 6 verified 2024 Final NECP observations ($N=223$).} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tex_lines, "output/tables/table1_summary_stats.tex")
cat("Successfully exported Figure 1, Figure 2, and Table 1 to output/.\n")