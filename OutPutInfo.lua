--全局
g_OutPutErrorFun=nil
g_OutPutInfoFun=nil

--只有全局变量被赋值该函数才有意义
function OutPutInfo(str)
    if(g_OutPutInfoFun) then
        return g_OutPutInfoFun(str)
    end
end

function OutPutError(str)
    if(g_OutPutErrorFun) then
        return g_OutPutErrorFun(str)
    end
end