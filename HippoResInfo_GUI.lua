--package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
--local guidir=string.sub(arg[0],1,)
scriptdir,scriptfile=string.match(arg[0],"(.+\\)(.-\.lua)")
package.cpath = package.cpath..";"..scriptdir.."?.dll;"

require( "iuplua" )
require( "iupluacontrols" )
require( "HippoResWalkerDll")
dofile( scriptdir .. "HippoResWalker.lua" )
dofile( scriptdir .. "OutPutInfo.lua")

local shell_arg=arg[1]

--iup.Message ("HippoResWalker", "Press the button")


--gui lay out
local tree_control=iup.tree { title="��򿪻�����ק�ļ�����",size = "500x200"}
local list_control=iup.list {expand="YES",BGCOLOR="0 0 0",FGCOLOR="0 255 0",size = "500x100",}
local prog_control=iup.progressbar{expand="YES",size = "300x8",BGCOLOR="0 0 0",FGCOLOR="0 255 0"}
local container=iup.vbox
{
	iup.vbox
	{
		tree_control,
		iup.label{ title="\n��Ϣ���:"},
		list_control,
		prog_control
		--iup.multiline{expand="YES", value="I ignore the 'g' key!", border="YES"}
	}
}



function ui_OutputInfo(str)
    if(str~=nil) then
        list_control.INSERTITEM1="Info >:  ".. str
    end
end


function ui_OutputError(str)
    --list_control.FGCOLOR="255 0 0"
    if(str~=nil) then
        list_control.INSERTITEM1="Error>:  ".. str
    end
end

--�����е������Ϣ����λ��ui�ĺ�����

g_OutPutInfoFun=ui_OutputInfo
g_OutPutErrorFun=ui_OutputError


function r_converttable(restable,input)
    if(type(input)=="table") then
        for k,v in pairs(input) do
            local t={}
            if(type(v)=="table") then
                --if(table.getn(v)>0) then
                    t["branchname"]=tostring(k)
                --end
                r_converttable(t,v)
            else
                --t["branchname"]=tostring(v)
                table.insert(restable,tostring(v))              
            end
            table.insert(restable,t)
        end
    else
        table.insert(restable,1,tostring(v))        
    end    
end

function ClearTree(tree)
	tree.VALUE = 0
	tree.delnode = "MARKED"
end



function UpdateTree(fn,tree)
	ClearTree(tree)
	tree.addbranch = fn
	local t=HippoParseFile(fn)
	local ct={}
    r_converttable(ct,t)
	iup.TreeAddNodes(tree, ct)
	OutPutInfo("���:" .. fn)
	prog_control.VALUE =prog_control.MAX
end

--main menu

local menu_item_open = iup.item {title = "Open File"}
local menu_item_exit = iup.item {title = "Exit"}
local menu_item_about= iup.item {title = "About"}
local menu_item_test= iup.item {title = "ѹ������"}
local menu_item_addtoright= iup.item {title = "��ӵ�Explorer�Ҽ��˵�"}


local menu_file = iup.menu {menu_item_open,menu_item_exit}
local menu_tool = iup.menu {menu_item_test,menu_item_addtoright}
local menu_help = iup.menu {menu_item_about}

submenu_file = iup.submenu {menu_file; title = "File"}
submenu_tool = iup.submenu {menu_tool; title = "Tool"}
submenu_help = iup.submenu {menu_help; title = "Help"}
menu_bar = iup.menu {submenu_file, submenu_tool,submenu_help}

function menu_item_addtoright:action()

    --���Ȱ�arg[0] arg[1]��б�ܱ��˫б��
    local luaexepath=string.gsub(arg[-1],"\\","\\\\")
    local scriptpath=string.gsub(arg[0],"\\","\\\\")
    --����1��reg�ļ���ִ����
    --reg�ļ����﷨ʵ����̫......
    local regfile_content=string.format("Windows Registry Editor Version 5.00\n\
[HKEY_CLASSES_ROOT\\*\\Shell\\�� HippoResWalker\\Command]\
@=\"\\\"%s\\\" \\\"%s\\\" \\\"%%1\\\"\"\n ",luaexepath,scriptpath)

    OutPutInfo(regfile_content)
    
    io.output("./right_menu.reg")
    io.write(regfile_content)
    io.close()
    
    OutPutInfo("����reg�ļ��ɹ�: right_menu.reg")
    
    os.execute("regedit ./right_menu.reg")
end
local stresstest_dir=nil
local stress_result_num=0

local stresstest_co

function sync_do_test(dirpath)
    local alldirs={}
    local allfiles={}
	for file in lfs.dir(dirpath) do
        if file ~= "." and file ~= ".." then
            local f = dirpath..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                table.insert(alldirs,dirpath..'/'..file)
            end
        end
    end
    
    for _id,_dirpath in pairs(alldirs) do
        for file in lfs.dir(_dirpath) do
            table.insert(allfiles,_dirpath..'/'..file)
        end
    end
    
    local tot=table.getn(allfiles)
    local idx=0
    for idx,path in pairs(allfiles) do
        HippoParseFile(path)
        idx=idx+1
        coroutine.yield(stresstest_co,idx/tot)   
    end
end


