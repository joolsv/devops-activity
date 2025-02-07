from flask import Flask

app=Flask(__name__)

@app.route('/')
def greeting():
    return 'Hello, World!'

@app.route('/page1')
def page1():
    return 'This is page 1'

if __name__=='__main__':
    app.run(host="0.0.0.0", port=5000)

