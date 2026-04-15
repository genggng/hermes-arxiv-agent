# hermes-arxiv-agent

一个基于 Hermes 的 agent skill：每天自动从 arXiv 抓取论文，用 AI 生成中文摘要和作者单位，推送到飞书，并提供可部署到 GitHub Pages 的静态阅读网站。

## Hermes 对话安装

在 Hermes 对话中直接说：

```text
请从该地址 https://github.com/genggng/hermes-arxiv-agent/blob/main/AGENT_SKILL.md 安装 skill 并执行。
```

Hermes 会按 skill 自动完成：

- 克隆仓库
- 安装依赖
- 生成定时任务 prompt
- 创建定时任务

## 效果展示

### 飞书推送

![Feishu Push](images/feishu.png)

每天自动推送论文日报，包含标题、作者、单位、PDF 链接和中文摘要。

### Web 阅读网站

![Web Viewer](images/web.png)

本地部署后可在浏览器中按日期筛选、关键词检索，并查看论文摘要与收藏结果。

## 功能

- 每天按关键词监控 arXiv 新论文
- 自动下载 PDF，维护本地 Excel 记录
- 由 Hermes/LLM 补全作者单位和中文摘要
- 自动推送飞书日报
- 提供静态阅读网站，支持本地运行或 GitHub Pages 发布
- 以 Hermes skill 的形式完成部署和日常运行

## Hermes 安装

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
hermes
```

飞书配置：

```bash
hermes gateway setup
```

## 定时任务说明

定时任务相关逻辑以 [AGENT_SKILL.md](AGENT_SKILL.md) 和 [cronjob_prompt.txt](cronjob_prompt.txt) 为准。

不推荐手工复制 prompt 或手工改路径，正确做法是让 Hermes 在部署时自动完成。

如果你已经有可用的本地仓库，只想刷新 cron prompt 和定时任务，不要删仓库重装。

可以在 Hermes 对话里直接说：

```text
请使用当前仓库里的 UPDATE_CRON_SKILL.md，只更新 hermes-arxiv-agent 的定时任务。不要重新克隆仓库，不要重装依赖。请基于当前本地仓库运行 prepare_deploy.sh，读取最新 cronjob_prompt.generated.txt，并将现有 cron 更新到最新版本；如果不能直接编辑，就删除旧任务后重建一个新的同名任务。
```

这个流程会复用当前本地仓库和现有数据，只更新定时任务配置，适合在仓库逻辑变更后同步 cron。

## 关键词默认配置

默认监控方向是 LLM 量化相关论文。

如需修改监控方向，编辑 [search_keywords.txt](search_keywords.txt) 即可。

## 本地阅读网站

启动方式：

```bash
cd viewer
python3 run_viewer.py
```

浏览器访问：

```text
http://localhost:8765
```

支持：

- 日期筛选
- 关键词全文检索
- 收藏（浏览器本地保存）
- Abstract 展开查看

## GitHub Pages

仓库已支持用 GitHub Actions 发布 `viewer/` 目录到 GitHub Pages。

首次启用时需要在 GitHub 仓库设置中将 Pages 的 source 切到 `GitHub Actions`。

日常更新流程：

```bash
cd /path/to/hermes-arxiv-agent
python3 viewer/build_data.py
bash scripts/publish_viewer.sh
```

说明：

- `viewer/papers_data.json` 会随提交推送到 GitHub
- push 到 `main` 后会触发 `.github/workflows/pages.yml`
- 公开站点的收藏功能使用浏览器 `localStorage`，不再依赖服务器端 `favorites.json`
