#!/bin/bash

# ScienceCV Markdown Podman Installation Script
# This script installs and configures the application to run with Podman

set -e

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

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root for security reasons"
        print_status "Please run as a regular user. Podman runs rootless by default."
        exit 1
    fi
}

# Function to check if Podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed"
        print_status "Please install Podman first:"
        echo "  RHEL/CentOS/Fedora: sudo dnf install podman"
        echo "  Ubuntu/Debian: sudo apt install podman"
        echo "  Arch Linux: sudo pacman -S podman"
        exit 1
    fi
    print_success "Podman is installed"
}

# Function to check if podman-compose is installed
check_podman_compose() {
    if ! command -v podman-compose &> /dev/null; then
        print_warning "podman-compose is not installed"
        print_status "Installing podman-compose via pip..."
        pip install --user podman-compose
        if command -v podman-compose &> /dev/null; then
            print_success "podman-compose installed successfully"
        else
            print_error "Failed to install podman-compose"
            print_status "You can still use the podman-run.sh script or podman directly"
        fi
    else
        print_success "podman-compose is installed"
    fi
}

# Function to setup Podman for rootless operation
setup_podman() {
    print_status "Setting up Podman for rootless operation..."
    
    # Check if user is in subuid/subgid ranges
    if ! grep -q "^${USER}:" /etc/subuid 2>/dev/null; then
        print_warning "User $USER not found in /etc/subuid"
        print_status "You may need to run: sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER"
    fi
    
    # Create podman configuration directory
    mkdir -p ~/.config/containers
    
    # Create containers.conf for better defaults
    if [[ ! -f ~/.config/containers/containers.conf ]]; then
        print_status "Creating Podman configuration..."
        cat > ~/.config/containers/containers.conf << EOF
[containers]
default_capabilities = [
    "CHOWN",
    "DAC_OVERRIDE",
    "FOWNER",
    "FSETID",
    "KILL",
    "NET_BIND_SERVICE",
    "NET_RAW",
    "SETFCAP",
    "SETGID",
    "SETPCAP",
    "SETUID",
    "SYS_CHROOT"
]

[engine]
events_logger = "file"
events_logfile_path = "/tmp/podman.log"
EOF
        print_success "Podman configuration created"
    fi
}

# Function to build and test the application
build_and_test() {
    print_status "Building the application image..."
    ./podman-run.sh build
    
    print_status "Testing the application..."
    ./podman-run.sh run &
    sleep 10
    
    # Test if the application is responding
    if curl -f http://localhost:5000/ &>/dev/null; then
        print_success "Application is working correctly"
    else
        print_error "Application failed to start properly"
        ./podman-run.sh stop
        exit 1
    fi
    
    ./podman-run.sh stop
}

# Function to create desktop shortcut (optional)
create_desktop_shortcut() {
    if [[ -n "$DISPLAY" ]] && command -v xdg-desktop-menu &> /dev/null; then
        print_status "Creating desktop shortcut..."
        cat > ~/.local/share/applications/sciencv-markdown.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=ScienceCV Markdown Formatter
Comment=Convert Markdown to Word-compatible text
Exec=firefox http://localhost:5000
Icon=text-x-markdown
Terminal=false
Categories=Office;TextEditor;
EOF
        print_success "Desktop shortcut created"
    fi
}

# Function to show usage instructions
show_usage() {
    print_success "Installation completed successfully!"
    echo ""
    print_status "Usage instructions:"
    echo "  Start application:    ./podman-run.sh run"
    echo "  View logs:           ./podman-run.sh logs"
    echo "  Stop application:    ./podman-run.sh stop"
    echo "  Show status:         ./podman-run.sh status"
    echo "  Get help:            ./podman-run.sh help"
    echo ""
    print_status "Or use podman-compose:"
    echo "  Start:               podman-compose -f podman-compose.yml up -d"
    echo "  Stop:                podman-compose -f podman-compose.yml down"
    echo ""
    print_status "Access the application at: http://localhost:5000"
}

# Main installation process
main() {
    print_status "Starting ScienceCV Markdown Podman installation..."
    
    check_root
    check_podman
    check_podman_compose
    setup_podman
    build_and_test
    create_desktop_shortcut
    show_usage
}

# Run main function
main "$@"
