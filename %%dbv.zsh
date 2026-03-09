

declare -A SCRIPT_FILES


emerge_file_content(){
	local f="$1"
	local sid=
	if [ -e "$f" ];then
		if [ -z "${SCRIPT_FILES[$f]}" ];then
			sid=SCRIPT_FILE_$RANDOM$RANDOM$RANDOM
			#dbv $sid
			SCRIPT_FILES[$f]=$sid
			local ln
			eval "
				$sid=()
				local i=1
				local IFS=""
				while read -r ln;do
					$sid+=(\"\$ln
\")
					i=\$((i + 1))
				done < $f
			"
		else
			sid=${SCRIPT_FILES[$f]}
		fi
	fi
}



source_depth() {
	local -a ctx
	local c depth=0
	ctx=(${(s.:.)ZSH_EVAL_CONTEXT})

	for c in $ctx; do
		[[ $c == file ]] && ((depth++))
	done

	((depth--))          # 自分自身の file 分を引く
	((depth < 0)) && depth=0
	print -r -- "$depth"
}


preexec() {
	if [ "$1" = "." -o "$1" = "source" ]; then
		this_cmd="$1 $2"
	else
		this_cmd="$1"
	fi
}


deb(){
	if [ -n "$DEBUG" ];then
		local w=
		if [ "$DEBUG" = "l" -o "$DEBUG" = "L" ] && typeset -f require >/dev/null 2>&1;then
			if require -q viewer; then
				w=$(emerge_viewer)
			else
			    if [ -z "$VIEWER_FD" ]; then
					mkdir -p /tmp/log
			        exec {VIEWER_FD}>> "/tmp/log/$(basename $0).log"
    			fi
			    w=$VIEWER_FD				
			fi
		fi
		if [ -z "$w" ];then
			w=2
		fi
		echo -en `date +"%Y-%m-%d %H:%M:%S.%3N"` $this_cmd\[$$\] $debug >&$w
		printf '%*s' $(source_depth) '' >&$w
		echo -e $@$plain >&$w
	fi
}



dbv(){
	if [ -n "$DEBUG" ];then
		local position
		local caption
        local IFS=" "
        local f="${funcfiletrace[1]%:*}"
		local f="`readlink -f $f`"
        local lno="${funcfiletrace[1]##*:}"
        local ln=
        local sid=
        emerge_file_content "$f"
        sid=${SCRIPT_FILES[$f]}
        if [ -n "$sid" ];then
            local difL_sid=difL_$sid
            local rlno=$lno
            ln="`eval 'echo -E ${'"$sid"'['"$lno"']}'`"
            ln="${ln#*dbv }"
            ln="${ln%%;*}"
            ln="$(printf '%s' "$ln" | sed 's/[[:space:]]*$//')"
            if [[ "$ln" == *'`'* || "$ln" == *'$'* || "$ln" == *'(('* ]] ;then
                ln="$(printf '%s' "$ln" | sed 's/[[:space:]]*$//')"
                deb ${f##*/}:$rlno ${fg[yellow]}${ln#*dbv }${fg[green]} = "'"${fg[cyan]}"$@"${fg[green]}"'"$plain
            else
                deb ${f##*/}:$rlno ${fg[cyan]}$@$plain
            fi
        else
            deb ${f##*/}:$lno ${fg[cyan]}$@$plain
        fi
	fi
}

