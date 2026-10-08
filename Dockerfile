# --- Build Stage ---
    FROM golang:1.22-alpine AS builder
    WORKDIR /app
    
    # Copy and download dependencies
    #COPY go.mod go.sum ./
    COPY go.mod ./
    RUN go mod download
    
    # Copy source code and build the binary
    COPY main.go .
    RUN CGO_ENABLED=0 GOOS=linux go build -o /server main.go
    
    # --- Run Stage ---
    FROM alpine:3.19
    WORKDIR /
    
    # Copy the binary from the builder stage
    COPY --from=builder /server /server
    
    # Expose the application port
    EXPOSE 8080
    
    # Run the application
    CMD ["/server"]
    