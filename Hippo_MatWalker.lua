
require "io"
require "LuaXML"
dofile( "Hippo_TplWalker.lua")
dofile( "Hippo_TextureWalker.lua")
dofile( "ProcessRelativePath.lua")

local _maskmatfn="D:\\alienbrainWork\\QQX5-2\\QQX5-2_Exe\\resources\\art\\role\\bodypart\\female\\trousers\\116105002\\116105002.mat"
local _commonmatfn="D:\\alienbrainWork\\QQX5-2\\QQX5-2_Exe\\resources\\art\\ui\\creatplayer\\1440_900_x52_ui_creat3.mat"

function parse_nodevar(fathernode,res_table)
	local nodevar=fathernode["sem"]
	local path=fathernode["value"]
	if(nodevar~=nil and path~=nil) then
        path=getFullPathFromRelpath( path,GetCurFn(),false)
        path=GetResRelativeFile_Texture(path) -- deal the dds issue
        if(nodevar=="texturePath") then
            table.insert(res_table.CommonTexture,path)
            print(path)
        elseif(nodevar=="cubetexturePath") then
            table.insert(res_table.CubeTexture,path)
            print(path)
        end	
    end

end


--解析mask mat中的贴图文件
function parse_maskmat_texture(xfile,res_table)
	local matins_elem=xfile:find("H3DMaterialInstance")
	--mask贴图
	res_table.MaskTexture=matins_elem.MaskFileName
	--print(maskfilename)
	local n=table.getn(matins_elem)
	for i=1,n,1 do
		--找第二层级的结点
		local second_lv_node=matins_elem[i]
		local m=table.getn(second_lv_node)
		for j=1,m,1 do
			--nodevar结点总是在第三层级的结点
			local third_lv_node = second_lv_node[j]
			if(third_lv_node) then
				parse_nodevar(third_lv_node,res_table)
			end
		end
	end
end


--找到mat文件中的texture
function parse_mat_texture(mat_xml_elem,singlemat_table)
	local n=table.getn(mat_xml_elem)
	for i=1,n,1 do
		--找第二层级的结点
		local second_lv_node=mat_xml_elem[i]
		parse_nodevar(second_lv_node,singlemat_table)
	end
end


function parse_maskmat_tpl(matins_elem,singlemat_table)
	local n=table.getn(matins_elem)
	singlemat_table.Tpls={}
	for i=1,n,1 do
		--找第二层级的结点
		local second_lv_node=matins_elem[i]
		local m=table.getn(second_lv_node)
		singlemat_table.Tpls[i]=getFullPathFromRelpath(second_lv_node["TemplateFile"],GetCurFn(),true)
	end
end

function parse_singlemat(mat_xml_elem,bIsMask)

	local singlemat_table={}
	singlemat_table.CommonTexture={}
	singlemat_table.CubeTexture={}
	
	if(bIsMask) then
		--tpls in mat(include tpl's texture)
		parse_maskmat_tpl(mat_xml_elem,singlemat_table)
		--textures in mat
		parse_maskmat_texture(mat_xml_elem,singlemat_table)
	else
		singlemat_table.Tpls={}
		--tpls in mat(include tpl's texture)
		local tplfullpath=getFullPathFromRelpath(mat_xml_elem.TemplateFile,GetCurFn(),true)
		singlemat_table.Tpls[tplfullpath]=GetResRelativeFile_Tpl(tplfullpath)

		--textures in mat
		parse_mat_texture(mat_xml_elem,singlemat_table)
	end

	return singlemat_table

end
--[[
参数 
matfn:mat的文件名，全路径
matname:如果指定了该参数，表示只解析该材质球

返回table,有以下字段：
MaskTexture
CommonTexture
CubeTexture
Tpl
--]]
function GetResRelativeFile_Mat(matfn,matname)
	local res_table={}
	if(IsFileExisit(matfn)==false) then
        --error("Mat文件不合法，找不到H3DMaterialInstance结点:" .. matfn )
		OutPutError("Mat文件不存在:" .. matfn )	
	    return res_table
	end
	
	local xfile = xml.load(matfn)
	local matins_elem=xfile:find("H3DMaterialInstance")
	if(matins_elem == nil) then
		--error("Mat文件不合法，找不到H3DMaterialInstance结点:" .. matfn )
		OutPutError("Mat文件不合法，找不到H3DMaterialInstance结点:" .. matfn )
		return res_table
	end
	SetCurFn(matfn)
	local bIsMask=(matins_elem.MaskFileName ~= nil)
	local nMatNum=table.getn(xfile)
	--遍历mat文件中的每个材质球
	for matidx=1,nMatNum,1 do
		local mat_xml_elem=xfile[matidx]
		if(matname==nil or matname==mat_xml_elem.MaterialName) then
		    local ballname="材质球: " .. mat_xml_elem.MaterialName
		    --print(ballname,bIsMask)
		    res_table[ballname]=parse_singlemat(mat_xml_elem,bIsMask)        
		end
	end
	OutPutInfo("成功解析mat相关文件:" .. matfn)
	return res_table
end


--print parse result
function print_mat_file(mattable)
	print("parse res size=",table.getn(mattable))
	for k,v in pairs(mattable) do
		print(k,v)
		for k2,v2 in pairs(v) do
			print(k2,v2)
		end
	end
end

--[[
测试用例应该准备：
1、一个文件中有1个普通mat
2、一个文件中有多个普通mat
3、一个文件中没有mat
4、一个文件中有1个普通mask mat
5、一个mat中有多个mat，普通mask都有
--]]
--print_mat_file(parse_mat_relfile(_maskmatfn))