function idle_cb()
	local b,t,percent=coroutine.resume(stresstest_co)
	prog_control.VALUE =percent
	if(not b) then
	    OutPutInfo("���������˳���ԭ��" .. tostring(t))
	end
    if(coroutine.status(stresstest_co)=="dead") then
        iup.SetIdle(nil)
    end
    return iup.DEFAULT
end


function menu_item_test:action()
    local res,dirpath=iup.GetParam("Ҫѹ�����Ե�Ŀ¼", nil,"��дĿ¼: %s\n","")
    if(res==true) then
        ClearTree(tree_control)
        stresstest_co=coroutine.create(sync_do_test)
        local b,t=coroutine.resume(stresstest_co,dirpath)
        iup.SetIdle(idle_cb)

       local msg=string.format("���Test,Ŀ¼:%s,�������ļ�����%d",dirpath,stress_result_num)
       OutPutInfo(msg)
    end

	return iup.DEFAULT
end

function menu_item_open:action()
	local filedlg = iup.filedlg{dialogtype = "OPEN", title = "OPEN",
						  filter = "*.*", filterinfo = "*.*",
						  directory=".\\"}
	filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
	status = filedlg.status
	if status == "0" then
		UpdateTree(filedlg.value,tree_control)
	end
	return iup.DEFAULT
end

--list box right click menu
local list_r_expanded =iup.item {title = "Clear"}
local list_rmenu = iup.menu {
list_r_expanded
}
function list_control:button_cb(but,pressed, x, y,statu)
  if(but==51) then --49=leftbutton 51==right button
    list_rmenu:popup(iup.MOUSEPOS,iup.MOUSEPOS)
  end
end

function list_r_expanded:action()
    list_control.REMOVEITEM=nil --����nil��ʾ�������
end
--tree right click menu

local tree_r_expanded =iup.item {title = "ȫ��չ��"}
local tree_r_collapsed=iup.item {title = "ȫ������"}
local tree_r_opendir=iup.item {title = "��Ŀ¼"}
local tree_r_openfile=iup.item {title = "���ļ�"}
local tree_r_viewfile=iup.item {title = "ʹ�ñ����ߵ����鿴���ļ�"}
local subitem1=iup.item{title="����·��(/)"}
local subitem2=iup.item{title="����·��(\\)"}
local tree_r_copypath=iup.submenu{
    iup.menu{
      subitem1,
      subitem2
    } 
    ;title="CopyPath"
  }

local tree_rmenu = iup.menu {
tree_r_expanded,
tree_r_collapsed,
iup.separator{},

tree_r_opendir,
tree_r_openfile,
tree_r_viewfile,
iup.separator{},

tree_r_copypath
}

--����·��(/)
function subitem1:action()
    local title_id_str="TITLE" .. tostring(tree_control.value)
    local text=tree_control[title_id_str]
    --ת��б��
    local copypath=string.gsub(text,"\\","/")
    
    CopyStringToClipBoard(copypath)
end

--����·��(\\)
function subitem2:action()
    local title_id_str="TITLE" .. tostring(tree_control.value)
    local text=tree_control[title_id_str]
    CopyStringToClipBoard(text)
end



function tree_control:rightclick_cb(id)
  tree_control.value = id
  tree_rmenu:popup(iup.MOUSEPOS,iup.MOUSEPOS)

end

function tree_r_expanded:action()
    tree_control.EXPANDALL  ="YES"
end

function tree_r_collapsed:action()
    tree_control.EXPANDALL  ="NO"
end

function tree_r_opendir:action()
    local title_id_str="TITLE" .. tostring(tree_control.value)
    local text=tree_control[title_id_str]
    local dirpath=string.match(text,"(.+[/\\])")
    if(dirpath~=nil) then
        --os.execute("start " .. dirpath)
        --ʹ��explorer��Ϊ���ܹ���shell�ж�λ���ļ�������ʹ��start����
        os.execute("explorer /select, " .. text) 
    end
    --OutPutInfo(dirpath)
end

function tree_r_openfile:action()
    local title_id_str="TITLE" .. tostring(tree_control.value)
    local text=tree_control[title_id_str]
    os.execute("start " .. text)
end

function tree_r_viewfile:action()
    local title_id_str="TITLE" .. tostring(tree_control.value)
    local text=tree_control[title_id_str]
    local str=string.format("start wlua.exe %s %s",arg[0],text)
    os.execute(str)
end


--dialog
dlg = iup.dialog{ container; title = "Hippo Resource Walker", menu=menu_bar,dragdrop=1}
dlg:showxy (iup.CENTER, iup.CENTER)

--��ӡһ�µ�ǰ������Ϣ
OutPutInfo("arg[-1]=" .. tostring(arg[-1]))
OutPutInfo("arg[0]=" .. tostring(arg[0]))
OutPutInfo("arg[1]=" .. tostring(arg[1]))
OutPutInfo("")

--call back of dialog's dragdrop

function dlg:dropfiles_cb(filename , num , x, y)
    print(filename , num , x, y)
    UpdateTree(filename,tree_control)
end



--�����������ָ���˲�����ִ����

if(shell_arg) then
    UpdateTree(shell_arg,tree_control)
end

--main loop
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end














