# hermes-arxiv-agent

一个基于 Hermes 的 agent skill：每天自动检索 arXiv 论文、补全中文摘要和作者单位，并将结果推送到飞书，同时提供本地或 GitHub Pages 的网页阅读入口。项目支持两种模式：

- 本地模式：默认模式。每天自动检索并处理论文，推送到你自己的飞书，并通过 `python3 viewer/run_viewer.py` 在本机启动网页阅读页
- GitHub Pages 模式：增强模式，包含本地模式的全部功能，并额外把静态网站自动发布到你自己 fork 的 GitHub Pages

## 安装目录

- [本地模式安装](#本地模式)
- [GitHub-Pages-模式安装](#github-pages-模式)

## 效果展示

### 飞书推送

![Feishu Push](images/feishu.png)

每天自动推送论文日报，包含标题、作者、单位、PDF 链接和中文摘要。

### Web 阅读网站

![Web Viewer](images/web.png)

支持按日期筛选、关键词检索、查看中文总结与 Abstract，以及本地收藏。

## 功能

- 每天按关键词监控 arXiv 新论文
- 自动下载 PDF，维护本地 Excel 记录
- 由 Hermes/LLM 补全作者单位和中文摘要
- 自动推送飞书日报
- 提供静态阅读网站，支持本地运行或 GitHub Pages 发布
- 可选通过 Hermes Tweet 做 X/Twitter 论文分享、关键词监听和互动跟进
- 以 Hermes skill 的形式完成部署和日常运行

## 分享与发布

- [小红书分享文案](XIAOHONGSHU_POST.md)
- [知乎文章模板](ZHIHU_ARTICLE.md)
- [X/Twitter 分享工作流](X_TWITTER_POST.md)

## 前提条件

使用本项目前，必须先安装 Hermes，并完成飞书配置。

### Hermes 安装

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
hermes
```

### 飞书配置

```bash
hermes gateway setup
```

## 本地模式

这是默认模式，适合希望每天自动检索并处理论文、推送飞书日报，同时在本机浏览网页阅读页的人。

这个模式下：

- 可以直接使用上游公开仓库
- 不要求 fork
- 不要求 GitHub 写权限
- 定时任务不会执行 `bash scripts/publish_viewer.sh`
- 网站依然可用，但通过本地 Python 脚本启动

### 安装方法

在 Hermes 对话中直接说这句固定安装话术：

```text
请从该地址 https://github.com/genggng/hermes-arxiv-agent/blob/main/AGENT_SKILL.md 安装 skill，并按本地模式部署。不要配置 GitHub Pages 发布。
```

Hermes 会自动完成：

- 克隆仓库
- 安装依赖
- 生成本地模式的 `cronjob_prompt.generated.txt`
- 创建定时任务

### 本地网站

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

### 更新定时任务

如果你已经有可用的本地仓库，只想刷新 cron prompt 和定时任务，不要删仓库重装。

可以在 Hermes 对话里直接说：

```text
请使用当前仓库里的 UPDATE_CRON_SKILL.md，只更新 hermes-arxiv-agent 的本地模式定时任务。不要重新克隆仓库，不要重装依赖。请基于当前本地仓库运行 prepare_deploy.sh，读取最新 cronjob_prompt.generated.txt，并将现有 cron 更新到最新版本；如果不能直接编辑，就删除旧任务后重建一个新的同名任务。
```

## GitHub Pages 模式

这是增强模式，包含本地模式的全部功能，并额外自动发布静态网站到你自己的 GitHub Pages。

这个模式下：

- 必须先 fork 项目
- `origin` 应该指向你自己的 fork，而不是上游仓库
- 推荐 `origin` 使用 SSH
- 定时任务会在补全完成后执行 `bash scripts/publish_viewer.sh`
- push 到你自己的 fork 后会触发 GitHub Actions 更新 GitHub Pages

### 安装方法

先 fork 本项目到你自己的 GitHub 账号，然后把下面占位符替换成你自己的 fork 地址，在 Hermes 对话中直接说这句固定安装话术：

```text
请从该地址 https://github.com/<your-github-id>/hermes-arxiv-agent/blob/main/AGENT_SKILL.md 安装 skill，并按 GitHub Pages publishing 模式部署。请使用当前 fork 仓库作为发布仓库，不要使用上游仓库作为推送目标。
```

Hermes 会自动完成：

- 克隆你自己 fork 的仓库
- 安装依赖
- 生成 GitHub Pages 模式的 `cronjob_prompt.generated.txt`
- 创建带发布步骤的定时任务

### GitHub 配置

建议让仓库 `origin` 使用 SSH：

```text
git@github.com:<your-github-id>/hermes-arxiv-agent.git
```

如果当前仓库 remote 还是 HTTPS，可以切换为：

```bash
git remote set-url origin git@github.com:<your-github-id>/hermes-arxiv-agent.git
```

首次启用时还需要在你自己 fork 的 GitHub 仓库设置中将 Pages 的 source 切到 `GitHub Actions`。

### 日常发布链路

GitHub Pages 模式下，定时任务会在 LLM 补全完成后自动发布。

如果你手动执行，流程是：

```bash
cd /path/to/hermes-arxiv-agent
DEPLOY_MODE=pages bash prepare_deploy.sh
python3 viewer/build_data.py
python3 monitor.py --sync-pending-state
bash scripts/publish_viewer.sh
```

说明：

- `viewer/papers_data.json` 会随提交推送到 GitHub
- push 到 `main` 后会触发 `.github/workflows/pages.yml`
- 推送目标应当是你自己 fork 的仓库
- 公开站点的收藏功能使用浏览器 `localStorage`，不再依赖服务器端 `favorites.json`

### 更新定时任务

如果你已经有可用的 GitHub Pages 模式仓库，只想刷新 cron prompt 和定时任务，不要删仓库重装。

可以在 Hermes 对话里直接说：

```text
请使用当前仓库里的 UPDATE_CRON_SKILL.md，只更新 hermes-arxiv-agent 的 GitHub Pages 模式定时任务。不要重新克隆仓库，不要重装依赖。请基于当前本地仓库以 DEPLOY_MODE=pages 运行 prepare_deploy.sh，读取最新 cronjob_prompt.generated.txt，并将现有 cron 更新到最新版本；如果不能直接编辑，就删除旧任务后重建一个新的同名任务。请保留当前 fork 仓库作为发布仓库，不要改回上游仓库。
```

## 定时任务说明

定时任务相关逻辑以 [AGENT_SKILL.md](AGENT_SKILL.md) 和 prompt 模板为准。

现在有两种不同的定时任务模板：

- 本地/飞书模式：使用 [cronjob_prompt.txt](cronjob_prompt.txt)
- GitHub Pages 模式：使用 [cronjob_prompt.pages.txt](cronjob_prompt.pages.txt)

`prepare_deploy.sh` 会根据部署模式生成对应的 `cronjob_prompt.generated.txt`，并在仓库根目录写入 `.deploy_mode` 记录当前模式。

## 关键词默认配置

默认监控方向是 LLM 量化相关论文。

如需修改监控方向，编辑 [search_keywords.txt](search_keywords.txt) 即可。
