# --- BUILDER STAGE ---
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Instalacja zależności
COPY package*.json ./
COPY prisma ./prisma
RUN npm ci

# Kopiowanie kodu źródłowego
COPY tsconfig*.json nest-cli.json ./
COPY src ./src

# Generowanie klienta Prisma i budowa aplikacji
RUN npx prisma generate
RUN npm run build

# --- RUNTIME STAGE ---
FROM node:18-alpine AS runtime

WORKDIR /usr/src/app

# Kopiowanie package.json i package-lock.json
COPY package*.json ./
# Kopiowanie node_modules, dist i prisma z buildera
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3220

CMD ["node", "dist/main"] 