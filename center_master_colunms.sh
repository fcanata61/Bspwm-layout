#!/bin/sh
# Dynamic Centered Master Layout (com colunas)
# 1 janela = mestre central
# Mais janelas = mestre central + colunas laterais verticais

arrange() {
    # lista janelas no desktop ativo
    nodes=$(bspc query -N -n .window.local)
    count=$(echo "$nodes" | wc -l)

    [ $count -eq 0 ] && return

    master=$(echo "$nodes" | head -n1)
    stack=$(echo "$nodes" | tail -n +2)

    # limpa a árvore
    bspc node @/ -C

    # só uma janela -> mestre central
    if [ $count -eq 1 ]; then
        bspc node "$master" -R 0.7
        return
    fi

    # coloca a master no centro (mais espaço)
    bspc node "$master" -R 0.6

    left_done=false
    right_done=false

    for n in $stack; do
        if [ "$left_done" = false ]; then
            # cria primeira janela na esquerda
            bspc node "$master" -p west -n "$n"
            left_root=$n
            left_done=true
        elif [ "$right_done" = false ]; then
            # cria primeira janela na direita
            bspc node "$master" -p east -n "$n"
            right_root=$n
            right_done=true
        else
            # adiciona alternadamente nas colunas
            if [ $(bspc query -N -n "$left_root" | wc -l) -le \
                 $(bspc query -N -n "$right_root" | wc -l) ]; then
                bspc node "$left_root" -p south -n "$n"
                left_root=$n
            else
                bspc node "$right_root" -p south -n "$n"
                right_root=$n
            fi
        fi
    done
}

# modo 1: rodar só uma vez
if [ "$1" = "once" ]; then
    arrange
    exit 0
fi

# modo 2: ficar monitorando eventos e manter layout
bspc subscribe node_add node_remove | while read -r _; do
    arrange
done
