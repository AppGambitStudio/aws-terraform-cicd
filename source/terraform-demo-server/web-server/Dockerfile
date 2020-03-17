FROM node:10-alpine
WORKDIR /src
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 8000
CMD ["node", "index.js"]