require "io"
require "LuaXML"
dofile( "ProcessRelativePath.lua")
dofile( "OutPutInfo.lua")
dofile( "Hippo_TextureWalker.lua")
--[[
解析tpl文件中的相关文件
返回table，table是一个含有贴图文件名的数组
--]]

function GetResRelativeFile_Tpl(tplfn)
	local res_table={}
	local errstr=nil
    if(IsFileExisit(tplfn)==false) then
        errstr="can not find tpl file on disk:" .. tplfn
        OutPutError(errstr)
	    return res_table,errstr
	end
	SetCurFn(tplfn)
	local xfile = xml.load(tplfn)
	if(xfile==nil) then
		errstr="open xml file failed:" .. tplfn
	end
	local rootelem=xfile:find("H3DMaterialTemplate")
	if(rootelem~=nil) then
	    local nvelem_num=table.getn(rootelem)
	    for idx=1,nvelem_num,1 do
	        local nodevar=rootelem[idx]
	        local nodevar_sem=nodevar["sem"]
	        local nodevar_path=nodevar["value"]
	        if(nodevar_sem == "texturePath" or nodevar_sem == "cubetexturePath") then
	            local fullpath=getFullPathFromRelpath( nodevar_path,GetCurFn(),false)
	            fullpath=GetResRelativeFile_Texture(fullpath) -- deal the dds issue
	            table.insert(res_table,fullpath)
				--print(fullpath)
	        end
	    end
	end
	OutPutInfo("成功解析tpl相关文件:" .. tplfn)
	return res_table,errstr
end


--GetResRelativeFile_Tpl("D:\\X52Demo\\resources\\art\\stage\\template\\common\\dsn.tpl")
