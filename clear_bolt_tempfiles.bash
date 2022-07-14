#!/usr/bin/env bash
set -euo pipefail

# https://stackoverflow.com/questions/59895
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
sudo rm -rf .plan_cache.json .task_cache.json bolt-debug.log report.txt Puppetfile .modules .resource_types pip_installed
