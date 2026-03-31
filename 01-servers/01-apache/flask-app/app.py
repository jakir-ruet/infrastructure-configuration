from flask import Flask # pyright: ignore[reportMissingImports]
app = Flask(__name__)

@app.route('/')
def home():
    return 'Flask App 1 on port 5000'

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(port=5000)
