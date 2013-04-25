
require( "iuplua" )
require( "iupluacontrols" )
dofile( "HippoResWalker.lua" )
dofile( "OutPutInfo.lua")


local shell_arg=arg[1]

test_path="D:\\X52Demo\\resources\\art\\stage\\beach001\\Model\\beach001_boat001.dml"



--gui lay out
local tree_control=iup.tree { title="请打开或者拖拽文件到此",size = "500x200"}
local list_control=iup.list {expand="YES",BGCOLOR="0 0 0",FGCOLOR="0 255 0",size = "500x100",}
local prog_control=iup.progressbar{expand="YES",size = "300x8",BGCOLOR="0 0 0",FGCOLOR="0 255 0"}
local container=iup.vbox
{
	iup.vbox
	{
		tree_control,
		iup.label{ title="\n信息输出:"},
		list_control,
		prog_control
		--iup.multiline{expand="YES", value="I ignore the 'g' key!", border="YES"}
	}
}



function ui_OutputInfo(str)
    list_control.INSERTITEM1="Info >: ".. str
end


function ui_OutputError(str)
    --list_control.FGCOLOR="255 0 0"
    list_control.INSERTITEM1="Error>: ".. str
end

--让所有的输出信息都定位到ui的函数中

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


function r_updatetree(_table,tree,btoplevel)
	for k,v in pairs(_table) do
	    if(btoplevel==1) then
	        tree.addbranch = tostring(k)
	    else
	        tree.addbranch1 = tostring(k)
	    end
		if(type(v)=="string") then
			tree.addleaf1 = v
		else
			r_updatetree(v,tree,0)
		end
	end
end



function UpdateTree(fn,tree)
	ClearTree(tree)
	tree.addbranch = fn
	local t=HippoParseFile(fn)
	local ct={}
    r_converttable(ct,t)
	iup.TreeAddNodes(tree, ct)
	OutPutInfo("完成:" .. fn)
	prog_control.VALUE =prog_control.MAX
end

--main menu

menu_item_open = iup.item {title = "Open"}
menu_item_exit = iup.item {title = "Exit"}
menu_item_about= iup.item {title = "About"}
menu_item_test= iup.item {title = "压力测试"}
menu_file = iup.menu {menu_item_open,menu_item_exit}
menu_help = iup.menu {menu_item_about,menu_item_test}



submenu_file = iup.submenu {menu_file; title = "File"}
submenu_help = iup.submenu {menu_help; title = "Help"}
menu_bar = iup.menu {submenu_file, submenu_help}

function menu_item_test:action()
--[[
    local filedlg = iup.filedlg{
        dialogtype = "DIR",
        title = "选择要压力测试的目录", 
        directory=".\\"} 
    filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
	status = filedlg.status
	if status == "0" then
		dotest_dir(filedlg.value)
	end
--]]
    local res,dirpath=iup.GetParam("要压力测试的目录", nil,"填写目录: %s\n","")
    if(res==1) then
       dotest_dir(filedlg.value)
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
    list_control.REMOVEITEM=nil --等于nil表示清空所有
end
--tree right click menu

local tree_r_expanded =iup.item {title = "全部展开"}
local tree_r_collapsed=iup.item {title = "全部收缩"}
local tree_r_opendir=iup.item {title = "打开目录"}
local tree_r_openfile=iup.item {title = "打开文件"}
local tree_r_viewfile=iup.item {title = "使用本工具单独查看该文件"}
local subitem1=iup.item{title="拷贝路径(/)"}
local subitem2=iup.item{title="拷贝路径(\\)"}
local tree_r_copypath=iup.submenu{
    iup.menu{
      subitem1,
      subitem2
    } 
    ;title="CopyPath"
  }

iup.menu{
      iup.item{title="拷贝路径(/)"},
      iup.item{title="拷贝路径(\\)"}
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

function subitem1:action()

end

function subitem2:action()
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
        --使用explorer是为了能够在shell中定位到文件，否则使用start即可
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
dlg = iup.dialog{ container; title = "HippoResInfo", menu=menu_bar,dragdrop=1}
dlg:showxy (iup.CENTER, iup.CENTER)



--call back of dialog's dragdrop

function dlg:dropfiles_cb(filename , num , x, y)
    print(filename , num , x, y)
    UpdateTree(filename,tree_control)
end



--如果从命令行指定了参数，执行它

if(shell_arg) then
    UpdateTree(shell_arg,tree_control)
end

--main loop
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end














