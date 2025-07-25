#!/bin/bash

INPUT=/tmp/input.$$

add_group() {
    dialog --inputbox "Enter group name to add:" 8 40 2>"$INPUT"
    groupname=$(<"$INPUT")

    if [ -z "$groupname" ]; then
        dialog --msgbox "Group name cannot be empty." 6 40
        return
    fi

    if getent group "$groupname" > /dev/null; then
        dialog --msgbox "Group '$groupname' already exists." 6 40
    else
        sudo groupadd "$groupname"
        dialog --msgbox "Group '$groupname' added successfully." 6 40
    fi
}

delete_group() {
    
    awk -F: '$3 >= 1000 {print $1, "-"}' /etc/group > "$INPUT"
    dialog --menu "Select group to delete:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    groupname=$(<"$INPUT")

    if [ -z "$groupname" ]; then
        dialog --msgbox "No group selected." 6 40
        return
    fi

    dialog --yesno "Are you sure you want to delete group '$groupname'?" 7 50
    response=$?
    if [ $response -eq 0 ]; then
        sudo groupdel "$groupname"
        dialog --msgbox "Group '$groupname' deleted." 6 40
    else
        dialog --msgbox "Deletion cancelled." 6 40
    fi
}

list_groups() {
    awk -F: '$3 >= 1000 {print $1}' /etc/group > "$INPUT"
    dialog --textbox "$INPUT" 20 50
}


modify_group() {

    awk -F: '$3 >= 1000 {print $1, "-"}' /etc/group > "$INPUT"
    dialog --menu "Select group to rename:" 20 50 10 $(cat "$INPUT") 2>"$INPUT"
    selected_group=$(<"$INPUT")

    if [ -z "$selected_group" ]; then
        dialog --msgbox "No group selected." 6 40
        return
    fi

    dialog --inputbox "Enter new name for group '$selected_group':" 8 60 2>"$INPUT"
    new_groupname=$(<"$INPUT")

    if [ -z "$new_groupname" ]; then
        dialog --msgbox "Group name cannot be empty." 6 40
        return
    fi

    if getent group "$new_groupname" &>/dev/null; then
        dialog --msgbox "Group '$new_groupname' already exists." 6 50
    else
        sudo groupmod -n "$new_groupname" "$selected_group"
        dialog --msgbox "Group renamed to '$new_groupname'." 6 40
    fi
}
