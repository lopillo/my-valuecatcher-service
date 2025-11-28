FROM node:18-alpine

WORKDIR /app

# Install production dependencies
COPY package*.json ./
RUN npm install --only=production

# Copy the rest of the app
COPY . .

EXPOSE 3000
CMD ["npm", "start"]
