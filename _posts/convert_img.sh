# sed -e 's/\({% *img *.*[^ ]*\) \(\/images\/[^ ]*\)\( .*}\)/\1 \/blog\2\3/g' -i *.markdown
# sed -e 's/\(<a href="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
# sed -e 's/\(<img src="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
# sed -e "s/{% img \(\/images\/[^ ]*\) *\([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src=\"{{ '\1' | relative_url }}\" width=\"\2\" height=\"\3\" alt=\4 \/> /" -i 2018-07-01-migrate-a-windows-vmware-vrtual-machine-to-kvm.markdown
# sed -e "s/{% img *\([^ ]*\) \/blog\/\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src=\"{{ '\/\2'  | relative_url }}\" class=\"\1\" width=\"\3\" height=\"\4\" alt=\5 \/>/g" -i *.markdown 
# sed -e "s/{% img *\([^ ]*\) \/blog\/\([^ ]*\) .*%}/<img src=\"{{ '\/\2'  | relative_url }}\" class=\"\1\" \/>/g"  -i *.markdown 
# sed -e "s/{%.*img *\([^ ]*\) \/blog\/\([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src=\"{{ '\/\2'  | relative_url }}\" class=\"\1\" width=\"\3\" height=\"\4\" \/>/g" -i *.markdown 
# sed -e 's/{% img *\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\).*%}/<img src="\2" class=\"\1\" width=\"\3\" height=\"\4\" alt=\"\5\" \/>/g' -i *.markdown 
# sed -e "s!\(<img src=\"\)/blog\(/[^\"]*\)\"!\1{{ '\2' | relative_url }}\"!g" -i *.markdown
# sed -e "s!\(<a href=\"\)/blog\(/[^\"]*\)\"!\1{{ '\2' | relative_url }}\"!g" -i *.markdown
# sed -e 's!\(<img.* alt="[^"]*\) !\1"!g' -i *.markdown
sed -e 's/ | relative_url }}/ | absolute_url }}/' -i *.markdown
