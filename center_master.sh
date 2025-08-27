#!/bin/sh
# Dynamic Center Master Layout for bspwm
# Mestre central, janelas adicionais divididas em colunas laterais

arrange() {
    # pega todas as janelas no desktop ativo
    nodes=$(bspc query -N -n .window.local)
    count=$(echo "$nodes" | wc -l)

    [ $count -eq 0 ] && return

    master=$(echo "$nodes" | head -n1)
    stack=$(echo "$nodes" | tail -n +2)

    # limpa árvore
    bspc node @/ -C

    # só uma janela -> vira master no centro
    if [ $count -eq 1 ]; then
        bspc node "$master" -R 0.7
        return
    fi

    # coloca a master no centro com mais espaço
    bspc node "$master" -R 0.6

    left_side=true
    for n in $stack; do
        if $left_side; then
            bspc node "$master" -p west -n "$n"
        else
            bspc node "$master" -p east -n "$n"
        fi
        left_side=!$left_side
    done
}

# modo 1: se rodar uma vez, organiza só no momento
if [ "$1" = "once" ]; then
    arrange
    exit 0
fi

# modo 2: ficar monitorando eventos do bspwm
bspc subscribe node_add node_remove | while read -r _; do
    arrange
done
