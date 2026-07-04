# data/SCHEMA.md — data dictionary (sandbox)

This is the reference an agent needs to write code that **runs against the data**. It
describes the tables, their grain, key columns, and how to read them. It does not
contain the data. What the data *is* and under what terms is in
[`PROJECT.md`](../PROJECT.md)'s data statement.

> **This is the sandbox.** The dataset is a public, already-anonymised sample of NYC
> yellow-taxi trips — safe to publish, safe to make mistakes on. Everything here works
> exactly like a real Republic-of-Letters project, except the "data server" is a GitHub
> Actions runner and the "Runner" is a robot (see [`README.md`](../README.md)).

## The `DATA_ROOT` contract

Your code does not hardcode where the data is. It reads one environment variable and
joins it with the canonical table names below:

```python
import os
from pathlib import Path

DATA_ROOT = Path(os.environ["DATA_ROOT"])
trips = DATA_ROOT / "trips.parquet"
zones = DATA_ROOT / "zones.parquet"
```

The Runner (here, the CI robot) sets `DATA_ROOT` at run time. To get the files onto
your own machine so you can test locally, run `bash scripts/get-data.sh` — it downloads
them from the repo's data release into `./.data/` and prints the `DATA_ROOT` to export.

## Canonical tables

| Canonical name   | Grain (one row =)          | Approx. rows | Scale          | Notes |
| ---------------- | -------------------------- | ------------ | -------------- | ----- |
| `trips.parquet`  | one completed taxi trip    | 300,000      | loads directly | random sample (seed 42) of clean January-2024 yellow-taxi trips |
| `zones.parquet`  | one taxi zone (lookup)     | 265          | loads directly | maps a location id to borough + zone name |

Both tables are small enough to load whole with `pandas.read_parquet` or
`polars.read_parquet`. (In a real project some tables are hundreds of millions of rows
and marked **never load whole** — that is where the lazy-scan discipline in AGENTS.md §7
bites. The sandbox keeps it simple so you can focus on the loop.)

## Key columns

**`trips`** — one completed yellow-taxi trip. The sample is already cleaned: only trips
with a pickup inside January 2024, `fare_amount > 0`, `total_amount > 0`, and
`0 < trip_distance < 100` miles are kept.

| Column                  | Type      | Meaning |
| ----------------------- | --------- | ------- |
| `tpep_pickup_datetime`  | timestamp | trip start, local NYC time (America/New_York) |
| `tpep_dropoff_datetime` | timestamp | trip end, local NYC time |
| `passenger_count`       | int       | passengers reported by the driver (may be null) |
| `trip_distance`         | float     | miles, from the taximeter |
| `PULocationID`          | int       | pickup zone id -> join to `zones.LocationID` |
| `DOLocationID`          | int       | dropoff zone id -> join to `zones.LocationID` |
| `payment_type`          | int       | 1 = credit card, 2 = cash, 3 = no charge, 4 = dispute, ... |
| `fare_amount`           | float     | metered fare, US dollars (excludes tip, tolls, surcharges) |
| `tip_amount`            | float     | tip, US dollars. **Card tips are recorded; cash tips are not** -- so tip analysis conventionally restricts to `payment_type == 1` |
| `total_amount`          | float     | total charged to the rider, US dollars |

**`zones`** — the official taxi-zone lookup.

| Column        | Type   | Meaning |
| ------------- | ------ | ------- |
| `LocationID`  | int    | zone id, joins to `PULocationID` / `DOLocationID` |
| `Borough`     | string | Manhattan, Brooklyn, Queens, Bronx, Staten Island, EWR |
| `Zone`        | string | neighbourhood-level zone name |
| `service_zone`| string | Yellow Zone / Boro Zone / Airports / EWR |

**Sample selection:** the whole of `trips.parquet` is the analysis sample. For anything
about tipping, restrict to `payment_type == 1` (card) — see the `tip_amount` note above.

## Conventions

- Sampling seed: `42` unless a round's `ASK.md` says otherwise.
- Timestamps are local NYC wall-clock time (America/New_York), as published by the TLC.
- Money columns are US dollars.
- Join trips to zones on `PULocationID == LocationID` (pickup) or
  `DOLocationID == LocationID` (dropoff).

## Provenance

NYC Taxi & Limousine Commission (TLC) Trip Record Data — Yellow Taxi, January 2024,
plus the official Taxi Zone Lookup. Public domain, published by the TLC at
<https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page>. Already trip-level and
anonymous at source — there is no rider or driver identity to protect. The sandbox ships
a 300k-row random sample (from ~2.9M clean January trips) so the whole loop stays fast.
