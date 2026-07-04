---
round:   R001
runner:  robot-runner
ran_on:  2026-07-04
status:  answered
sample:  trips.parquet, payment_type==1 & fare_amount>0 (240,242 card trips)
runtime: ~10 s on a GitHub Actions runner
---

## Headline

The median card tip runs about **23.7%–28.0%** of fare across the day — a modest
but real swing of ~4.2 points: lowest around 05:00 and highest around
19:00.

## What was actually run

`python run.py` on the 300k-row sample, card trips only (`payment_type == 1`), tip
percentage = 100 × tip / fare, clipped to [0, 100] (325 rows touched by the
clip), median per pickup hour.

## Figures / tables

- `tables/tip_by_hour.csv` — hour, n_trips, median_tip_pct (24 rows).
- `figures/tip_by_hour.png` — median tip % vs hour; the shape is the answer.

## Caveats

Cash tips are invisible (not recorded), so this is card behaviour only. It is a
300k-row sample of one month; medians are stable but the level is not the population
level. Association only — hour of day proxies for rider mix, trip type, and fatigue,
none of which are controlled here.

## Next

Split by trip distance or by pickup borough (join `zones`), or swap hour for day of
week. Any of those is a clean follow-up round.
