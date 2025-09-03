FROM node:24-alpine AS install
WORKDIR /digital_garden
COPY package.json .
COPY package-lock.json* .
RUN npm ci

FROM install AS build
COPY quartz/ quartz/
COPY globals.d.ts index.d.ts quartz.config.ts quartz.layout.ts ./
COPY content/ content/
RUN npx quartz build --concurrency 8

FROM nginx:1.29-alpine AS run
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /digital_garden/public /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
