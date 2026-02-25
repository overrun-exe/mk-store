FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG VUE_APP_API_URL=/api
ARG VUE_APP_PUBLIC_PATH=/
ENV VUE_APP_API_URL=${VUE_APP_API_URL}
ENV VUE_APP_PUBLIC_PATH=${VUE_APP_PUBLIC_PATH}

RUN npm run build

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
