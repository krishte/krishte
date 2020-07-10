//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

//class Classcool: Identifiable {
//    var name: String = ""
//    var attentionspan: Int = 0
//    var tolerance: Int = 0
//    var color: Color = Color.blue
//    var assignmentlist: [Assignment] = []
//
//    init(name: String, attentionspan: Int, tolerance: Int, color: Color, assignmentlist: [Assignment])
//    {
//        self.name = name
//        self.attentionspan = attentionspan
//        self.tolerance = tolerance
//        self.color = color
//        self.assignmentlist = assignmentlist
//    }
//}

//class Assignment: Identifiable {
//    var subject: String = ""
//    var name: String = ""
//    var type: AssignmentTypes = AssignmentTypes.exam
//    var duedate: Date
//    var totaltime: Int = 0
//    var progress: Int = 0
//    var timeleft: Int = 0
//    var subassigmentlist: [SubAssignment] = []
//
//
//    init(subject: String, name: String, type: AssignmentTypes, duedate: Date, totaltime: Int, progress: Int, timeleft: Int, subsylist: [SubAssignment])
//    {
//        self.subject = subject
//        self.name = name
//        self.type = type
//        self.duedate = duedate
//        self.totaltime = totaltime
//        self.progress = progress
//        self.timeleft = timeleft
//        self.subassigmentlist = subsylist
//
//    }
//
//}

//enum AssignmentTypes: String {
//    case essay
//    case exam
//    case presentation
//    case test
//}

class SubAssignment: Identifiable {
    var startdatetime: String = ""
    var enddatetime: String = ""
    var assignmentname: String = ""
    
    init(startdatetime: String, enddatetime: String, assignmentname: String)
    {
        self.startdatetime = startdatetime
        self.enddatetime = enddatetime
        self.assignmentname = assignmentname
        
    }

}



struct ClassView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    

    var assignmentlist: FetchedResults<Assignment>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(classcool.name).font(.subheadline).fontWeight(.bold)
                if (assignmentlist.count > 0)
                {
                    List {
                        ForEach(assignmentlist) {
                            assignment in
                            Text(assignment.name)
                        }
                    }
                }
            }.background(classcool.color)
            Spacer()
            Text(String(assignmentlist.count))
        }
    }
}

struct DetailView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).fontWeight(.bold)
            Spacer()
            Text("Tolerance: " + String(classcool.tolerance))
            
            
            List {
                ForEach(assignmentlist) {
                    assignment in
                    Text(assignment.name)
                }
            }
        }
    }
}

struct ClassesView: View {

    
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
//
//    var classlist: [Classcool] = [
//        Classcool(name: "German", attentionspan: 5, tolerance: 4, color: Color("one"), assignmentlist: []),
//        Classcool(name: "Math", attentionspan: 4, tolerance: 3,color: Color("two"), assignmentlist: []),
//        Classcool(name: "English", attentionspan: 1, tolerance: 2,color: Color("three"), assignmentlist: [])
//
//
//
//    ]

    var body: some View {
         GeometryReader { geometry in
             NavigationView{
                List {
                    ForEach(classlist) {
                      classcool in
                      NavigationLink(destination: DetailView(classcool: classcool )) {
                        ClassView(classcool:classcool )
                      }
                    }.onDelete { indexSet in
                    for index in indexSet {
                    self.managedObjectContext.delete(self.classlist[index])
                    }
                }
            }
                 .navigationBarItems(
                    leading:
                        HStack(spacing: geometry.size.width / 4.2) {
                            Button(action: {print("settings button clicked")}) {
                                Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }.padding(.leading, 2.0);
                        
                            Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                            Button(action: {print("add button clicked")}) {
                                Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }
                    }.padding(.top, -11.0)).navigationBarTitle(Text("Classes"))
                    
             }
        }
//           HStack {
//             Button(action: {
//               let classnames = ["german", "math", "english", "music", "history"]
//
//
//
//                for classname in classnames {
//                    let newClass = Classcool(context: self.managedObjectContext)
//                    newClass.attentionspan = Int64.random(in: 0 ... 10)
//                    newClass.tolerance = Int64.random(in: 0 ... 10)
//                    newClass.name = classname
//                    do {
//                       try self.managedObjectContext.save()
//                       print("Order saved.")
//                      } catch {
//                       print(error.localizedDescription)
//                       }
//                }
//
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)

    }
}
