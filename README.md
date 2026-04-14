# arXiv LLM Quantization Paper Monitor

每天自动搜索 arXiv 上与 LLM 量化相关的新论文，下载 PDF、记录到 Excel、补全中文摘要与作者单位，并生成本地静态阅读站与飞书日报。

## 功能特性

- 每天从 arXiv API 按关键词检索最新 LLM 量化论文
- 自动去重，避免重复下载和重复写入 Excel
- 自动下载论文 PDF 到本地 `papers/` 目录
- 将论文元数据写入 `papers_record.xlsx`，便于长期积累和检索
- 输出 `new_papers.json` 给 hermes cronjob agent，用内置 LLM 补全作者单位和中文摘要
- 导出 `viewer/papers_data.json`，驱动本地静态论文阅读网站
- 提供本地静态站点，支持浏览、筛选、收藏和查看论文信息
- 支持飞书日报推送，适合做定时巡检和日报自动化

## 目录结构

```text
arxiv_llm_quantization_paper_monitor/
├── monitor.py                 # 主脚本：搜索 arXiv、下载 PDF、写 Excel、导出 viewer JSON
├── extract_affiliation.py     # 从 PDF 前几页提取作者单位（pdfplumber）
├── extract_pdf_info.py        # 额外的 PDF 信息提取脚本（辅助调试/实验）
├── search_keywords.txt        # arXiv 搜索关键词
├── crawled_ids.txt            # 已抓取 arXiv ID，作为去重缓存
├── new_papers.json            # 供 hermes cronjob agent 读取的中间结果
├── papers_record.xlsx         # 论文主记录表
├── papers_record.csv          # 本地导出/备份数据
├── papers/                    # 下载后的 PDF 文件目录
├── cron_add_command.txt       # hermes cronjob agent 的任务配置示例
└── viewer/
    ├── run_viewer.py          # 启动本地静态论文阅读站
    ├── build_data.py          # 从 Excel 生成 papers_data.json
    ├── papers_data.json       # 网站数据文件（建议保留版本管理）
    ├── favorites.json         # 本地收藏列表
    ├── index.html             # 前端页面
    ├── app.js                 # 前端逻辑
    ├── styles.css             # 前端样式
    └── README.md              # viewer 子模块说明
```

## 快速开始

### 1. Python 环境

项目当前使用 hermes agent 自带 Python：

```bash
/home/wsg/.hermes/hermes-agent/venv/bin/python3
```

建议全程使用这个解释器，避免依赖装到错误环境里。

### 2. 安装依赖

```bash
/home/wsg/.hermes/hermes-agent/venv/bin/python3 -m pip install openpyxl requests pdfplumber
```

### 3. 配置搜索关键词

编辑根目录下的 `search_keywords.txt`，填入 arXiv API 的 `search_query` 语法，例如：

```text
all:quantization+AND+all:large+AND+all:language+AND+all:model
```

如果文件为空，`monitor.py` 会回退到默认关键词。

### 4. 代理配置

如果本机访问 arXiv 或下载 PDF 不稳定，先配置代理：

```bash
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
```

项目脚本默认通过 `requests` 访问网络，若环境变量已设置，会自动沿用。

### 5. 运行主流程

```bash
/home/wsg/.hermes/hermes-agent/venv/bin/python3 /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/monitor.py
```

运行后会完成以下步骤：

1. 从 arXiv 检索最新论文
2. 根据 `crawled_ids.txt` 和 `papers_record.xlsx` 去重
3. 下载新论文 PDF 到 `papers/`
4. 将基础信息写入 `papers_record.xlsx`
5. 导出 `viewer/papers_data.json`
6. 输出 `new_papers.json`，等待 hermes cronjob agent 用 LLM 补全 `affiliations` 和 `summary_cn`

如果当天没有新论文，脚本也会生成“无新论文”的结果 JSON，方便后续自动推送。

## 静态网站使用说明

### 启动命令

在 `viewer/` 目录中启动：

```bash
cd /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/viewer
/home/wsg/.hermes/hermes-agent/venv/bin/python3 run_viewer.py
```

默认监听：

- 本机地址：`http://127.0.0.1:8765`
- 局域网地址：脚本启动时会自动打印

如果端口冲突，可改端口：

```bash
/home/wsg/.hermes/hermes-agent/venv/bin/python3 run_viewer.py --port 8766
```

### 网站功能

- 启动时自动执行 `build_data.py`，从 `papers_record.xlsx` 重建 `viewer/papers_data.json`
- 在浏览器中查看论文标题、作者、单位、摘要、分类和日期
- 通过本地静态页面快速筛选和阅读已抓取论文
- 支持收藏功能，收藏信息保存在 `viewer/favorites.json`
- 所有网站数据来自本地 Excel，不依赖额外后端服务

如果只想单独重建网站数据，也可以执行：

```bash
cd /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/viewer
/home/wsg/.hermes/hermes-agent/venv/bin/python3 build_data.py
```

## Cronjob 配置说明

### 定时任务

项目已经提供了 `cron_add_command.txt`，其中包含适配 hermes cronjob agent 的任务描述。当前示例计划为：

```cron
0 9 * * *
```

表示每天 `09:00` 执行一次。

建议 cron 流程如下：

1. 调用 `monitor.py` 抓取新论文并输出 `new_papers.json`
2. 若脚本输出 `No new papers` 或 `new_count=0`，直接生成“今日无新论文”消息
3. 若有新论文，调用 hermes cronjob agent 读取 `new_papers.json`
4. 用内置 LLM 完成两项补全：
   - 从 PDF 提取作者单位 `affiliations`
   - 基于 abstract 生成中文摘要 `summary_cn`
5. 用 `openpyxl` 回填 `papers_record.xlsx`
6. 生成飞书 Markdown 日报并推送

### 飞书推送

飞书消息建议包含以下信息：

- 标题：`LLM 量化论文日报`
- 日期
- 新论文数量
- 每篇论文的标题、arXiv ID、发布日期、作者、单位、PDF 链接、中文摘要
- 本地文件落盘说明，例如 PDF 目录和 Excel 记录路径

具体推送动作由 hermes cronjob agent 或你的飞书 webhook 流程负责，本仓库主要负责生成结构化输入和本地数据文件。

## 复现注意事项

- 优先使用固定 Python 路径：`/home/wsg/.hermes/hermes-agent/venv/bin/python3`
- 若网络受限，请在运行前设置代理：`http://127.0.0.1:7890`
- `papers/` 目录体积可能很大，默认不建议提交到 Git
- `papers_record.xlsx` 和 `new_papers.json` 都是运行过程中的本地数据文件，适合作为状态文件使用
- `viewer/papers_data.json` 是静态站点依赖的数据文件，建议保留版本管理，便于直接打开 viewer
- 第一次运行前请确认 `search_keywords.txt` 已正确配置，否则检索结果可能为空或偏离主题

## 常用命令

```bash
# 运行每日抓取
/home/wsg/.hermes/hermes-agent/venv/bin/python3 /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/monitor.py

# 提取单篇论文作者单位
/home/wsg/.hermes/hermes-agent/venv/bin/python3 /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/extract_affiliation.py 2604.07955

# 启动本地 viewer
cd /home/wsg/hermes_path/arxiv_llm_quantization_paper_monitor/viewer
/home/wsg/.hermes/hermes-agent/venv/bin/python3 run_viewer.py
```
