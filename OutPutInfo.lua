--ȫ��
g_OutPutErrorFun=nil
g_OutPutInfoFun=nil

--ֻ��ȫ�ֱ�������ֵ�ú�����������
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