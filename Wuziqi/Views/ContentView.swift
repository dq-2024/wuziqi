//
//  ContentView.swift
//  Wuziqi
//
//  主视图 - 标签页容器
//

import SwiftUI

struct ContentView: View {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
