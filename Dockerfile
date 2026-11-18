# Single-container build for Render: nginx (frontend + /api proxy) + Node backend
FROM node:20-alpine AS frontend
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
ARG VITE_API_URL=http://localhost:4000
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

FROM node:20-alpine
RUN apk add --no-cache nginx gettext openssl
WORKDIR /app/backend
COPY backend/package*.json ./
COPY backend/prisma ./prisma
RUN npm ci
COPY backend/tsconfig.json ./
COPY backend/src ./src
RUN npm run build && npx prisma generate
COPY --from=frontend /app/dist /usr/share/nginx/html
COPY deploy/nginx.conf.template /etc/nginx/nginx.conf.template
COPY deploy/start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 10000
CMD ["/start.sh"]
