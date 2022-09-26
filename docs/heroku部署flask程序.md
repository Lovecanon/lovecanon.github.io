<!--
Date: 2020-10-20
Tags: ["heroku", "linux"]
Category: Linux
-->
# heroku部署flask程序.md
## 安装heroku-cli
```bash
curl https://cli-assets.heroku.com/install.sh | sh

# 登陆heroku，如果不加 -i 则需要本机访问命令行打印的链接
heroku login -i
```

## 创建项目
```bash
$ tree .
.
├── Procfile
├── requirements.txt
└── run.py

# 编写Procfile，用于heroku运行程序
$ vim Procfile
web: flask db upgrade; flask translate compile; gunicorn run:app

# 编写flask代码
$ vim run.py
from flask import Flask, send_file, send_from_directory, make_response
import os
app = Flask(__name__)

@app.route("/index")
def index():
    return "Index Page"
```

## 本地运行
```bash
# 常用命令
# 本地运行，注：本地需要安装：gunicorn
heroku local web
```

## 部署
```bash
# 将当前本地目录项目关联到远程Heroku项目（indexProject）。也可以下载远程项目：heroku git:clone -a geektime
$ heroku git:remote -a indexProject

$ git add .
$ git commit -am "make it better"
$ git push heroku master  # 项目将上传、自动部署、运行在Heroku中
```

## 注意事项
* `heroku login -i`：直接输入用户名密码登陆，简单方便；
* `requirements.txt`文件需要添加：`gunicorn`库
