
local _currentProcessFileName=nil

function GetCurFn()
    return _currentProcessFileName
end

function SetCurFn(fn)
    _currentProcessFileName=fn
end


--验证一个相对路径的合法性
function relpath_validator(relpath)
	--允许这样的文件名:没有斜杠的，例如:1.mat
	local res=false
	local t000=string.match(relpath,"[/\\]")
	if(t000==nil) then
		return true
	end

	--只接受 ../resources 和 ../data
	local t00=string.match(relpath,"(\.\.[/\\]resources)[/\\].+")
	local t01=string.match(relpath,"(\.\.[/\\]data)[/\\].+")
	local t10=string.match(relpath,"(\.\.[/\\]resources_kucun)[/\\].+")
	local t11=string.match(relpath,"(\.\.[/\\]resources_daishen)[/\\].+")
	local t1=t01 or t00 or t10 or t11
	if(t1==nil) then
		error(string.format("不合法的相对路径:%s",relpath))
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

--根据一个相对路径返回全路径
--relpath:指的是资源中的相对路径，例如../resources/art/role/...
--rootRespath：指的是顶层资源的全路径，例如dml，chr的资源路径
--bProcessNotExisitFile:如果=true，那么如果文件不存在，在文件名前面加上"不存在"的字符串
--返回值:
--根据顶层资源的路径确定引用的资源的全路径
--该文件是否在磁盘上存在
function getFullPathFromRelpath(relpath,rootRespath,bProcessNotExisitFile)

	relpath_validator(relpath)
	fullpath_validator(rootRespath)

    local res=relpath
    --捕获resources之前的字符串
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
			--relpath中没有包含路径，例如只写了1.mat。此时只需要加上顶层资源的路径即可
			t1=string.match(rootRespath,"(.+[/\\])")
			t2=relpath
		end
		res=t1 .. t2
	end
    local bexisit=IsFileExisit(res)
    --如果资源在磁盘找不到，直接在全路径前加上
    if(bProcessNotExisitFile==true and bexisit==false) then
        res = "(缺失) " .. res
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
