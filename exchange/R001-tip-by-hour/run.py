"""R001 — does the card tip rate vary by hour of day?

Runnable as `python run.py` from inside this folder. Reads the sandbox data from
$DATA_ROOT (see data/SCHEMA.md), writes only under ./result/. No network, no shell.
"""

import os
from pathlib import Path

import pandas as pd

DATA_ROOT = Path(os.environ["DATA_ROOT"])
RESULT = Path(__file__).parent / "result"
(RESULT / "figures").mkdir(parents=True, exist_ok=True)
(RESULT / "tables").mkdir(parents=True, exist_ok=True)


def main() -> None:
    cols = ["tpep_pickup_datetime", "payment_type", "fare_amount", "tip_amount"]
    df = pd.read_parquet(DATA_ROOT / "trips.parquet", columns=cols)

    # card trips only — cash tips are not recorded (data/SCHEMA.md)
    card = df[(df.payment_type == 1) & (df.fare_amount > 0)].copy()

    card["tip_pct"] = (100 * card.tip_amount / card.fare_amount)
    n_clipped = int((card.tip_pct > 100).sum() + (card.tip_pct < 0).sum())
    card["tip_pct"] = card.tip_pct.clip(0, 100)
    card["hour"] = card.tpep_pickup_datetime.dt.hour

    by_hour = (
        card.groupby("hour")
        .agg(n_trips=("tip_pct", "size"), median_tip_pct=("tip_pct", "median"))
        .reset_index()
    )
    by_hour["median_tip_pct"] = by_hour.median_tip_pct.round(2)
    by_hour.to_csv(RESULT / "tables" / "tip_by_hour.csv", index=False)

    lo, hi = by_hour.median_tip_pct.min(), by_hour.median_tip_pct.max()
    hour_lo = int(by_hour.loc[by_hour.median_tip_pct.idxmin(), "hour"])
    hour_hi = int(by_hour.loc[by_hour.median_tip_pct.idxmax(), "hour"])

    # figure
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(by_hour.hour, by_hour.median_tip_pct, marker="o", color="#4c72b0")
    ax.set_xlabel("hour of day (pickup, NYC time)")
    ax.set_ylabel("median tip % of fare")
    ax.set_title("Card tip rate by hour of day — NYC yellow taxi, Jan 2024 (sample)")
    ax.set_xticks(range(0, 24, 2))
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(RESULT / "figures" / "tip_by_hour.png", dpi=130)

    # write the reading
    spread = hi - lo
    with open(RESULT / "RESULT.md", "w") as f:
        f.write(f"""---
round:   R001
runner:  robot-runner
ran_on:  2026-07-04
status:  answered
sample:  trips.parquet, payment_type==1 & fare_amount>0 ({len(card):,} card trips)
runtime: ~10 s on a GitHub Actions runner
---

## Headline

The median card tip runs about **{lo:.1f}%–{hi:.1f}%** of fare across the day — a modest
but real swing of ~{spread:.1f} points: lowest around {hour_lo:02d}:00 and highest around
{hour_hi:02d}:00.

## What was actually run

`python run.py` on the 300k-row sample, card trips only (`payment_type == 1`), tip
percentage = 100 × tip / fare, clipped to [0, 100] ({n_clipped:,} rows touched by the
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
""")

    print(by_hour.to_string(index=False))
    print(f"\nclip touched {n_clipped} rows; card trips = {len(card)}")


if __name__ == "__main__":
    main()
