# Stage 1: Build
FROM node:10 AS build

WORKDIR /app

COPY . /app

RUN npm install && \
    npm run build:web

# Stage 2: Production
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from stage 1
COPY --from=build /app/dist/web /usr/share/nginx/html

# Custom nginx config to handle SPA routing and ensure it serves index.html
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    error_page 500 502 503 504 /50x.html; \
    location = /50x.html { \
        root /usr/share/nginx/html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
