"""Round entry point. Runnable as `python run.py` from inside this folder.

Contract (see AGENTS.md §7):
  - read inputs from $DATA_ROOT + canonical names in data/SCHEMA.md
  - write outputs ONLY under ./result/
  - no absolute paths, no secrets, no machine-specific assumptions
  - tables marked "never load whole" in SCHEMA.md: scan lazily —
    project columns + push down a predicate
"""

import os
from pathlib import Path

DATA_ROOT = Path(os.environ["DATA_ROOT"])          # the Runner sets this
RESULT = Path(__file__).parent / "result"
(RESULT / "figures").mkdir(parents=True, exist_ok=True)
(RESULT / "tables").mkdir(parents=True, exist_ok=True)


def main() -> None:
    import polars as pl

    # --- load -------------------------------------------------------------
    # Tables SCHEMA.md says load directly:
    #   df = pl.read_parquet(DATA_ROOT / "table_a.parquet")
    #
    # Tables SCHEMA.md marks "never load whole" — scan lazily instead:
    #   lf = (pl.scan_parquet(DATA_ROOT / "table_b.parquet")
    #           .select(["key", "value", "ts"])
    #           .filter(pl.col("key") == some_key))
    #   df = lf.collect()

    # --- analyse ----------------------------------------------------------
    # TODO: this round's analysis.

    # --- write ------------------------------------------------------------
    # summary.write_csv(RESULT / "tables" / "summary.csv")
    raise NotImplementedError("replace with this round's analysis")


if __name__ == "__main__":
    main()
