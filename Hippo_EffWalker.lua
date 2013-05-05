dofile( "OutPutInfo.lua")
dofile( "ProcessRelativePath.lua")
dofile( "Hippo_DmlWalker.lua")
dofile( "Hippo_MatWalker.lua")
--[[
解析eff文件中的相关文件
eff中只可能包含2种文件：shader和dml
返回table，table中含有shader文件以及dml文件
--]]
function GetResRelativeFile_Eff(efffn)
    local restable={}
    local errstr=""
    if(IsFileExisit(efffn)==false) then
        errstr="can not find eff file on disk:" .. efffn
        OutPutError(errstr)
	    return res_table,errstr
	end
	SetCurFn(efffn)
	--打开文件
	io.input(efffn)
	local effcontent=io.read("*all")
	--查找所有的shader
	local shader_res={}
	for ballname,mfn in string.gmatch(effcontent,"<Shader value=\"(.-)\" />\n.-<MatFileName value=\"(.-)\".-/>") do
	    local matfullpath=getFullPathFromRelpath( mfn,GetCurFn(),true)
	    local shadertitle=string.format("材质球:%s;文件名:%s",ballname,matfullpath)
		shader_res[shadertitle]=GetResRelativeFile_Mat(matfullpath,ballname)
	    --print(ballname,matfullpath)
    end
    --查找所有的dml
    local dml_res={}
    for dmlfn in string.gmatch(effcontent,"<mParticleModelName.-value=\"(.-)\".-/>") do

    	if(string.len(dmlfn)>4) then
    		local dmlfullpath=getFullPathFromRelpath( dmlfn,GetCurFn(),true)
			local dmlparseres=GetResRelativeFile_DML(dmlfullpath)
    		table.insert(dml_res,dmlparseres)
            --print(fullpath)
    	end

    end
    restable["Shader"]=shader_res
    restable["模型粒子"]=dml_res
    OutPutInfo("成功解析eff相关文件:" .. efffn)
    io.close()
    return restable,errstr
end

function testfun()
	local fn="D:\\X52Demo\\resources\\art\\effect\\ui\\normal_st\\a_combo_lizi_lev1.eff"
	local fn2="D:\\X52Demo\\resources\\art\\effect\\Particle\\Par_Buff_04.eff"

	GetResRelativeFile_Eff(fn)
	GetResRelativeFile_Eff(fn2)
end

--testfun()
