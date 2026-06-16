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

# Disable default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Custom nginx config with cache busting and explicit root
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html =404; \
        add_header Cache-Control "no-store, no-cache, must-revalidate"; \
    } \
}' > /etc/nginx/conf.d/panel.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
