---
round:    R000
title:    Worked example — mean outcome by group
topic:    T00
kind:     analysis
proposer: "@example-proposer"
created:  2026-07-04
status:   answered
data:     []              # synthetic — a real round lists canonical tables here
depends_on: []
---

## Question

As a format demonstration: what is the mean outcome `y` by group, and how does its
dispersion compare across groups?

## Why

This round exists to show the round mechanism end to end — the `ASK.md` → `run.py` →
`result/` → `RESULT.md` loop — not to establish a finding. A real round would replace
this with a substantive question. It is also the template for the onboarding **drill**
(ONBOARDING.md Phase 3): every new member's agent reproduces this loop once.

## What to run

Group the synthetic frame by `group`, compute mean and standard deviation of `y`, and
plot mean `y` per group with a zero reference line.

## Expected output

- `result/tables/y_by_group.csv` — group, n, mean_y, sd_y
- `result/figures/y_by_group.png` — bar chart of mean y by group
- `result/RESULT.md` — one-paragraph reading

## Notes / open decisions

This example's `run.py` synthesises its own tiny frame (seed 42) so it runs anywhere
with no `DATA_ROOT` and no dependencies beyond the standard library (matplotlib for
the figure, optional). A real round reads actual tables — see the pattern in the
docstring and in `exchange/_TEMPLATE/run.py`.
