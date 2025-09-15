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
├── app.py                 # Flask application
├── requirements.txt       # Python dependencies
├── static/
│   ├── style.css         # CSS styling
│   └── script.js         # Frontend JavaScript
├── templates/
│   └── index.html        # Main HTML template
├── README.md             # This file
└── .gitignore           # Git ignore file
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

## License

This project is open source and available under the MIT License.

