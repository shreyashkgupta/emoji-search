# Auto-generated by Cloud Code AI

# Use Ubuntu as the base image
FROM ubuntu:latest

# Update the system
RUN apt-get update -y

# Install Node.js
RUN apt-get install -y nodejs npm

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the source code
COPY . .

# Build the application
RUN npm run build

# Expose the port the app runs in
EXPOSE 3000

# Serve the app
CMD [ "npm", "start" ]