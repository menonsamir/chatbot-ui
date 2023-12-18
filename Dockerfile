# ---- Base Node ----
FROM node:19-alpine AS base
WORKDIR /app
COPY package*.json ./

# ---- Dependencies ----
FROM base AS dependencies
RUN npm ci

# ---- Build ----
FROM dependencies AS build
COPY . .
RUN npm run build

# ---- Production ----
FROM node:19-alpine AS production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/package*.json ./
COPY --from=build /app/next.config.js ./next.config.js
COPY --from=build /app/next-i18next.config.js ./next-i18next.config.js

# Expose the port the app will run on
EXPOSE 3000

# Add environment variables
ENV DEFAULT_MODEL=mistralai/Mistral-7B-Instruct-v0.1
ENV OPENAI_API_HOST=https://enclave.blyss.dev
ENV OPENAI_API_KEY=EMPTY
ENV GOOGLE_API_KEY=EMPTY
ENV GOOGLE_CSE_ID=EMPTY

# Start the application
CMD ["npm", "start"]
