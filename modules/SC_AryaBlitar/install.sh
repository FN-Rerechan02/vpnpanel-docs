#!/bin/bash

source_code="GegeDevs/vpnpanel-docs"
module_name="SC_AryaBlitar"
bin_dir="/etc/gegevps/bin"

if [[ "$EUID" -ne 0 ]]; then
    echo "The script must be run as root." >&2
    exit 1
fi

function link_gen(){
    dl_link="https://raw.githubusercontent.com/${source_code}/refs/heads/main/modules/${module_name}/telegram-${1}-${2}.sh"
    echo "${dl_link}"
}

function install_sh(){
    full_link="$(link_gen ${1} ${2})"
    file_name="$(echo "${full_link}" | rev | cut -d'/' -f 1 | rev)"
    wget -qO "${bin_dir}/${file_name}" "${full_link}"
    chmod +x "${bin_dir}/${file_name}"
}

function tunnels_list(){
    echo "
        sshvpn
        vmess
        vless
        ssocks
    " | sed 's/^[ \t]*//g;/^$/d'
}

function actions_list(){
    echo "
        create
        extend
    " | sed 's/^[ \t]*//g;/^$/d'
}

tunnels_list | while read -r tunnel; do
    if [[ ! -d "${bin_dir}" ]]; then
        mkdir -p "${bin_dir}"
    fi
    actions_list | while read -r action; do
        install_sh "${tunnel}" "${action}"
    done
done

echo "Module ${module_name} installed successfully."
