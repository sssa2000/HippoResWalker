// HippoResWalkerDll.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include "HippoLuaContex.h"
#include <Windows.h>


int TestLib(lua_State* L)
{
	::MessageBoxA(0,"test lib",0,0);
	return 0;
}

HippoLuaContex gLuaContex;

int CopyStringToClipBoard(lua_State* L)
{
	if( OpenClipboard(0) )
	{
		const char* str=gLuaContex.GetStringArgument(1,"");
		HGLOBAL clipbuffer;
		char * buffer;
		EmptyClipboard();
		clipbuffer = GlobalAlloc(GMEM_DDESHARE, strlen(str)+1);
		buffer = (char*)GlobalLock(clipbuffer);
		strcpy(buffer, str);
		GlobalUnlock(clipbuffer);
		SetClipboardData(CF_TEXT,clipbuffer);
		CloseClipboard();
	}
	return 0;
}

//定义要导出到lua的函数列表
extern HippoExportFunDef HippoResWalker_Lib[] = 
{
	{"CopyStringToClipBoard", CopyStringToClipBoard},
	{"TestLib", TestLib},
	{NULL, NULL}
};




extern "C" __declspec(dllexport) int luaopen_HippoResWalkerDll(lua_State* L)
{
	
	gLuaContex.InitUseExternLuaState(L);
	gLuaContex.RegFunArrayToLua(HippoResWalker_Lib);

	return 0;
}