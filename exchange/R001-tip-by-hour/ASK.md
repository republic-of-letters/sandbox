---
round:    R001
title:    Does the card tip rate vary by hour of day?
topic:    T01
kind:     analysis
proposer: "@alonegg"
created:  2026-07-04
status:   open
data:     [trips]
depends_on: []
---

## Question

Among credit-card taxi trips, does the median tip (as a percentage of the metered
fare) vary by the hour of day the trip started?

## Why

The first real round on the sandbox data, and the pattern newcomers copy. Tipping is a
familiar behaviour with an obvious time dimension — late-night vs commute vs
mid-afternoon — so the answer is easy to sanity-check and the code is short.

## What to run

- Sample: `trips.parquet`, restricted to `payment_type == 1` (only card tips are
  recorded — see `data/SCHEMA.md`).
- Define `tip_pct = 100 * tip_amount / fare_amount`. Drop non-positive fares and, to
  keep a stray outlier from moving a mean, clip `tip_pct` to [0, 100].
- Group by `hour = tpep_pickup_datetime.hour` (0–23). Report the count and the
  **median** `tip_pct` per hour (median, not mean, because tip percentages are skewed).
- Plot median `tip_pct` against hour.

## Expected output

- `result/tables/tip_by_hour.csv` — hour, n_trips, median_tip_pct
- `result/figures/tip_by_hour.png` — median tip % by hour of day
- `result/RESULT.md` — one paragraph: is there a pattern, and roughly how big?

## Notes / open decisions

Median over mean is deliberate (skew). The [0, 100] clip is a guard against divide-by
tiny fares; note in RESULT.md how many rows it touched.
