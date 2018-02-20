# Fake Follower Finder
Find fake followers on Twitter and get rid of 'em!

## Fake Follower Classes:
- There are robots on twitter, which follow many of people, in order to gather data.
- There are accounts that their last tweet belongs to many days ago. In act, they're inactive accounts.
- There are accounts that are protected, But they are following you.
- There are accounts, which their owner hasn't written any tweets.
- There are people that following many other people and they don't really care about what you are tweeting.<br/>
...
## What does this script do for you?
This script helps you get rid of such accounts.<br/>
It chooses the followers from <b>GROUPIES:`the accounts which follows you, but you don't follow them back`</b>.

You can simply choose one or more class of Fake Followers and choose a method to deal with them.
The methods are:
1. `Block-Unblock`: The user can keep communicating with you, like they have never started following you.
2. `Block`: Simply Blocks those accounts.

This script is based on t, the Twitter CLI: https://github.com/sferik/t <br/>
Please read its documents from its github page in above link.<br/>

## Requirements:
You should have `rubygems` and `ruby-dev` and `build-essential` packages installed on your system in order that the `gem` command works correctly.<br/> You should then install <b>t</b> by running:<br/>
<code>gem install t</code><br/>
Also you need that the packages `dateutils` and `bsdmainutils` are installed, for script functionality.

## To Do:
As it is mentioned in the script:
- Make this script accept parameters for each function and method
- Embed an auto-installation script, which could run on the major Linux distros: Debian, CentOS, Arch,...


Happy Blocking! 😉
