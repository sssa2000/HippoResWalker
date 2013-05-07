dofile( scriptdir .. "ProcessRelativePath.lua")
dofile( scriptdir .. "OutPutInfo.lua")
local _currentProcessFileName=nil

--[[
传入一个贴图文件名(全路径)，
返回一个贴图文件名(全路径)，
如果在同目录下存在dds，优先返回dds的路径
--]]
function GetResRelativeFile_Texture(texturefn)
    --first try the dds file
    local res=string.sub(texturefn,1,#texturefn-3) .. "dds"
    bexisit=IsFileExisit(res)
    if(not bexisit) then
        local bexisit=IsFileExisit(texturefn)
        if(not bexisit) then
            res = "(缺失) " .. texturefn
            OutPutError("无法找到贴图文件:" .. texturefn)
        end
    end
    return res
end