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
    \
    . /etc/os-release; \
    echo "Detected Debian version: ${VERSION_ID} / ${VERSION_CODENAME}"; \
    \
    rm -f /etc/apt/sources.list.d/mssql-release.list; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/${VERSION_ID}/prod ${VERSION_CODENAME} main" \
        > /etc/apt/sources.list.d/mssql-release.list; \
    \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18; \
    \
    pip install --no-cache-dir \
        --trusted-host pypi.org \
        --trusted-host files.pythonhosted.org \
        pyodbc \
        psycopg2-binary \
        pymysql \
        mysqlclient \
        pandas \
        openpyxl; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER superset
