from flask import Flask
import os
app = Flask(__name__)

@app.route("/")
def home():
    env_name = os.environ.get("ENV_NAME")
    return f"Hello in {env_name} cluster"

if __name__ == "__main__":
        debug_mode = os.environ.get("DEBUG_MODE")
        host = os.environ.get("HOST", "0.0.0.0")
        port = os.environ.get("PORT", 5000)
        app.run(debug=debug_mode, host=host, port=port)
