#!/bin/bash

# ScienceCV Markdown Podman Run Script
# This script provides easy commands to run the application with Podman

set -e

IMAGE_NAME="sciencv-markdown"
CONTAINER_NAME="sciencv-app"
PORT="5000"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed. Please install Podman first."
        echo "Installation instructions:"
        echo "  RHEL/CentOS/Fedora: sudo dnf install podman"
        echo "  Ubuntu/Debian: sudo apt install podman"
        exit 1
    fi
    print_success "Podman is installed"
}

# Function to build the image
build_image() {
    print_status "Building Podman image: $IMAGE_NAME"
    podman build -f Containerfile -t $IMAGE_NAME .
    print_success "Image built successfully"
}

# Function to run the container
run_container() {
    print_status "Starting container: $CONTAINER_NAME"
    
    # Check if container already exists
    if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        print_warning "Container $CONTAINER_NAME already exists"
        print_status "Stopping and removing existing container..."
        podman stop $CONTAINER_NAME 2>/dev/null || true
        podman rm $CONTAINER_NAME 2>/dev/null || true
    fi
    
    # Run the container
    podman run -d \
        --name $CONTAINER_NAME \
        -p $PORT:5000 \
        --restart=unless-stopped \
        --security-opt no-new-privileges:true \
        $IMAGE_NAME
    
    print_success "Container started successfully"
    print_status "Application is available at: http://localhost:$PORT"
}

# Function to stop the container
stop_container() {
    print_status "Stopping container: $CONTAINER_NAME"
    podman stop $CONTAINER_NAME 2>/dev/null || print_warning "Container not running"
    print_success "Container stopped"
}

# Function to remove the container
remove_container() {
    print_status "Removing container: $CONTAINER_NAME"
    podman stop $CONTAINER_NAME 2>/dev/null || true
    podman rm $CONTAINER_NAME 2>/dev/null || print_warning "Container not found"
    print_success "Container removed"
}

# Function to show container status
show_status() {
    print_status "Container status:"
    podman ps -a --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Application logs (last 20 lines):"
        podman logs --tail 20 $CONTAINER_NAME
    fi
}

# Function to show logs
show_logs() {
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Showing logs for $CONTAINER_NAME (Ctrl+C to exit):"
        podman logs -f $CONTAINER_NAME
    else
        print_error "Container $CONTAINER_NAME is not running"
    fi
}

# Function to execute commands in the container
exec_container() {
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Executing command in container: $CONTAINER_NAME"
        podman exec -it $CONTAINER_NAME "$@"
    else
        print_error "Container $CONTAINER_NAME is not running"
    fi
}

# Function to show help
show_help() {
    echo "ScienceCV Markdown Podman Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Podman image"
    echo "  run       Build and run the container"
    echo "  start     Start the existing container"
    echo "  stop      Stop the container"
    echo "  restart   Restart the container"
    echo "  remove    Stop and remove the container"
    echo "  status    Show container status and logs"
    echo "  logs      Show container logs (follow mode)"
    echo "  exec      Execute command in container"
    echo "  clean     Remove container and image"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 run                    # Build and run the application"
    echo "  $0 logs                   # Follow application logs"
    echo "  $0 exec /bin/bash         # Open bash shell in container"
    echo "  $0 clean                  # Remove everything"
}

# Main script logic
case "${1:-help}" in
    build)
        check_podman
        build_image
        ;;
    run)
        check_podman
        build_image
        run_container
        ;;
    start)
        check_podman
        podman start $CONTAINER_NAME
        print_success "Container started"
        ;;
    stop)
        check_podman
        stop_container
        ;;
    restart)
        check_podman
        stop_container
        run_container
        ;;
    remove)
        check_podman
        remove_container
        ;;
    status)
        check_podman
        show_status
        ;;
    logs)
        check_podman
        show_logs
        ;;
    exec)
        check_podman
        shift
        exec_container "$@"
        ;;
    clean)
        check_podman
        remove_container
        print_status "Removing image: $IMAGE_NAME"
        podman rmi $IMAGE_NAME 2>/dev/null || print_warning "Image not found"
        print_success "Cleanup completed"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
