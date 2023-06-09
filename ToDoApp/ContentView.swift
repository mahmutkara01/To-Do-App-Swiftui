//
//  ContentView.swift
//  ToDoApp
//
//  Created by mahmut kara on 9.06.2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDark = true
    var body: some View {
        NavigationStack{
            Home()
                .toolbar{
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing){
                        Button(action: {isDark.toggle()}, label: {
                            isDark ? Label("Dark",systemImage: "lightbulb.fill") : Label("Dark",systemImage: "lightbulb")
                        })
                    }
                }.navigationTitle("To-Do App")
                
        }.environment(\.colorScheme, isDark ? .dark : .light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
