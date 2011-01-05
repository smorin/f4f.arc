#!/bin/sh

if [ "x$F4F_HOME" == "x" ] ; then
  F4F_HOME=~/code/f4f.arc
fi

if [ "x$F4F_ARCH" == "x" ] ; then
  F4F_ARCH=`uname`
fi

if [ "x$F4F_ARCH" == "xLinux" ] ; then
  F4F_RACKET_HOME=racket-5.0.2-bin-x86_64-linux-f7
elif [ "x$F4F_ARCH" == "xDarwin" ] ; then
  F4F_RACKET_HOME=racket-5-0-2-bin-i386-osx-mac-dmg
else 
  echo "Your os isn't recognized by the script:"`uname`"exiting"
  exit 1
fi

ARC_HOME=arc3.1

alias mzscheme=${F4F_HOME}'/'${F4F_RACKET_HOME}'/bin/mzscheme'
alias arc='pushd '${F4F_HOME}'/'${ARC_HOME}'/ > /dev/null; mzscheme -f as.scm; pushd > /dev/null'
alias arcdir='cd '${F4F_HOME}'/'${ARC_HOME}'/'


arc