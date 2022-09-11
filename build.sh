#!/bin/sh

# 自动扫描项目中的markdown文件，并生成book.toml、SUMMARY.md，
# 用于mdbook转换成HTML文件
# 心得：
# 1、`$basename`这种写法较`${basename}`更简单、更快速

PROJECTDIR="/opt/gitee/css-tutorial"
# basename命令获取路径中的文件名，-s选项移除文件名的后缀
# basename include/stdio.h .h     -> "stdio"
# basename -s .h include/stdio.h  -> "stdio"
PROJECTNAME=$(basename "${PROJECTDIR}")
DOCDIR="${PROJECTDIR}/docs"

# echo -e 解释\t、\n
# -n 取消末尾换行
echo -e "Project Dir:\t${PROJECTDIR}"
echo -e "Project Name:\t${PROJECTNAME}"
echo -e "Project Docs:\t${DOCDIR}"

SUMMARYFILE="${PROJECTDIR}/SUMMARY.md"
TOMLFILE="${PROJECTDIR}/book.toml"

# 将「文件路径」转换成「markdown的链接」
function to_markdown_link() {
    local fpath="$1"
    local isindent="$2"
    local fname=$(basename "$fpath" .md)
    local item=""

    # 绝对路径转成相对路径
    fpath=$(realpath --relative-to="$PROJECTDIR" "$fpath")

    if [ "$isindent" = true ]; then # base可以直接使用true/false
        item+="    "
    fi
    item+="- [$fname]($fpath)\n"

    # 这里不能加-e
    echo -n "$item" # return只能返回数字类型
}

# 迭代DOCDIR目录下的md文件。这里的文件分为两类
# 1、xx.md
# 2、chapterx/xxx.md
SUMMARYCONTENT=""
SUMMARYCONTENT+="目录\n\n"
CHAPTERS=()

# 处理第一种情况。并将章节目录保存到数组中
for fpath in "$DOCDIR"/*; do
    if [ -d "$fpath" ]; then
        CHAPTERS+=("$fpath")
    elif [[ -f "$fpath" && "$fpath" = *.md ]]; then
        SUMMARYCONTENT+=$(to_markdown_link $fpath false)
    fi
done

# 处理第二种情况。遍历所有章节
for chapter in "${CHAPTERS[@]}"; do
    chaptername=$(basename "$chapter")
    SUMMARYCONTENT+="\n# $chaptername\n"

    for fpath in "$chapter"/*.md; do
        SUMMARYCONTENT+=$(to_markdown_link $fpath true)
    done
done

echo -e ${SUMMARYCONTENT} > "${SUMMARYFILE}"
