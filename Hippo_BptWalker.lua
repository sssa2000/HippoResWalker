dofile( "OutPutInfo.lua")
dofile( "ProcessRelativePath.lua")
dofile( "Hippo_ChrWalker.lua")


function GetResRelativeFile_Bpt(filename)
	local res_table={}
	local res_reson=nil
	SetCurFn(filename)
	io.input(filename)
	local t=io.read("*all")

    for fn in string.gmatch(t,"<BodypartEntry.-file=\"(.-)\".-/>") do
        local fullpath=getFullPathFromRelpath(fn,GetCurFn(),true)
        table.insert(res_table,fullpath)
    end

	return res_table,res_reson
end
