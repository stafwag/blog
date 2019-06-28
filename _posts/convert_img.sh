sed -e 's/\({% *img *.*[^ ]*\) \(\/images\/[^ ]*\)\( .*}\)/\1 \/blog\2\3/g' -i *.markdown
sed -e 's/\(<a href="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
sed -e 's/\(<img src="\)\(\/images\)/\1\/blog\2/g' -i *.markdown
