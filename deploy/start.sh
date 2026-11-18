#!/bin/sh
set -e
export PORT="${PORT:-10000}"
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
cd /app/backend
npx prisma db push --skip-generate
npm run seed:google-config:docker || true
APP_PORT=4000 node dist/server.js &
exec nginx -g 'daemon off;'
