FROM tensorflow/tensorflow:2.13.0-gpu as builder

ENV LC_ALL C.UTF-8
ENV TZ=Europe/Berlin

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  NUMBA_CACHE_DIR=/tmp \
  POETRY_VIRTUALENVS_CREATE=true \
  OMP_NUM_THREADS=4 \
  NUMBA_NUM_THREADS=4 \
  PATH="$PATH:$HOME/.local/bin"

RUN apt update && apt-get install -y git python3.9 python3.9-dev && \
    apt-get clean  && \
    curl https://bootstrap.pypa.io/get-pip.py | python3.9 - --user

RUN mkdir /data
WORKDIR /data
RUN ulimit -c 0

RUN python3.9 -m pip install -U pip

RUN curl -sSL https://install.python-poetry.org | python3.9 -

COPY ./pyproject.toml ./poetry.lock /data/
RUN mkdir -p /root/.cache/pypoetry/virtualenvs/ && \
  touch /root/.cache/pypoetry/virtualenvs/envs.toml && \
  $HOME/.local/bin/poetry env use 3.9
RUN $HOME/.local/bin/poetry install --only main --no-interaction --no-root

FROM builder
COPY ./ /data/
RUN $HOME/.local/bin/poetry install --without dev,doc --no-interaction
ENTRYPOINT ["/root/.local/bin/poetry", "run"]
