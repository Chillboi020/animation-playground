FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the SvelteKit app
RUN npm run build

# Install production dependencies
RUN npm ci --omit=dev

# Final stage for production
FROM node:18-alpine

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Expose port (default for adapter-node is 3000)
EXPOSE 3000

# Command to run the app
CMD ["node", "build"]
