# ScienceCV Markdown Formatter

A modern web application that converts Markdown text to Word-compatible formatted text with a beautiful, intuitive interface.

## Features

- **Two-Window Interface**: Clean input and output areas
- **Real-time Formatting**: Convert Markdown to Word-compatible HTML
- **Modern UI**: Responsive design with gradient backgrounds and smooth animations
- **Copy to Clipboard**: One-click copying of formatted text
- **Keyboard Shortcuts**: 
  - `Ctrl/Cmd + Enter`: Format text
  - `Ctrl/Cmd + Shift + C`: Copy to clipboard
- **Word Compatibility**: Formatted text is optimized for pasting into Microsoft Word documents

## Supported Markdown Features

- Headers (H1-H6)
- **Bold** and *italic* text
- Lists (ordered and unordered)
- Code blocks and `inline code`
- Tables
- Blockquotes
- Links and images

## Installation & Setup

### Prerequisites
- Python 3.7 or higher
- pip (Python package installer)

### Quick Start

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd sciencv_markdown
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application**
   ```bash
   python app.py
   ```

4. **Open your browser**
   Navigate to `http://localhost:5000`

## Usage

1. **Enter Markdown**: Type or paste your Markdown text in the top text area
2. **Format**: Click the "Format" button or press `Ctrl/Cmd + Enter`
3. **Copy**: Click the "Copy" button to copy the formatted text to your clipboard
4. **Paste**: Paste the formatted text directly into your Word document

## Project Structure

```
sciencv_markdown/
├── app.py                    # Flask application
├── requirements.txt          # Python dependencies
├── Containerfile             # Podman container definition
├── podman-compose.yml        # Podman Compose configuration
├── podman-run.sh            # Podman management script
├── install-podman.sh        # Podman installation script
├── sciencv-markdown.service # Systemd service file
├── static/
│   ├── style.css            # CSS styling
│   └── script.js            # Frontend JavaScript
├── templates/
│   └── index.html           # Main HTML template
├── README.md                # Project documentation
├── Process.md               # Development process documentation
└── .gitignore              # Git ignore file
```

## Technical Details

- **Backend**: Flask (Python web framework)
- **Markdown Processing**: Python Markdown library with extensions
- **Frontend**: Vanilla HTML, CSS, and JavaScript
- **Styling**: Custom CSS with Word-compatible formatting
- **Port**: 5000 (configurable in app.py)

## Development

To run in development mode:
```bash
python app.py
```

The application will start in debug mode with auto-reload enabled.

## Container Deployment

### Using Podman (Recommended)

#### Quick Start with Podman Script

1. **Build and run the application:**
   ```bash
   ./podman-run.sh run
   ```

2. **View logs:**
   ```bash
   ./podman-run.sh logs
   ```

3. **Stop the application:**
   ```bash
   ./podman-run.sh stop
   ```

4. **Show all available commands:**
   ```bash
   ./podman-run.sh help
   ```

#### Using Podman Compose

1. **Build and run the application:**
   ```bash
   podman-compose -f podman-compose.yml up --build
   ```

2. **Run in background:**
   ```bash
   podman-compose -f podman-compose.yml up -d --build
   ```

3. **Stop the application:**
   ```bash
   podman-compose -f podman-compose.yml down
   ```

#### Using Podman directly

1. **Build the image:**
   ```bash
   podman build -f Containerfile -t sciencv-markdown .
   ```

2. **Run the container:**
   ```bash
   podman run -p 5000:5000 sciencv-markdown
   ```

3. **Run in background:**
   ```bash
   podman run -d -p 5000:5000 --name sciencv-app --restart=unless-stopped sciencv-markdown
   ```


### Container Features

- **Production Ready**: Uses Gunicorn WSGI server for production deployment
- **Health Checks**: Built-in health monitoring
- **Security**: Runs as non-root user (Podman runs rootless by default)
- **Optimized**: Multi-layer build for smaller image size
- **Auto-restart**: Container restarts automatically unless stopped
- **No Daemon**: Podman doesn't require a background daemon
- **Better Security**: Enhanced container isolation and rootless operation
- **Easy Management**: Simple script-based container management

### Access the Application

Once running, access the application at:
- **Local**: `http://localhost:5000`
- **Network**: `http://your-server-ip:5000`

## License

This project is open source and available under the MIT License.

