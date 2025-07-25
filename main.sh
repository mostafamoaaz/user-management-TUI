#!/bin/bash

# Check if dialog is installed
if ! command -v dialog &>/dev/null; then
    echo "dialog is required but not installed. Install it with: sudo apt install dialog"
    exit 1
fi

# Source the logic files
source ./users.sh
source ./groups.sh
# (Later) source ./validations.sh

# Group management submenu
group_menu() {
    while true; do
        user_choice=$(dialog --clear --backtitle "Group Manager TUI" \
            --title "Group Management" \
            --menu "Choose a group option:" 15 50 6 \
            1 "Add Group" \
            2 "Delete Group" \
            3 "List Groups" \
            4 "Modify Group" \
            0 "Back to Main Menu" \
            2>&1 > /dev/tty)

        case "$user_choice" in
            1) add_group ;;
            2) delete_group ;;
            3) list_groups ;;
            4) modify_group ;;
            0) break ;;
            *) break ;;
        esac
    done
}
# User management submenu
user_menu(){
    while true; do
        user_choice=$(dialog --clear --backtitle "User Manager TUI" \
            --title "User Management" \
            --menu "Choose a user option:" 15 50 6 \
            1 "Add User" \
            2 "Delete User" \
            3 "List Users" \
            4 "Modify User" \
            5 "Change Password" \
            6 "Lock User" \
            7 "Unlock User" \
            0 "Back to Main Menu" \
            2>&1 > /dev/tty)

        case "$user_choice" in
            1) add_user ;;
            2) delete_user ;;
            3) list_users ;;
            4) modify_user ;;
            5) change_password ;;
            6) lock_user ;;
            7) unlock_user ;;
            0) break ;;
            *) break ;;
        esac
    done
}
# Main menu
main_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "User Manager TUI" \
            --title "Main Menu" \
            --menu "Choose an option:" 15 50 6 \
            1 "User Management" \
            2 "Group Management" \
            0 "Exit" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) user_menu ;;
            2) group_menu ;;
            0) break ;;
            *) break ;;
        esac
    done
    clear
}

# Run the menu
main_menu

# Clean up
rm -f /tmp/input.*
