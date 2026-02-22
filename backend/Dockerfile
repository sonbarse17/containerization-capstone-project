# builder stage
FROM python:3.9-slim AS builder

WORKDIR /app

# Create an app-specific user (taskflow) for the runtime
RUN useradd -r -s /bin/false taskflow

COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

# runtime (distroless)
FROM gcr.io/distroless/python3-debian11

WORKDIR /app

# Copy the user and group configurations from the builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

COPY --from=builder /app/dependencies /usr/local/lib/python3.9/site-packages
COPY . .

ENV PYTHONPATH=/usr/local/lib/python3.9/site-packages

# Run as our custom app-specific user
USER taskflow

EXPOSE 5000

CMD ["/app/app.py"]
