try
	-- 第一步：从 Finder 获取目标路径
	tell application "Finder"
		if (count of windows) is 0 then
			error "未检测到已打开的 Finder 窗口，请先打开一个文件夹窗口"
		end if
		set theFolder to (folder of front window as alias)
		set currentPath to POSIX path of theFolder
	end tell

	-- 第二步：判断 iTerm2 是否在运行
	set iTermRunning to (do shell script "pgrep -x iTerm2 >/dev/null 2>&1 && echo yes || echo no") is "yes"

	-- 第三步：构造静默切换目录的启动命令
	set qt to quote
	set shellCmd to "/bin/zsh -c " & qt & "cd " & (quoted form of currentPath) & " && exec /bin/zsh -l" & qt

	if not iTermRunning then
		do shell script "open -b com.googlecode.iterm2 " & quoted form of currentPath
	else
		-- 将 iTerm 专属语法放入 run script 字符串，延迟到运行时再编译。
		-- 这样构建环境（如 GitHub Actions）无需安装 iTerm2 即可通过 osacompile；
		-- 运行时在用户机器上编译，此时 iTerm2 已安装，字典可正常解析。
		set itermScript to "
on run {cmd}
	tell application \"iTerm\"
		if (count of windows) is 0 then
			create window with default profile command cmd
		else
			activate
			tell current window to create tab with default profile command cmd
		end if
	end tell
end run"
		run script itermScript with parameters {shellCmd}
	end if

on error errMsg number errNum
	display dialog "执行失败：" & errMsg & "（错误码：" & errNum & "）" buttons {"确定"} default button 1
end try
