#!/bin/sh

echo "Installing homebrew"
if $(which brew > /dev/null); then
  echo "Homebrew already installed...moving on"
else
  echo "Installing homebrew...there will be prompts"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

declare -a caskItems=(
"atom"
"firefox"
"google-chrome"
"kitematic"
"zotero"
"virtualbox"
"lastpass"
"google-backup-and-sync"
"microsoft-office"
"hipchat"
"java8"
)

declare -a baseItems=(
"git"
"httpie"
"docker-machine"
"docker-compose"
)

brew tap caskroom/versions

echo "Installing base items"
for myFormula in "${baseItems[@]}"
do
  if brew ls --versions ${myFormula} > /dev/null; then
    echo "Package ${myFormula} already installed...moving on"
  else
    brew install ${myFormula}
  fi
done

echo "Installing cask items"
for myFormula in "${caskItems[@]}"
do
  if brew cask ls --versions ${myFormula} > /dev/null; then
    echo "Cask Package ${myFormula} already installed...moving on"
  else
    brew cask install ${myFormula}
  fi
done
