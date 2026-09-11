Follow my shared personal agent rules under:

`~/.config/agent-rules/`

Read `AGENTS.md` there before planning or orchestrating delegated work.

Everything that is not specific to Claude Code lives there — planning behavior,
git conventions, tool resolution, executor selection, and configuration
scoping. Only Claude-specific mechanics belong in this file.

## Plan mode

- `planning.md` in the shared rules governs planning behavior. In Claude Code it
  has one concrete consequence: **do not call `ExitPlanMode`, or otherwise ask
  for approval to start, unless the user has asked to begin.** Finishing the
  plan file and saying so is the end of the turn.

## Remote 会话的文件可达性

我经常通过手机或浏览器 remote 连接会话，看不到本地编辑器。因此：

- **不要给 markdown 链接 + 本地绝对路径，手机上点不开**（2026-08-31 实测）。
  路径只有在本地终端里才可点，remote 客户端拿不到本地文件系统。
- 当回答涉及我可能需要查看的文件（新建或修改的计划、文档、报告、关键代码等），
  用 `SendUserFile` 直接把文件发过来，在对话里出文件卡片，手机上点开就能看内容。
- 只发本次回答真正相关的文件，不要把碰过的文件全发一遍；同一个文件没有实质变化就不要重复发。
- 提到文件位置时仍然写出仓库内的相对路径（例如 `plans/xxx.md`），当作说明用，
  但不要把它写成链接、也不要指望我去点它。

## 交流方式（2026-09-09，从结算影子比对那次对话总结）

那次对话我反复听不懂、反复纠错，原因不是内容难，是下面这些习惯。每一条都是当时实际发生过的。

- **文档和代码里的内部词，第一次出现必须解释。** 开关名、规则编号、函数名、
  「某某侧」这类词，是计划文件和代码里的，不是我脑子里的。第一次用时要用一句
  大白话说清「它是什么、在哪、管什么」（例如：「写入开关，就是环境变量
  `AUTO_SETTLEMENT_WRITE_ENABLED`，关着时收到识别结果什么都不做」）。我没用过
  的词，就当我不认识。整段全是编号和符号的回答我看不懂，等于没写。
- **先回答我问的那个问题。** 我问「是否通过」「能否上线」，第一句就要是
  是 / 否 / 不能确认，接着是理由。附带的风险、建议、别的发现放最后，压成几行。
  不要把一个问题答成一份报告，把我要的那句埋在中间。
- **结论之前先摆论据，而且论据要能被我查。** 说「从没跑通过」「全部是人工路径」
  这种话之前，把推出它的查询条件写出来。建立在 SQL 上的结论，要先核过字段语义：
  默认值是 0 还是 NULL、分组用的字段是不是所有路径都会写。核不了就说「我没查到
  证据」，不要说「从来没发生过」。
- **计划、契约里的一行待办不是事实。** 「X 侧已知会」不证明存在 X 团队；「条件未
  满足」不证明今天还没满足。先跟已有规则和当前数据对一遍再引用。被我纠正过一次
  的事，不要下一轮又当阻塞项提出来。
- **提方案之前先验证机制成立。** 提「加设备白名单」之前先确认消息是怎么路由的；
  提「可回滚」之前先确认回滚路径真的存在。提出来又收回，比不提更耗我的时间。
- **纠错一次说清。** 发现前面说错了，直接给正确事实和它改变了哪个结论。不要
  分好几轮一层层往回改，每轮改一点。
- **不要每条回复末尾都问「要我……吗」。** 授权范围内的事直接做；需要我定的，
  一次只给一个明确的选择，说清选每一边的代价。
