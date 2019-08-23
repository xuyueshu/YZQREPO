#!/bin/bash
##使用expect进行交互
/usr/bin/expect <<EOF
set timeout 10
spawn ssh root@116.62.109.76
expect "#" {send "cd ~\r"}
expect	"#" {send "mkdir you\r";}
expect	"#" {send "cd you && touch expect.txt\r"}

expect eof

EOF