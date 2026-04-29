# 我把论文监控项目做成了一个 Hermes Agent Skill

最近把自己用的 arXiv 论文监控工具整理成了一个真正可安装的 agent skill。

现在不是让别人下载代码、看 README、自己配环境、自己改路径、自己写定时任务了，而是可以直接在 Hermes 对话里说一句：

```text
请从该地址 https://github.com/genggng/hermes-arxiv-agent/blob/main/AGENT_SKILL.md 安装 skill 并执行。
```

剩下的事情交给 Hermes：

- 自动从 GitHub 拉代码
- 自动安装依赖
- 自动生成定时任务 prompt
- 自动创建定时任务
- 自动每天抓 arXiv 新论文
- 自动补全作者单位和中文摘要
- 自动推送到飞书

这个项目现在做的事情很直接：

- 每天抓取我关心方向的 arXiv 论文
- 自动下载 PDF
- 用 agent 读取 PDF 前几页提取作者单位
- 用 AI 生成中文摘要
- 更新到 Excel
- 同步生成本地静态网页，方便检索和回看

我这次最想验证的一件事不是“又做了一个工具”，而是：

以后很多个人项目，真的可以直接按“给 agent 安装和执行”来设计。

以前的软件交付方式一般是：

- 先教用户安装
- 再教用户配置
- 再教用户运行
- 最后教用户排错

现在如果项目一开始就按 agent skill 来设计，用户体验会变成：

- 在 Hermes 里说一句话
- agent 自己完成部署
- agent 自己创建定时任务
- agent 自己持续执行

我觉得这会是接下来很重要的一种软件形态：

- 不是“把功能写出来”就结束
- 而是“让 agent 能稳定安装、理解、运行、维护”

这个项目本身不大，但很适合验证这个方向。  
尤其是 Hermes 最近很火，我也顺手把整个使用链路尽量做成了 Hermes-first。

如果你平时也会追 arXiv、做信息监控、写自动化脚本，真的可以试试把项目直接做成 agent skill，而不是只做成一个脚本仓库。

仓库地址：

```text
https://github.com/genggng/hermes-arxiv-agent
```

一句话安装入口：

```text
https://github.com/genggng/hermes-arxiv-agent/blob/main/AGENT_SKILL.md
```

我自己的结论很简单：

未来很多项目，第一目标不一定是“给人用”，而是“先让 agent 能用”。
