# Builder stage
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine

WORKDIR /app

# Nonroot user setup
RUN addgroup -S taskflow && adduser -S taskflow -G taskflow

# Copy package data and install production dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy production server 
COPY server.js .

# Copy built React files
COPY --from=builder /app/dist ./dist

# Ensure the app folder is owned by our specific user
RUN chown -R taskflow:taskflow /app

# Switch to standard specific unprivileged user
USER taskflow

EXPOSE 8080

CMD ["node", "server.js"]
