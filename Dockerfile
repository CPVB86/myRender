FROM node:24-bookworm-slim
WORKDIR /app
COPY apps/kt-academy/bot/package*.json ./
RUN npm ci --omit=dev
RUN mkdir -p /app/data && chown node:node /app/data
COPY apps/kt-academy/bot/src ./src
COPY apps/kt-academy/bot/config/bots.json ./config/bots.json
RUN chmod -R a+rX /app/src /app/config
USER node
CMD ["node", "src/index.js"]
