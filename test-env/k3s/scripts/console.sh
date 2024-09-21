COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_NC='\033[0m' # No Color

STATIC_MENU_TYPE="static"
DYNAMIC_MENU_TYPE="dynamic"
BLANK_MENU_TYPE="blank"
DIVIDER_MENU_TYPE="divider"
HIDDEN_MENU_TYPE="hidden"

write-error() {
    echo -e "${COLOR_RED}ERROR: $1${COLOR_NC}"
    write_log "ERROR: $1"
}

write-warning() {
    echo -e "${COLOR_YELLOW}WARNING: $1${COLOR_NC}"
    write_log "WARNING: $1"
}

write-info() {
    echo "$1"
    write_log "$1"
}

write-success() {
    echo -e "${COLOR_GREEN}SUCCESS: $1${COLOR_NC}"
    write_log "SUCCESS: $1"
}

write-message() {
    echo "$1"
    write_log "$1"
}

write-debug() {
    if [[ $- == *x* ]]; then
        echo -e "${COLOR_YELLOW}DEBUG: $1${COLOR_NC}"
    fi
    write_log "DEBUG: $1"
}

write_log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >>"$log_file"
}

#https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
execute_menu() {
    local menuName=$1
    local -n __menu=$menuName

    add_default_menu_items $menuName

# draw a long blue line
    echo ""
    echo -e "\e[44m  Menu:                                                 \e[0m"
    echo ""

    while true; do # Menu Loop
        local selected_menu_item_name=""
        get_menu_selected_item $menuName selected_menu_item_name
        if [ $? -ne 0 ]; then
            write-error "Error while getting selected menu item"
            continue
        fi

        local -n selected_menu_item=$selected_menu_item_name
        write-info ""
        write-debug "$selected_menu_item_name"
        eval "${selected_menu_item[command]}"
    done # Menu Loop
}



declare -A clear_screen_menu_item=(
    [title]="Clear Screen"
    [command]="clear"
    [selectable]=false
    [hotkeys]="clear"
)
declare -A back_menu_item=(
    [title]="Go back (b, back)"
    [command]="return 0"
    [hotkeys]="b,back"
)

declare -A exit_menu_item=(
    [title]="Exit (q, quit)"
    [command]="exit 0"
    [hotkeys]="q,quit"
)

declare -A show_enviroment_menu_item=(
    [title]="Show Environment"
    [command]="cat .env"
    [selectable]=true
    [hotkeys]="env"
)

add_default_menu_items() {
    local menu_name=$1
    add_hidden_menu_item $menu_name clear_screen_menu_item
    add_hidden_menu_item $menu_name back_menu_item
    add_hidden_menu_item $menu_name exit_menu_item
    add_hidden_menu_item $menu_name show_enviroment_menu_item
    add_blank_menu_item $menu_name
}

# Retruns the name of the selected item in the menu
get_menu_selected_item() {
    local menu_name=$1
    local -n __menu=$menu_name
    local return_value_name=$2

    local visible_menu_items=()
    declare -A hotkeys=()

    # Build the menu
    # Loop through the menu items
    # For dynamic menus check if they should be used
    # Collect all the displayable itmes
    # while looping also collect all the hotkeys
    for menu_item_name in "${__menu[@]}"; do # Menu build loop

        local -n menu_item=$menu_item_name
        if [ ${menu_item[type]} == $DYNAMIC_MENU_TYPE ]; then
            local item_display_text=$(eval "${menu_item[title]}")
            if [ -z "${item_display_text}" ]; then
                continue
            fi
        else
            local item_display_text=${menu_item[title]}
        fi

        #If the menu item is not hidden, create display entry
        if [ ${menu_item[type]} != $HIDDEN_MENU_TYPE ]; then
            display_menu_itemName="${menuName}_${menu_item_name}_display"
            eval "declare -A $display_menu_itemName=()"
            local -n display_menu_item=$display_menu_itemName

            display_menu_item[title]=$item_display_text
            display_menu_item[selectable]=${menu_item[selectable]}
            display_menu_item[source_menu_item]=$menu_item_name

            visible_menu_items+=($display_menu_itemName)
        fi

        # Check for hotkeys
        IFS=',' read -r -a extracted_hotkeys <<<${menu_item[hotkeys]}
        for hotkey in "${extracted_hotkeys[@]}"; do # Hotkey Loop
            hotkeys[${hotkey}]=$menu_item_name
            #echo "Hotkey: $hotkey, Menu Item: $menu_item_name"
        done # Hotkey Loop
    done     # Menu build loop

    while true; do #display loop
        # call navigate_menu with the menu items and hotkeys and assing the selected option to selected_option
        local selected_option

        navigate_menu visible_menu_items selected_option

        if [ $? -ne 0 ]; then
            write-error "Error while navigating menu"
            continue
        fi
        #echo "Selected Option: $selected_option"

        local selected_source_menu_item_name=""
        # check to see if the selected option is not the visible menu items
        if [[ ! " ${visible_menu_items[@]} " =~ " ${selected_option} " ]]; then
            #try to assign it from the hotkeys
            selected_source_menu_item_name=${hotkeys[$selected_option]}
        else
            local -n selected_display_menu_item=$selected_option
            selected_source_menu_item_name=${selected_display_menu_item[source_menu_item]}
        fi

        if [ -z "$selected_source_menu_item_name" ]; then
            write-warning "Invalid selection"
            continue
        fi
        local -n return_value=$return_value_name
        return_value=$selected_source_menu_item_name
        return 0
    done #display loop
}

