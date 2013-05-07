package.cpath = package.cpath..";"..scriptdir.."?.dll;"
require "io"
require "LuaXML"
dofile( scriptdir .. "Hippo_TplWalker.lua")
dofile( scriptdir .. "Hippo_TextureWalker.lua")
dofile( scriptdir .. "ProcessRelativePath.lua")

local _maskmatfn="D:\\alienbrainWork\\QQX5-2\\QQX5-2_Exe\\resources\\art\\role\\bodypart\\female\\trousers\\116105002\\116105002.mat"
local _commonmatfn="D:\\alienbrainWork\\QQX5-2\\QQX5-2_Exe\\resources\\art\\ui\\creatplayer\\1440_900_x52_ui_creat3.mat"

function parse_nodevar(nodevar_elem,res_table)
	local varsem=nodevar_elem["sem"]
	local path=nodevar_elem["value"]
	if(varsem=="texturePath" or varsem=="cubetexturePath" and path~=nil) then
        path=getFullPathFromRelpath( path,GetCurFn(),false)
        path=GetResRelativeFile_Texture(path) -- deal the dds issue
        if(varsem=="texturePath") then
            table.insert(res_table.CommonTexture,path)
        elseif(varsem=="cubetexturePath") then
            table.insert(res_table.CubeTexture,path)
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



--解析mask材质的一个channel，mask材质输出的格式和普通材质不同
--参数
--channelname：通道的名字
--channel_xml_elem：单个channel材质的xml结点
--res_table：存放结果的table
--返回：void
function parse_mask_channel(channelname,channel_xml_elem,res_table)
    local channelres={}
    channelres.CommonTexture={}
	channelres.CubeTexture={}
    channelres.Tpls={}
    --tpl filename
    local tplstr=channel_xml_elem["TemplateFile"]
    local tplfullpath=getFullPathFromRelpath(tplstr,GetCurFn(),true)
    channelres.Tpls[tplfullpath]=GetResRelativeFile_Tpl(tplfullpath)
    
    --channel texture
    local nodevarn=table.getn(channel_xml_elem)
    for i=1,nodevarn,1 do
        local nodevar_elem=channel_xml_elem[i]
        parse_nodevar(nodevar_elem,channelres)
    end
    
    res_table[channelname]=channelres
end

local maskchannel_dic={}
maskchannel_dic["MaskStand"]=1
maskchannel_dic["MaskChannelR"]=1
maskchannel_dic["MaskChannelG"]=1
maskchannel_dic["MaskChannelB"]=1
maskchannel_dic["MaskChannelA"]=1

--解析单个材质球，可能是mask也可能是普通材质
function parse_singlemat(mat_xml_elem,bIsMask)

	local singlemat_table={}

	
	if(bIsMask) then
	    --mask贴图
	    singlemat_table["MaskTexture"]=getFullPathFromRelpath(mat_xml_elem.MaskFileName,GetCurFn(),true)
	    local n=table.getn(mat_xml_elem)
	    --遍历每个结点，找到mask通道
        for i=1,n,1 do
            local channel=mat_xml_elem[i]
	        if(maskchannel_dic[channel[0]]~=nil) then --channel[0]就是该节点的名字
	            parse_mask_channel(channel[0],channel,singlemat_table)
	        end
	    end

	else
		singlemat_table.CommonTexture={}
	    singlemat_table.CubeTexture={}
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
	local res_reson
	if(IsFileExisit(matfn)==false) then
        res_reson="can not find mat file on disk:" .. matfn
        OutPutError(res_reson)
	    return res_table,res_reson
	end
	
	local xfile = xml.load(matfn)
	local matins_elem=xfile:find("H3DMaterialInstance")
	if(matins_elem == nil) then
		--error("Mat文件不合法，找不到H3DMaterialInstance结点:" .. matfn )
		OutPutError("Mat文件不合法，找不到H3DMaterialInstance结点:" .. matfn )
		return res_table
	end
	SetCurFn(matfn)
	
	local nMatNum=table.getn(xfile)
	--遍历mat文件中的每个材质球
	for matidx=1,nMatNum,1 do
		local mat_xml_elem=xfile[matidx]
		local bIsMask=(mat_xml_elem.MaskFileName ~= nil)
		if(matname==nil or matname==mat_xml_elem.MaterialName) then
		    SetCurFn(matfn)
            local ballname="材质球: " .. mat_xml_elem.MaterialName
		    res_table[ballname]=parse_singlemat(mat_xml_elem,bIsMask)        
		end
	end
	OutPutInfo("成功解析mat相关文件:" .. matfn)
	return res_table,res_reson
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
