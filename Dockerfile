# Stage 1: Build
FROM node:10-slim AS build

# Install build dependencies for node-sass and other native modules
RUN apt-get update && apt-get install -y \
    python \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build:web

# Stage 2: Production
FROM nginx:alpine

# Copy built assets from stage 1
# Note: based on webpack.web.config.js, the output path is dist/web
COPY --from=build /app/dist/web /usr/share/nginx/html

# Custom nginx config to handle SPA routing if needed
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
