# Stage 1: Build
# Using the full node:10 image which already includes build tools (make, g++, python)
FROM node:10 AS build

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
COPY --from=build /app/dist/web /usr/share/nginx/html

# Custom nginx config to handle SPA routing
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
