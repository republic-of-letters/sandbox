# sandbox — your first letter

The **Republic of Letters** is research by correspondence: you have a question, someone
else has the data it needs, and a *round* — one question, one branch, one pull request —
carries the question out and a result back, without the data ever changing hands. Humans
hold the decisions; agents do the legwork. ([The protocol.](https://github.com/republic-of-letters/protocol))

This repo is the **sandbox**: a place to walk that whole loop **once**, on a public
dataset, with a **robot** standing in for the data holder — so nobody has to be online
for you to start. About **thirty minutes**, most of it your agent's, from zero to a
result committed under your name.

> **What's real and what's a stand-in.** The loop, the files, the safety gate, the
> result contract — all real, identical to a live project. The two stand-ins: the
> "data server" is a GitHub Actions runner, and the **Runner is a robot** that runs your
> code automatically. That is safe here *only because the data is public* (NYC taxi
> trips, already anonymous). In a real project a **person** reads your code before it
> touches private data — that human data gate is the heart of the protocol, and the one
> thing the sandbox simulates rather than performs.

中文说明见 [`README.zh.md`](README.zh.md)。合作契约：[`AGENTS.md`](AGENTS.md) ·
[`AGENTS.zh.md`](AGENTS.zh.md)。

---

## The loop, once

```
YOU + your agent                             THE ROBOT (Runner)
────────────────                             ──────────────────
1. fork, open a round folder
2. write ASK.md (the question)
   + run.py (the code)
3. open a pull request  ───────────────────▶ 4. safety-scan the code
                                             5. run it on the public data
                                             6. commit result/ back, comment the answer
7. read the reply; merge your own PR  ◀──────  "Headline: …"
```

You write steps 1–3 and 7. The robot does 4–6, in a couple of minutes, the moment your
PR opens.

## What you need

- a **GitHub account** (free) and an **AI agent** (Claude Code, or any that can run `git`
  and `gh`). Hand your agent this file — it's written to be executed.
- **git** and the **GitHub CLI** (`gh`). That's it. You do *not* need the data on your
  machine unless you want to test locally (step 5 does that for you).

## Step by step

### 0. Fork and clone (2 min)

```bash
gh repo fork republic-of-letters/sandbox --clone --default-branch-only
cd sandbox
```

Working in **your fork** is the recommended path: you own it, so the robot has
permission to push the result straight back to your branch and comment. (You can also
open a PR to the upstream sandbox to have your round shown publicly — see "Two ways to
open the PR" below.)

> **One-time click:** GitHub disables Actions on new forks. Open your fork's **Actions**
> tab once and press *"I understand my workflows, go ahead and enable them"* — otherwise
> the robot never wakes up. (Or: `gh api -X PUT repos/:owner/sandbox/actions/permissions -F enabled=true`.)

### 1. Scaffold a round (30 sec)

```bash
./scripts/new-round.sh "does the tip vary by hour"
```

This makes a branch `round/R00N-does-the-tip-vary-by-hour`, a folder
`exchange/R00N-does-the-tip-vary-by-hour/`, and stamps its `ASK.md`. Pick your own
question — the topic [`T01-tipping`](topics/T01-tipping/TOPIC.md) is open and easy, or
invent one. (Numbers auto-increment; `R001` is already the worked example on `main`.)

### 2. Write the ask (5 min, your agent drafts it)

Open `exchange/R00N-*/ASK.md` and fill in: the **Question** (one sentence), a line of
**Why**, **What to run** (sample, grouping, output), and the **Expected output** (the
artifact that answers it). Set `topic: T01` and `kind: analysis`. The contract is
AGENTS.md §6. Keep it concrete — the robot's "definition of done" is your Expected
output.

### 3. Write the code (10 min, your agent writes it)

Edit `exchange/R00N-*/run.py`. The rules (AGENTS.md §7), all enforced automatically:

- read the data from `os.environ["DATA_ROOT"]` + the table names in
  [`data/SCHEMA.md`](data/SCHEMA.md) — never a hardcoded path;
- write **only** under `./result/` (`result/tables/`, `result/figures/`, `result/RESULT.md`);
- no network, no shell, no secrets — the safety scan rejects those (that *is* the data gate);
- for tips, restrict to `payment_type == 1` (only card tips are recorded — see SCHEMA).

The worked example [`exchange/R001-tip-by-hour/`](exchange/R001-tip-by-hour/) is a
complete, real round doing exactly this — read it first; it's the pattern.

**Test locally (optional but nice):**

```bash
bash scripts/get-data.sh                     # downloads the public data into ./.data/
export DATA_ROOT="$PWD/.data"
cd exchange/R00N-* && python run.py           # writes result/, same as the robot will
bash ../../scripts/scan-round.sh .            # the same safety scan the robot runs
cd ../..
```

### 4. Open the pull request (1 min)

```bash
git add exchange/R00N-*
git commit -m "R00N: does the card tip rate vary by hour?"
git push -u origin round/R00N-does-the-tip-vary-by-hour
gh pr create --fill                           # base = your fork's main, head = your branch
```

That's the letter, sent.

### 5. The robot replies (~2 min, automatic)

Watch the PR (`gh pr checks --watch`, or the Actions tab). The robot:

1. **safety-scans** your code — if it reaches the network, spawns a shell, or writes
   outside `result/`, it stops and tells you why (this is the automated data gate);
2. **downloads** the public dataset and runs `python run.py` with a 5-minute cap;
3. **checks** nothing landed outside `result/` and nothing is over 5 MB (the raw-data tripwire);
4. **commits** `result/` back to your branch and **comments the headline** on the PR.

If the scan or the run fails, it says so in the PR and the check goes red — fix, push,
and it runs again. Iterating is just more commits.

### 6. Merge — you've completed a round (30 sec)

When the reply answers your question, merge your own PR:

```bash
gh pr merge --squash
```

The merged folder on `main` is now the permanent, timestamped record of your question
and its answer — a full round, start to finish. **That timestamp is a priority claim**:
in a real project it is on-record proof that *you* proposed this, the idea side's
protection the way the data boundary protects the data side. You've sent your first
letter and it's in the archive.

## Two ways to open the PR

| | Within your fork *(recommended)* | To the upstream sandbox |
| --- | --- | --- |
| `base` of the PR | your fork's `main` | `republic-of-letters/sandbox` `main` |
| Robot pushes result + comments on the PR | **yes** — you hold the token | no — a maintainer approves the run first, and results land in the Actions run summary (upstream can't write into a fork's PR) |
| Good for | learning the loop, fastest feedback | having your round shown in the public repo |

Either way the robot runs your code; within your fork it's instant and needs no one else.

## What's in the box

```
AGENTS.md / AGENTS.zh.md   the protocol — the contract your agent follows (中/EN)
PROJECT.md                 this project's constitution: the robot Runner, the data statement
data/SCHEMA.md             the two tables: trips, zones — names, columns, how to read them
topics/T01-tipping/        an open topic to hang your first round on
exchange/R000-example-hello/  the format demo (synthetic, runs anywhere)
exchange/R001-tip-by-hour/    a complete REAL round on the taxi data — the pattern to copy
exchange/_TEMPLATE/        what new-round.sh copies
scripts/
  new-round.sh             scaffold the next round
  get-data.sh              download the public dataset for local testing
  scan-round.sh            the safety scan (the robot runs this; you can too)
  check.sh                 the data-boundary guard (size limit, no data files)
.github/workflows/
  robot-runner.yml         the robot Runner — scans, runs, replies
  validate-round.yml       the boundary guard in CI
```

## The rules, in three lines

1. **Raw data never enters the repo.** Results are aggregates — tables, figures, a
   written reading. CI enforces it (`scripts/check.sh`).
2. **The safety gate is real.** Code that reaches the network, spawns a shell, or writes
   outside `result/` does not run. In the sandbox a robot enforces it; in a real project
   a person does.
3. **The record is yours.** A merged round is timestamped proof of who asked what —
   ideas are protected the way data is.

Ready? Fork, and hand your agent step 0.
