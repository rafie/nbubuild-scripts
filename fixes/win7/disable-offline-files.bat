@echo off

sc stop CscService
sc config CscService start= disabled
