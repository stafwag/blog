# sed -e 's/\({% *img *.*[^ ]*\) \(\/images\/[^ ]*\)\( .*}\)/\1 \/blog\2\3/g' -i *.markdown
# sed -e 's/\(<a href="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
# sed -e 's/\(<img src="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
sed -e "s/{% img *\([^ ]*\) \/blog\/\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src=\"{{ '\/\2'  | relative_url }}\" class=\"\1\" width=\"\3\" height=\"\4\" alt=\5 \/>/g" -i *.markdown 
sed -e 's/{% img *\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src="\2" class=\"\1\" width=\"\3\" height=\"\4\" alt=\"\5\" \/>/g' -i *.markdown 
