#!/usr/bin/env bash
# bash completion for remocon
# Usage: source remocon-completion.bash
# Requires: bash-completion 2+
##
#   Copyright 2018 Jaeho Shin
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
##

# If there is no ssh completion, but we have the _completion loader try to load it
if ! declare -F _scp_remote_files > /dev/null && declare -F _completion_loader > /dev/null; then
  _completion_loader scp
fi
__remocon_init_completion() {
    COMPREPLY=()
    _get_comp_words_by_ref cur prev words cword
}
__remocon_remote_files() {
    remote_workdir=$(remocon remote_workdir)
    remote_prefix=${remote_workdir#*:}
    cur="$remote_workdir$cur"; _scp_remote_files; cur=${cur#$remote_workdir}
    reply=(); for c in "${COMPREPLY[@]}"; do reply+=("${c#$remote_prefix}"); done; COMPREPLY=("${reply[@]}")
    compopt -o nospace
}
_remocon() {
    local cur prev words cword;
    if declare -F _init_completion &>/dev/null; then
        _init_completion
    else
        __remocon_init_completion
    fi
    case $cword in
        (1)
            COMPREPLY=($(compgen -W "$(
                printf '%s\n' \
                    set \
                    put \
                    run \
                    get \
                    prg \
                    rec \
                    #
                )" -- ${cur}))
                ;;
        (*)
            case ${COMP_WORDS[1]} in
                (set) # ssh_host:dir
                    [[ $cword -eq 2 ]] || return
                    case $cur in
                        (*:*)
                            _scp_remote_files -d
                            ;;
                        (*)
                            _known_hosts_real -a "$cur"
                    esac
                    compopt -o nospace
                    ;;
                (run|rec) : # command arg...
                    _command_offset 2
                    ;;
                (get) : # remote_path...
                    __remocon_remote_files
                    ;;
                (prg) # remote_path... -- command arg...
                    for (( i=1; i <= COMP_CWORD; i++ )); do
                        case "${COMP_WORDS[i]}" in
                            (--)
                                offset=$i
                                let ++offset
                                _command_offset "$offset"
                                return
                        esac
                    done
                    #COMPREPLY+=("-- ")  # XXX disabling as this interferes normal remote file name completion somehow
                    __remocon_remote_files
                    ;;
                (put|*) # XXX end of args or unrecognized command COMPREPLY=()
            esac
        esac
}
complete -F _remocon remocon
