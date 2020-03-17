FROM node:10-alpine
WORKDIR /src
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 8080
CMD ["node", "index.js"]