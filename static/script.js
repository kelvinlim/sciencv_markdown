// DOM elements
const markdownInput = document.getElementById('markdown-input');
const formatBtn = document.getElementById('format-btn');
const formattedOutput = document.getElementById('formatted-output');
const copyBtn = document.getElementById('copy-btn');
const loading = document.getElementById('loading');

// Event listeners
formatBtn.addEventListener('click', formatMarkdown);
copyBtn.addEventListener('click', copyToClipboard);

// Auto-resize textarea
markdownInput.addEventListener('input', function() {
    this.style.height = 'auto';
    this.style.height = this.scrollHeight + 'px';
});

// Format markdown function
async function formatMarkdown() {
    const text = markdownInput.value.trim();
    
    if (!text) {
        showError('Please enter some Markdown text to format.');
        return;
    }
    
    // Show loading state
    showLoading(true);
    
    try {
        const response = await fetch('/sciencv/format', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: text })
        });
        
        const data = await response.json();
        
        if (data.error) {
            showError('Error formatting text: ' + data.error);
        } else {
            displayFormattedText(data.html);
            showSuccess('Text formatted successfully!');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        showLoading(false);
    }
}

// Display formatted text
function displayFormattedText(html) {
    if (html.trim()) {
        formattedOutput.innerHTML = html;
        formattedOutput.classList.remove('placeholder');
    } else {
        formattedOutput.innerHTML = '<p class="placeholder">No content to display</p>';
    }
}

// Copy to clipboard function
async function copyToClipboard() {
    const content = formattedOutput.innerHTML;
    
    if (!content || content.includes('placeholder')) {
        showError('No formatted content to copy.');
        return;
    }
    
    try {
        // Create a ClipboardItem with both HTML and plain text
        const htmlContent = new Blob([content], { type: 'text/html' });
        const textContent = new Blob([formattedOutput.textContent || formattedOutput.innerText || ''], { type: 'text/plain' });
        
        const clipboardItem = new ClipboardItem({
            'text/html': htmlContent,
            'text/plain': textContent
        });
        
        // Copy to clipboard with HTML formatting preserved
        await navigator.clipboard.write([clipboardItem]);
        
        // Show success feedback
        const originalText = copyBtn.textContent;
        copyBtn.textContent = '✓ Copied!';
        copyBtn.style.background = '#ffcc33';
        copyBtn.style.color = '#7a0019';
        
        setTimeout(() => {
            copyBtn.textContent = originalText;
            copyBtn.style.background = '#7a0019';
            copyBtn.style.color = 'white';
        }, 2000);
        
    } catch (error) {
        // Fallback: Try to copy HTML directly using execCommand
        try {
            // Create a temporary div with the HTML content
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = content;
            tempDiv.style.position = 'absolute';
            tempDiv.style.left = '-9999px';
            tempDiv.style.top = '-9999px';
            document.body.appendChild(tempDiv);
            
            // Select the content
            const range = document.createRange();
            range.selectNodeContents(tempDiv);
            const selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(range);
            
            // Copy using execCommand
            document.execCommand('copy');
            
            // Clean up
            selection.removeAllRanges();
            document.body.removeChild(tempDiv);
            
            showSuccess('Content copied to clipboard!');
            
        } catch (fallbackError) {
            // Final fallback: copy plain text
            try {
                const textArea = document.createElement('textarea');
                textArea.value = formattedOutput.textContent || formattedOutput.innerText || '';
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
                
                showSuccess('Content copied to clipboard (plain text only)!');
            } catch (finalError) {
                showError('Unable to copy to clipboard. Please select and copy manually.');
            }
        }
    }
}

// Show loading state
function showLoading(show) {
    if (show) {
        formatBtn.style.display = 'none';
        loading.classList.remove('hidden');
    } else {
        formatBtn.style.display = 'flex';
        loading.classList.add('hidden');
    }
}

// Show error message
function showError(message) {
    // Create or update error message
    let errorDiv = document.querySelector('.error-message');
    if (!errorDiv) {
        errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #7a0019;
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 1000;
            max-width: 300px;
            font-weight: 500;
        `;
        document.body.appendChild(errorDiv);
    }
    
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
        errorDiv.style.display = 'none';
    }, 5000);
}

// Show success message
function showSuccess(message) {
    // Create or update success message
    let successDiv = document.querySelector('.success-message');
    if (!successDiv) {
        successDiv = document.createElement('div');
        successDiv.className = 'success-message';
        successDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #ffcc33;
            color: #7a0019;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 1000;
            max-width: 300px;
            font-weight: 500;
        `;
        document.body.appendChild(successDiv);
    }
    
    successDiv.textContent = message;
    successDiv.style.display = 'block';
    
    // Auto-hide after 3 seconds
    setTimeout(() => {
        successDiv.style.display = 'none';
    }, 3000);
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + Enter to format
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        formatMarkdown();
    }
    
    // Ctrl/Cmd + Shift + C to copy
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
        e.preventDefault();
        copyToClipboard();
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Focus on input
    markdownInput.focus();
    
    // Add some sample content if empty
    if (!markdownInput.value.trim()) {
        markdownInput.value = `# Welcome to SciENcv Markdown Formatter

This tool converts your **Markdown** text into *Word-compatible* formatted text. Scroll down for
Markdown features.

### Sample content from a personal statement with bolding and paragraphs.
---
In this project, we propose to collect EMA and wearable data in three clinical pain populations. Following EMA, at baseline, subjects will be randomized to one of two groups.  Group 1 will be told what their causal factors for PI are and how they can be addressed.  Group 2 will receive general information about biopsychosocial factors that can affect PI.  Pain assessments will be collected at baseline and 6 months after. 

Recent projects that I would like to highlight include:

**1I01CX002088**  
Holtzheimer(PI); Role: Site PI;  
10/1/2020-9/30/2025  
Assessing an electroencephalography (EEG) biomarker of response to transcranial magnetic stimulation for major depression  

**I01CX001995**  
Lim(PI);  
1/1/2020-12/31/2025  
Effects of tDCS Paired with Cognitive Training on Brain Networks associated with Alcohol Use Disorder in Veterans
---
## Features
- Headers and subheaders
- **Bold** and *italic* text
- Lists and numbered lists
- Code blocks and \`inline code\`
- Tables and blockquotes

### Try it out!
Enter your own Markdown text above and click the **Format** button.


`;
    }
});
