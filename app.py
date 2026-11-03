from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(
        message="Hello! Your GitHub Actions CI/CD deployment is live on AWS EC2.",
        status="success",
        deployment="GitHub Actions -> Docker -> Amazon ECR -> Amazon EC2"
    )

@app.get("/health")
def health():
    return jsonify(status="healthy"), 200
