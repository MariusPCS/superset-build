FROM apache/superset:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg2 \
        unixodbc \
        unixodbc-dev \
        gcc \
        g++ \
        ca-certificates && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    pip install --no-cache-dir \
        --trusted-host pypi.org \
        --trusted-host files.pythonhosted.org \
        pyodbc \
        psycopg2-binary \
        pymysql \
        mysqlclient \
        pandas \
        openpyxl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER superset