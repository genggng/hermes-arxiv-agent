# X/Twitter 分享工作流

这个文档说明如何把 `hermes-arxiv-agent` 的每日论文结果接到 Hermes Tweet，作为可选的 X/Twitter 分享和监听链路。

Hermes Tweet 是一个 Hermes Agent X/Twitter plugin，适合在 Hermes 里 scrape/search tweets、search Twitter/X、read tweet replies、look up users、monitor tweets、export followers，并在人工确认后 post tweets/replies、send DMs 或 automate X actions。

## 安装

先安装本项目的 Hermes skill，再按需安装 Hermes Tweet：

```bash
hermes plugins install Xquik-dev/hermes-tweet --enable
```

交互式安装会提示保存 `XQUIK_API_KEY`。如果是在 cron 或非交互环境里运行，请先在 Hermes 进程环境或 `~/.hermes/.env` 中配置该变量，然后重启相关 Hermes 会话。

## 建议流程

1. 让 `hermes-arxiv-agent` 继续按原流程抓取 arXiv、生成中文摘要、更新 Excel 和阅读网站。
2. 使用 Hermes Tweet 的 `tweet_read` 搜索 Twitter/X 里的论文标题、作者账号、模型名和关键词。
3. 读取相关 tweet replies，判断论文讨论热度和常见问题。
4. 让 Hermes 基于当天论文结果生成 X/Twitter 线程草稿。
5. 人工确认文案、账号、链接和发布时间。
6. 只有确认后才启用 `tweet_action` 发送 tweets/replies 或 DMs。

## 提示词示例

```text
请读取今天的 papers_record.xlsx 和 viewer/papers_data.json，挑选 3 篇最值得分享的论文，写成中文 X/Twitter 线程草稿。先用 Hermes Tweet search Twitter/X 检查相关关键词、论文标题和作者账号，不要发帖。
```

```text
请用 Hermes Tweet read tweet replies，查看这些论文或作者账号下的讨论点，并把常见问题整理成 5 条回复草稿。只生成草稿，不要发送。
```

```text
我确认发送这条线程。请用 Hermes Tweet post tweets，并把每条 tweet 的链接记录到今天的运行摘要中。
```

## 安全边界

- 无人值守 cron 默认只做 arXiv 监控、摘要生成、飞书推送和 X/Twitter 读取。
- 不要把 API key、账号密码或 cookie 写进提示词、README、issue 或公开日志。
- `tweet_action` 只用于已经确认的 tweets/replies、DMs、关注、监控配置和其他账号动作。
- 如果要自动 monitor tweets 或 export followers，先明确关键词、账号范围、频率和保存位置。
- 发布内容优先链接到论文、PDF、项目阅读网站或当天的 GitHub Pages 页面。
