
is_wsl(){
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
}


get_multipass_path() {
    if [ $(is_wsl) == "true" ]; then
        echo "multipass.exe"
    else
        echo "multipass"
    fi
}

convert_path() {
    if [ $(is_wsl) == "true" ]; then
        echo $(wslpath -w $1)
    else
        echo $1
    fi
}