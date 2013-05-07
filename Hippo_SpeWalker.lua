dofile( scriptdir .. "OutPutInfo.lua")
dofile( scriptdir .. "ProcessRelativePath.lua")
dofile( scriptdir .. "Hippo_DmlWalker.lua")
dofile( scriptdir .. "Hippo_ChrWalker.lua")
dofile( scriptdir .. "Hippo_MatWalker.lua")
dofile( scriptdir .. "HIppo_EffWalker.lua")


function ParseEntityLine(entityline,restable)
    local fn=string.match(entityline,"url=\"(.-)\"")
    if(fn==nil) then
        return
    end
    local fullpath=getFullPathFromRelpath( fn,GetCurFn(),true)
    local shadername=string.match(entityline,"shader=\"(.-)\"")
    local lowstr=string.lower(fullpath)
    local extname=string.sub(lowstr,-4,-1)
    local tmptable={}
    local idxstr=nil
    if(shadername~=nil) then
        local mattable=GetResRelativeFile_Mat(fullpath,shadername)
        tmptable[fullpath]=mattable
        idxstr="Mat"
    else
        if(extname==".dml") then
            local dmltable=GetResRelativeFile_DML(fullpath)
            tmptable[fullpath]=dmltable
            idxstr="Dml"
        elseif(extname==".chr") then
            local chrtable=GetResRelativeFile_Chr(fullpath)
            tmptable[fullpath]=chrtable
            idxstr="Chr"
        elseif(extname==".eff") then
            local efftable=GetResRelativeFile_Eff(fullpath)
            tmptable[fullpath]=efftable
            idxstr="Eff"
        else
            OutPutError("发现spe中有未知的文件类型:" .. fullpath)
            return
        end
    end
    restable[idxstr]=tmptable
end
--[[
解析 spe 文件中的相关文件
spe 中可能包含:dml,chr,shader和eff
返回table，table中含有shader文件以及dml文件
--]]
function GetResRelativeFile_Spe(spefn)

    local restable={}
    local errstr=""
    if(IsFileExisit(spefn)==false) then
        errstr="can not find spe file on disk:" .. spefn
        OutPutError(errstr)
	    return res_table,errstr
	end
	SetCurFn(spefn)
	--打开文件
	io.input(spefn)
	local specontent=io.read("*all")
	
	--找到所有的entity行
	for entityline in string.gmatch(specontent,"<Entity (.-)/>") do
	    SetCurFn(spefn)
        ParseEntityLine(entityline,restable)
	end

    OutPutInfo("成功解析eff相关文件:" .. spefn)
    io.close()
    return restable,errstr
end