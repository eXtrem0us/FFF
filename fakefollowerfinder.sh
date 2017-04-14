#!/bin/bash

# It is assumed that you have installed 't', the Twitter API CLI tool.
# If you haven't, please follow the instructions in page https://github.com/sferik/t
# It is recommended to install it by issuing the command:
#
#   gem install t
#
# For this purpose, on Debian based systems you need to install:
# - rubygems
# - ruby-dev
# - build-essential
#
# Also, these packages are needed for script functionality:
# - bsdmainutils
# - dateutils

#>>>>>>>>>>>
#>>Metrics<<
#<<<<<<<<<<<

# Uncomment below line, if you think who has exceeded following more than below number of accounts, is fake:
MaximumFollowings=3000

# Uncomment below line, if you think who has never tweeted (TweetCount=0) or has just few tweets, is fake:
TweetCount=0

# Uncomment below line, if you think who has not any tweets after some days, is fake:
InactiveDays=200

# There are users, who are protected and you don't follow them, but they do. Set below variable
# to "true" if you don't like them:
NoFozool="true"

#>>>>>>>>>>
#>>Method<<
#<<<<<<<<<<

# Please choose the method, how FFF would deal with the fake followers:
# 1: Block-Unblock:	Blocks and then Unblocks the list of fake followers. The user stops following
#			you without noticing. (Safe Method)
# 2: Just Block:	Blocks the User. The user would not have any interactions or conversations with
#			you. (Unsafe Method)
Method=1


#>>>>>>>>>>>>>>
#>>Do Stuffs!<<
#<<<<<<<<<<<<<<

# As you may know, Twitter API restricts normal user in the way they use it. Users should issue a limited
# number of queries to twitter per minutes. So, here is a variable which sets the delay (by seconds) between
# each query that be issued to twitter.
SmoothDelay=0

function CheckRequirements
{
#Checks, if dateutils is installed
    [ $(command -v dateutils.ddiff) ] && datediff=dateutils.ddiff
    [ $(command -v ddiff) ] && datediff=ddiff
    [ ! -v datediff ] && echo -e "Please install \e[96mdateutils\e[39m." && exit 1

    #Checks, if 't' is installed:
    [ -z $(command -v t) ] && echo -e "You have not installed \e[96mt\e[39m or proper \$PATH is not set to locate \e[96mt\e[39m" && exit 1

    #Checks, if 't' is configured. if you use -p parametter manually to locate the config file, comment below line:
    [ ! -f ~/.trc ] && echo -e "You have not configured \e[96mt\e[39m. Please run the command \e[96mt authorize\e[39m." && exit 1
}

function GatherGroupies
{
    #Gathering a list of followers whom you don't follow:
    echo -n > groupies.csv
    echo "Gathering information from the followers whom you don't follow. Please be patient..."
    for groupy in $(t groupies)
    do
	echo $groupy
	echo "$(t whois -c $groupy | tail -n +2 | tr -d '\n')" >> groupies.csv
	sleep $SmoothDelay
    done
    echo "Found $(wc -l < groupies.csv) Entries!"
}

function SpecifyExceeded
{
    [ ! -v MaximumFollowings ] && return 0
    echo -n > Exceeded.lst
    echo "Specifying the followers, who are following many accounts"
    while read -r groupy
    do
	temp=$(echo "$groupy"|cut -d, -f7)
	[ "$temp" -ge "$MaximumFollowings" ] && echo "$groupy" | cut -d, -f9 >> Exceeded.lst
    done < groupies.csv
    echo "Found $(wc -l < Exceeded.lst) Entries!"
}

function SpecifyNoInhabitant
{
    [ ! -v TweetCount ] && return 0
    echo -n > NoInhabitant.lst
    echo "Specifying the followers, who have few or no any tweets"
    while read -r groupy
    do
	temp="$(echo "$groupy"|cut -d, -f4)"
	[ "$temp" -le "$TweetCount" ] && echo "$groupy" | cut -d, -f9 >> NoInhabitant.lst
    done < groupies.csv
    echo "Found $(wc -l < NoInhabitant.lst) Entries!"
}

function SpecifyInactives
{
    [ ! -v InactiveDays ] && return 0
    echo -n > Inactives.lst
    echo "Specifying the users, who haven't been active in the last $InactiveDays days"
    while read -r groupy
    do
	temp=$(echo "$groupy"|cut -d, -f3|cut -d' ' -f1)
	if [ ! -z $temp ]
	then
	    tempdiff=$($datediff $temp today)
	    [ "$tempdiff" -ge "$InactiveDays" ] && echo "$groupy" | cut -d, -f9 >> Inactives.lst
	fi
    done < groupies.csv
    echo "Found $(wc -l < Inactives.lst) Entries!"
}

function SpecifyFozools
{
    [ "$NoFozool" != "true" ] && return 0
    echo -n > Fozools.lst
    echo "Specifying the users, whom are following you, but they're protected and you don't follow them"
    while read -r groupy
    do
	temp=$(echo "$groupy"|cut -d, -f12)
	[ "$temp" == "true" ] && echo "$groupy" | cut -d, -f9 >> Fozools.lst
    done < groupies.csv
    echo "Found $(wc -l < Fozools.lst) Entries!"
}

function GetUserAcknowledge
{
    if [ "$Method" -eq "1" ]
    then
	echo -e "\n\e[44mHere is the list of twitter id which would be Block-Unblocked!\e[49m\e[93m\n"
	elif [ "$Method" -eq "2" ]
	then
	    echo -e "\n\e[44mHere is the list of twitter id which would be Blocked!\e[49m\e[93m\n"
	else
	    echo -e "\n\e[44mUNDEFINED METHOD!\e[49m\e[93m\n"
	    exit 1
    fi
    cat *.lst | sort | uniq | column
    echo -e "\e[39m\nPress \e[41mEnter\e[49m to Start the process or \e[44mCtrl+C\e[49m to Abort..."
    read -p ''
}

function DoAction
{
    echo "Using method $Method"
    for groupy in $(cat *.lst|sort|uniq)
    do
	t block $groupy
	echo "Blocked $groupy"
	[ "$Method" -eq "1" ] && t delete block $groupy && echo "UnBlocked $groupy"
	sleep $SmoothDelay
    done
}

function Cleanup
{
    echo "Cleaning up..."
    lstfiles=$(ls *.lst | tr -d '\n')
    [ ! -z $lstfiles ] && rm *.lst && echo "Done!"
}


CheckRequirements
GatherGroupies
SpecifyExceeded
SpecifyNoInhabitant
SpecifyInactives
SpecifyFozools
GetUserAcknowledge
DoAction
Cleanup

 ######## 
## ToDo ##
#        ###################################################################################################
# Make this script accept parameters for each function and method                                          #
# Embed an auto-installation script, which could run on the major Linux distros: Debian, CentOS, Arch,...  #
#                                                                                                          #
# Written by @eXtrem0us                                                                                    #
############################################################################################################
