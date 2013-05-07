set basedir=%~dp0
set scriptfilepath=%basedir%HippoResInfo_GUI.lua
set luaexepath=%basedir%env/lua.exe

call %luaexepath% %scriptfilepath%
