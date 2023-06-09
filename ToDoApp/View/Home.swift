//
//  Home.swift
//  ToDoApp
//
//  Created by mahmut kara on 9.06.2023.
//

import SwiftUI

struct Home: View {
    //View Properties
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks: Bool = true
    @State private var showCompletedTasks: Bool = true
    @State private var selectedLanguage = "tr"

    var body: some View {
        List {
            DatePicker(selection: $filterDate,displayedComponents: [.date]){
                
            }.labelsHidden()
                .datePickerStyle(.graphical)
            
            CustomFilteringDataView(filterDate: $filterDate){
                pendingTasks, completedTasks in
                
                DisclosureGroup(isExpanded: $showPendingTasks){
                    // Custom Core Data Filter View, Which will Display Only Pending Tasks on this Day
                    if pendingTasks.isEmpty {
                        Text("no_tasks_found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(pendingTasks){
                            TaskRow(task: $0, isPendingTask: true)
                        }
                    }
                    
                } label: {
                    HStack(spacing: 5){
                        Text("pending_tasks")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(pendingTasks.isEmpty ? "" : "(\(pendingTasks.count))")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                DisclosureGroup(isExpanded: $showCompletedTasks){
                    // Custom Core Data Filter View, Which will Display Only Completed Tasks on this Day
                    
                    if completedTasks.isEmpty {
                        Text("no_tasks_found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(completedTasks){
                            TaskRow(task: $0, isPendingTask: false)
                        }
                    }
                    
                } label: {
                    Text("completed_tasks")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(completedTasks.isEmpty ? "" : "(\(completedTasks.count))")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
            
           
        }.toolbar{
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing:0) {
                    Button {
                        
                    } label: {
                    
                            Menu {
                                Button(action: {
                                    selectedLanguage = "tr"
                                }) {
                                    Label("turkish", systemImage: "globe")
                                }
                                Button(action: {
                                    selectedLanguage = "en"
                                }) {
                                    Label("english", systemImage: "globe")
                                }
                                
                                //Button("english", action: ingilizce)
                                //Button("turkish", action: turkce)
                                
                                
                            } label : {
                                Image(systemName: "arrow.left.arrow.right.circle")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(10)
                                    .background(.blue .opacity(0.1))
                                    .cornerRadius(30)
                            }
                    }
                    Button {
                        // Simply Opening Pending Task View
                        // Then Adding an Empty Task
                        do {
                            let task = Task(context: env.managedObjectContext)
                            task.id = .init()
                            task.date = filterDate
                            task.title = ""
                            task.isCompleted = false
                            
                            try env.managedObjectContext.save()
                            showPendingTasks = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    } label: {
                        HStack{
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("new_task")
                        }.fontWeight(.bold)
                            .padding(10)
                            .background(.blue .opacity(0.1))
                            .cornerRadius(30)
                    }
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TaskRow: View {
    @ObservedObject var task: Task
    var isPendingTask: Bool
    //View Properties
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    var body: some View{
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
                save()
                
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4){
                TextField("task_title",text: .init(get: {
                    return task.title ?? ""
                }, set: { value in
                    task.title = value
                }))
                .focused($showKeyboard)
                .onSubmit {
                    removeEmptyTask()
                    save()
                }
                .foregroundColor(isPendingTask ? .primary : .gray)
                .strikethrough(!isPendingTask, pattern: .dash,color: .primary)
                //Custom Date Picker
                Text((task.date ?? .init()).formatted(date: .omitted, time:.shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay{
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                        }, set: { value in
                            task.date = value
                            //Saving Date When ever it's Updated
                            save()
                        }), displayedComponents: [.hourAndMinute]){
                            
                        }
                        .labelsHidden()
                        // Hiding View by Utilizing BlendMode Modifier
                        .blendMode(.destinationOver)
                    }
            }
            .frame(maxWidth: .infinity,alignment: .leading)
        }
        .onAppear{
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        //Verifiying Content When user leaves the app
        .onChange(of: env.scenePhase) { newValue in
            if newValue != .active {
                // Checking if  it's Empty
                removeEmptyTask()
                save()
            }
        }
        //Adding Swipe to Delete
        .swipeActions(edge: .trailing,allowsFullSwipe: true) {
            Button(role: .destructive){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    env.managedObjectContext.delete(task)
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    //Context Saving Method
    func save(){
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //Removing Empty Task
    func removeEmptyTask(){
        if(task.title ?? "").isEmpty{
            //Removing Empty Task
            env.managedObjectContext.delete(task)
        }
    }
}
