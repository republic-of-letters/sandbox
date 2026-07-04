SYNTHETIC — smoke test, do not cite

---
round:   R000
runner:  "@example-runner"
ran_on:  2026-07-04
status:  answered
sample:  synthetic demo frame, 6 groups × 2,000 rows (seed 42)
runtime: <1 s anywhere
agent:   claude-fable-5
---

## Headline

In the synthetic frame, mean outcome `y` ranges from −0.031 (charlie) to +0.100
(foxtrot), with near-identical dispersion (sd ≈ 0.15) across all six groups — by
construction, since the generator draws each group from a Gaussian with a random
mean and fixed sd.

## What was actually run

`python run.py` with no `DATA_ROOT` set — the synthetic path, exactly as `ASK.md`
specifies. No deviation. (This is the line where a real round would note "used F2
instead of F1 because …".)

## Figures / tables

- `tables/y_by_group.csv` — group, n, mean_y, sd_y; foxtrot highest (+0.100),
  charlie lowest (−0.031).
- `figures/y_by_group.png` — bar chart of mean y with a zero reference line.

## Caveats

Everything: the data is synthesised. This round demonstrates the format only — the
SYNTHETIC banner at the top of this file is the §8 labelling rule in action, and it
is what a Proposer's smoke-test draft must carry before the Runner's real run
replaces it.

## Next

None — a real round's "Next" names the follow-up question(s) this answer suggests.
