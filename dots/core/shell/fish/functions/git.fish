# WSL: Windows' git.exe is ~20x faster than Linux git on /mnt/* (Windows filesystem).
function git --wraps git
    if string match -q '/mnt/*' -- $PWD; and command -q git.exe
        git.exe $argv
    else
        command git $argv
    end
end
