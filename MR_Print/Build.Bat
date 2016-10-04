@ECHO OFF

HARBOUR -build

DEL MRPrint.Exe

HBMK2 Demo.hbp

MRPrint.exe
