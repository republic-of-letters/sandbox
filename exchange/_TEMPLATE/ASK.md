---
round:    R000            # the new-round script stamps this for you
title:    One-line question
topic:    T00             # the topic this round belongs to (see topics/)
kind:     analysis        # analysis | decision | design (AGENTS.md §3)
proposer: "@<your-handle>"
created:  2026-01-01
status:   open            # open | running | answered | merged
data:     []              # canonical tables touched, e.g. [table_a] (see data/SCHEMA.md)
depends_on: []            # other round ids this builds on, if any
---

## Question

<The one thing this round answers. One sentence.>

## Why

<One or two sentences of motivation — enough for the Runner to sanity-check intent.>

## What to run

<The analysis in plain words: sample, grouping, estimator, output. Reference
data/SCHEMA.md for table and column names.>

## Expected output

<What artifact answers the question — a number, a figure, a regression table? This is
also the Runner's definition of done.>

## Notes / open decisions

<Edge cases, anything the Runner must decide. Mark in-code decisions with
`# RUNNER: please decide X`.>
