

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


	function deb(){
		if [ -n "$DEBUG" ];then
			echo -en $debug
			for ((i=0; i<${#BASH_SOURCE[@]}; i++)); do
				echo -n " "
			done		
			echo -e $@$plain >&2
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
                deb ${f##*/}:$rlno "'$yellow"${ln#*dbv }"$green'" = "'$cyan""$@""$green'"
            else
                deb ${f##*/}:$rlno $cyan$@
            fi
        else
            deb ${f##*/}:$lno $cyan$@
        fi
	fi
}

