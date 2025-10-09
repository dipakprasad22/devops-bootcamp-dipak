from flask import Flask, render_template_string

app = Flask(__name__)

# HTML template for the home page
template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple Flask App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        p {
            color: #666;
            line-height: 1.6;
        }
        .highlight {
            background-color: #e7f3ff;
            padding: 10px;
            border-radius: 4px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Demo Python Flask Application! 🚀</h1>
        <p>This is a simple Flask web application.</p>
        <div class="highlight">
            <p><strong>Features:</strong></p>
            <ul>
                <li>Single page application</li>
                <li>Clean, responsive design</li>
                <li>Ready to extend with more functionality</li>
            </ul>
        </div>
        <p>You can modify this page by editing the template in <code>app.py</code></p>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(template)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)