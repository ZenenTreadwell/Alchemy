from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route("/")
@app.route("/<name>")
def demo(name=None):
        wd = os.popen('pwd').readline()
        return render_template('demo.html', name=name, wd=wd)
