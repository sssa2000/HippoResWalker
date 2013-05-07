--[[
gui�����������
--]]
dofile(scriptdir .. "Hippo_DmlWalker.lua")
dofile(scriptdir .. "Hippo_MatWalker.lua")
dofile(scriptdir .. "Hippo_TplWalker.lua")
dofile(scriptdir .. "Hippo_ChrWalker.lua")
dofile(scriptdir .. "Hippo_EffWalker.lua")
dofile(scriptdir .. "Hippo_SpeWalker.lua")
dofile(scriptdir .. "Hippo_BptWalker.lua")
dofile(scriptdir .. "OutPutInfo.lua")
require "lfs"
--[[
����һ���ļ�
����1���ļ�����Դ���õ�table
����2��ʧ�ܵ�ԭ���ַ���
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
		failed_str="�޷�ʶ����ļ�����\n" .. filename
		OutPutError(failed_str)
	end

	return restable,failed_str
end



--dotest_dir("D:\\X52Demo\\resources\\art\\stage\\")