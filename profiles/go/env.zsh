# Go (profile: go)
export GOPATH="$HOME/go"
case ":${PATH}:" in *:"$GOPATH/bin":*) ;; *) export PATH="$GOPATH/bin:$PATH" ;; esac
