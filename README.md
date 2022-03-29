# Relocalize

### What?
script goes through project and renames localization call "key".localized to strictly typed enum calls like S.key.localizedString

### How?
- clean your Localizable.strings from all comments
- make sure there're no \n before '=' in Localizable.strings
- make script executable
> chmod +x <path>/main.swift
- run in terminal 
> main.swift -s < path to source code folder > -l < path to main Localizable.strings > -f < path to any empty file >

**no < or > needed*


script will go through Localizable.strings and generate clean cases for *some enum*, will put that data to empty file (-f), go through source code and rename all calls that looks like **< key >.localized** to **S.< case >.localizedString**.

### Not working
After all that above you will have you source code ready for localization. You will have to adapt you project to be able to read S.key.localizedString and add created cases somewhere, for example read 'example'
  
  *example goes from https://stackoverflow.com/a/28213905/1140941
