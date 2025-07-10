## -- GO BUILD ------- 

  FROM golang:1.24-alpine AS builder

  WORKDIR /app
  
  COPY go.mod go.sum ./
  RUN go mod download
  
  COPY ./src ./src
  
  WORKDIR /app/src
  
  RUN go test -count=1 ./... && go build -o /app/main .
  
  ## -- YARN BUILD ------- 
  FROM node:22-alpine AS frontend-builder
  
  WORKDIR /app
  
  COPY package.json yarn.lock* package-lock.json* ./
  COPY tailwind.config.js postcss.config.js ./
  
  RUN if [ -f yarn.lock ]; then yarn install; else npm install; fi
  
  COPY ./src ./src
  
  RUN npm run build
  
  ## -- ASSEMBLE --------
  FROM golang:1.23-alpine
  
  WORKDIR /app
  
  COPY --from=builder /app/main .
  
  COPY --from=frontend-builder /app/src/templates ./src/templates
  
  EXPOSE 8080
  
  CMD ["./main"]
  