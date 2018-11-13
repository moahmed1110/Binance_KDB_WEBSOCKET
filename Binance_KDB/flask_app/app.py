from flask import Flask
from flask import render_template
app = Flask(__name__)



@app.route('/')
def hello():
    return render_template('index1.html')


if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=3000)
