from flask import Flask, render_template
import os
import random
app = Flask(__name__)

# list of cat images
images = [
"https://media.tenor.com/OZLXGyrE6FYAAAAM/alpaca-eating.gif",
"https://media0.giphy.com/media/3otWpNrbfVfVgyAOis/200w.gif?cid=6c09b952recmr8nlic7m1swn2vl11l5rchuo1v4eup5bwpia&ep=v1_gifs_search&rid=200w.gif&ct=g"
]


@app.route("/")
def index():
    url = random.choice(images)
    return render_template("index.html", url=url)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
