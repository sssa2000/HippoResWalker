dofile( "OutPutInfo.lua")
dofile( "Hippo_MatWalker.lua")
dofile( "ProcessRelativePath.lua")



function ParseChrDmlSection(filecontent,res_table,sectionName)
    local tmpStr=string.format("%s[%s%s]\n(.-)\n","%",sectionName,"%") --好吧，这真的很蛋疼
    --print(tmpStr)
	local matchedfn=string.match(filecontent,tmpStr)
    if(matchedfn~=nil) then
        local geofullpath,bexisit=getFullPathFromRelpath(matchedfn,GetCurFn(),true)
        local tmptable={}
        table.insert(tmptable,geofullpath)
        res_table[sectionName]=tmptable
    end
end


--[[
解析dml，chr中的材质三元组部分
参数：fileContent：文件的内容

返回：
返回值1：table,table的结构是这样的：table中有多个table(subTable),
		subTable有3个字段：MeshName，MatFileName，MatBallName
--]]
function ParseFile_MatInfo(fileContent,res_table)
	local mattable={}
	for meshname,matfilename,ballname in string.gmatch(fileContent,"%[SubEntity%]\n(.-)\n(.-)\n(.-)\n") do
		local matball={}
		matball["MeshName"]="网格: " .. meshname .. ",材质球: " .. ballname
		--matball["MatBallName"]="材质球: " .. ballname
		local matfiletable={}
		local matfullpath=getFullPathFromRelpath(matfilename,GetCurFn(),true)
		matfiletable[matfullpath]=GetResRelativeFile_Mat(matfullpath,ballname)
		matball["MatFileName"]=matfiletable
		table.insert(mattable,matball)
	end

    res_table["MatInfo"]=mattable
	return mattable
end


function GetResRelativeFile_DML(dmlPath)
	local res_table={}
	local res_reson=nil
    if(IsFileExisit(dmlPath)==false) then
        res_reson="can not find dml file on disk:" .. dmlPath
        OutPutError(res_reson)
	    return res_table,res_reson
	end
	SetCurFn(dmlPath)
	io.input(dmlPath)
	local t=io.read("*all")

	--解析geometry部分
	ParseChrDmlSection(t,res_table,"GEOMETRY MESH")
	
	--解析材质三元组部分
	ParseFile_MatInfo(t,res_table)

    io.close()
	return res_table,res_reson
end

function test_GetResRelativeFile_DML()
	local _t,res=GetResRelativeFile_DML(test_path)
	print(_t["Geometry"])
	for idx,mat in pairs(_t["MatInfo"]) do
		for k,v in pairs(mat) do
			print(k,v)
		end

	end
end
