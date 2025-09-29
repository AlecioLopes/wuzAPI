#!/data/data/com.termux/files/usr/bin/bash

ps aux | grep wuzapi | grep -v grep | awk '{print $2}' | xargs kill -9
