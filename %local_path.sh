insert_path_once() {
    local dir="$1"
    [ -d "$dir" ] || return 0

    case ":$PATH:" in
        *":$dir:"*)
            ;;              # 既に含まれている
        *) PATH="$dir:$PATH"
            ;;     # 未登録なら追加（末尾）
    esac
}

insert_path_once "/usr/local/bin"
insert_path_once "$HOME/.local/bin"

remove_from_path() {
  target="$1"
  newpath=""
  oldifs=$IFS
  IFS=:
  for p in $PATH; do
    [ "$p" = "$target" ] && continue
    if [ -z "$newpath" ]; then
      newpath="$p"
    else
      newpath="$newpath:$p"
    fi
  done
  IFS=$oldifs
  PATH="$newpath"
  export PATH
}



export PATH

