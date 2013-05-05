dofile( "OutPutInfo.lua")
dofile( "Hippo_MatWalker.lua")
dofile( "ProcessRelativePath.lua")



function ParseChrDmlSection(filecontent,res_table,sectionName)
    local tmpStr=string.format("%s[%s%s]\n(.-)\n","%",sectionName,"%") --�ðɣ�����ĺܵ���
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
����dml��chr�еĲ�����Ԫ�鲿��
������fileContent���ļ�������

���أ�
����ֵ1��table,table�Ľṹ�������ģ�table���ж��table(subTable),
		subTable��3���ֶΣ�MeshName��MatFileName��MatBallName
--]]
function ParseFile_MatInfo(fileContent,res_table)
	local mattable={}
	for meshname,matfilename,ballname in string.gmatch(fileContent,"%[SubEntity%]\n(.-)\n(.-)\n(.-)\n") do
		local matball={}
		matball["MeshName"]="����: " .. meshname .. ",������: " .. ballname
		--matball["MatBallName"]="������: " .. ballname
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

	--����geometry����
	ParseChrDmlSection(t,res_table,"GEOMETRY MESH")
	
	--����������Ԫ�鲿��
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
