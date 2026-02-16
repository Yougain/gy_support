dbv(){
	if [ -n "$DEBUG" ];then
        if ! declare -f emerge_file_content > /dev/null; then
            error="\033[41m\033[33mERROR    :\033[m \033[31m"
            warning="\033[43m\033[31mWARNING:\033[m \033[33m"
            info="\033[46m\033[34mINFO     :\033[m \033[36m"
            debug="\033[42m\033[34mDEBUG     :\033[m \033[32m"
            plain="\033[m"
            normal="\033[m"
            green="\033[32m"
            yellow="\033[33m"
            cyan="\033[36m"

            function deb(){
                if [ -n "$DEBUG" ];then
                    echo -en $debug
                    for ((i=0; i<${#BASH_SOURCE[@]}; i++)); do
                        echo -n " "
                    done		
                    echo -e $@$plain >&2
                fi
            }


            declare -A SCRIPT_FILES


            emerge_file_content(){
                local f="`readlink -f $1`"
                local sid
                if [ -e "$f" ];then
                    if [ -z "${SCRIPT_FILES[$f]}" ];then
                        sid=SCRIPT_FILE_$RANDOM$RANDOM$RANDOM
                        #dbv $sid
                        SCRIPT_FILES["$f"]=$sid
                        local ln
                        eval "
                            $sid=()
                            local i=0
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
        fi
		local position
		local caption
		if [ "$1" = "--position" ];then
			shift
			position="$1"
			shift
			if [ "$1" = "--caption" ];then
				shift
				caption="$1"
				shift
			fi
			if [ -n "$caption" ] && [[ $caption =~ \`|\$|\(\( ]] ;then
				deb $position "'$yellow"$caption"$green'" = "'$cyan""$@""$green'"
			else
				deb $position $cyan$@
			fi
		else
			local IFS=" "
			local frame=(`caller 0`)
			local f="`readlink -f ${frame[2]}`"
			local lno="${frame[0]}"
			local ln
			local sid
			if [ -n "$SSH_ID" ];then
				local tdir="$SCRIPT_TMP_DIR/$SSH_ID/file_transferred/"
				local tdsz=${#tdir}
				if [ "$f" = "$SCRIPT_TMP_DIR/$SSH_ID/do_content" -o "$f" = "$SCRIPT_TMP_DIR/$SSH_ID/env" -o "$f" = "$SCRIPT_TMP_DIR/$SSH_ID/main" ];then
					if [ -z "${SCRIPT_FILES[$f]}" ];then
						sid=__ssh_dbv_sid__${f##*/}$SSH_ID$RANDOM
						SCRIPT_FILES["$f"]=$sid
						local line_conv
						eval "
							$sid=()
							local i=0
							local IFS=
							while read -r ln;do
								if [ \"\${ln:0:6}\" = \"#line \" -o \"\${ln:0:6}\" = \"#line	\" ];then
									line_conv=\"\$((i + 1)) \${ln:6}\"
								fi
								$sid+=(\"\$ln
			\")
								i=\$((i + 1))
							done < $f
						"
						if [ -n "$line_conv" ];then
							local difL=$(($(echo "$line_conv" | awk '{print $2}') - $(echo "$line_conv" | awk '{print $1}')))
							local altF=$(echo "$line_conv" | awk '{print $4}')
							eval "difL_$sid=$difL"
							eval "altF_$sid=$altF"
						fi
					fi
				elif [ "${f:0:$tdsz}" = "$SCRIPT_TMP_DIR/$SSH_ID/file_transferred/" ];then
					local s
					for s in ${!SCRIPT_FILES[@]}; do
						if [ "${s##*/}" = "${f##*/}" ];then
							sid=${SCRIPT_FILES[$s]}
							break
						fi
					done
				fi
			else
				emerge_file_content "$f"
				sid=${SCRIPT_FILES["$f"]}
			fi
			if [ -n "$sid" ];then
				local difL_sid=difL_$sid
				local rlno
				if [ -n "${!difL_sid}" ];then
					local difL=${!difL_sid}
					local altF_sid=altF_$sid
					rlno=$((lno + difL))
					f=${!altF_sid}
				else
					rlno=$lno
				fi
				ln="`eval 'echo -E ${'"$sid"'['"$((lno - 1))"']}'`"
				ln="${ln#*dbv }"
				ln="${ln%%;*}"
				if [[ $ln =~ ^(.*)[\ \
\	]+$ ]]; then
					ln="${BASH_REMATCH[1]}"
				fi
				if [[ $ln =~ \`|\$|\(\( ]] ;then
					deb ${f##*/}:$rlno "'$yellow"${ln#*dbv }"$green'" = "'$cyan""$@""$green'"
				else
					deb ${f##*/}:$rlno $cyan$@
				fi
			else
				deb ${f##*/}:$lno $cyan$@
			fi
		fi
	fi
}

