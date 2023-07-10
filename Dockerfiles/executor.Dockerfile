ARG CUDA_VERSION=118
ARG TORCH_VERSION=2.0.1
ARG EXECUTOR_MODULE=CausualLMExecutor

# devel needed for bitsandbytes requirement of libcudart.so, otherwise runtime sufficient
FROM mosaicml/pytorch:${TORCH_VERSION}_cu${CUDA_VERSION}-python3.10-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# copy will almost always invalid the cache
COPY . /workspace/
WORKDIR /workspace


RUN curl -sSL https://install.python-poetry.org | python3 -
RUN poetry config virtualenvs.create false
RUN poetry install --only main

RUN echo "\
jtype: CausualLMExecutor\n\
py_modules:\n\
  - open_gpt.serve.executors.base\n\
with:\n\
  device_map: balanced\n\
" > config.yml

ENTRYPOINT ["jina", "executor", "--uses", "config.yml", "--timeout-ready", "3600000"]