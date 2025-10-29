//
//  AppIconGenerator.swift
//  Wuziqi
//
//  App 图标生成器 - 卡通风格五子棋图标
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // 背景 - 木质棋盘渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.7, blue: 0.4),
                    Color(red: 0.75, green: 0.6, blue: 0.35)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 棋盘网格（简化版）
            VStack(spacing: 20) {
                ForEach(0..<4) { _ in
                    HStack(spacing: 20) {
                        ForEach(0..<4) { _ in
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .padding(30)

            // 中心的五子连珠图案
            VStack(spacing: -35) {
                // 第一行 - 斜线的一部分
                HStack(spacing: 45) {
                    CartoonPiece(color: .black, size: 55, showSparkle: false)
                    Spacer()
                }
                .padding(.leading, 40)

                // 第二行 - 中心
                HStack(spacing: 35) {
                    Spacer()
                    CartoonPiece(color: .black, size: 60, showSparkle: true)
                    CartoonPiece(color: .white, size: 60, showSparkle: true)
                    Spacer()
                }

                // 第三行 - 获胜的五连
                HStack(spacing: -30) {
                    CartoonPiece(color: .black, size: 70, showSparkle: true, isWinning: true)
                    CartoonPiece(color: .black, size: 70, showSparkle: true, isWinning: true)
                    CartoonPiece(color: .black, size: 70, showSparkle: true, isWinning: true)
                }

                // 第四行
                HStack(spacing: 35) {
                    Spacer()
                    CartoonPiece(color: .white, size: 60, showSparkle: false)
                    CartoonPiece(color: .black, size: 55, showSparkle: false)
                    Spacer()
                }

                // 第五行
                HStack(spacing: 45) {
                    Spacer()
                    CartoonPiece(color: .white, size: 55, showSparkle: false)
                }
                .padding(.trailing, 40)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

// 卡通风格棋子
struct CartoonPiece: View {
    let color: Color
    let size: CGFloat
    let showSparkle: Bool
    var isWinning: Bool = false

    var body: some View {
        ZStack {
            // 阴影
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: size, height: size)
                .offset(x: 3, y: 3)
                .blur(radius: 4)

            // 主体
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: color == .black ? [
                            Color.gray,
                            Color.black,
                            Color.black
                        ] : [
                            Color.white,
                            Color.white,
                            Color(white: 0.85)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)

            // 高光
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(color == .black ? 0.4 : 0.9),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(x: -size * 0.15, y: -size * 0.15)

            // 描边
            Circle()
                .strokeBorder(
                    color == .black ? Color.white.opacity(0.2) : Color.gray.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            // 获胜光环
            if isWinning {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow,
                                Color.orange,
                                Color.yellow
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: size + 8, height: size + 8)
            }

            // 闪光效果
            if showSparkle {
                ForEach(0..<3) { index in
                    SparkleShape()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 12, height: 12)
                        .rotationEffect(.degrees(Double(index) * 120))
                        .offset(x: size * 0.4, y: -size * 0.3)
                }
            }
        }
    }
}

// 星星闪光形状
struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4

        for i in 0..<4 {
            let angle = Double(i) * .pi / 2 - .pi / 2
            let point = CGPoint(
                x: center.x + outerRadius * cos(angle),
                y: center.y + outerRadius * sin(angle)
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }

            let innerAngle = angle + .pi / 4
            let innerPoint = CGPoint(
                x: center.x + innerRadius * cos(innerAngle),
                y: center.y + innerRadius * sin(innerAngle)
            )
            path.addLine(to: innerPoint)
        }

        path.closeSubpath()
        return path
    }
}

// 预览和导出视图
struct AppIconPreview: View {
    @State private var showExportInfo = false

    var body: some View {
        VStack(spacing: 20) {
            Text("五子棋 App 图标")
                .font(.title)
                .bold()

            // 不同尺寸预览
            HStack(spacing: 20) {
                VStack {
                    AppIconView()
                        .frame(width: 180, height: 180)
                        .cornerRadius(40)
                        .shadow(radius: 10)
                    Text("180x180")
                        .font(.caption)
                }

                VStack {
                    AppIconView()
                        .frame(width: 120, height: 120)
                        .cornerRadius(27)
                        .shadow(radius: 8)
                    Text("120x120")
                        .font(.caption)
                }

                VStack {
                    AppIconView()
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .shadow(radius: 6)
                    Text("80x80")
                        .font(.caption)
                }
            }

            Button(action: {
                showExportInfo = true
            }) {
                Text("如何导出图标")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert("导出说明", isPresented: $showExportInfo) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("""
            1. 在 Xcode 中运行此预览
            2. 截图或使用 Xcode 的 View Hierarchy 导出
            3. 使用图像编辑工具调整为所需尺寸
            4. 将图标添加到 Assets.xcassets/AppIcon.appiconset

            或使用在线工具生成不同尺寸：
            - appicon.co
            - makeappicon.com
            """)
        }
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppIconPreview()
                .previewLayout(.sizeThatFits)

            AppIconView()
                .frame(width: 1024, height: 1024)
                .previewDisplayName("1024x1024 (App Store)")
        }
    }
}
