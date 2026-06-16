# STAGE 1: Build
FROM node:10 AS build

WORKDIR /app

# Install dependencies separately to leverage Docker cache
COPY package*.json ./
RUN npm install

# Copy all files and build
COPY . .
RUN npm run build:web

# STAGE 2: Production
FROM nginx:stable-alpine

# Clean up default nginx files
RUN rm -rf /usr/share/nginx/html/* && \
    rm -rf /etc/nginx/conf.d/*

# Copy build result from Stage 1
# IMPORTANT: Verify if the folder is really dist/web
COPY --from=build /app/dist/web /usr/share/nginx/html

# Create a fail-proof nginx config
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/panel.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
