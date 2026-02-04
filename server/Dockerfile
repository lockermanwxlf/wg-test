FROM python:3.14 AS base

FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-dev --compile-bytecode

FROM base AS final
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y bash wireguard-tools wireguard-go iproute2 iptables iputils-ping
WORKDIR /app
COPY --from=builder /app/.venv .venv
ENV PATH="/app/.venv/bin:$PATH"
COPY . .
CMD ["bash", "entrypoint.bash"]