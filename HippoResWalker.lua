--[[
gui交互的总入口
--]]
dofile("Hippo_DmlWalker.lua")
dofile("Hippo_MatWalker.lua")
dofile("Hippo_TplWalker.lua")
dofile("Hippo_ChrWalker.lua")
dofile("Hippo_EffWalker.lua")
dofile("Hippo_SpeWalker.lua")
dofile("Hippo_BptWalker.lua")
dofile( "OutPutInfo.lua")
require "lfs"
--[[
解析一个文件
返回1：文件中资源引用的table
返回2：失败的原因字符串
--]]
function HippoParseFile(filename)
	local restable={}
	local failed_str=nil
	local lowstr=string.lower(filename)
	local extname=string.sub(lowstr,-4,-1)
	if(extname==".dml") then
		restable=GetResRelativeFile_DML(filename)
	elseif(extname==".mat") then
		restable=GetResRelativeFile_Mat(filename)
    elseif(extname==".tpl") then
		restable=GetResRelativeFile_Tpl(filename)
    elseif(extname==".chr") then
		restable=GetResRelativeFile_Chr(filename)
    elseif(extname==".eff") then
		restable=GetResRelativeFile_Eff(filename)
    elseif(extname==".spe") then
		restable=GetResRelativeFile_Spe(filename)
    elseif(extname==".bpt") then
		restable=GetResRelativeFile_Bpt(filename)
	else
		failed_str="无法识别的文件类型\n" .. filename
		OutPutError(failed_str)
	end

	return restable,failed_str
end

function dotest_dir(dirpath)
	for file in lfs.dir(dirpath) do
        if file ~= "." and file ~= ".." then
            local f = dirpath..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                dotest_dir (f)
            else
                HippoParseFile(dirpath..'/'..file)
            end
        end
    end    
end

--dotest_dir("D:\\X52Demo\\resources\\art\\stage\\")