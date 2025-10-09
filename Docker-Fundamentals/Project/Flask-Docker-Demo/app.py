from flask import Flask, jsonify
import os
import time


app = Flask(__name__)


# Configuration via environment variables with sensible defaults
app.config['DEBUG'] = os.getenv('FLASK_DEBUG', 'false').lower() in ('1', 'true', 'yes')
app.config['PORT'] = int(os.getenv('PORT', 5000))
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret')
app.config['SERVICE_MODE'] = os.getenv('SERVICE_MODE', 'normal')


# Example application endpoints
@app.route('/')
def index():
	return jsonify({
		'message': 'Hello from Flask in Docker!',
		'service_mode': app.config['SERVICE_MODE']
	})


# A simple health check — extend this to check DB, cache, etc.
@app.route('/health')
def health():
	# Example of a "deeper" check: ensure SECRET_KEY is set to something non-default
	secret_ok = app.config['SECRET_KEY'] != 'dev-secret'
	status = 'ok' if secret_ok else 'warn'
	checks = {
		'app_server': 'ok',
		'secret_key_non_default': 'ok' if secret_ok else 'warning: using default secret'
	}
	code = 200 if secret_ok else 429
	return jsonify({'status': status, 'checks': checks}), code


if __name__ == '__main__':
	# Use 0.0.0.0 so the container exposes the port
	app.run(host='0.0.0.0', port=app.config['PORT'], debug=app.config['DEBUG'])