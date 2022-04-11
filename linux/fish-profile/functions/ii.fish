function ii
    set dir "$argv"
    [ -z "$argv" ] && set dir "."
    [ ! -d "$dir" ] && set dir $(dirname "$(which $dir)")

    if [ -e /mnt/c ]
        set dir "$(wslpath -w "$dir")"
    else if [ -e /c ]
        set dir "$(cygpath -w "$dir")"
    end
    echo "$dir"

    if [ -e /mnt/c ] || [ -e /c ]
        explorer.exe "$dir"
    else if [ "$(command -v xdg-open)" ]
        xdg-open "$dir"
    else
        echo "No command to open file"
        exit 1
    end
end
