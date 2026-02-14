

if grep -q microsoft /proc/version; then
    export IN_WSL=1
else
    export IN_WSL=
fi


