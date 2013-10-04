rem @echo off

setlocal

set PATH=C:\Ruby193\bin

cd /d %~dp0

ruby VhtFeed.rb %*
