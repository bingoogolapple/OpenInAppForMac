#!/usr/bin/env bash
#
# 从 src/*.scpt 源码自动导出为 .app 应用，并替换图标。
# 等价於脚本编辑器「文件 → 导出 → 应用程序」那几个步骤。
#
set -euo pipefail

cd "$(dirname "$0")"

SRC_DIR="src"
BUILD_DIR="build"

# 清空并重建输出目录，避免残留旧产物。
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 收集需要导出的脚本（按文件名排序，保证输出顺序稳定）
found=0
while IFS= read -r scpt; do
  found=1
  name="$(basename "$scpt" .scpt)"        # 例如 OpenInVSCode
  app="$BUILD_DIR/$name.app"
  icns="$SRC_DIR/$name.icns"

  echo "→ 编译 $scpt 为 $app"
  rm -rf "$app"
  # osacompile 参数说明（等价于脚本编辑器「文件 → 导出」）：
  #   -o "$app"  目标以 .app 结尾 ⇒ 文件格式选「应用程序」
  #   不写 -u     ⇒ 「显示启动屏幕」不选（Use startup screen）
  #   不写 -s     ⇒ 「运行处理程序后保持打开」不选（Stay-open applet）
  #   不写 -x     ⇒ 「仅运行」不选（不剥离源码，保留可编辑脚本）
  #   无签名选项 ⇒ 默认「不使用代码签名」（osacompile 本身无签名 flag）
  # 注：下方 codesign --sign - 仅为替换图标后修复 bundle 的 ad-hoc 重签名，
  #     与导出时的「不使用代码签名」无关。
  osacompile -o "$app" "$scpt"

  # 替换图标（src 目录存在同名 .icns 时才处理）
  if [ -f "$icns" ]; then
    echo "  替换图标: $icns"
    # osacompile 默认 CFBundleIconFile=applet（→ applet.icns），直接原地覆盖即可，
    # 无需新增图标文件、也无需改 Info.plist 的 CFBundleIconFile。
    cp "$icns" "$app/Contents/Resources/applet.icns"

    # 关键：osacompile 生成的 app 带有 CFBundleIconName(=applet) 和 Assets.car，
    # 现代 macOS 下它们优先级高于 CFBundleIconFile，会让自定义图标不生效。
    # 删掉该键并移除 Assets.car，强制系统使用上面的 applet.icns。
    /usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" \
      "$app/Contents/Info.plist" 2>/dev/null || true
    rm -f "$app/Contents/Resources/Assets.car"

    # 修改 bundle（Info.plist / 资源）后必须重新签名，否则 ad-hoc 签名失效，
    # 在 Apple 芯片 Mac 上会导致 app 无法启动。「-」表示重新做 ad-hoc 签名。
    if ! codesign --force --sign - "$app" >/dev/null 2>&1; then
      echo "  警告: 重新签名失败，app 在 Apple Silicon 上可能无法启动" >&2
    fi

    # 清除 quarantine 标记：分发给他人或在别处打开时，macOS 会加此属性触发
    # Gatekeeper「无法验证开发者」拦截。构建产物本地自用也清掉以防万一。
    xattr -dr com.apple.quarantine "$app" 2>/dev/null || true
  fi

  # 打包成 zip 方便分发（与 .app 同名，如 OpenInVSCode.zip）。
  # -y 保留可能的符号链接，-q 静默；先删旧的避免追加内容。
  echo "  打包: $name.zip"
  rm -f "$BUILD_DIR/$name.zip"
  # 进入 BUILD_DIR 再压缩，使 zip 内为扁平结构（解压后直接是 .app，而非 build/xxx.app）。
  (cd "$BUILD_DIR" && zip -r -y -q "$name.zip" "$name.app")

  echo "  完成: $PWD/$app"
done < <(find "$SRC_DIR" -maxdepth 1 -name '*.scpt' | sort)

if [ "$found" -eq 0 ]; then
  echo "未在 $SRC_DIR/ 下找到任何 .scpt 脚本" >&2
  exit 1
fi

echo "全部导出完成。"
