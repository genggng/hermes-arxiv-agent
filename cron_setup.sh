#!/usr/bin/env bash
set -euo pipefail

# hermes-arxiv-agent 定时任务安装脚本
# 使用方法：bash cron_setup.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$SCRIPT_DIR}"

if [[ ! -f "$PROJECT_DIR/monitor.py" ]]; then
  echo "错误：找不到 monitor.py，请检查 PROJECT_DIR：$PROJECT_DIR" >&2
  exit 1
fi

python3 -m pip install openpyxl requests pdfplumber
PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT_DIR/prepare_deploy.sh"

echo "依赖已安装，定时任务提示词已生成：$PROJECT_DIR/cronjob_prompt.generated.txt"
