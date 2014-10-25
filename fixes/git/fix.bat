@echo off

call git config --global user.name %USERNAME%
call git config --global user.email %USERNAME%@avaya.com
call git config --global core.autocrlf false
