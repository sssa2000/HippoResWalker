dofile( scriptdir .. "OutPutInfo.lua")
dofile( scriptdir .. "ProcessRelativePath.lua")
dofile( scriptdir .. "Hippo_ChrWalker.lua")


function GetResRelativeFile_Bpt(filename)
	local res_table={}
	local res_reson=nil
    if(IsFileExisit(filename)==false) then
        res_reson="can not find bpt file on disk:" .. filename
        OutPutError(res_reson)
	    return res_table,res_reson
	end	
	SetCurFn(filename)
	io.input(filename)
	local t=io.read("*all")

    for fn in string.gmatch(t,"<BodypartEntry.-file=\"(.-)\".-/>") do
        SetCurFn(filename)
        local fullpath=getFullPathFromRelpath(fn,GetCurFn(),true)
        local chrtable=GetResRelativeFile_Chr(fullpath)
        --table.insert(res_table,chrtable)
        res_table[fullpath]=chrtable
    end
    io.close()
	return res_table,res_reson
end
