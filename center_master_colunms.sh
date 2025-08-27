#!/bin/sh
# Dynamic Centered Master Layout (com colunas fixas)
# 1 janela = mestre central ocupando 70%
# Mais janelas = mestre central (70%) + colunas laterais

arrange() {
    # pega todas as janelas do desktop atual
    nodes=$(bspc query -N -n .window.local)
    count=$(echo "$nodes" | wc -l)

    [ $count -eq 0 ] && return

    master=$(echo "$nodes" | head -n1)
    stack=$(echo "$nodes" | tail -n +2)

    # limpa árvore atual
    bspc node @/ -C

    # sempre centraliza a master com 70%
    bspc node "$master" -R 0.7

    # se tiver só a master, acabou
    [ $count -eq 1 ] && return

    left_done=false
    right_done=false

    for n in $stack; do
        if [ "$left_done" = false ]; then
            # primeira janela: cria coluna esquerda
            bspc node "$master" -p west -n "$n"
            left_root=$n
            left_done=true
        elif [ "$right_done" = false ]; then
            # segunda janela: cria coluna direita
            bspc node "$master" -p east -n "$n"
            right_root=$n
            right_done=true
        else
            # distribui balanceado entre esquerda e direita
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

# modo 1: rodar só uma vez (manual)
if [ "$1" = "once" ]; then
    arrange
    exit 0
fi

# modo 2: ficar monitorando eventos (automático)
bspc subscribe node_add node_remove | while read -r _; do
    arrange
done
