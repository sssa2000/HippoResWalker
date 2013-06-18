dofile( scriptdir .. "OutPutInfo.lua")
dofile( scriptdir .. "Hippo_MatWalker.lua")
dofile( scriptdir .. "ProcessRelativePath.lua")
dofile( scriptdir .. "Hippo_DmlWalker.lua")

function GetResRelativeFile_Chr(chrPath)
	local res_table={}
	local res_reson=nil
    if(IsFileExisit(chrPath)==false) then
        res_reson="can not find chr file on disk:" .. chrPath
        OutPutError(res_reson)
	    return res_table,res_reson
	end		
	SetCurFn(chrPath)
	io.input(chrPath)
	local filecontent=io.read("*all")

    local fix="%[CLOTH%]\n(.-)\n"
    local matchedfn=string.match(filecontent,fix)
	--cloth
    ParseChrDmlSection(filecontent,res_table,"CLOTH")

    --skin
	ParseChrDmlSection(filecontent,res_table,"SKIN")
	
	--skl
	ParseChrDmlSection(filecontent,res_table,"SKELETON")
	
	--animation
	ParseChrDmlSection(filecontent,res_table,"ANIMATION")
	
	--bv
	ParseChrDmlSection(filecontent,res_table,"BV")
	
	--解析材质三元组部分
	ParseFile_MatInfo(chrPath,filecontent,res_table)
	
	io.close()
	return res_table,res_reson
end

function test_GetResRelativeFile_Chr()
	local test_path="D:/X52Demo/resources/art/role/bodypart/male/hair/103020001/103020.chr"
	local _t,res=GetResRelativeFile_Chr(test_path)
	for k,v in pairs(_t) do
		print(k,v)
	end
end

--test_GetResRelativeFile_Chr()