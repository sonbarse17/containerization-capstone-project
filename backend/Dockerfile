# builder stage
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

# runtime (distroless)
FROM gcr.io/distroless/python3-debian11

WORKDIR /app

COPY --from=builder /app/dependencies /usr/local/lib/python3.11/site-packages
COPY . .

ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

EXPOSE 5000

CMD ["python3", "app.py"]
