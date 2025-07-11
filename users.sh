#!/bin/bash

INPUT=/tmp/input.$$ 
OUTPUT=/tmp/output.$$

add_user() {
    dialog --inputbox "Enter username to add:" 8 40 2>"$INPUT"
    username=$(<"$INPUT")

    if [ -z "$username" ]; then
        dialog --msgbox "Username cannot be empty." 6 40
        return
    fi

    if id "$username" &>/dev/null; then
        dialog --msgbox "User '$username' already exists." 6 40
    else
        sudo useradd -m "$username"
        dialog --msgbox "User '$username' added successfully." 6 40
    fi
}

delete_user() {
    # Step 1: List users with UID ≥ 1000
    awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1, "-"}' /etc/passwd > "$INPUT"
    dialog --menu "Select user to delete:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    username=$(<"$INPUT")

    if [ -z "$username" ]; then
        dialog --msgbox "No user selected." 6 40
        return
    fi

    # Step 2: Confirm deletion
    dialog --yesno "Are you sure you want to delete user '$username'?" 7 50
    if [ $? -eq 0 ]; then
        sudo userdel -r "$username"
        dialog --msgbox "User '$username' deleted." 6 40
    else
        dialog --msgbox "Deletion cancelled." 6 40
    fi
}

list_users() {
    awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1}' /etc/passwd > "$INPUT"
    dialog --textbox "$INPUT" 20 50
}

modify_user() {
    # Step 1: Select user
    awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1 " -"}' /etc/passwd > "$INPUT"
    dialog --menu "Select user to modify:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    selected_user=$(<"$INPUT")

    if [ -z "$selected_user" ]; then
        dialog --msgbox "No user selected." 6 40
        return
    fi

    # Step 2: Enter new username 
    dialog --inputbox "Enter new username or leave blank to keep '$selected_user':" 8 60 2>"$INPUT"
    new_username=$(<"$INPUT")

    if [[ -n "$new_username" && "$new_username" != "$selected_user" ]]; then
        sudo usermod -l "$new_username" "$selected_user"
        dialog --msgbox "Username changed from '$selected_user' to '$new_username'" 6 60
    else
        dialog --msgbox "Username unchanged." 6 40
    fi
}


change_password() {
    awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1, "-"}' /etc/passwd > "$INPUT"
    dialog --menu "Select user to change password:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    username=$(<"$INPUT")

    if [ -z "$username" ]; then
        dialog --msgbox "No user selected." 6 40
        return
    fi

    sudo passwd "$username"
    dialog --msgbox "Password changed for '$username'." 6 50
}


lock_user() {
    awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1, "-"}' /etc/passwd > "$INPUT"
    dialog --menu "Select user to lock:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    username=$(<"$INPUT")

    if [ -z "$username" ]; then
        dialog --msgbox "No user selected." 6 40
        return
    fi

    sudo usermod -L "$username"
    dialog --msgbox "User '$username' has been locked." 6 50
}


unlock_user() {
    awk -F: '($2 ~ /^!/) && ($1 !~ /^nobody$/) {print $1, "-"}' /etc/shadow > "$INPUT"

    if [ ! -s "$INPUT" ]; then
        dialog --msgbox "No locked users found." 6 40
        return
    fi

    dialog --menu "Select locked user to unlock:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    username=$(<"$INPUT")

    if [ -z "$username" ]; then
        dialog --msgbox "No user selected." 6 40
        return
    fi

    sudo usermod -U "$username"
    dialog --msgbox "User '$username' has been unlocked." 6 50
}
