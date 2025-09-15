from flask import Flask, render_template, request, jsonify
import markdown
import re
from io import StringIO

app = Flask(__name__)
# add following to support reverse proxy static files
app.config['APPLICATION_ROOT'] = '/sciencv'
def convert_markdown_to_word_html(markdown_text):
    """
    Convert markdown text to HTML that's compatible with Word documents.
    This includes proper styling and formatting that Word can understand.
    """
    # Pre-process the text to ensure proper paragraph breaks
    # Split on double newlines to create proper paragraphs
    paragraphs = markdown_text.split('\n\n')
    
    # Process each paragraph separately to ensure proper formatting
    processed_paragraphs = []
    for paragraph in paragraphs:
        if paragraph.strip():
            # Configure markdown with extensions for better formatting
            md = markdown.Markdown(extensions=['tables', 'fenced_code', 'toc'])
            # Convert this paragraph to HTML
            html = md.convert(paragraph.strip())
            processed_paragraphs.append(html)
    
    # Join paragraphs with proper spacing
    html = '\n\n'.join(processed_paragraphs)
    
    # Add Word-compatible CSS styling with proper paragraph spacing
    word_compatible_html = f"""
    <div style="font-family: Arial, sans-serif; font-size: 12pt; line-height: 1.15; margin: 0; padding: 0;">
        {html}
    </div>
    """
    
    # Apply Word-specific formatting
    word_compatible_html = apply_word_formatting(word_compatible_html)
    
    return word_compatible_html

def apply_word_formatting(html):
    """
    Apply Word-specific formatting to HTML content.
    """
    # Style headers for Word compatibility
    html = re.sub(r'<h1>(.*?)</h1>', r'<h1 style="font-size: 18pt; font-weight: bold; margin: 12pt 0 6pt 0;">\1</h1>', html)
    html = re.sub(r'<h2>(.*?)</h2>', r'<h2 style="font-size: 16pt; font-weight: bold; margin: 10pt 0 5pt 0;">\1</h2>', html)
    html = re.sub(r'<h3>(.*?)</h3>', r'<h3 style="font-size: 14pt; font-weight: bold; margin: 8pt 0 4pt 0;">\1</h3>', html)
    html = re.sub(r'<h4>(.*?)</h4>', r'<h4 style="font-size: 13pt; font-weight: bold; margin: 6pt 0 3pt 0;">\1</h4>', html)
    html = re.sub(r'<h5>(.*?)</h5>', r'<h5 style="font-size: 12pt; font-weight: bold; margin: 4pt 0 2pt 0;">\1</h5>', html)
    html = re.sub(r'<h6>(.*?)</h6>', r'<h6 style="font-size: 12pt; font-weight: bold; margin: 4pt 0 2pt 0;">\1</h6>', html)
    
    # Style paragraphs with proper spacing for Word
    html = re.sub(r'<p>(.*?)</p>', r'<p style="margin: 0 0 12pt 0; line-height: 1.15; padding: 0;">\1</p>', html)
    
    # Add explicit line breaks between paragraphs for better Word compatibility
    html = re.sub(r'</p>\s*<p>', '</p>\n<br>\n<p style="margin: 0 0 12pt 0; line-height: 1.15; padding: 0;">', html)
    
    # Handle double line breaks that should create paragraph breaks
    html = re.sub(r'</p>\s*<br>\s*<br>\s*<p>', '</p>\n<br>\n<p style="margin: 0 0 12pt 0; line-height: 1.15; padding: 0;">', html)
    
    # Ensure the last paragraph doesn't have extra spacing
    html = re.sub(r'<p style="margin: 0 0 12pt 0; line-height: 1.15; padding: 0;">(.*?)</p>\s*$', r'<p style="margin: 0; line-height: 1.15; padding: 0;">\1</p>', html)
    
    # Style lists
    html = re.sub(r'<ul>(.*?)</ul>', r'<ul style="margin: 0 0 6pt 0; padding-left: 20pt;">\1</ul>', html)
    html = re.sub(r'<ol>(.*?)</ol>', r'<ol style="margin: 0 0 6pt 0; padding-left: 20pt;">\1</ol>', html)
    html = re.sub(r'<li>(.*?)</li>', r'<li style="margin: 0 0 3pt 0;">\1</li>', html)
    
    # Style code blocks
    html = re.sub(r'<pre><code>(.*?)</code></pre>', r'<pre style="background-color: #f5f5f5; padding: 6pt; margin: 6pt 0; border: 1pt solid #ddd; font-family: \'Courier New\', monospace; font-size: 10pt;"><code>\1</code></pre>', html, flags=re.DOTALL)
    
    # Style inline code
    html = re.sub(r'<code>(.*?)</code>', r'<code style="background-color: #f5f5f5; padding: 1pt 2pt; font-family: \'Courier New\', monospace; font-size: 10pt;">\1</code>', html)
    
    # Style blockquotes
    html = re.sub(r'<blockquote>(.*?)</blockquote>', r'<blockquote style="margin: 6pt 0 6pt 20pt; padding-left: 6pt; border-left: 3pt solid #ddd; font-style: italic;">\1</blockquote>', html, flags=re.DOTALL)
    
    # Style tables
    html = re.sub(r'<table>(.*?)</table>', r'<table style="border-collapse: collapse; margin: 6pt 0; width: 100%;">\1</table>', html, flags=re.DOTALL)
    html = re.sub(r'<th>(.*?)</th>', r'<th style="border: 1pt solid #000; padding: 3pt; background-color: #f0f0f0; font-weight: bold;">\1</th>', html)
    html = re.sub(r'<td>(.*?)</td>', r'<td style="border: 1pt solid #000; padding: 3pt;">\1</td>', html)
    
    return html

@app.route('/')
def index():
    """Serve the main page."""
    return render_template('index.html')

@app.route('/format', methods=['POST'])
def format_markdown():
    """API endpoint to format markdown text."""
    try:
        data = request.get_json()
        markdown_text = data.get('text', '')
        
        if not markdown_text.strip():
            return jsonify({'html': '', 'error': None})
        
        # Convert markdown to Word-compatible HTML
        formatted_html = convert_markdown_to_word_html(markdown_text)
        
        return jsonify({'html': formatted_html, 'error': None})
    
    except Exception as e:
        return jsonify({'html': '', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
