#!/bin/bash
# 检查模型是否已存在
if [ ! -f /app/weights/icon_detect/model.pt ]; then
    echo "模型不存在，正在从 HuggingFace 下载..."
    # 确保安装了 huggingface_hub
    pip install huggingface-hub

    # 强制设置国内源
    export HF_ENDPOINT=https://hf-mirror.com

    # 下载模型
    hf download microsoft/OmniParser-v2.0 --local-dir /app/weights

    # 重命名文件夹以符合你的代码逻辑
    if [ -d "/app/weights/icon_caption" ]; then
        mv /app/weights/icon_caption /app/weights/icon_caption_florence
    fi
    echo "模型下载完成。"
else
    echo "模型已存在，跳过下载。"
fi

# 执行原始的 CMD 命令
exec "$@"
