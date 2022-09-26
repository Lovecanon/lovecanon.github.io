<!--
Date: 2022-09-26
Tags: ["mdbook", "linux", "github.io"]
Category: Linux
-->
# mdbook发布到github.io并让Google搜索

## 通过Github Actions实现：提交后自动发布
项目根目录下创建：`.github/workflows/deploy.yml`文件，

```yaml
name: Deploy
on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
    - name: Install mdbook
      run: |
        mkdir mdbook
        curl -sSL https://github.com/rust-lang/mdBook/releases/download/v0.4.14/mdbook-v0.4.14-x86_64-unknown-linux-gnu.tar.gz | tar -xz --directory=./mdbook
        echo `pwd`/mdbook >> $GITHUB_PATH
    - name: Deploy GitHub Pages
      run: |
        # This assumes your book is in the root of your repository.
        # Just add a `cd` here if you need to change to another directory.
        mdbook build
        git worktree add gh-pages
        git config user.name "Deploy from CI"
        git config user.email "xxx@qq.com"
        cd gh-pages
        # Delete the ref to avoid keeping history.
        git update-ref -d refs/heads/gh-pages
        rm -rf *
        mv ../book/* .
        git add .
        git commit -m "Deploy $GITHUB_SHA to gh-pages"
        git push --force --set-upstream origin gh-pages
```
大致的流程如下：
1. 创建最新版的ubuntu容器，并安装mdbook命令
2. `git worktree add gh-pages`，创建gh-pages分支，该分支保存编译后的HTML文件
3. 编译markdown成HTML文件
4. add, commit, push

因为HTML文件被推送到远程的`gh-pages`分支，所以需要在「Settings」--「Pages」指定该分支。这样才能在xxx.github.io访问到编译后的HTML页面。

### 参考：
* [mdBook Automated Deployment: GitHub Actions](https://github.com/rust-lang/mdBook/wiki/Automated-Deployment%3A-GitHub-Actions)

## xxx.github.io让Google搜索到
第一步，检查该网站是否被Google搜索。通过Google搜索：`site: xxx.github.io`，如果出现很多该域名下的条目说明该博客已经被Google搜索到了。如果没有被搜索到，应该就只会出现一条github.com的条目。

第二步，向Google证明该域名是自己拥有的。[Google Search Console](https://search.google.com/search-console)，添加所要搜索的域名：xxx.github.io。按照提示，Google会让你将`google228fxxx4.html`文件放到网站中，即：访问xxx.github.io/google228fxxx4.html，就会返回`google228fxxx4.html`文件内容。

第三步，刚验证通过，Google会提示：正在处理数据，请过 1 天左右再来查看。
