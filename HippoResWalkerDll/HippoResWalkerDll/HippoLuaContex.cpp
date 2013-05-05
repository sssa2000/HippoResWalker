#include "HippoLuaContex.h"
#include <stdio.h>
#include <string>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

HippoLuaContex::HippoLuaContex()
{
	m_pErrorHandler = NULL;
	m_bUseExternContex=false;
}

void HippoLuaContex::InitUseExternLuaState(lua_State* L)
{
	m_bUseExternContex=true;
	m_pScriptContext=L;
	LoadDefaultLib();
}

void HippoLuaContex::InitCreateNewLuaState(lua_State* L)
{
	m_bUseExternContex=false;
	m_pScriptContext = lua_open();
	LoadDefaultLib();
}

void HippoLuaContex::LoadDefaultLib()
{
	int res=lua_cpcall(m_pScriptContext,luaopen_base,0);
	res=lua_cpcall(m_pScriptContext,luaopen_io,0);
	res=lua_cpcall(m_pScriptContext,luaopen_string,0);
	res=lua_cpcall(m_pScriptContext,luaopen_math,0);
	res=lua_cpcall(m_pScriptContext,luaopen_debug,0);
	res=lua_cpcall(m_pScriptContext,luaopen_table,0);
}
HippoLuaContex::~HippoLuaContex()
{
	if(!m_bUseExternContex && m_pScriptContext)
		lua_close(m_pScriptContext);
}




bool HippoLuaContex::RunScriptFromFile(const char *pFname)
{
	const char *pFilename = pFname;

	if (0 != luaL_loadfile(m_pScriptContext, pFilename))
	{
		if(m_pErrorHandler)
		{
			char buf[256];
			sprintf_s(buf,sizeof(buf),"Lua Error - Script Load\nScript Name:%s\nError Message:%s\n", pFilename, luaL_checkstring(m_pScriptContext, -1));
			m_pErrorHandler(buf);
		}

		return false;
	}
	if (0 != lua_pcall(m_pScriptContext, 0, LUA_MULTRET, 0))
	{
		if(m_pErrorHandler)
		{
			char buf[256];
			sprintf_s(buf,sizeof(buf),"Lua Error - Script Run\nScript Name:%s\nError Message:%s\n", pFilename, luaL_checkstring(m_pScriptContext, -1));
			m_pErrorHandler(buf);
		}

		return false;
	}
	return true;

}

bool HippoLuaContex::RunStringFromString(const char *pCommand)
{
	if (0 != luaL_loadbuffer(m_pScriptContext, pCommand, strlen(pCommand), NULL))
	{
		if(m_pErrorHandler)
		{
			char buf[256];
			sprintf_s(buf,sizeof(buf),"Lua Error - String Load\nString:%s\nError Message:%s\n", pCommand, luaL_checkstring(m_pScriptContext, -1));
			m_pErrorHandler(buf);
		}

		return false;
	}
	if (0 != lua_pcall(m_pScriptContext, 0, LUA_MULTRET, 0))
	{
		if(m_pErrorHandler)
		{
			char buf[256];
			sprintf_s(buf,sizeof(buf),"Lua Error - String Run\nString:%s\nError Message:%s\n", pCommand, luaL_checkstring(m_pScriptContext, -1));
			m_pErrorHandler(buf);
		}

		return false;
	}
	return true;
}

const char *HippoLuaContex::GetErrorString(void)
{
	return luaL_checkstring(m_pScriptContext, -1);
}


bool HippoLuaContex::RegAFunToLua(const char *pFunctionName, LuaFunctionType pFunction)
{
	lua_register(m_pScriptContext, pFunctionName, pFunction);
	return true;
}

bool HippoLuaContex::RegFunArrayToLua(HippoExportFunDef pFunctions[])
{
	for(int i=0; pFunctions[i].fname_in_lua; i++)
	{
		RegAFunToLua(pFunctions[i].fname_in_lua,pFunctions[i].func_in_c);
	}
	return true;
}

const char *HippoLuaContex::GetStringArgument(int num, const char *pDefault)
{
	return luaL_optstring(m_pScriptContext, num, pDefault);

}

double HippoLuaContex::GetNumberArgument(int num, double dDefault)
{
	return luaL_optnumber(m_pScriptContext, num, dDefault);
}

void HippoLuaContex::PushString(const char *pString)
{
	lua_pushstring(m_pScriptContext, pString);
}

void HippoLuaContex::PushNumber(double value)
{
	lua_pushnumber(m_pScriptContext, value);
}

void HippoLuaContex::PushUserType(void* udata,const char* typeName)
{
	//首先查询该指针是否已经创建过了，如果创建过在全局表中有记录
	lua_pushlightuserdata(m_pScriptContext,udata);
	lua_rawget(m_pScriptContext,LUA_ENVIRONINDEX);//在全局表中查找是否有p
	//如果没创建过，那么创建1个table，把指针设置给table
	if (lua_isnil(m_pScriptContext,-1)) 
	{
		lua_newtable(m_pScriptContext);                 // create table to be the object
		lua_pushlightuserdata(m_pScriptContext,udata);  // push address
		lua_setfield(m_pScriptContext,-2,"_pointer");   // table._pointer = address
		luaL_getmetatable(m_pScriptContext,typeName);   // get metatable 
		lua_setmetatable(m_pScriptContext,-2);          // set metatable for table
		lua_pushlightuserdata(m_pScriptContext,udata);  // push address
		lua_pushvalue(m_pScriptContext,-2);             // push table
		lua_rawset(m_pScriptContext,LUA_ENVIRONINDEX);  // envtable[address] = table
	}
}

void* HippoLuaContex::GetUserDataTypePtr(int index,const char* typeName)
{
	//拿到stack上index变量的元表
	lua_getmetatable(m_pScriptContext,index);

	//从注册表中拿到类型的元表
	lua_getfield(m_pScriptContext, LUA_REGISTRYINDEX, typeName);

	while (lua_istable(m_pScriptContext,-1))
	{
		//两个元表必须相等
		if (lua_rawequal(m_pScriptContext,-1,-2))
		{
			//把两个元表抛弃
			lua_pop(m_pScriptContext,2);
			//拿到原始指针
			lua_getfield(m_pScriptContext,index,"_pointer");
			void* udata = lua_touserdata(m_pScriptContext,-1);
			return udata;
		}
		lua_getfield(m_pScriptContext,-1,"_base");          // get mt._base
		lua_replace(m_pScriptContext,-2);                   // replace: mt = mt._base
	}
	luaL_typerror(m_pScriptContext,index,typeName);
	return 0;
}

void HippoLuaContex::SetErrorHandler(void(*pErrHandler)(const char *pError))
{
	m_pErrorHandler= pErrHandler;
}