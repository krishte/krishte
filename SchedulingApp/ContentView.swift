//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
import Foundation
import SwiftUI
import UserNotifications
import GoogleSignIn
import GoogleAPIClientForREST

class DisplayedDate: ObservableObject {
    @Published var score: Int = 0
}

class AddTimeSubassignment: ObservableObject {
    @Published var subassignmentname = "SubAssignmentNameBlank"
    @Published var subassignmentlength = 0
    @Published var subassignmentcolor = "one"
    @Published var subassignmentstarttimetext = "aa:bb"
    @Published var subassignmentendtimetext = "cc:dd"
    @Published var subassignmentdatetext = "dd/mm/yy"
    @Published var subassignmentindex = 0
    @Published var subassignmentcompletionpercentage: Double = 0
}

class ActionViewPresets: ObservableObject {
    @Published var actionViewOffset: CGFloat = UIScreen.main.bounds.size.width
    @Published var actionViewType: String = ""
    @Published var actionViewHeight: CGFloat = 0
    
//    @Published var setupLaunchClass: Bool = false
//    @Published var setupLaunchFreetime: Bool = false
}

class AddTimeSubassignmentBacklog: ObservableObject {
    @Published var backlogList: [[String: String]] = []
}

class MasterRunning: ObservableObject {
    @Published var masterRunningNow: Bool = false
    @Published var masterDisplay: Bool = false
    @Published var onlyNotifications: Bool = false
    @Published var displayText: Bool = false
    @Published var uniqueAssignmentName: String = ""
}

struct MasterRunningDisplay: View {
    @EnvironmentObject var masterRunning: MasterRunning
  //  @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            Text("Optimizing Schedule").foregroundColor(Color.black)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2.5, style: .continuous).foregroundColor(.gray).opacity(0.6).frame(width: 163, height: 5)
                RoundedRectangle(cornerRadius: 2.5, style: .continuous).foregroundColor(.blue).frame(width: masterRunning.masterDisplay ? 163 : 0, height: 5).animation(Animation.easeInOut(duration: 1.2).delay(0.4))
            }.cornerRadius(3)
        }.padding(.all, 15).frame(maxHeight: 70).background(Color.white).cornerRadius(10).padding(.all, 15).shadow(radius: 3)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
   // @EnvironmentObject var googleDelegate: GoogleDelegate

    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var firstLaunchTutorial: Bool = false
    
    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        

       // UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().backgroundColor = .clear
//        changingDate.score = 1
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @State var newclasspresenting = false
    //every time new update, create new userdefaultsvar for that update. If false, recreate userdefaultsvars and core data safely (with whatever updated properties)
    func initialize() {
        let defaults = UserDefaults.standard

        if !(defaults.object(forKey: "LaunchedBefore") as? Bool ?? false) {
            defaults.set(true, forKey: "LaunchedBefore")
         //   print("kewl")
            let gradingschemes: [String] = ["P", "N1-7", "LA-F", "N1-8", "N1-4"]
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
            
            
            defaults.set(gradingschemes, forKey: "savedgradingschemes")
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
            
            for assignmenttype in assignmenttypes {
                let newType = AssignmentTypes(context: self.managedObjectContext)
                
                newType.type = assignmenttype
                newType.rangemin = 60
                newType.rangemax = 180
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            defaults.set(Date(), forKey: "lastNudgeDate")
            
            self.firstLaunchTutorial = true
        }
        var val = defaults.object(forKey: "weeklyzeroday") as? Date
        if (val == nil)
        {
            val = Date()
        }
        if (Date() > val!)
        {
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
        }
        for (index, element) in classlist.enumerated()
        {
            if (element.isTrash)
            {
                self.managedObjectContext.delete(self.classlist[index])
            }

        }
        
        
    }
    @State var selectedtab = 0
    @State var worktype1selected: Bool = true

    @State var rotation = 0.0
    
    let demoMaxWidth = UIScreen.main.bounds.size.width/2 - 30
    
    @State var essayDemoWidth: CGFloat = 50
    @State var essayDemoOffset1: CGFloat = 15 //rectangle
    @State var essayDemoOffset2: CGFloat = -10 //circle 1
    @State var essayDemoOffset3: CGFloat = 40 //circle 2
    
    var body: some View {
        ZStack {
            if (!firstLaunchTutorial)
            {
//                NavigationView
//                {
                VStack
                {
                  //  ZStack
                   // {
                     //   TabView(selection: $selectedtab)
            //            {
                    VStack
                    {
                        if (selectedtab == 0)
                        {
                            
                            
                            
                            HStack {
                                VStack(spacing: 5) {
                                    HStack {
                                        Text("Essay")
                                        Spacer()
                                    }
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                                        )
                                        
                                        Rectangle().fill(Color.green).frame(width: self.essayDemoWidth, height: 19).offset(x: self.essayDemoOffset1)
                                    
                                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: self.essayDemoOffset2)
                                        
                                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: self.essayDemoOffset3)
                                    }
                                    
                                    VStack(spacing: 5) {
                                        HStack {
                                            Text("Exam")
                                            Spacer()
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                                            )
                                            
                                            Rectangle().fill(Color.green).frame(width: 0.45 * self.demoMaxWidth, height: 19).offset(x: -0.25 * self.demoMaxWidth)
                                            
                                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: -0.35 * self.demoMaxWidth)
                                            
                                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: 0.1 * self.demoMaxWidth)
                                        }
                                        
                                        HStack {
                                            Text("Homework")
                                            Spacer()
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.demoMaxWidth, height: 20, alignment: .leading).overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: UIScreen.main.bounds.size.width/2 - 30, height: 20, alignment: .leading)
                                            )
                                            
                                            Rectangle().fill(Color.green).frame(width: 0.45 * self.demoMaxWidth, height: 19).offset(x: -0.25 * self.demoMaxWidth)
                                            
                                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: -0.35 * self.demoMaxWidth)
                                            
                                            Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2).offset(x: 0.1 * self.demoMaxWidth)
                                        }
                                    }.blur(radius: 2)
                                }.frame(width: UIScreen.main.bounds.size.width/2 - 10)
                            
                                VStack {
                                    
                                }.frame(width: UIScreen.main.bounds.size.width/2 - 10)
                            }.frame(width: UIScreen.main.bounds.size.width - 10).padding(.horizontal, 5)
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            VStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).frame(width: 40, height: 60)
                                
                                Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 200, height: 200)
                                            .rotationEffect(.degrees(rotation))
                                            .animation(Animation.easeInOut(duration: 3).delay(1), value: rotation)
                                            .onTapGesture {
                                                rotation += 360
                                            }
                                
                            }.tag(0)
                            
