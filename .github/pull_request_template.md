<!--
A PR here is one collaboration round. Title it `R<NNN>: <one-line question>`.
The body can stay as the round's ASK.md — keep the checklist below.
For kind: decision / design rounds, the Runner checklist does not apply.
-->

**Round:** R<NNN>-<slug>
**Topic:** T<NN> (label the PR `topic:T<NN>`)
**Kind:** analysis | decision | design

### Proposer checklist
- [ ] `ASK.md` filled in (Question, Why, What to run, Expected output; `topic:` + `kind:` set)
- [ ] `run.py` reads `$DATA_ROOT`, writes only to `./result/`, no hardcoded paths/secrets *(analysis only)*
- [ ] any committed result artifacts are labelled `SYNTHETIC — smoke test, do not cite`
- [ ] `bash scripts/check.sh` passes locally
- [ ] my human asked for this PR to be opened (AGENTS.md §13)

### Runner checklist (analysis rounds, filled when results come back)
- [ ] safety gate passed: `scan-round.sh` clean **and** code read by a human-supervised session (§5.2)
- [ ] ran on real data, sandboxed (non-root, read-only `DATA_ROOT`, no egress); `result/RESULT.md` answers the Question
- [ ] only aggregates/figures/tables committed (no raw data); synthetic placeholders replaced
- [ ] label set to `round:answered`

### Merge gate (both sides, before merge — AGENTS.md §13)
- [ ] humans on both sides are content in the thread
- [ ] decisions that outlive this round promoted to `TOPIC.md` / durable files
