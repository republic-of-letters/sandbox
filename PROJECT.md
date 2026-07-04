---
project:  sandbox
protocol: v2.2                  # pinned; upstream = republic-of-letters/protocol
created:  2026-07-04
visibility: open                # the repo itself is public — anyone may open a round
---

# PROJECT.md — the project constitution

`AGENTS.md` is the invariant protocol; this file is everything specific to *this*
project. An agent reads this second (AGENTS.md §14).

**This project is the sandbox.** Its purpose is not to produce a paper — it is to let
anyone, with their agent, walk the whole loop once (ask -> code -> safety scan -> run ->
result -> merge) on public data, in about thirty minutes. See [`README.md`](README.md).

## Direction

Learn the Republic-of-Letters loop by doing one complete round on a public dataset,
with a robot standing in for the Runner so no human has to be online for you to start.

## Members

| Handle       | Side      | Brings                                          | Mentor |
| ------------ | --------- | ----------------------------------------------- | ------ |
| `@alonegg`   | data side | the sandbox, the robot Runner, maintenance      | —      |
| *you*        | idea side | a question and the code to answer it            | —      |

- **Runner:** the **CI robot** (`.github/workflows/robot-runner.yml`) runs every round
  automatically. `@alonegg` maintains it and is the human backstop. Unlike a real
  project, the data is public, so the data gate (AGENTS.md §13) is enforced by an
  automated safety scan rather than a human read — this is the one place the sandbox
  deliberately differs from the protocol, and the README says so plainly.
- Anyone who opens a round is that round's **Proposer** (AGENTS.md §2). No invitation is
  needed: this is a `tier: open` project.
- **Deputy Runner (optional):** `—` (not needed; the robot scales).

## Data statement

| Field | Value |
| ----- | ----- |
| Core dataset(s) | NYC TLC Yellow-Taxi trips (Jan 2024, 300k-row sample) + Taxi Zone Lookup |
| Physical location | attached to this repo as a data **release**; the robot downloads it at run time |
| Licence / usage terms | Public domain (NYC TLC open data). Free to publish and redistribute. |
| Sensitive content | None — the source is already trip-level and anonymous; no rider or driver identity exists to de-anonymise |
| Restricted-licence side data | None |

Schema and read patterns: [`data/SCHEMA.md`](data/SCHEMA.md).

## Conventions

- Sampling seed: `42` unless a round's `ASK.md` says otherwise.
- Timestamps are local NYC time (America/New_York); money is US dollars.
- The main sample is the whole of `trips.parquet`; tip questions restrict to
  `payment_type == 1` (only card tips are recorded).

## Visibility & showcase

- **Tier:** `open` — the repo is public; open a topic or a round directly.
- **Approved for public display:** everything here is public by design.
