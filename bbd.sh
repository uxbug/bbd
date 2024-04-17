# 配置镜像站地址
mirror_url="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/"

# 搜索 bottles
search_results=$(curl -k -s "$mirror_url" | grep -E "href=\"($1.*\.bottle.*\.tar\.gz)\"" | sed 's/.*href="\([^"]*\)".*/\1/')

# 检查搜索结果
if [ -z "$search_results" ]; then
  echo "错误: 找不到 $1 的 bottle"
  exit 1
fi

# 显示搜索结果并选择
echo "找到以下 bottles:"
i=1
for result in $search_results; do
  echo "$i) $result"
  i=$((i+1))
done

# 获取用户选择
read -p "请选择要下载的 bottle (默认 1): " choice
choice=${choice:-1}

# 检查选择是否有效
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$i" ]; then
  echo "错误: 无效的选择"
  exit 1
fi

# 获取下载链接
download_url="$mirror_url$(echo "$search_results" | sed -n "$choice p")"

# 下载 bottle
echo "正在下载 $download_url..."
curl -k -L -o "$(basename "$download_url")" "$download_url"

echo "下载完成: $(basename "$download_url")"
