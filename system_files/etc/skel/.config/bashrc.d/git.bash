alias g='git'

alias ga='git add'
alias ga.='git add .'
alias gac='git add . && gc'
alias gacm='git add . && gcm'

alias gb='git branch'
alias gbd='git branch -d'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcam='git commit --amend -m'

alias gch='git checkout'
alias gchb='git checkout -b'

alias gcl='git config list'

alias gd='git diff'
alias gds='git diff --staged'

alias gf='git fetch'
alias gfa='git fetch --all'

alias gl='git --no-pager log --oneline --graph --decorate --all'
alias glo='git --no-pager log --oneline --graph --decorate --all origin..HEAD'

alias gpo='git push origin'
alias gpt='git push origin --tags'

alias gpu='git pull origin'
alias gpr='git pull --rebase'

alias grb='git rebase'
alias grbi='git rebase -i'

alias gs='git status'
alias gss='git status -s'

alias gsh='git stash'
alias gsp='git stash pop'
alias gsd='git stash drop'

alias gsw='git switch'
alias gswc='git switch -c'

alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'