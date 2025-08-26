from flask import Flask
import os
app = Flask(__name__)

@app.route("/")
def home():
    env_name = os.environ.get("ENV_NAME")
    return f"Hello in {env_name} cluster"

if __name__ == "__main__":
        debug_mode = os.environ.get("DEBUG_MODE")
        app.run(debug=debug_mode)
