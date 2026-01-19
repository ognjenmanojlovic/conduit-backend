# === Build stage ===
FROM python:3.5-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt


FROM python:3.5-slim

WORKDIR /app


COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

COPY . .

RUN chmod +x ./entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["./entrypoint.sh"]

