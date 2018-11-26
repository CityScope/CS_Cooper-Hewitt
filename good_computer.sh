#! /usr/bin/env bash

# get rid of any tmux sessions
tmux kill-server

clear

echo " ██████╗██╗████████╗██╗   ██╗███████╗ ██████╗██╗███████╗███╗   ██╗ ██████╗███████╗"
echo "██╔════╝██║╚══██╔══╝╚██╗ ██╔╝██╔════╝██╔════╝██║██╔════╝████╗  ██║██╔════╝██╔════╝"
echo "██║     ██║   ██║    ╚████╔╝ ███████╗██║     ██║█████╗  ██╔██╗ ██║██║     █████╗  "
echo "██║     ██║   ██║     ╚██╔╝  ╚════██║██║     ██║██╔══╝  ██║╚██╗██║██║     ██╔══╝  "
echo "╚██████╗██║   ██║      ██║   ███████║╚██████╗██║███████╗██║ ╚████║╚██████╗███████╗"
echo " ╚═════╝╚═╝   ╚═╝      ╚═╝   ╚══════╝ ╚═════╝╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝"

sleep 10

echo "--------------------------------------------------------------------------"

echo -ne "auto reboot script running                                            "\\r
sleep 10
echo -ne "waiting for 3min to warm up computer                                  "\\r
sleep 10
echo -ne "after this script, you will have two tmux sessions running            "\\r
sleep 10
echo -ne "access the processes by 'tmux a -t simulation' and 'tmux a -t scanner'"\\r
sleep 10
echo -ne "to detach the session, you need to hit Ctrl-b, d                      "\\r
sleep 10
echo -ne "two minutes left for simulation to start...."\\r
sleep 120
echo -ne ""

echo -ne "starting simulation                                                   "\\r
tmux new-session -d -s simulation 'processing-java --sketch=/Users/cityscience/Documents/GitHub/CS_Cooper-Hewitt/ABMobility --run'
echo -ne "simulation started                                                    "\\r
sleep 60
echo -ne "starting scanner                                                      "\\r
tmux new-session -d -s scanner 'python3 /Users/cityscience/Documents/GitHub/CityScope_Scanner_Python/scanner/scanner.py'
echo -ne "scanner started                                                       "\\r

clear

echo "bye have a nice day"
