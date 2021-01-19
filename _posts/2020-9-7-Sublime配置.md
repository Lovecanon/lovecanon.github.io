# sublime


### 高亮React项目

 1. <b>For windows:</b> Press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> <b>For mac:</b> <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>
 2. Then <b>type</b> `install` and <b>select</b> `Package control: Install Package`
 3. Then <b>type</b> `Babel` and <b>select</b> `'Babel'`. It will install babel in few moments.<br>
 4. Then <b>set the Babel syntax</b> in Sublime3 Editor <b>from</b>: `View > Syntax > Babel > Javascript`

### 编译、运行go代码

1. 安装`golang build`插件
2. 配置go路径：Preferences -> package settings -> Golang Config -> Settings - Uesrs
```bash
{
    "PATH": "C:/Go/bin",
    "GOPATH": "C:/Go"
}
```

### windows keymap
 编辑Preferences -> Key Bindings
```
[
    // delete line
    { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Delete Line.sublime-macro"} },
    // newline
    { "keys": ["shift+enter"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Add Line.sublime-macro"} },
    // find
    { "keys": ["ctrl+f"], "command": "show_panel", "args": {"panel": "find", "reverse": false} },
    // find and replace
    { "keys": ["ctrl+h"], "command": "show_panel", "args": {"panel": "replace", "reverse": false} },
]
```

### sfpt配合focus_lost配置自动上传
1、切换程序时保存文件
```bash
# Preferences -> Settings添加save_on_focus_lost
"save_on_focus_lost": true
```
2、安装并配置sftp
2.1 安装sftp插件；
2.2 激活sftp插件：修改`C:\Users\datatom\AppData\Roaming\Sublime Text 3\Packages\SFTP`
```json
{
  	"debug": false,
    "email": "sftp@sftp.org",
    "product_key": "227fd9-891cd4-ea5e0b-70267b-916e36",
}
```

2.3 配置sftp配置文件：`sftp-config.json`
```json
{
    // The tab key will cycle through the settings when first created
    // Visit https://codexns.io/products/sftp_for_subime/settings for help
    
    // sftp, ftp or ftps
    "type": "sftp",

    "save_before_upload": true,
    "upload_on_save": true,
    "sync_down_on_open": false,
    "sync_skip_deletes": false,
    "sync_same_age": true,
    "confirm_downloads": false,
    "confirm_sync": true,
    "confirm_overwrite_newer": false,
    
    "host": "192.168.60.60",
    "user": "root",
    "password": "datatom2017",
    //"port": "22",
    
    "remote_path": "/data/ANewHope/linuxc/",
    "ignore_regexes": [
        "\\.sublime-(project|workspace)", "sftp-config(-alt\\d?)?\\.json",
        "sftp-settings\\.json", "/venv/", "\\.svn/", "\\.hg/", "\\.git/",
        "\\.bzr", "_darcs", "CVS", "\\.DS_Store", "Thumbs\\.db", "desktop\\.ini"
    ],
    //"file_permissions": "664",
    //"dir_permissions": "775",
    
    //"extra_list_connections": 0,

    "connect_timeout": 30,
    //"keepalive": 120,
    //"ftp_passive_mode": true,
    //"ftp_obey_passive_host": false,
    //"ssh_key_file": "~/.ssh/id_rsa",
    //"sftp_flags": ["-F", "/path/to/ssh_config"],
    
    //"preserve_modification_times": false,
    //"remote_time_offset_in_hours": 0,
    //"remote_encoding": "utf-8",
    //"remote_locale": "C",
    //"allow_config_upload": false,
}
```

