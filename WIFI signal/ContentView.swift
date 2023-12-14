//
//  ContentView.swift
//  WIFI signal
//
//  Created by User on 12/4/23.
//

import SwiftUI
import Combine
import Network




struct ContentView: View {
    @State var locationName = ""
    @State var wifiSignal = ""

    @State var showNewScreen = false
    @Environment(\.presentationMode) var presentationMode

    @StateObject var deviceLocationService = DeviceLocationService.shared

    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0, 0)
    
    var body: some View {
        
        ZStack {
            VStack {
                VStack{
                    

                    CardViewUserLocation(coordinates: $coordinates).previewLayout(.sizeThatFits)
                    CardViewWIFISignal(wifiSignal: $wifiSignal).previewLayout(.sizeThatFits)
                }
                Spacer()
                VStack{
                    Button {
                        showNewScreen.toggle()
                    }label: {
                        Text("Proceed")
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width-40)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                            .font(.system(size: 16))
                            .background(Color("color_blue").cornerRadius(10))
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                  
                }
            }
            .padding()
            
            PopUp(showNewScreen: $showNewScreen,locationName: $locationName, wifiSignal: $wifiSignal, coordinates: $coordinates)
                .offset(y: showNewScreen ? 0 : UIScreen.main.bounds.height)
                .animation(.spring())
        }
        .onAppear {
                     observeCoordinateUpdates()
                    observeDeniedLocationAccess()
                    deviceLocationService.requestLocationUpdates()
                }
    }
    
    
    func observeCoordinateUpdates() {
          deviceLocationService.coordinatesPublisher
              .receive(on: DispatchQueue.main)
              .sink { completion in
                  print("Handle \(completion) for error and finished subscription.")
              } receiveValue: { coordinates in
                  self.coordinates = (coordinates.latitude, coordinates.longitude)
              }
              .store(in: &tokens)
      }

      func observeDeniedLocationAccess() {
          deviceLocationService.deniedLocationAccessPublisher
              .receive(on: DispatchQueue.main)
              .sink {
                  print("Handle access denied event, possibly with an alert.")
              }
              .store(in: &tokens)
      }
    

}

#Preview {
    ContentView()
}

struct CardViewUserLocation: View {
    @Binding var coordinates: (lat: Double, lon: Double)

    var body: some View {
        VStack {
            
            Text("User location")
                .font(.system(size: 16))
                .padding()
            
            Text("Latitude: \(coordinates.lat)")
                .font(.system(size: 14))
                .frame(width: UIScreen.main.bounds.width-80,alignment: .leading)
            
            Text("Longitude: \(coordinates.lon)")
                .font(.system(size: 14))
                .frame(width: UIScreen.main.bounds.width-80,alignment: .leading)
                .padding(5)
            
//            Text("Address: Alexander Brown Hall, UCH, Ibadan, Oyo State")
//                .font(.system(size: 14))
//                .frame(width: UIScreen.main.bounds.width-80,alignment: .leading)
//                .padding(5)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width-40, height: 130) // Adjust the width and height according to your needs
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
    }
}

struct CardViewWIFISignal: View {
    @Binding var wifiSignal: String

    var body: some View {
        VStack {
            
            Text("WIFI Signal")
                .font(.system(size: 16))
                .padding()
            
            Text(wifiSignal)
                .font(.system(size: 24))
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width-40, height: 120) // Adjust the width and height according to your needs
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
    }
}

struct PopUp: View{
    @Environment(\.presentationMode) var presentationMode
    @Binding var showNewScreen: Bool
    @State private var showingAlert = false
    @Binding var locationName: String
    @Binding var wifiSignal: String
    @Binding var coordinates: (lat: Double, lon: Double)


    var body: some View{
        
        ZStack{
            ZStack {
                VStack {
                    Button {
                        //presentationMode.wrappedValue.dismiss()
                        showNewScreen.toggle()
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-200)
                            .foregroundColor(.black)
                            .opacity(0.6)
                        .ignoresSafeArea()
                    }
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                    VStack {
                        VStack{
                            Text("Location")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                                .padding()
                            
                            VStack {
                                FloatingTextField(placeholder: "Location name", input: $locationName)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                FloatingTextField(placeholder: "WIFI Signal", input: $wifiSignal)
                                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                            }.frame(width: UIScreen.main.bounds.width-40)
                            

                            }.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                        
                        
                        Spacer()
                        
                        Button {
                            
                            writeToCSVFile(coordinates: coordinates, locationName: locationName, wifiSignal: wifiSignal)
                            
                            showingAlert = true


                        }label: {
                            Text("Save")
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width-60)
                                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                                .font(.system(size: 16))
                                .background(Color("color_blue").cornerRadius(10))
                        }.alert("You have successfully saved to \(locationName)", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { 
                                locationName = ""
                                showNewScreen.toggle()
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                        
                        

                    }.frame(width: UIScreen.main.bounds.width, height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                )

                    
                }
                    

               
            }
        }
        
        
    }
 
    func writeToCSVFile(coordinates: (lat: Double, lon: Double),locationName: String,wifiSignal: String){

        
        // File name
        let sFileName = "wifi_signal.csv"
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let documentURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(sFileName)
        
        let output = OutputStream.toMemory()
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        if existingFile(fileName: sFileName) == true {
            //file exist update
            // Array to add data
            
            do{
                let savedData =  try String(contentsOf: documentURL)
                let rows = savedData.components(separatedBy: "\n")
                print(rows)
                print("each")
                
                
                var count = 0
                for row in rows {
                    let colomn = row.components(separatedBy: ",")
                    
                    for item in colomn{
                        print(item)
                        csvWriter?.writeField(item)
                    }
                    csvWriter?.finishLine()
                    
                }

            }
            catch{
                
            }
            
            csvWriter?.writeField(getCurrentDate())
            csvWriter?.writeField(coordinates.lat)
            csvWriter?.writeField(locationName)
            csvWriter?.writeField(coordinates.lon)
            csvWriter?.writeField(wifiSignal)
            csvWriter?.finishLine()

          } else {
             //File does not exist
             // Header
             csvWriter?.writeField("Date")
             csvWriter?.writeField("Latitude")
             csvWriter?.writeField("Location_Name")
             csvWriter?.writeField("Longitude")
             csvWriter?.writeField("WIFI_Signal")
             csvWriter?.finishLine()
                    
                    // Array to add data
                    
            csvWriter?.writeField(getCurrentDate())
            csvWriter?.writeField(coordinates.lat)
            csvWriter?.writeField(locationName)
            csvWriter?.writeField(coordinates.lon)
                    csvWriter?.writeField(wifiSignal)
                    csvWriter?.finishLine()

                }

        
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        do{
            try buffer.write(to: documentURL)
        }catch{
            
        }

    }
    
    func getCurrentDate() -> String {

            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

            return dateFormatter.string(from: Date())

        }
    
    func existingFile(fileName: String) -> Bool {

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(fileName)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath)

           {

            return true

            } else {

            return false

            }

        } else {

            return false

            }


    }
}

struct FloatingTextField: View {
    
    let placeholder: String
    @Binding var input: String

    var body: some View {
        ZStack {
            HStack {
                TextField(placeholder,text: $input)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black,lineWidth: 0.3)
                            .frame(height: 60)
                            
                        
                    )
            }.frame(height: 60)
                
            if(input != ""){
                Text(" " + placeholder)
                    .opacity(0.4)
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .background(.white)
                    .animation(Animation.easeInOut(duration: 0.4), value: EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    .frame(width: UIScreen.main.bounds.width-40, height: 80, alignment: .topLeading)
            }
            
            
            
        }
    }
}




