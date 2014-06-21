@echo off

setlocal
call set-nbu-build-env.bat
ruby -e "require 'rufus/mnemo'; puts Rufus::Mnemo.from_i(rand(13**5))"
