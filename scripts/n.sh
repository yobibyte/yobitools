url="$(xsel -b -o)"
content=$(w3m -dump -o display_link_number=1 $url)
echo -e "$url \n\n $content" | nvim

