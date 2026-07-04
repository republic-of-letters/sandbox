"""Worked example round — runnable anywhere.

Demonstrates the round contract (AGENTS.md §7) with no data dependency: it
synthesises a tiny (group, y) frame with seed 42 and needs nothing beyond the
standard library (+ matplotlib for the figure, which is optional).

A real round reads the actual data instead:

    DATA_ROOT = Path(os.environ["DATA_ROOT"])
    df = pl.read_parquet(DATA_ROOT / "<table>.parquet")     # names: data/SCHEMA.md

Either way, outputs go ONLY into ./result/.
"""

import csv
import math
import random
from pathlib import Path

RESULT = Path(__file__).parent / "result"
(RESULT / "figures").mkdir(parents=True, exist_ok=True)
(RESULT / "tables").mkdir(parents=True, exist_ok=True)

GROUPS = ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]


def load_demo():
    """Synthesise (group, y) pairs, deterministic (seed 42, the convention)."""
    rng = random.Random(42)
    rows = []
    for g in GROUPS:
        mu = rng.uniform(-0.05, 0.10)        # group-specific true mean
        for _ in range(2000):
            rows.append((g, rng.gauss(mu, 0.15)))
    return rows


def summarise(rows):
    """group -> (n, mean_y, sd_y)."""
    out = {}
    for g in GROUPS:
        ys = [y for grp, y in rows if grp == g]
        n = len(ys)
        mean = sum(ys) / n
        sd = math.sqrt(sum((y - mean) ** 2 for y in ys) / n) if n > 1 else 0.0
        out[g] = (n, mean, sd)
    return out


def main():
    rows = load_demo()
    summary = summarise(rows)

    # table
    with open(RESULT / "tables" / "y_by_group.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["group", "n", "mean_y", "sd_y"])
        for g, (n, mean, sd) in summary.items():
            w.writerow([g, n, f"{mean:.4f}", f"{sd:.4f}"])

    # figure (optional — skipped cleanly if matplotlib is absent)
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        groups = list(summary.keys())
        means = [summary[g][1] for g in groups]
        fig, ax = plt.subplots(figsize=(7, 4))
        ax.bar(groups, means, color="#4c72b0")
        ax.axhline(0, color="#444", linewidth=0.8)
        ax.set_ylabel("mean y")
        ax.set_title("Mean outcome by group  (R000 demo — SYNTHETIC)")
        ax.tick_params(axis="x", rotation=30)
        fig.tight_layout()
        fig.savefig(RESULT / "figures" / "y_by_group.png", dpi=130)
        print("wrote figure")
    except ImportError:
        print("matplotlib not available — skipped figure (table still written)")

    for g, (n, mean, sd) in summary.items():
        print(f"{g:9s} n={n:5d}  mean_y={mean:+.4f}  sd_y={sd:.4f}")


if __name__ == "__main__":
    main()
