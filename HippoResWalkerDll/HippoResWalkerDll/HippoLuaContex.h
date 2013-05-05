/********************************************************************
	created:	2013/04/29
	created:	29:4:2013   1:50
	filename: 	C:\Users\sssa2000\Desktop\HippoResWalker\HippoResWalkerDll\HippoResWalkerDll\HippoLuaContex.h
	file path:	C:\Users\sssa2000\Desktop\HippoResWalker\HippoResWalkerDll\HippoResWalkerDll
	file base:	HippoLuaContex
	file ext:	h
	author:		sssa2000
	
	purpose:	
*********************************************************************/
#pragma once

struct lua_State;

#define LuaGlue extern "C" int
extern "C" 
{
	typedef int (*LuaFunctionType)(struct lua_State *pLuaState);
};

//定义c函数到lua函数的映射结构体
typedef struct 
{
	const char *fname_in_lua;
	int (*func_in_c)(lua_State *);
}HippoExportFunDef;


class HippoLuaContex
{
public:
	HippoLuaContex();
	void InitUseExternLuaState(lua_State* L);
	void InitCreateNewLuaState(lua_State* L);
	~HippoLuaContex();

	bool		RunScriptFromFile(const char *pFilename);
	bool		RunStringFromString(const char *pCommand);
	const char* GetErrorString(void);
	bool		RegAFunToLua(const char *pFunctionName, LuaFunctionType pFunction);
	bool		RegFunArrayToLua(HippoExportFunDef pFunctions[]);
	const char* GetStringArgument(int num, const char *pDefault);
	double		GetNumberArgument(int num, double dDefault=0.0);
	void*		GetUserDataTypePtr(int index,const char* typeName);
	void		PushString(const char *pString);
	void		PushNumber(double value);
	void		PushUserType(void* udata,const char* typeName);
	void		SetErrorHandler(void(*pErrHandler)(const char *pError));

	lua_State	*GetScriptContext(void)		{return m_pScriptContext;}

private:
	void LoadDefaultLib();
	lua_State* m_pScriptContext;
	bool m_bUseExternContex;
	void(*m_pErrorHandler)(const char *pError);
};