# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"

upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
secs=$((${upSeconds}%60))
mins=$((${upSeconds}/60%60))
hours=$((${upSeconds}/3600%24))
days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

# get the load averages
read one five fifteen rest < /proc/loadavg

et=`(/sbin/ifconfig eth0  | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1)`
wl=`(/sbin/ifconfig wlan0 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1)`

echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.
  : .~.'~'.~. :   Uptime.............: ${UPTIME}
 ~ (   ) (   ) ~  Memory.............: `cat /proc/meminfo | grep MemFree | awk {'print $2'}`kB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}`kB (Total)
( : '~'.~.'~' : ) Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
 ~ .~ (   ) ~. ~  Running Processes..: `ps ax | wc -l | tr -d " "`
  (  : '~' :  )   IP Addresses.......: ${et} ${wl} and `wget -q -O - http://icanhazip.com/ | tail`
   '~ .~~~. ~'
       '~'
$(tput sgr0)"
