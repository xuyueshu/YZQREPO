#!/bin/bash
##使用expect进行交互
expect <<EOF
set timeout -1
spawn ssh root@116.62.109.76
expect "#" {send "cd ~/you\r"}
expect "#" {send "env>expect.txt\r"}
expect "#" {send "cat expect.txt\r"}

interact
expect eof
EOF