//                            VStack
//                            {
//                                Spacer().frame(height: 20)
//                                Text("Intro").font(.system(size: 50)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)//.padding(.top, -30)//.frame(alignment: .leading)
//                                Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 300)//.padding(.top, -50)
//                                Spacer().frame(height: 50)
//                                Image("Tracr").resizable().aspectRatio(contentMode: .fit).frame(width: 200)
//
//                                Text("Welcome to TRACR. An app designed to help you stay on top of your schoolwork. Press next to continue the setup process and get started with the app. You can edit the settings you're about to select at any point unless otherwise indicated. ").padding(20)
//                                Spacer()
//                            }.tag(0)
                        }
                        if (selectedtab == 1)
                        {
                            
//                                NavigationLink(destination: GoogleView())
//                                {
//                                    Text("Click me")
//                                }.gesture(DragGesture()).tag(1)
                            NavigationView
                            {
                                GoogleUnsignedinView().tag(1)
                            }.navigationTitle("Google Stuff").navigationBarTitleDisplayMode(.inline)
                        }
                        if (selectedtab == 2)
                        {
                            NavigationView
                            {
                                SyllabusView(showinginfo: true).tag(2)
                               // Text("This is the syllabus stuff")

                            }.navigationTitle("Syllabus").navigationBarTitleDisplayMode(.large)
                        }
                        if (selectedtab == 3)
                        {
                            NavigationView
                            {
                            ScrollView
                            {
                               VStack
                               {
                                Spacer().frame(height: 20)
                                    HStack
                                    {
                                        Spacer()
                                        Button(action:
                                                {
                                                    worktype1selected = true
                                                })
                                        {
                                            ZStack
                                            {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.clear).frame(width:UIScreen.main.bounds.size.width/2)
                                                if (worktype1selected)
                                                {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width:UIScreen.main.bounds.size.width/2 - 20 )
                                                }
                                                TabView
                                                {
                                                    Image("WorkHoursType1").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width/2-10).padding(.vertical, 20)
                                                    Image("HomeViewType1").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width/2-10).padding(.vertical, 20)
                                                }.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)).tabViewStyle(PageTabViewStyle())
                                            }.offset(x: 10)
                                        }
                                        Spacer().frame(width: 20)
                                        Button(action:
                                                {
                                                    worktype1selected = false
                                                })
                                        {
                                            ZStack
                                            {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.clear).frame(width:UIScreen.main.bounds.size.width/2)
                                                if (!worktype1selected)
                                                {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width:UIScreen.main.bounds.size.width/2 - 20 )
                                                }
                                                TabView
                                                {
                                                    Image("WorkHoursType2").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width/2-10).padding(.vertical, 20)
                                                    Image("HomeViewType2").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width/2-10).padding(.vertical, 20)
                                                }.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)).tabViewStyle(PageTabViewStyle())
                                            }.offset(x: -10)
                                        }
                                        Spacer()
                                    }
                                Spacer().frame(height: 10)
                                    HStack
                                    {
                                        Spacer()
                                        VStack
                                        {
                                            Text("Option 1").fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width/2-40)
                                            Text("This option requires you only to select amounts of time to work on each day. For example, you could set yourself 5 hours on Mondays.").frame(width: UIScreen.main.bounds.size.width/2-40)
                                            Spacer()
                                        }
                                        Spacer().frame(width: 20)
                                        VStack
                                        {
                                            Text("Option 2").fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width/2-40)
                                            Text("This option requires you to select amonts of time to work on each day in addition to when the time will take place. For example, you could set yourself 5 hours from 8am to 13pm on Mondays.").frame(width: UIScreen.main.bounds.size.width/2-40)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                
                               }
                            }.navigationTitle("Work Hours Type").navigationBarTitleDisplayMode(.inline)
                            }.onDisappear {
                                let defaults = UserDefaults.standard
                                defaults.set(!worktype1selected, forKey: "specificworktimes")
                            }
                        }
                        if (selectedtab == 4)
                        {
                            NavigationView
                            {
                                WorkHours().tag(4)
                            }//.navigationTitle("Work Hours").navigationBarTitleDisplayMode(.inline)
                        }

                        if (selectedtab == 5)
                        {
                            NavigationView
                            {
                                ScrollView
                                {
                                    VStack
                                    {
                                        Spacer()
                                        Text("Yay! Looks like you've completed the setup. Press 'Continue' to start using the app")
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }.frame(height: UIScreen.main.bounds.size.height-90)
                    //Spacer()
                //        }.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)).tabViewStyle(PageTabViewStyle()).navigationBarTitle("Setup", displayMode: .inline)
                    VStack
                    {
                        Spacer()
                        Button(action:
                                {
                                    if (selectedtab < 5)
                                    {
                                        selectedtab += 1
                                    }
                                    else
                                    {
                                        print("hello")
                                        firstLaunchTutorial.toggle()
                                        print("hello2")
                                    }
                                 //   selectedtab += 1
                                })
                        {
                            ZStack
                            {
                                Rectangle().fill(Color.clear).frame(width: UIScreen.main.bounds.size.width-40, height: 70)
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: UIScreen.main.bounds.size.width-40, height: 50)
                                Text("Continue").foregroundColor(Color.white).fontWeight(.bold)
                            }
                        }
                        Spacer().frame(height: 10)
                    }//.frame(height: 50)//.offset(y: UIScreen.main.bounds.size.height-70)

             //   }
 
              //  Spacer()
                        
                    

                }
            }
            else
            {
                TabView {
                    HomeView().tabItem {
                        Image(systemName: "house").resizable().scaledToFill()
                        Text("Home").font(.body)
                    }
                    
                    FilterView().tabItem {
                        Image(systemName:"doc.plaintext").resizable().scaledToFill()
                        Text("Assignments")
                    }
                    
                    ClassesView().tabItem {
                        Image(systemName: "folder").resizable().scaledToFill()
                        Text("Classes")
                    }
                    
                    ProgressView().tabItem {
                        Image(systemName: "chart.bar").resizable().scaledToFit()
                        Text("Progress")
                    }
                    
    //                GoogleView().tabItem {
    //                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
    //                    Text("Hello")
    //                }
            
                
                    

                }.onAppear
                {
                    initialize()
                    let defaults = UserDefaults.standard

                    defaults.set(false, forKey:"accessedclassroom")
                    
                }.onDisappear
                {
                    let defaults = UserDefaults.standard
                    defaults.set(Date(timeIntervalSinceNow: 0), forKey: "lastaccessdate")
                    
                }//.accentColor(Color.orange)
                
                VStack {
                    MasterRunningDisplay().offset(y: masterRunning.masterDisplay ? 0 : -200 ).animation(.spring())
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width).background((masterRunning.masterDisplay ? Color(UIColor.label).opacity(0.15) : Color.clear).edgesIgnoringSafeArea(.all))
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        ContentView()
    }
}

struct CoolView1: View
{
    
    var body: some View
    {
        NavigationLink(destination: Text("kewl2"))
        {
            Text("kewl")
        }
    }
}

