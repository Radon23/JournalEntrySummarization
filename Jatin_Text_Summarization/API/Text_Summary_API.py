import TextSummarization
from flask import *

app = Flask(__name__)


@app.route('/')
def home():
    return "Welcome to Model API."


@app.route('/summary', methods=['POST'])
def summary():
    article = request.form.get('article')
    result = TextSummarization.summarize(article)
    return jsonify({'summary': str(result)})


if __name__ == '__main__':
    app.run(debug=True)
