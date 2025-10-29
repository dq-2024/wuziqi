# App 图标生成指南

## 设计说明

我已经创建了一个卡通风格的五子棋 App 图标，设计特点：

- **背景**：木质棋盘渐变色调
- **主题**：五子连珠获胜场景
- **风格**：卡通、可爱、醒目
- **元素**：
  - 黑白棋子带有 3D 质感
  - 获胜的三颗黑棋带金色光环
  - 闪光星星效果
  - 柔和的阴影和高光

## 方法一：使用 SwiftUI 生成（推荐）

1. **在 Xcode 中打开项目**
   ```bash
   open Wuziqi.xcodeproj
   ```

2. **打开 AppIconGenerator.swift 文件**
   - 位置：`Wuziqi/Utils/AppIconGenerator.swift`

3. **显示预览**
   - 在 Xcode 右侧点击 "Canvas" 或按 `Option + Cmd + Enter`
   - 选择 `AppIconView_Previews`
   - 你会看到 1024x1024 的图标预览

4. **导出图标**
   - 在预览中右键点击图标
   - 选择 "Show SwiftUI Inspector"
   - 或者直接截图保存

5. **生成所有尺寸**
   - 使用在线工具生成所有需要的尺寸：
     - [appicon.co](https://appicon.co) - 免费
     - [makeappicon.com](https://makeappicon.com) - 免费
   - 上传 1024x1024 的图标
   - 下载生成的所有尺寸

6. **替换图标**
   - 将生成的图标文件拖入 `Assets.xcassets/AppIcon.appiconset/`
   - Xcode 会自动识别并放置到正确位置

## 方法二：使用 AI 图像生成工具

你也可以使用以下工具生成图标：

### 推荐工具：
1. **Midjourney** 或 **DALL-E 3**

   提示词（Prompt）：
   ```
   Cartoon style app icon for Gomoku (Five in a Row) game,
   cute black and white game pieces on wooden board background,
   winning five pieces in a row with golden glow effect,
   sparkle stars, 3D effect, rounded corners, iOS style,
   vibrant colors, friendly and appealing design
   ```

2. **Stable Diffusion**

   提示词：
   ```
   app icon, gomoku game, cartoon style, five black pieces in a row,
   white pieces, wooden board, golden winner glow, sparkles,
   3D rendered, cute, iOS style, 1024x1024
   ```

3. **在线设计工具**
   - [Canva](https://canva.com) - 使用模板自定义
   - [Figma](https://figma.com) - 专业设计工具
   - [Adobe Express](https://express.adobe.com) - 快速设计

## 方法三：手动截图（快速方案）

1. 在 Xcode 中运行 App
2. 在模拟器中显示图标预览
3. 使用 macOS 截图工具：
   - `Cmd + Shift + 4` 然后按空格键
   - 点击窗口截图
4. 使用图像编辑工具调整大小

## iOS App 图标尺寸要求

| 设备/用途 | 尺寸 |
|----------|------|
| App Store | 1024x1024 |
| iPhone 通知 @2x | 40x40 |
| iPhone 通知 @3x | 60x60 |
| iPhone 设置 @2x | 58x58 |
| iPhone 设置 @3x | 87x87 |
| iPhone Spotlight @2x | 80x80 |
| iPhone Spotlight @3x | 120x120 |
| iPhone App @2x | 120x120 |
| iPhone App @3x | 180x180 |
| iPad 通知 @1x | 20x20 |
| iPad 通知 @2x | 40x40 |
| iPad 设置 @1x | 29x29 |
| iPad 设置 @2x | 58x58 |
| iPad Spotlight @1x | 40x40 |
| iPad Spotlight @2x | 80x80 |
| iPad App @1x | 76x76 |
| iPad App @2x | 152x152 |
| iPad Pro App @2x | 167x167 |

## 设计建议

1. **保持简洁**：图标在小尺寸下也要清晰可辨
2. **使用对比色**：确保在不同背景下都醒目
3. **圆角处理**：iOS 会自动应用圆角，设计时考虑这点
4. **测试多尺寸**：在不同设备上预览效果
5. **避免文字**：小图标上文字难以阅读
6. **统一风格**：与 App 整体设计风格一致

## 快速预览代码

如果你想在 App 中直接预览图标，可以临时修改 `ContentView.swift`：

```swift
import SwiftUI

struct ContentView: View {
    @State private var showIconPreview = false

    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("对战", systemImage: "gamecontroller")
                }

            StatisticsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }

            // 临时添加 - 用于预览图标
            AppIconPreview()
                .tabItem {
                    Label("图标", systemImage: "app.badge")
                }
        }
    }
}
```

## 问题排查

**Q: 图标不显示？**
- 检查文件名是否正确
- 确保图标是 PNG 格式
- 清理项目（Product > Clean Build Folder）

**Q: 图标被拉伸？**
- 确保图标是正方形
- 检查分辨率是否正确

**Q: 图标边缘被裁剪？**
- iOS 会自动添加圆角
- 重要内容保持在安全区域内（距离边缘 10%）
