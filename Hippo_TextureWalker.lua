dofile( scriptdir .. "ProcessRelativePath.lua")
dofile( scriptdir .. "OutPutInfo.lua")
local _currentProcessFileName=nil

--[[
����һ����ͼ�ļ���(ȫ·��)��
����һ����ͼ�ļ���(ȫ·��)��
�����ͬĿ¼�´���dds�����ȷ���dds��·��
--]]
function GetResRelativeFile_Texture(texturefn)
    --first try the dds file
    local res=string.sub(texturefn,1,#texturefn-3) .. "dds"
    bexisit=IsFileExisit(res)
    if(not bexisit) then
        local bexisit=IsFileExisit(texturefn)
        if(not bexisit) then
            res = "(ȱʧ) " .. texturefn
            OutPutError("�޷��ҵ���ͼ�ļ�:" .. texturefn)
        end
    end
    return res
end