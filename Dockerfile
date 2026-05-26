FROM apache/superset:latest

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        ca-certificates \
        apt-transport-https \
        unixodbc \
        unixodbc-dev \
        gcc \
        g++ \
        pkg-config \
        default-libmysqlclient-dev; \
    . /etc/os-release; \
    rm -f /etc/apt/sources.list.d/mssql-release.list; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/${VERSION_ID}/prod ${VERSION_CODENAME} main" \
        | tee /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18; \
    /app/.venv/bin/python -m pip install --no-cache-dir \
        --trusted-host pypi.org \
        --trusted-host files.pythonhosted.org \
        pyodbc \
        psycopg2-binary \
        pymysql \
        mysqlclient \
        pandas \
        openpyxl; \
    mkdir -p /app/pythonpath; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN cat <<'PYCONF' | tee /app/pythonpath/superset_config.py
import os

SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "change_me")

SQLALCHEMY_DATABASE_URI = os.getenv(
    "SUPERSET_DATABASE_URI",
    "postgresql+psycopg2://superset:superset@db:5432/superset",
)

CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_HOST": "redis",
    "CACHE_REDIS_PORT": 6379,
    "CACHE_REDIS_DB": 1,
}

DATA_CACHE_CONFIG = CACHE_CONFIG

class CeleryConfig:
    broker_url = "redis://redis:6379/0"
    result_backend = "redis://redis:6379/0"

CELERY_CONFIG = CeleryConfig
PYCONF

RUN chown -R superset:superset /app/pythonpath

USER superset
