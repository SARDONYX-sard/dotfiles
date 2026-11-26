function git_prune_trackings --description 'delete local branches whose upstream is gone'
    git fetch --prune; or return
    git for-each-ref --format '%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)' refs/heads \
        | string match -rv '^$' | xargs -r git branch -d
end
