# AGENTS.md — collaboration protocol

**Protocol v2.2** · upstream: [`republic-of-letters/protocol`](https://github.com/republic-of-letters/protocol).
This copy travels with the project; fixes and lessons learned flow back upstream as
PRs to the template, so every project inherits them.

This file is the contract. If you are an agent (Claude, Codex, or otherwise) acting
for any member, **read this once, then follow it exactly.** It is written
to be executed, not interpreted: where it gives a command, run that command.

Every agent acts on behalf of one human member. Anything outward-facing
(opening a PR, merging, closing, running code on the data server) must match what
your human asked for — the human gates are §13, and they are part of the design,
not etiquette.

Who the members are, who the Runner is, and what data this project runs on live in
[`PROJECT.md`](PROJECT.md) — the per-project constitution. This file is the invariant
protocol; that file is the project.

> **Not set up yet** — no GitHub account, no clone, no `gh`? Do
> [`ONBOARDING.md`](ONBOARDING.md) first; it gets you from zero to access, then sends
> you back here.

---

## 0. The loop, in six steps

```
PROPOSER                                   RUNNER
────────                                   ──────
1. scaffold a round folder
2. write ASK.md + runnable code
3. open a PR  ──────────────────────────▶  4. safety-review the code, then run it
                                              on the real data
                                           5. push RESULT.md + figures/tables to the PR
6. read the result, discuss in   ◀───────  (review summarises the finding)
   the PR thread; iterate or merge
```

(Step 0, once per research direction: a **topic** exists under `topics/` — see §12.
Rounds belong to topics; `decision` and `design` rounds skip steps 4–5.)

Everything below is the detail behind those six steps.

---

## 1. Mental model

- This repo is a **transport layer**, not a workspace. It carries *questions*,
  *code*, and *results*. It never carries the dataset.
- The dataset lives only on the **Runner's** machines. The **Proposer** writes code
  blind to where the data physically is, by reading from an environment variable
  `DATA_ROOT` and the canonical table names in [`data/SCHEMA.md`](data/SCHEMA.md).
- A **topic** is the unit of research direction — one candidate paper, living in
  `topics/T<NN>-<slug>/` (§12). A **round** is the atomic unit of work inside a
  topic. One round = one git branch = one folder under `exchange/` = one pull
  request. The three are named identically.
- When a round's PR merges, its folder on `main` becomes the permanent, citable
  record of that question and its answer.
- **One repo = one trust circle.** Everything committed here is visible to every
  member. There are no hidden corners: if a piece of work needs a different set of
  eyes, it lives in a different repo with its own membership — never in a private
  arrangement inside this one. The circle protects ideas as much as data: a hypothesis
  disclosed inside it is on the record as its proposer's, symmetric to the data
  boundary (§12).

## 2. Members and roles

The member list — who is on this project, which side they are on, and what they
bring — lives in [`PROJECT.md`](PROJECT.md). This section defines the roles.

Roles are per-round, not per-person: whoever opens a round is its **Proposer**, and
anyone — including the data side — can propose. What never moves is the data
boundary: only the **Runner** touches the dataset, and the Runner is always the data
side. `PROJECT.md` names the Runner. Each topic additionally names a **lead** in its
`TOPIC.md`: the human who owns that topic's direction and keeps its decision log
current.

**Mentored members.** A member may list a `mentor` in `PROJECT.md` (typical for a
student working under a faculty member). The mentor's approval is then part of the
merge gate (§13) for that member's rounds — request their review on every PR the
mentored member opens.

## 3. The unit of work: a round

A round is identified by `R<NNN>-<slug>`, e.g. `R001-fifty-cent-crossings`.

- `<NNN>` is a zero-padded sequence number, monotonically increasing across all
  rounds regardless of who opens them. The scaffold script computes the next one.
- `<slug>` is 2–5 lowercase words, hyphenated, describing the question.

That identifier is used **verbatim** in three places:

| Place        | Value                              |
| ------------ | ---------------------------------- |
| git branch   | `round/R001-fifty-cent-crossings`  |
| folder       | `exchange/R001-fifty-cent-crossings/` |
| PR title     | `R001: <one-line question>`        |

Numbering is **global across all topics** — `R<NNN>` never restarts. The scaffold
script checks remote branches too, so two proposers scaffolding concurrently won't
collide; if a collision slips through anyway, the later PR renumbers before merge.

A round also declares its **kind** in `ASK.md`:

| `kind`               | What it is                                                            | Runner action                          |
| -------------------- | --------------------------------------------------------------------- | -------------------------------------- |
| `analysis` (default) | Code to run against the data                                          | Safety gate §5.2 → run → `RESULT.md`   |
| `decision`           | A decision record: GO/NO-GO, pivot, post-mortem                       | None — review, discuss, merge archives it |
| `design`             | A spec or plan to agree on before code exists                         | None — discuss in the thread           |

Killing or pivoting a topic **requires** a `kind: decision` round that archives the
evidence and the reasoning. Topics never just go quiet — "everything we tried, and
why we stopped" is this repo's most valuable asset.

## 4. Proposer workflow

### 4.1 Scaffold

From a clean, up-to-date `main`:

```bash
git switch main && git pull
./scripts/new-round.sh "fifty cent crossings"   # prints the new round id, makes the branch + folder
```

This creates branch `round/R001-fifty-cent-crossings`, copies `exchange/_TEMPLATE/`
to `exchange/R001-fifty-cent-crossings/`, and stamps the id into `ASK.md`.

(Manual equivalent, if you prefer not to use the script: pick the next `R<NNN>`,
`git switch -c round/R<NNN>-<slug>`, `cp -r exchange/_TEMPLATE exchange/R<NNN>-<slug>`.)

### 4.2 Write the ask

Fill in `exchange/R<NNN>-<slug>/ASK.md`. See §6 for the exact contract. Be concrete
about **what question** and **what output would answer it**. State the hypothesis if
there is one; state the falsifier.

### 4.3 Write the code

Put runnable code in the round folder (start from the copied `run.py`). The code
contract is §7. The essentials:

- read inputs from `os.environ["DATA_ROOT"]` + canonical names from `data/SCHEMA.md`;
- write **only** into `./result/` (relative to the round folder);
- never hardcode an absolute path, never embed a secret, never assume a specific
  machine;
- respect the scale notes in `data/SCHEMA.md` — tables marked **never load whole**
  must be read lazily (column projection + predicate pushdown).

If parts of the analysis can't be settled without seeing the data, say so in
`ASK.md` and leave a clear `# RUNNER: please decide X` marker in the code. The
Runner can push fixups to the same branch.

### 4.4 Open the PR

```bash
git add exchange/R<NNN>-<slug>
git commit -m "R<NNN>: <one-line question>"
git push -u origin round/R<NNN>-<slug>
gh pr create --title "R<NNN>: <one-line question>" \
             --body-file exchange/R<NNN>-<slug>/ASK.md \
             --label "round:running" --label "topic:T<NN>" --reviewer <runner-handle>
```

(The Runner's handle is in `PROJECT.md`; CODEOWNERS auto-requests it anyway.)

Open it as a normal (not draft) PR when the code is ready to run. Use a **draft** PR
if you want early eyes on the plan before the code is final. If other members are
active on the same topic, add them as reviewers too — the Runner reviews for safety
and execution, topic members review for substance. If you have a mentor (§2), add
them as a reviewer on every PR you open.

## 5. Runner workflow

### 5.0 How you find out a round arrived

`.github/CODEOWNERS` makes every PR auto-request the Runner's review, so GitHub
notifies the Runner's human (email + web + mobile) the instant a round opens. The
agent has no inbox — it pulls. To see rounds waiting on you:

```bash
gh pr status                                    # PRs created / assigned / review-requested
gh pr list --search "review-requested:@me"      # just the rounds awaiting your run
gh api /notifications --jq '.[].subject.title'  # unread GitHub notifications
```

New rounds arrive labelled `round:running`.

**Queue discipline (one Runner, many proposers).** `analysis` rounds are served
FIFO. A proposer may add `priority:high` (sparingly — if everything is high,
nothing is); high beats normal, FIFO within each. On pickup, the Runner posts a
one-line ETA in the thread. If a round has waited ~48h with no Runner comment, the
proposer nudges with an `@`-mention — that is expected, not rude. `decision` and
`design` rounds skip the queue entirely; they need reading, not compute.

### 5.1 Pick up

```bash
gh pr checkout <PR-number>          # lands you on round/R<NNN>-<slug>
cd exchange/R<NNN>-<slug>
```

Read `ASK.md` and the code. If the question is underspecified or the code is wrong
in a way you can fix, fix it on the branch and note it — don't silently change the
intent. If intent is unclear, ask in the PR thread (`@` the round's proposer) and stop.

### 5.2 Safety gate — before any code touches the data server

This code is about to run on a machine that holds the real dataset. **Review it first.
Passing the automated scan is necessary but not sufficient — you still read the code.**

```bash
bash scripts/scan-round.sh exchange/R<NNN>-<slug>    # static triage for risky patterns
```

Then read the code against these red lines. If a round trips any of them, **do not run
it**: label the PR `blocked`, comment what you found (`@` the round's proposer), and stop.

*Code safety — reject / question if the code:*
- reaches the **network** (`requests`, `urllib`, `httpx`, `socket`, `paramiko`,
  `curl`/`wget`, SMTP/FTP) — analysis needs no egress, and egress means exfiltration;
- runs a **shell or subprocess** (`os.system`, `subprocess`, `os.popen`, `pty`), or
  **evaluates dynamic code** (`eval`, `exec`, `compile`, `__import__`, `pickle.load`,
  `marshal`, base64/hex blobs decoded then run);
- **deletes or mutates** anything (`shutil.rmtree`, `os.remove`, `open(..., "w")`)
  outside its own `./result/` — and never writes under `DATA_ROOT`;
- reads **secrets or other users' data** (`~/.ssh`, `.aws`, `id_rsa`, keychains,
  tokens, `/etc/…`, broad `os.environ` dumps beyond `DATA_ROOT`);
- tries to **install packages** or fetch remote code at run time;
- ignores scale rules (eagerly loads a table `SCHEMA.md` marks never-load-whole,
  unbounded memory) — operational, but it can take the box down, so treat it as a
  blocker until fixed.

*Content safety — reject / question if the analysis:*
- attempts to **de-anonymise** subjects, or to single out and expose
  individual-level records rather than study aggregate behaviour;
- would push **raw or near-raw data** back through the repo (see §8 — results are
  aggregates only);
- conflicts with the **data licence / usage terms** for the source it touches
  (the project's licence notes are in `PROJECT.md`).

When in doubt, ask in the PR thread before running — never "run it to see."

### 5.3 Run

Only after the gate passes. Run on the data server, not in the repo's synced folder,
in the dedicated analysis environment, as a normal (non-root) user, with `DATA_ROOT`
treated as read-only:

```bash
export DATA_ROOT=...           # the Runner's real data location (never committed)
python run.py                  # writes into ./result/ only
```

The Runner is the only party that sets a real `DATA_ROOT`. (The Runner keeps its own
private runbook for *which* server and *how* it is sandboxed; that never enters this
repo.)

### 5.4 Return the result

Write `result/RESULT.md` (contract in §9). Commit the write-up plus any
`result/figures/*` and `result/tables/*`. Then:

```bash
git add exchange/R<NNN>-<slug>/result
git commit -m "R<NNN>: result"
git push
gh pr review <PR-number> --comment --body "Ran it. Headline: <one sentence>. See result/RESULT.md."
```

Move the label from `round:running` to `round:answered`. Leave merging to the
agreement in the PR thread (see §10).

### 5.5 Runner load — the honest constraint

A project's throughput is bounded by Runner human-hours. §5.2 requires a person to
read every round before it touches data, and that read does not scale past what the
Runner's human can actually read. The bottleneck is not compute; it is the Runner's
attention. Plan around that, don't pretend it away.

- **The topic gate weighs the Runner budget.** A GO is also a commitment of Runner
  time (§13): deciding a topic is worth doing is deciding its rounds are worth the
  Runner's reading.
- **The Runner may batch runs and post ETAs.** Queue discipline (§5.0) stands; within
  it the Runner can group runs and tell proposers when to expect them.
- **The Runner may decline or defer a round on load grounds** — said in the thread. A
  deferred round is not a dead round; it keeps its place in the queue.
- **A project may name a deputy Runner** in `PROJECT.md` — must be data side (§2's
  boundary stands: only the data side touches the dataset), held to the same §5.2
  gate. The deputy shares the load; the boundary does not move.
- **An agent may pre-review** — run the scan, draft the review — to save the human
  time. But the human read remains the gate: pre-review compresses the reading, it
  never replaces it.

## 6. The `ASK.md` contract

YAML front-matter, then prose. Required fields are marked.

```yaml
---
round:    R001                       # required, matches the folder
title:    One-line question          # required
topic:    T01                        # required, the topic this round belongs to (§12)
kind:     analysis                   # analysis | decision | design (§3)
proposer: "@<your-handle>"           # required
created:  2026-01-01                 # required, ISO date
status:   open                       # open | running | answered | merged
data:     [table_a, table_b]         # canonical tables this round touches (see SCHEMA)
depends_on: []                       # other round ids this builds on, if any
---
```

Then these sections (keep them short and concrete):

- **Question** — the one thing this round answers.
- **Why** — one or two sentences of motivation. Enough for the Runner to sanity-check.
- **What to run** — the analysis in plain words: sample, grouping, estimator, output.
- **Expected output** — what artifact would answer the question (a number? a figure?
  a regression table?). This is also the Runner's definition of done.
- **Notes / open decisions** — anything the Runner must decide, edge cases, caveats.

## 7. The code contract

- **Entry point.** A round is runnable as `python run.py` from inside its folder, or
  the `ASK.md` names the exact command. If there are dependencies beyond the standard
  scientific stack, list them in a `requirements.txt` next to `run.py`.
- **Input.** Read the data location from `os.environ["DATA_ROOT"]`. Build table paths
  from the canonical names in `data/SCHEMA.md`, e.g.
  `Path(os.environ["DATA_ROOT"]) / "<table>.parquet"`.
- **Output.** Write **only** under `./result/` — `result/figures/`, `result/tables/`,
  and `result/RESULT.md`. Don't write anywhere else.
- **Scale.** Tables that `data/SCHEMA.md` marks **never load whole** must be read
  lazily — column projection plus a pushed-down predicate (polars `scan_parquet`,
  pyarrow filters, or DuckDB over the files). Everything else states its approximate
  size in `SCHEMA.md`; when unsure, scan lazily.
- **Determinism.** If you sample, use the project's seed convention from
  `data/SCHEMA.md` (default: `42`). Don't depend on wall-clock time or network access.
- **Hygiene.** No absolute paths, no credentials, no machine-specific assumptions, no
  writing outside `result/`.

## 8. The result contract

What comes back through the repo is **derived and aggregated**, never raw rows:

- ✅ figures (`.png`/`.pdf`/`.svg`), summary tables, regression output, coefficients,
  small grids, logs, a written interpretation.
- ❌ row-level data dumps, full parquet/CSV exports, anything that reconstructs the
  dataset, any single file over a few MB.

If a table is large because it has many cells, aggregate it or attach only the slice
that answers the question. CI will reject large files; that guard exists to make the
data boundary impossible to cross by accident.

**Who commits results.** Only the party who actually ran on real data commits
`result/` artifacts. A Proposer without data access may commit *synthetic smoke-test*
output only if it is unmistakably labelled — a `SYNTHETIC — smoke test, do not cite`
line at the top of the draft `RESULT.md` — and the Runner's real run **replaces** it
before merge. (Lesson from an early deployment: unlabelled smoke-test tables nearly
merged as real.)

## 9. The `RESULT.md` contract

YAML front-matter, then prose.

```yaml
---
round:   R001
runner:  "@<runner-handle>"
ran_on:  2026-01-01
status:  answered
sample:  <what was actually used, e.g. main panel, 15.9M rows>
runtime: ~3 min on <env>              # rough, for reproducibility planning
agent:   <model that drafted this, e.g. claude-fable-5>   # provenance, one line
---
```

Then:

- **Headline** — one sentence: the answer to the round's Question.
- **What was actually run** — note any deviation from `ASK.md` and why.
- **Figures / tables** — reference each artifact in `result/` with one line of reading.
- **Caveats** — sample construction, censoring, identification limits that bear on the
  reading. Be honest about what the result does *not* establish.
- **Next** — the obvious follow-up round(s), if any.

## 10. Discussion, iteration, and done

- **Discussion** happens in the **PR thread**, not in commits. `@`-mention whoever
  you need to pull in. Keep `ASK.md`/`RESULT.md` as the clean record; use comments
  for the back-and-forth.
- **Decisions outlive threads.** When a thread reaches a call that matters beyond the
  round — a topic pivot, a GO/NO-GO, an authorship agreement, a protocol change —
  promote it into the durable file (`TOPIC.md` decision log, `PROJECT.md`, or this
  file) in the same PR or a follow-up commit. Threads are not the record (§14).
- **Iteration** is just more commits on the same branch. A round can go
  ask → run → "try it split by category" → run again, all in one PR.
- **Status** is tracked two ways that must agree: the `status:` field in the
  front-matter, and the PR label (`round:running` / `round:answered` / `blocked`).
- **Done** = the PR is merged. A round is mergeable when:
  1. `RESULT.md` exists and answers the Question;
  2. both sides are content in the thread;
  3. CI is green (see §11).
  Merge with a squash unless the commit history is itself worth keeping. The merged
  folder on `main` is the archived round.

## 11. What CI enforces

`scripts/check.sh` runs on every PR (and you can run it locally before pushing). It
fails the PR if:

- any file exceeds the size limit (default 5 MB) — the raw-data tripwire;
- a tracked file has a data extension (`.parquet`, `.feather`, `.arrow`, `.duckdb`, …);
- a folder under `exchange/R*/` is missing its `ASK.md`;
- a folder under `topics/T*/` is missing its `TOPIC.md`.

Green CI is a precondition for merge. If `check.sh` blocks something legitimate,
that's a protocol question — raise it in an issue, don't bypass it.

## 12. Topics — the layer above rounds

Rounds answer questions; **topics** decide which questions are worth asking. A topic
is one candidate paper (or one coherent research programme), and it owns its rounds.

- Every topic is a folder `topics/T<NN>-<slug>/` holding one `TOPIC.md` — the topic's
  constitution and log: motivation and hypotheses (with the falsifier), members,
  authorship agreement, its rounds, and a **decision log**. Copy
  `topics/_TEMPLATE/` to start one.
- Topic ids are `T01`, `T02`, … Round front-matter carries `topic: T<NN>`; the PR
  carries the matching `topic:T<NN>` label (create it if it doesn't exist:
  `gh label create "topic:T<NN>" --color 1D76DB`).
- **Lifecycle** (the `status:` field): `proposing → probing → go | dead`, then
  `go → active → writing → merged-paper`; any state can move to `dead`. Every status
  change is a decision — it goes in the decision log with the round(s) that justify it.
- **Opening a topic is cheap, on purpose.** An issue describing the idea, or a small
  PR adding the `TOPIC.md` in `proposing`. Recording an idea costs one file.
- **The archive is a priority claim.** Opening a topic or a round timestamps who
  proposed which hypothesis — in the git history and the PR record. This is the idea
  side's structural protection, symmetric to the data boundary that protects the data
  side: what a member discloses inside the circle is on the record as theirs. Taking a
  hypothesis disclosed here outside the circle, or using it without credit, is a
  protocol violation of the same severity as moving raw data off the data server.
- **Provisional credit before the first analysis round.** An `analysis` round can run
  while a topic is still `probing` (§3) — a member reveals their hypothesis and code
  before any terms exist. So before a topic's **first** `analysis` round runs,
  `TOPIC.md` must carry a one-line **provisional credit line**: who originated the
  hypothesis, plus the default that the originator(s) and the Runner co-author any
  paper the topic produces, unless renegotiated at `go`. One line, not a contract —
  the full agreement still lands no later than `go` (next).
- **Authorship is agreed no later than `go`** — name order or the rule that decides
  it, written in `TOPIC.md`. Data/compute and off-repo licensed-data contributions
  count. Deferring this past `go` is a protocol violation, because it only gets
  harder later.
- **Killing a topic is a first-class outcome**, not an absence of activity: it takes
  a `kind: decision` round (§3) archiving the evidence, plus a `dead` entry in the
  decision log.

## 13. Human gates — where a person decides

Agents do the legwork; humans hold three gates. These gates **are the design** — an
agent that routes around one is malfunctioning, no matter how good its intentions.

| Gate | What passes through it | Who decides |
| ---- | ---------------------- | ----------- |
| **1. Topic gate** | GO / NO-GO, pivot, kill; authorship (provisional credit before the first analysis round, full agreement by `go`) | The topic's human members, recorded in `TOPIC.md`'s decision log |
| **2. Data gate**  | Any code executing against the real dataset | The Runner's human: safety gate §5.2 (scan **and** read), then a sandboxed run (non-root, `DATA_ROOT` read-only, no egress) |
| **3. Merge gate** | A round becoming part of the permanent record | The humans on both sides content in the thread; CI green (§10); the mentor too, for a mentored member's rounds (§2) |

Operating rules:

- An agent may scaffold, draft, analyse, search, and comment **autonomously**.
- An agent may **not** open a PR, merge, close, or run code against real data unless
  its human asked for that action. A standing instruction ("run all rounds that pass
  the gate") is a valid ask; guessing ("they'd probably want this merged") is not.
- When a gate call is ambiguous, the agent asks **its own human** — not the
  counterpart's agent, and not the PR thread on the human's behalf.
- **Emergency stop:** any human can put the `blocked` label on any PR at any time.
  Agents treat `blocked` as an unconditional halt on that round until a human
  removes it.

## 14. Agents — how AI participates

All members work through AI agents; the protocol assumes it. These rules keep
N humans × N agents coherent:

- **Identity.** An agent acts as its human's account and never acquires one of its
  own. Results, reviews, and decisions belong to the human; the agent is the pen.
  When context matters, say so in the thread ("acting on <human>'s instruction to…").
- **The durable layer is files, not threads.** A fresh agent session reconstructs
  context from committed files; assume it reads no PR threads older than the open
  ones. Anything that must survive — a decision, a caveat, a parameter choice —
  lives in `TOPIC.md`, `ASK.md`/`RESULT.md`, `PROJECT.md`, or this file.
- **Write for the next agent.** Load-bearing content is Markdown in the repo.
  Binary formats (`.docx`, `.pdf`, `.pptx`) are allowed as attachments, but the
  substance they carry must also exist as reviewable, diffable text.
- **Context loading order** for a fresh session:
  1. this file; 2. `PROJECT.md`; 3. the `TOPIC.md` of the topic at hand; 4. that
  topic's merged rounds (`ASK.md` + `RESULT.md`, newest backwards); 5. the open PR
  thread.
- **No invisible state.** If humans decided something out-of-band (a call, an
  email, a hallway conversation), the agent writes it into the right durable file
  *before* acting on it. Work that depends on unwritten agreements will be redone
  wrong by the next session.

## 15. External and contributed data

Rounds sometimes need data beyond the core dataset. Two cases, two rules — what
decides between them is **redistribution rights**, not where the data came from.

**Restricted-licence data (WRDS, FactSet, Compustat, …).** Data whose licence bars
sharing stays on the machine of whoever holds the licence — it never enters this
repo and never lands on the data server:

- Joins between the two worlds happen on **derived, aggregated tables** that already
  passed through a merged round (a crosswalk, an aggregated panel), executed on the
  licence-holder's side.
- The code and aggregated results of such off-repo work still come back through a
  round, so the archive stays complete even for work no Runner ever executed.

**Contributed data (a member's own dataset, shareable with the group).** A member
who has the right to share a dataset can have it ingested into the data server so
rounds can run against it directly:

1. **Declare it first** — in an issue or the round's `ASK.md`: what the data is,
   provenance, the licence / right-to-share statement, approximate size, and schema.
2. **Transfer off-repo** — the download link (Dropbox, S3, …) or credentials go to
   the Runner through a private channel (email, DM). **Never commit links or
   credentials to the repo** — a share link in git is a leaked capability, even in
   a private repo.
3. **Runner ingests** — pulling data onto the data server is a data-gate action
   (§13): the Runner's human approves, downloads, checksums, and sanity-passes it
   (row counts and schema match the declaration; no unexpected personal data).
4. **Register it** — the table gets a canonical name and an entry in
   `data/SCHEMA.md` (convention: `contrib_<owner>_<table>`, stored under
   `DATA_ROOT/contrib/<owner>/`), with provenance: who contributed it, when, and
   the licence note. From then on, rounds reference it like any core table.

The repo boundary is identical in both cases: raw data — core, restricted, or
contributed — never enters this repo; what comes back through PRs is aggregates.

## 16. Quick reference

```
constitution    PROJECT.md — members, Runner, data statement, visibility
new topic       cp -r topics/_TEMPLATE topics/T<NN>-<slug>   # edit TOPIC.md, PR it
new round       ./scripts/new-round.sh "short slug"          # then set topic:/kind: in ASK.md
local checks    bash scripts/check.sh
open round      gh pr create --title "R001: ..." --body-file exchange/R001-*/ASK.md
pick up round   gh pr checkout <n>
safety gate     bash scripts/scan-round.sh exchange/R001-*  # Runner, before running (§5.2)
run             DATA_ROOT=... python run.py        # Runner only, after the gate passes
return result   write result/RESULT.md; git push; gh pr review <n> --comment ...
identifiers     branch round/R001-slug · folder exchange/R001-slug · PR "R001: ..."
labels          round:running / round:answered / blocked · topic:T<NN> · priority:high
data names      see data/SCHEMA.md
boundaries      no raw data · results only · read $DATA_ROOT · write ./result/ only
ideas           archive = priority claim · provisional credit before a topic's first analysis round — §12
human gates     topic (GO/kill/authorship) · data (safety gate) · merge — §13
protocol        v2.2 · improvements → PR to republic-of-letters/protocol
```
