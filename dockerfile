FROM apache/superset:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        gcc \
        g++ \
        unixodbc \
        unixodbc-dev && \
    pip install --no-cache-dir \
        pyodbc \
        psycopg2-binary \
        pymysql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER superset