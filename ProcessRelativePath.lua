
local _currentProcessFileName=nil

function GetCurFn()
    return _currentProcessFileName
end

function SetCurFn(fn)
    _currentProcessFileName=fn
end


--��֤һ�����·���ĺϷ���
function relpath_validator(relpath)
	--�����������ļ���:û��б�ܵģ�����:1.mat
	local res=false
	local t000=string.match(relpath,"[/\\]")
	if(t000==nil) then
		return true
	end

	--ֻ���� ../resources �� ../data
	local t00=string.match(relpath,"(\.\.[/\\]resources)[/\\].+")
	local t01=string.match(relpath,"(\.\.[/\\]data)[/\\].+")
	local t10=string.match(relpath,"(\.\.[/\\]resources_kucun)[/\\].+")
	local t11=string.match(relpath,"(\.\.[/\\]resources_daishen)[/\\].+")
	local t1=t01 or t00 or t10 or t11
	if(t1==nil) then
		error(string.format("���Ϸ������·��:%s",relpath))
		return false
	end
	return true
end

function fullpath_validator(fullpath)

end

function IsFileExisit(fullpath)
    local f,errstr=io.open(fullpath,"r")
    local res= (f~=nil)
    if(f~=nil) then
        io.close(f)
    end
    return res
end

--����һ�����·������ȫ·��
--relpath:ָ������Դ�е����·��������../resources/art/role/...
--rootRespath��ָ���Ƕ�����Դ��ȫ·��������dml��chr����Դ·��
--bProcessNotExisitFile:���=true����ô����ļ������ڣ����ļ���ǰ�����"������"���ַ���
--����ֵ:
--���ݶ�����Դ��·��ȷ�����õ���Դ��ȫ·��
--���ļ��Ƿ��ڴ����ϴ���
function getFullPathFromRelpath(relpath,rootRespath,bProcessNotExisitFile)

	relpath_validator(relpath)
	fullpath_validator(rootRespath)

    local res=relpath
    --����resources֮ǰ���ַ���
    local t00=string.match(rootRespath,"(.-[/\\])resources[/\\].+")
	local t01=string.match(rootRespath,"(.-[/\\])data[/\\].+")
	local t10=string.match(rootRespath,"(.-[/\\])resources[/\\].+")
	local t11=string.match(rootRespath,"(.-[/\\])resources[/\\].+")
	local t1=t01 or t00 or t01 or t11

	if(t1) then
		local t02=string.match(relpath,".-[/\\](resources[/\\].+)")
		local t03=string.match(relpath,".-[/\\](data[/\\].+)")
		local t04=string.match(relpath,".-[/\\](resources[/\\].+)")
		local t05=string.match(relpath,".-[/\\](resources[/\\].+)")
		local t2= t02 or t03 or t04 or t05

		if(t2==nil) then
			--relpath��û�а���·��������ֻд��1.mat����ʱֻ��Ҫ���϶�����Դ��·������
			t1=string.match(rootRespath,"(.+[/\\])")
			t2=relpath
		end
		res=t1 .. t2
	end
    local bexisit=IsFileExisit(res)
    --�����Դ�ڴ����Ҳ�����ֱ����ȫ·��ǰ����
    if(bProcessNotExisitFile==true and bexisit==false) then
        res = "(ȱʧ) " .. res
    end
    return res,bexisit
end




function test_fun()
	local fp=getFullPathFromRelpath("../resources/art/stage/beach001/model/1.mat","D:\\X52Demo/resources\\art\\stage\\beach001\\Model\\1.dml",true)
	--print (fp)

	local fp2=getFullPathFromRelpath("1.mat","D:\\X52Demo/resources\\art\\stage\\beach001\\Model\\1.dml",true)
	--print (fp2)

	local fp3=getFullPathFromRelpath("../data/template/default.tpl","..\\resources\\art\\stage\\beach001\\Model\\beach001_coconut002.mat",true)
	print (fp3)

	local fp4=getFullPathFromRelpath("../data/enginefx/1.mat","D:\\X52Demo/resources\\art\\stage\\beach001\\Model\\1.dml",true)
	--print (fp4)

	local fp5=getFullPathFromRelpath("../art/stage/beach001/model/1.mat","D:\\X52Demo/data\\1.dml",true)
	--print (fp5)
end

--test_fun()
