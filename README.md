## Lovecanon Blog

### 安装

##### 1、使用Rben安装Ruby
> yum只能安装比较老的Ruby版本，`ruby 2.0.0p648 (2015-12-16) [x86_64-linux]`

Rbenv是一个轻量级的Ruby版本管理实用程序，可让您轻松切换Ruby版本。

我们还将安装ruby-build插件，该插件扩展了Rbenv的核心功能，使我们可以轻松地从源代码安装任何Ruby版本。
```bash
# 安装ruby-build工具所需的依赖项
$ yum install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel

# 运行以下 curl命令安装rbenv和ruby-build
$ curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -
Running doctor script to verify installation...
Checking for `rbenv' in PATH: which: no rbenv in (/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/go/bin:/home/go/bin)
not found
  You seem to have rbenv installed in `/root/.rbenv/bin', but that
  directory is not present in PATH. Please add it to PATH by configuring
  your `~/.bashrc', `~/.zshrc', or `~/.config/fish/config.fish'.

# 脚本将克隆这两个 rbenv 和 ruby-build 从GitHub到~/.rbenv目录的存储库。安装程序脚本还会调用另一个脚本，该脚本将尝试验证安装。
# 如果您使用的是Bash，请输入：
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# 我们已经在系统上安装了rbenv，我们可以轻松安装最新的Ruby稳定版本并将其设置为默认版本
rbenv install 2.5.1
rbenv global 2.5.1

# 要列出所有可用的Ruby版本，您可以使用：
rbenv install -l

# 通过打印版本号来验证Ruby是否已正确安装：
ruby -v

# 如果此时ruby版本还是2.0.0，卸载yum安装的ruby即可：yum remove ruby
```
### 替换gem源
```bash
# 更新gem，尽可能用比较新的 RubyGems 版本，建议 2.6.x 以上
$ gem update --system # 这里请翻墙一下
$ gem -v
2.6.3

$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l
https://gems.ruby-china.com
# 确保只有 gems.ruby-china.com

# 如果你使用 Gemfile 和 Bundler (例如：Rails 项目)
# 你可以用 Bundler 的 Gem 源代码镜像命令
$ bundle config mirror.https://rubygems.org https://gems.ruby-china.com
```

### 安装 Jekyll 和 bundler gems
```bash
gem install bundler jekyll

# 构建网站并启动一个本地服务器。
bundle exec jekyll serve

# 根据Gemfile安装依赖
bundle install
# 如果报错，/root/.rbenv/versions/2.5.1/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundler (Gem::GemNotFoundException)
# 考虑删除 Gemfile.lock 文件即可

# 运行，enjoy！
bundle exec jekyll serve -H 0.0.0.0
```

### 使用

##### 1、文章顶部设置预定义的变量
在这些三点虚线之间，您可以设置预定义的变量（请参阅下面的参考），甚至可以创建自己的自定义变量。

然后，您可以使用Liquid标记访问这些变量，这些标记既可以在文件中的更下方，也可以在任何页面或相关页面所依赖的布局中使用。

```yaml
---
layout: post
title: Blogging Like a Hacker
---
```

**参考：**
* [Front Matter](http://jekyllrb.com/docs/frontmatter/)
* [Variables](https://jekyllrb.com/docs/variables/)


### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/Lovecanon/lovecanon.github.com/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
