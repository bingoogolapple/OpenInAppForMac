try
	tell application "Finder"
		if (count of windows) is 0 then
			error "未检测到已打开的 Finder 窗口，请先打开一个文件夹窗口"
		end if
		set theFolder to (folder of the front window as alias)
		set currentPath to POSIX path of theFolder
	end tell

	do shell script "open -b com.exafunction.windsurf " & quoted form of currentPath
on error errMsg number errNum
	display dialog "执行失败：" & errMsg & "（错误码：" & errNum & "）" buttons {"确定"} default button 1
end try
