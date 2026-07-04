> 本文件是 [`AGENTS.md`](AGENTS.md) 的中文译本。若两者有出入，以英文版 [`AGENTS.md`](AGENTS.md) 为准。

# AGENTS.md — 协作协议

**协议 v2.2** · 上游：[`republic-of-letters/protocol`](https://github.com/republic-of-letters/protocol)。
本副本随项目一同流转；修正与经验教训以 PR 的形式回流到上游模板，从而让每个项目都能继承它们。

本文件即契约。如果你是一个代表某成员行事的 agent（Claude、Codex 或其他），**请通读一遍，然后严格照做。** 它写来是用于执行、而非供人诠释的：凡是给出命令之处，就运行那条命令。

每个 agent 都代表某一位人类成员行事。任何对外的动作（开 PR、合并、关闭、在数据服务器上运行代码）都必须与你的人类所要求的一致——人类闸门（human gates）见 §13，它们是设计的一部分，不是客套。

本项目有哪些成员、执行方（Runner）是谁、跑的是什么数据，都写在 [`PROJECT.md`](PROJECT.md) 里——那是每个项目各自的章程。本文件是不变的协议；那份文件才是具体的项目。

> **还没配置好？** ——没有 GitHub 账号、没有克隆、没有 `gh`？请先做
> [`ONBOARDING.md`](ONBOARDING.md)；它带你从零走到有权限，然后再把你送回这里。

---

## 0. 整个循环，六步

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

（第 0 步，每个研究方向做一次：`topics/` 下存在一个**课题**（topic）——见 §12。轮次（round）从属于课题；`decision` 和 `design` 类型的轮次跳过第 4–5 步。）

下文全部是这六步背后的细节。

---

## 1. 心智模型

- 本仓库是一个**传输层**（transport layer），而非工作区。它承载的是*问题*、*代码*和*结果*。它从不承载数据集本身。
- 数据集只存在于**执行方（Runner）**的机器上。**提议方（Proposer）**在不知道数据物理位置的情况下编写代码，方式是从环境变量 `DATA_ROOT` 以及 [`data/SCHEMA.md`](data/SCHEMA.md) 中规范的表名去读取。
- **课题（topic）**是研究方向的单位——一篇候选论文，落在 `topics/T<NN>-<slug>/`（§12）。**轮次（round）**是课题内部工作的原子单位。一个 round = 一条 git 分支 = `exchange/` 下的一个文件夹 = 一个 pull request。三者命名完全一致。
- 当一个 round 的 PR 合并后，它在 `main` 上的文件夹就成为该问题及其答案的永久、可引用记录。
- **一个仓库 = 一个信任圈。** 在此提交的一切对每位成员都可见。这里没有隐蔽的角落：如果某项工作需要另一批人来看，它就该待在另一个有自己成员名单的仓库里——绝不能藏在本仓库内部的某个私下安排里。这个圈子既保护数据，也同等地保护想法：在圈内披露的一个假设，就以其提议者的名义记录在案，与数据边界对称（§12）。

## 2. 成员与角色

成员名单——本项目有谁、各自站在哪一侧、带来什么——写在 [`PROJECT.md`](PROJECT.md) 里。本节定义各个角色。

角色是按 round 划分的，而非按人划分：谁开了一个 round，谁就是它的**提议方（Proposer）**，而任何人——包括数据方（data side）——都可以提议。永不移动的是数据边界：只有**执行方（Runner）**才碰数据集，而 Runner 永远是数据方。`PROJECT.md` 指明谁是 Runner。此外，每个课题在其 `TOPIC.md` 中另外指定一位**牵头人（lead）**：负责该课题方向、并保持其决策日志（decision log）更新的那个人。

**受指导成员（Mentored members）。** 成员可在 `PROJECT.md` 中列出一位 `mentor`（学生在教师指导下工作时较为典型）。此后，该导师的批准便成为该成员各个 round 的合并闸门（§13）的一部分——在这位受指导成员开的每个 PR 上都请求导师评审。

## 3. 工作单位：round

一个 round 由 `R<NNN>-<slug>` 标识，例如 `R001-fifty-cent-crossings`。

- `<NNN>` 是零填充的序号，跨所有 round 单调递增，无论是谁开的。脚手架脚本会算出下一个。
- `<slug>` 是 2–5 个小写单词、以连字符相连，描述该问题。

该标识符在三处**原样**使用：

| 位置        | 取值                              |
| ------------ | ---------------------------------- |
| git branch   | `round/R001-fifty-cent-crossings`  |
| folder       | `exchange/R001-fifty-cent-crossings/` |
| PR title     | `R001: <one-line question>`        |

编号在**所有课题间是全局的**——`R<NNN>` 从不重新计数。脚手架脚本也会检查远程分支，所以两个提议方并发地做脚手架不会撞号；万一还是漏过去撞了号，较晚的那个 PR 在合并前重新编号。

一个 round 还要在 `ASK.md` 中声明它的**类型（kind）**：

| `kind`               | 它是什么                                                            | Runner 动作                          |
| -------------------- | --------------------------------------------------------------------- | -------------------------------------- |
| `analysis`（默认） | 要在数据上运行的代码                                          | 安全闸门 §5.2 → 运行 → `RESULT.md`   |
| `decision`           | 一份决策记录：GO/NO-GO、转向（pivot）、复盘（post-mortem）                       | 无——评审、讨论、合并即归档 |
| `design`             | 在代码存在之前需先达成一致的规格或计划                         | 无——在 thread 中讨论           |

杀掉或转向一个课题**必须**有一个 `kind: decision` 的 round 来归档证据和推理过程。课题绝不会就这么悄无声息地消失——"我们试过的一切，以及为何停手"是本仓库最有价值的资产。

## 4. 提议方（Proposer）工作流

### 4.1 脚手架

从干净、最新的 `main` 出发：

```bash
git switch main && git pull
./scripts/new-round.sh "fifty cent crossings"   # prints the new round id, makes the branch + folder
```

这会创建分支 `round/R001-fifty-cent-crossings`，把 `exchange/_TEMPLATE/` 复制到 `exchange/R001-fifty-cent-crossings/`，并把 id 打进 `ASK.md`。

（若你不想用脚本，手动等价做法：选下一个 `R<NNN>`，`git switch -c round/R<NNN>-<slug>`，`cp -r exchange/_TEMPLATE exchange/R<NNN>-<slug>`。）

### 4.2 写出问题（ask）

填写 `exchange/R<NNN>-<slug>/ASK.md`。确切的契约见 §6。要具体说明**问的是什么问题**以及**什么样的输出能回答它**。如果有假设就写出假设；写出证伪条件（falsifier）。

### 4.3 写代码

把可运行的代码放进 round 文件夹（从复制来的 `run.py` 起步）。代码契约见 §7。要点：

- 从 `os.environ["DATA_ROOT"]` 加上 `data/SCHEMA.md` 中的规范名读取输入；
- **只**写入 `./result/`（相对于 round 文件夹）；
- 绝不硬编码绝对路径，绝不内嵌密钥，绝不假设某台特定机器；
- 遵守 `data/SCHEMA.md` 里的规模提示——标注为 **never load whole** 的表必须惰性读取（列投影 + 谓词下推）。

如果分析中有些部分不看到数据就定不下来，就在 `ASK.md` 里说明，并在代码里留一个清晰的 `# RUNNER: please decide X` 标记。Runner 可以往同一分支推送修正（fixup）。

### 4.4 开 PR

```bash
git add exchange/R<NNN>-<slug>
git commit -m "R<NNN>: <one-line question>"
git push -u origin round/R<NNN>-<slug>
gh pr create --title "R<NNN>: <one-line question>" \
             --body-file exchange/R<NNN>-<slug>/ASK.md \
             --label "round:running" --label "topic:T<NN>" --reviewer <runner-handle>
```

（Runner 的 handle 在 `PROJECT.md` 里；CODEOWNERS 无论如何都会自动请求它。）

当代码已可运行时，开一个普通（非 draft）PR。如果你想在代码定稿前就让人先看看计划，用 **draft** PR。如果同一课题上还有别的活跃成员，也把他们加为 reviewer——Runner 评审安全性与执行，课题成员评审实质内容。如果你有导师（§2），在你开的每个 PR 上都把他加为 reviewer。

## 5. 执行方（Runner）工作流

### 5.0 你怎么知道来了一个 round

`.github/CODEOWNERS` 让每个 PR 都自动请求 Runner 评审，所以一个 round 一开，GitHub 就会即刻通知 Runner 的人类（邮件 + 网页 + 手机）。agent 没有收件箱——它是靠拉取（pull）。要看有哪些 round 在等你：

```bash
gh pr status                                    # PRs created / assigned / review-requested
gh pr list --search "review-requested:@me"      # just the rounds awaiting your run
gh api /notifications --jq '.[].subject.title'  # unread GitHub notifications
```

新来的 round 带 `round:running` 标签。

**队列纪律（一个 Runner，多个提议方）。** `analysis` 类的 round 按 FIFO 服务。提议方可以加 `priority:high`（省着用——如果什么都高优先级，那就等于都不是）；high 胜过 normal，各自内部再 FIFO。接手时，Runner 在 thread 里贴一行 ETA。如果某个 round 等了约 48 小时还没有 Runner 的评论，提议方用 `@` 提醒一下——这是意料之中的，不算失礼。`decision` 和 `design` 类的 round 完全跳过队列；它们需要的是阅读，不是算力。

### 5.1 接手

```bash
gh pr checkout <PR-number>          # lands you on round/R<NNN>-<slug>
cd exchange/R<NNN>-<slug>
```

读 `ASK.md` 和代码。如果问题描述不足，或代码有你能修的错误，就在分支上修好并记下来——不要悄悄改变原意。如果原意不清楚，就在 PR thread 里问（`@` 该 round 的提议方）并停下。

### 5.2 安全闸门——在任何代码碰到数据服务器之前

这段代码即将在一台保存着真实数据集的机器上运行。**先审查它。通过自动扫描是必要的，但并不充分——你仍然要读代码。**

```bash
bash scripts/scan-round.sh exchange/R<NNN>-<slug>    # static triage for risky patterns
```

然后对照这些红线读代码。如果某个 round 触了其中任何一条，**不要运行它**：给 PR 打 `blocked` 标签，评论你发现了什么（`@` 该 round 的提议方），然后停下。

*代码安全——如果代码有下列情形则拒绝 / 质询：*
- 触达**网络**（`requests`、`urllib`、`httpx`、`socket`、`paramiko`、`curl`/`wget`、SMTP/FTP）——分析不需要任何出站流量，而出站流量意味着数据外泄；
- 运行 **shell 或子进程**（`os.system`、`subprocess`、`os.popen`、`pty`），或**动态执行代码**（`eval`、`exec`、`compile`、`__import__`、`pickle.load`、`marshal`、先解码 base64/hex blob 再运行）；
- 在其自有的 `./result/` 之外**删除或改动**任何东西（`shutil.rmtree`、`os.remove`、`open(..., "w")`）——并且绝不写入 `DATA_ROOT` 之下；
- 读取**密钥或其他用户的数据**（`~/.ssh`、`.aws`、`id_rsa`、钥匙串、令牌、`/etc/…`、超出 `DATA_ROOT` 的大范围 `os.environ` 转储）；
- 试图在运行时**安装软件包**或拉取远程代码；
- 无视规模规则（急切地整表加载 `SCHEMA.md` 标注为 never-load-whole 的表、无界内存）——这是操作性问题，但它能把机器搞垮，所以在修好之前一律当作阻断项处理。

*内容安全——如果分析有下列情形则拒绝 / 质询：*
- 试图给对象**去匿名化（de-anonymise）**，或挑出并暴露个体层级的记录，而不是研究总体行为；
- 会把**原始或近乎原始的数据**经仓库推回来（见 §8——结果只能是聚合量）；
- 与它所触及来源的**数据许可 / 使用条款**相冲突（项目的许可说明在 `PROJECT.md` 里）。

拿不准时，运行前先在 PR thread 里问——绝不"跑一下看看"。

### 5.3 运行

只有在闸门通过之后才运行。在数据服务器上运行，而不是在仓库的同步文件夹里，在专用的分析环境中，以普通（非 root）用户身份，并把 `DATA_ROOT` 当作只读：

```bash
export DATA_ROOT=...           # the Runner's real data location (never committed)
python run.py                  # writes into ./result/ only
```

只有 Runner 这一方才设置真实的 `DATA_ROOT`。（Runner 自留一份私有的操作手册，记录用*哪台*服务器以及*如何*沙箱化；那绝不进入本仓库。）

### 5.4 交回结果

写 `result/RESULT.md`（契约见 §9）。提交这份说明，外加任何 `result/figures/*` 和 `result/tables/*`。然后：

```bash
git add exchange/R<NNN>-<slug>/result
git commit -m "R<NNN>: result"
git push
gh pr review <PR-number> --comment --body "Ran it. Headline: <one sentence>. See result/RESULT.md."
```

把标签从 `round:running` 移到 `round:answered`。是否合并，交给 PR thread 里的共识（见 §10）。

### 5.5 Runner 负荷——诚实的约束

一个项目的吞吐量受限于 Runner 的人工工时。§5.2 要求每个 round 在碰到数据前都有一个人来读，而这份阅读无法扩展到超过 Runner 的人类实际能读的量。瓶颈不是算力；是 Runner 的注意力。围绕它来规划，别假装它不存在。

- **课题闸门要权衡 Runner 预算。** 一个 GO 同时也是对 Runner 时间的承诺（§13）：判定一个课题值得做，就是判定它的各个 round 值得占用 Runner 的阅读。
- **Runner 可以批量运行并贴 ETA。** 队列纪律（§5.0）依然有效；在其框架内，Runner 可以把若干运行归组，并告诉提议方大约何时能得到结果。
- **Runner 可以以负荷为由拒绝或推迟一个 round**——在 thread 里说明。被推迟的 round 不是死掉的 round；它保留在队列中的位置。
- **项目可以指定一位副执行方（deputy Runner）**，写在 `PROJECT.md` 里——必须是数据方（§2 的边界依然成立：只有数据方才碰数据集），受同一条 §5.2 闸门约束。副执行方分担负荷；边界并不移动。
- **agent 可以做预审（pre-review）**——跑扫描、起草评审——以节省人类的时间。但人类的阅读仍然是那道闸门：预审是压缩阅读，绝不替代它。

## 6. `ASK.md` 契约

YAML front-matter，然后是正文散文。必填字段已标注。

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

然后是这些小节（保持简短、具体）：

- **Question（问题）** —— 这个 round 回答的那一件事。
- **Why（为何）** —— 一两句动机。够 Runner 做个合理性核对即可。
- **What to run（要运行什么）** —— 用大白话说清分析：样本、分组、估计量、输出。
- **Expected output（预期输出）** —— 什么样的产物能回答这个问题（一个数字？一张图？一张回归表？）。这也是 Runner 判定"完成"的定义。
- **Notes / open decisions（备注 / 待定决策）** —— 任何 Runner 必须决定的事、边缘情形、注意事项。

## 7. 代码契约

- **入口点。** 一个 round 在其文件夹内以 `python run.py` 即可运行，或者 `ASK.md` 指明确切的命令。如果有超出标准科学栈的依赖，就在 `run.py` 旁边的 `requirements.txt` 里列出。
- **输入。** 从 `os.environ["DATA_ROOT"]` 读取数据位置。用 `data/SCHEMA.md` 中的规范名构造表路径，例如 `Path(os.environ["DATA_ROOT"]) / "<table>.parquet"`。
- **输出。** **只**写入 `./result/` 之下——`result/figures/`、`result/tables/`、以及 `result/RESULT.md`。别往其他任何地方写。
- **规模。** `data/SCHEMA.md` 标注为 **never load whole** 的表必须惰性读取——列投影加上下推的谓词（polars `scan_parquet`、pyarrow filters，或对文件用 DuckDB）。其余的表在 `SCHEMA.md` 里都注明了大致大小；拿不准时就惰性扫描。
- **确定性。** 如果你要抽样，用 `data/SCHEMA.md` 里项目的种子约定（默认：`42`）。别依赖挂钟时间或网络访问。
- **卫生。** 无绝对路径、无凭据、无机器特定的假设、不往 `result/` 之外写。

## 8. 结果契约

经仓库回流的东西是**派生且聚合的**，绝不是原始行：

- ✅ 图（`.png`/`.pdf`/`.svg`）、汇总表、回归输出、系数、小型网格、日志、一份书面解读。
- ❌ 行级数据转储、完整的 parquet/CSV 导出、任何能重建数据集的东西、任何单个超过几 MB 的文件。

如果一张表因为格子多而很大，就把它聚合，或只附上回答问题的那一片。CI 会拒绝大文件；那道守卫的存在，是为了让数据边界不可能被意外越过。

**谁提交结果。** 只有真正在真实数据上跑过的那一方才提交 `result/` 产物。没有数据访问权的提议方只能提交*合成的冒烟测试（synthetic smoke-test）*输出，且必须明确无误地标注——在草稿 `RESULT.md` 顶部写一行 `SYNTHETIC — smoke test, do not cite`——并且在合并前由 Runner 的真实运行**替换**掉它。（一次早期部署的教训：没标注的冒烟测试表差点被当作真结果合并。）

## 9. `RESULT.md` 契约

YAML front-matter，然后是正文散文。

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

然后：

- **Headline（一句话结论）** —— 一句话：对这个 round 的 Question 的答案。
- **What was actually run（实际运行了什么）** —— 注明任何相对 `ASK.md` 的偏离及其原因。
- **Figures / tables（图 / 表）** —— 逐个引用 `result/` 里的每个产物，各配一行解读。
- **Caveats（注意事项）** —— 样本构造、截断、识别（identification）局限，凡是影响解读的都说。对结果*没能*确立的东西要诚实。
- **Next（下一步）** —— 显而易见的后续 round（如果有的话）。

## 10. 讨论、迭代与完成

- **讨论**发生在 **PR thread** 里，而非提交（commit）里。需要谁就 `@` 谁进来。把 `ASK.md`/`RESULT.md` 保持为干净的记录；来回讨论用评论。
- **决策比 thread 活得更久。** 当一条 thread 达成了一个超出该 round 意义的判断——课题转向、一个 GO/NO-GO、一份署名约定、一次协议变更——就在同一个 PR 或后续提交里把它提升进持久文件（`TOPIC.md` 决策日志、`PROJECT.md`，或本文件）。thread 不是记录（§14）。
- **迭代**无非就是在同一分支上多提交几次。一个 round 可以走 提问 → 运行 → "按类别拆开再试" → 再运行，全都在一个 PR 里。
- **状态（Status）**用两种必须一致的方式追踪：front-matter 里的 `status:` 字段，和 PR 标签（`round:running` / `round:answered` / `blocked`）。
- **完成** = PR 已合并。一个 round 可合并的条件是：
  1. `RESULT.md` 存在且回答了 Question；
  2. 双方在 thread 里都满意；
  3. CI 为绿（见 §11）。
  除非提交历史本身值得保留，否则用 squash 合并。`main` 上合并后的文件夹就是归档下来的 round。

## 11. CI 强制什么

`scripts/check.sh` 在每个 PR 上运行（你也可以在推送前本地运行）。它会在以下情况让 PR 失败：

- 任何文件超过大小上限（默认 5 MB）——原始数据的绊线；
- 某个被追踪的文件带有数据扩展名（`.parquet`、`.feather`、`.arrow`、`.duckdb`，…）；
- `exchange/R*/` 下的某个文件夹缺少它的 `ASK.md`；
- `topics/T*/` 下的某个文件夹缺少它的 `TOPIC.md`。

绿色 CI 是合并的前提。如果 `check.sh` 拦住了某个正当的东西，那是个协议问题——去开一个 issue 提出来，别绕过它。

## 12. 课题（Topics）——round 之上的一层

round 回答问题；**课题（topics）**决定哪些问题值得问。一个课题就是一篇候选论文（或一个自洽的研究计划），它拥有自己的一批 round。

- 每个课题是一个文件夹 `topics/T<NN>-<slug>/`，其中放一个 `TOPIC.md`——该课题的章程与日志：动机与假设（连同证伪条件）、成员、署名约定、它的各个 round，以及一份**决策日志（decision log）**。复制 `topics/_TEMPLATE/` 来开一个。
- 课题 id 是 `T01`、`T02`，… round 的 front-matter 带 `topic: T<NN>`；PR 带相应的 `topic:T<NN>` 标签（若不存在就创建它：`gh label create "topic:T<NN>" --color 1D76DB`）。
- **生命周期**（`status:` 字段）：`proposing → probing → go | dead`，然后 `go → active → writing → merged-paper`；任何状态都能转到 `dead`。每次状态改变都是一个决策——它连同支撑它的那个（些）round 一起进入决策日志。
- **开一个课题很便宜，这是有意为之。** 一个描述想法的 issue，或者一个在 `proposing` 状态添加 `TOPIC.md` 的小 PR。记录一个想法只花一个文件的成本。
- **归档就是一份优先权凭证（priority claim）。** 开一个课题或一个 round 会给"谁提出了哪个假设"打上时间戳——记在 git 历史和 PR 记录里。这是想法方（idea side）的结构性保护，与保护数据方的数据边界对称：成员在圈内披露的东西，就以他本人的名义记录在案。把在此披露的假设拿到圈外去，或者不署名地使用它，是一次协议违规，其严重程度与把原始数据挪出数据服务器相同。
- **在第一个分析 round 之前的临时署名（provisional credit）。** 一个 `analysis` round 可以在课题还处于 `probing` 时就运行（§3）——即成员在任何条款存在之前就亮出了假设和代码。所以在一个课题的**第一个** `analysis` round 运行之前，`TOPIC.md` 必须带一行**临时署名行（provisional credit line）**：谁原创了该假设，外加一条默认规则——除非在 `go` 时重新谈判，否则原创者与 Runner 共同署名该课题产出的任何论文。这是一行字，不是合同——完整约定最迟仍要在 `go` 时落定（见下一条）。
- **署名最迟在 `go` 时议定**——名次顺序，或决定名次的规则，写在 `TOPIC.md` 里。数据/算力贡献以及仓库外的许可数据贡献都算数。把这件事拖过 `go` 是一次协议违规，因为它只会越往后越难办。
- **杀掉一个课题是一种一等结局（first-class outcome）**，而非活动的缺席：它需要一个 `kind: decision` 的 round（§3）来归档证据，外加决策日志里的一条 `dead` 记录。

## 13. 人类闸门（Human gates）——由人来决定之处

agent 干跑腿活；人类把守三道闸门。这些闸门**就是设计本身**——绕过其中任何一道的 agent 都是在故障运行，无论它的用意有多好。

| 闸门 | 通过它的是什么 | 由谁决定 |
| ---- | ---------------------- | ----------- |
| **1. 课题闸门（Topic gate）** | GO / NO-GO、转向、杀掉；署名（第一个分析 round 之前的临时署名，`go` 时的完整约定） | 该课题的人类成员，记录在 `TOPIC.md` 的决策日志里 |
| **2. 数据闸门（Data gate）**  | 任何针对真实数据集执行的代码 | Runner 的人类：安全闸门 §5.2（扫描**并**阅读），然后一次沙箱化运行（非 root、`DATA_ROOT` 只读、无出站） |
| **3. 合并闸门（Merge gate）** | 一个 round 成为永久记录的一部分 | 双方的人类在 thread 里都满意；CI 为绿（§10）；对受指导成员的 round，还要有导师（§2） |

运作规则：

- agent 可以**自主地**做脚手架、起草、分析、检索和评论。
- agent **不得**开 PR、合并、关闭，或针对真实数据运行代码，除非它的人类要求了那个动作。一条常设指令（"运行所有通过闸门的 round"）是一个有效的要求；猜测（"他们大概会想合并这个"）不是。
- 当一个闸门判断有歧义时，agent 去问**它自己的人类**——不是对方的 agent，也不是代表人类去 PR thread 发言。
- **紧急停止（Emergency stop）：** 任何人类都可以在任何时候给任何 PR 打上 `blocked` 标签。agent 把 `blocked` 当作对该 round 的无条件停止，直到某个人类把它移除。

## 14. Agent——AI 如何参与

所有成员都通过 AI agent 工作；本协议以此为前提。这些规则让 N 个人类 × N 个 agent 保持自洽：

- **身份。** agent 以其人类的账号行事，永不获得属于自己的账号。结果、评审和决策归属于人类；agent 只是那支笔。当上下文重要时，在 thread 里说明（"acting on <human>'s instruction to…"）。
- **持久层是文件，不是 thread。** 一个全新的 agent 会话是从已提交的文件重建上下文的；假定它不读比当前打开的更旧的 PR thread。任何必须存活下来的东西——一个决策、一条注意事项、一个参数选择——都要落在 `TOPIC.md`、`ASK.md`/`RESULT.md`、`PROJECT.md`，或本文件里。
- **为下一个 agent 而写。** 承载信息的内容是仓库里的 Markdown。二进制格式（`.docx`、`.pdf`、`.pptx`）允许作为附件，但它们所承载的实质内容必须同时以可评审、可 diff 的文本形式存在。
- 全新会话的**上下文加载顺序**：
  1. 本文件；2. `PROJECT.md`；3. 手头这个课题的 `TOPIC.md`；4. 该课题已合并的各个 round（`ASK.md` + `RESULT.md`，从最新往回）；5. 当前打开的 PR thread。
- **没有隐形状态。** 如果人类在渠道之外定了什么事（一通电话、一封邮件、一次走廊里的交谈），agent 要在依据它行动*之前*把它写进正确的持久文件里。依赖于未落纸约定的工作，会被下一个会话重做错。

## 15. 外部数据与贡献数据

round 有时需要核心数据集之外的数据。两种情形，两条规则——在二者之间做判定的是**再分发权（redistribution rights）**，而非数据从何而来。

**受限许可数据（WRDS、FactSet、Compustat，…）。** 其许可禁止分享的数据，留在持有许可者的机器上——它绝不进入本仓库，也绝不落到数据服务器上：

- 两个世界之间的连接（join）在**派生的、聚合的表**上进行，而这些表已经经过某个已合并的 round（一张桥接表、一个聚合面板），并在持许可者的一侧执行。
- 此类仓库外工作的代码与聚合结果仍然经由一个 round 回流，这样即使某项工作没有任何 Runner 执行过，归档也保持完整。

**贡献数据（某成员自己的、可与本组分享的数据集）。** 有权分享某数据集的成员，可以把它导入数据服务器，好让 round 能直接针对它运行：

1. **先声明**——在一个 issue 或该 round 的 `ASK.md` 里：这是什么数据、来源出处、许可 / 分享权声明、大致大小，以及 schema。
2. **在仓库外传输**——下载链接（Dropbox、S3，…）或凭据通过私密渠道（邮件、私信）给到 Runner。**绝不把链接或凭据提交到仓库**——git 里的一个分享链接就是一份泄漏出去的能力，哪怕是在私有仓库里。
3. **Runner 导入**——把数据拉到数据服务器上是一次数据闸门动作（§13）：Runner 的人类批准、下载、做校验和，并做合理性检查（行数与 schema 与声明相符；没有意料之外的个人数据）。
4. **登记它**——该表得到一个规范名，以及 `data/SCHEMA.md` 里的一条记录（约定：`contrib_<owner>_<table>`，存于 `DATA_ROOT/contrib/<owner>/` 之下），带上来源信息：谁贡献的、何时、以及许可说明。从那以后，round 就像引用任何核心表一样引用它。

两种情形下仓库边界完全相同：原始数据——无论核心、受限还是贡献的——绝不进入本仓库；经 PR 回流的是聚合量。

## 16. 速查

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
