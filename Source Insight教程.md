Source Insight快捷键
====================

###tips
操作：移动、选中/复制、删除
对象：字符、单词(词首or词尾)、行、行尾、行首、字符串、函数
*增加中文支持*

###移动
Ctrl+g                  跳转到行
Ctrl+r                  跳转函数
F3                      搜索前一个
F4                      搜索后一个
Ctrl+,                  Go Back
Ctrl+.                  Go Forword
上下左右                移动光标
Alt+ikjl                移动光标
Ctrl+上下左右           按单词移动
Ctrl+=                  跳转符号/函数实现或者跳转到文件
Ctrl+-                  跳转到符号/函数定义
Ctrl+a Ctrl+e           行首 行尾  将光标放至选中单行内容末尾或多行内容每行行尾
ctrl+m                  光标移动至括号内开始或结束的位置
Alt+F3, Shift+F8        高亮，选择所有相同的词
Ctrl + Shift + up       光标所在行与上行互换
Ctrl + Shift + down     光标所在行与下行互换
Ctrl + [                减少当前行缩进
Ctrl + ]                增加当前行缩进
Ctrl+j                  与下一行合并


###选中/复制
Ctrl+c v                复制粘贴
Ctrl+x                  选定内容状态下为剪切内容，未选中为剪切光标当前所在行
Ctrl+y z                撤销/恢复撤销

Shift+左右              字符选中
Shift+Alt+jl

Ctrl+Shift+左右         词选中
ctrl+d                  选中单词 （继续按键则选择下个相同的字符串）
Ctrl+Shift+d            选择词并替换为复制内容
Ctrl+l                  复制行
Ctrl+Shift+l            复制当前行，插入在下一行
ctrl+i                  插入新行(行前)
ctrl+enter              插入新行(行后)
ctrl+shift+m            选择括号内的内容（继续按键则选择父括号）


###删除
Backspace/Delete        删除字符
Ctrl+Backspace          删除单词
Ctrl+Delete             删除单词
Ctrl+Shift+k            删除行
Ctrl+Shift+Backspace    删除到行首
Ctrl+Shift+Delete       删除到行尾

###其他
Ctrl+n                  新建文件
Ctrl+o                  打开文件
Ctrl+w                  关闭窗口
Alt+d                   svn diff
Alt+b                   svn blame
Alt+n                   svn log
Alt+e                   打开explorer                   
>>> Ctrl+Shift+[            折叠打开
>>> Ctrl+Shift+]            代码折叠
>>> F9                      行排序

###有用的设置
关闭自动补全
扩展tab： Expend tab


Source Insight入门
====================
1、常规配置
2、多用通配符，正则
3、Relation Window？？
4、Symbol Window
5、整理自己的快捷键
6、扩展（macro） quicker.em
7、中文支持
8、code view？？
9、source insight调用crt编译？？
10、如何增加菜单


插件配置
====================

如果已经存在Base工程，可以直接将quicker.em加入到其中，并且同步文件。也可以删除它重建立一个Base工程，然后再把quicker.em加入其中，同步工程后，再定义好热键和菜单
si30.CF3是si3.x的配置文件，si21.cf是si2.1的配置文件，它已经定义好菜单和热键。图方便的话可以直接使用这两个配置文件，这样就可以不用自己定义菜单和热键了。
选择Options的Save Configuration先保存自己的配置，以便回退，然后再选择Options的
Load Configuration来装载该配置，如果不喜欢我的配置风格，只想要热键和菜单定义，
只要勾上菜单和热键两个子项即可。

1. 运行Source Insight，打开Base工程，如果没有该工程，则生成它，将Quicker.em加入到工程中
2. 安装触发热键和菜单，打开SI的Options的Key Assignments菜单，在Command窗口中选择AutoExpand，然后对其赋一个热键，例如Ctrl Enter
3. 对于FormatLine,UpdateFunctionList,InsertTraceInfo,InsertFuncName,ReplaceBufTab,ReplaceTabInProj,ComentCPPtoC等功能，可以根据情况定义为菜单或热键
4. 对于Si2.1用户还要做如下配置，将sidate.exe拷贝到si目录
下，打开Options的Custom Commands菜单，在Name窗口写
上sidate，然后在Run窗口选择sidate.exe文件即可
5. Quicker有两种命令，一种是扩展命令，一种是普通命令。
扩展命令：在代码文件中输入命令名，然后按前面AutoExpand宏所定义的热键（Ctrl  Enter）来执行该命令，对于块命令输入命令后再选择输入块

普通命令：直接根据定义的热键或菜单来执行，目前一般的扩展命令都对应有相应的普通命令

