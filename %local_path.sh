add_path_once() {
    local dir="$1"
    [ -d "$dir" ] || return 0

    case ":$PATH:" in
        *":$dir:"*)
            echo found
            ;;              # 既に含まれている
        *) PATH="$PATH:$dir"
            ;;     # 未登録なら追加（末尾）
    esac
}

add_path_once "$HOME/.local/bin"
add_path_once "/usr/local/bin"
export PATH