# Display the given menu and return the selected item
# Return value is stored in the return_value_name is either the selected item or command user typed in
navigate_menu() {
    local menu_name=$1
    local return_value_name=$2

    local -n __menu=$menu_name

    local cur=0
    local line_count=${#__menu[@]}
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    local buffer=""            # buffer for user input other than arrow keys
    ((line_count++))           # add one more line for the command line

    declare -A slectableItems=()

    while true; do #display and navigate menu loop
        selectablitems=()
        local selectable_index=-1 # assuming there is nothing selectable

        for menu_item_name in "${__menu[@]}"; do
            local -n menu_item=$menu_item_name

            if [ ${menu_item[selectable]} == true ]; then
                ((selectable_index++))
                selectableItems[$selectable_index]=$menu_item_name
            fi

            if [ "$cur" == "${selectable_index}" ] && [ ${menu_item[selectable]} == true ]; then
                echo -e " >\e[7m${menu_item[title]}\e[0m" # mark & highlight the current option
            else
                echo "  ${menu_item[title]}" # normal option
            fi
        done

        # Clear the line at cursor
        echo -en "\e[K"
        echo "command: $buffer"

        read -s -n1 key # wait for user to press a key

        # check for navigation keys
        if [[ $key == $esc ]]; then
            buffer=$key
            read -s -n2 -t 0.1 key # read 2 more chars
            buffer+=$key

            if [[ $buffer == $esc[A ]]; then # up arrow
                ((cur--))
                ((cur < 0)) && ((cur = 0))
            elif [[ $buffer == $esc[B ]]; then # down arrow
                ((cur++))
                ((cur >= selectable_index)) && ((cur = selectable_index))
            elif [[ $buffer == $esc ]]; then # escape clear the buffer
                buffer=""
            fi
            buffer=""
        elif [[ $key == "" ]]; then # enter key
            break
        else
            buffer+=$key
        fi
        echo -en "\e[${line_count}A" # go up to the beginning to re-render
    done                             #display and navigate menu loop

    local -n return_value=$return_value_name
    return_value=""

    if [ -z "$buffer" ]; then
        return_value=${selectableItems[$cur]}
        return 0
    else
        return_value=$buffer
        return 0
    fi
}

add_menu_item() {
    __add_menu_item "$STATIC_MENU_TYPE" true "$@"
}

add_dynamic_menu_item() {
    __add_menu_item "$DYNAMIC_MENU_TYPE" true "$@"
}

add_hidden_menu_item() {
    __add_menu_item "$HIDDEN_MENU_TYPE" false "$@"
}

declare -A BLANK_MENU_ITEM=(
    [type]=$BLANK_MENU_TYPE
    [selectable]=false
    [title]=""
    [command]="")
add_blank_menu_item() {
    local -n __menu=$1
    __menu+=(BLANK_MENU_ITEM)
}

declare -A DIVIDER_MENU_ITEM=(
    [type]=$DIVIDER_MENU_TYPE
    [selectable]=false
    [title]="--------------------------------------------"
    [command]="")

add_divider_menu_item() {
    local -n __menu=$1
    __menu+=(DIVIDER_MENU_ITEM)
}

__add_menu_item() {
    local menu_type=$1
    shift
    local selectable=$1
    shift
    local parent_menu_name=$1
    local menu_item_name=$2

    local -n __parent_menu=$parent_menu_name
    local -n __menu_item=$menu_item_name

    __parent_menu+=("$menu_item_name")
    __menu_item[type]="$menu_type"
    __menu_item[selectable]=$selectable
}
