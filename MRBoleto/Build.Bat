@ECHO OFF

HARBOUR -build

DEL MRboleto.Exe

HBMK2 Demo.hbp

MRboleto.exe
