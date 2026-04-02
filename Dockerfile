FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 2. 设置 uv 和 pip 的全局国内源环境变量
ENV UV_INDEX_URL=https://pypi.mirrors.ustc.edu.cn/simple
# 如果你担心某些步骤会回退到原生 pip，也可以设置这个：
ENV PIP_INDEX_URL=https://pypi.mirrors.ustc.edu.cn/simple

# 3. 设置 Hugging Face 国内镜像（强烈建议，否则模型下载会非常慢）
ENV HF_ENDPOINT=https://hf-mirror.com

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common curl git libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3.12 python3.12-venv python3.12-dev \
    && ln -sf /usr/bin/python3.12 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.12 /usr/bin/python \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

WORKDIR /app

COPY pyproject.toml ./
RUN uv venv .venv --python python3.12 \
    && . .venv/bin/activate \
    && uv pip install -r pyproject.toml \
    && uv pip install huggingface-hub

COPY . .

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

# python -m omniparserserver must run from the module's directory
WORKDIR /app/omnitool/omniparserserver

# 添加启动脚本
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 设置入口点
ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["python", "-m", "omniparserserver", \
     "--som_model_path", "/app/weights/icon_detect/model.pt", \
     "--caption_model_name", "florence2", \
     "--caption_model_path", "/app/weights/icon_caption_florence", \
     "--device", "cuda", \
     "--host", "0.0.0.0", \
     "--port", "8000"]
