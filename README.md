# Replication & 2024 Extension: EU-27 Renewable Energy Targets (STP Chair, FAU)

Reproducible **R** and **LaTeX** replication of the Chair of Sustainability Transition Policy (STP) open dataset on EU-27 renewable energy targets (*Data on renewable targets*, Version 2, Chaianong et al., 2026, Zenodo DOI: `10.5281/zenodo.18482541`), extended with verified 2023–2024 Final Updated National Energy and Climate Plan (NECP) observations.

## Repository Structure
```text
├── data/
│   ├── raw/          # Unmodified Zenodo v2 CSV baseline
│   └── processed/    # Extended dataset (eu_renewable_targets_extended.csv)
├── docs/             # STP codebook and D6.4.5 showcase report
├── scripts/
│   ├── 01_clean_and_extend.R     # Appends verified 2024 Final NECP rows
│   └── 02_generate_outputs.R     # Exports publication figures & booktabs LaTeX table
├── output/
│   ├── figures/      # High-res PNG and vector PDF plots
│   └── tables/       # Auto-generated LaTeX summary table
└── paper/
    ├── replication_note.tex      # LaTeX source
    └── replication_note.pdf      # Compiled 3-page research brief