import SwiftUI
import CoreData
import SwiftData

@main
struct WeatherApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
        }
    }
}

protocol WeatherDataProtocol {
    var id: UUID { get }
    var city: String { get }
    var temperature: String { get }
    var humidity: String { get }
    var windSpeed: String { get }
    var rainAmount: String { get }
}

struct WeatherData: Identifiable, WeatherDataProtocol {
    let id = UUID()
    let city: String
    let temperature: String
    let humidity: String
    let windSpeed: String
    let rainAmount: String
}

class AppSettings: ObservableObject {
    @Published var accentColor: Color = .accentColor
    @Published var temperatureUnit: String = "Celsius"
    @Published var capitalCity: String? = nil
    @Published var cities: [WeatherData] = []
}

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personalisierung")) {
                    ColorPicker("Akzentfarbe", selection: $appSettings.accentColor)
                    
                    Picker("Einheit", selection: $appSettings.temperatureUnit) {
                        Text("Celsius").tag("Celsius")
                        Text("Fahrenheit").tag("Fahrenheit")
                    }
                }
                Section(header: Text("Wetterstation")) {
                    HStack {
                        Text("Akkustand")
                        Text("87%").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Update Status")
                        Spacer()
                        Text("Kein Update verfügbar 😀").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Stationsname")
                        Spacer()
                        TextField("Geben Sie Ihren Namen ein", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                if !appSettings.cities.isEmpty {
                    Section(header: Text("Hauptstadt")) {
                        Picker("Hauptstadt", selection: $appSettings.capitalCity) {
                            ForEach(appSettings.cities, id: \.id) { city in
                                Text(city.city).tag(city.city as String?)
                            }
                        }
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("Version: 1.0.0 Beta")
                    Text("Entwickler: Weatherstation Company 🌦️")
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddCityView: View {
    @Binding var cities: [WeatherData]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    let allCities = [
        WeatherData(city: "Berlin", temperature: "5°C", humidity: "70%", windSpeed: "10 km/h", rainAmount: "0 mm"),
        WeatherData(city: "Hamburg", temperature: "4°C", humidity: "75%", windSpeed: "12 km/h", rainAmount: "0.2 mm"),
        WeatherData(city: "München", temperature: "4°C", humidity: "53%", windSpeed: "8 km/h", rainAmount: "4 mm"),
        WeatherData(city: "Bremen", temperature: "3°C", humidity: "45%", windSpeed: "12 km/h", rainAmount: "4 mm"),
        WeatherData(city: "Köln", temperature: "6°C", humidity: "65%", windSpeed: "14 km/h", rainAmount: "0.1 mm"),
        WeatherData(city: "Bünde", temperature: "8°C", humidity: "62%", windSpeed: "13 km/h", rainAmount: "0.2 mm"), 
        WeatherData(city: "Zürich", temperature: "3°C", humidity: "47%", windSpeed: "7 km/h", rainAmount: "3.7 mm"), 
        WeatherData(city: "Bern", temperature: "4°C", humidity: "49%", windSpeed: "5 km/h", rainAmount:"2.1 mm"), 
        WeatherData(city:"Stuttgart",temperature:"3°C",humidity:"51%",windSpeed:"4 km/h",rainAmount:"1.2 mm"),
        WeatherData(city:"Osnabrück",temperature:"6°C",humidity:"52%",windSpeed:"3 km/h",rainAmount:"7.2 mm"), 
        WeatherData(city:"Herford",temperature:"3,4°C",humidity:"51%",windSpeed:"4 km/h",rainAmount:"2.3 mm"), 
        WeatherData(city:"Minden",temperature:"5°C",humidity:"51%",windSpeed:"4 km/h",rainAmount:"2.3 mm"), 
        WeatherData(city:"Bielefeld",temperature:"5°C",humidity:"51%",windSpeed:"5 km/h",rainAmount:"3.1 mm"), 
        WeatherData(city:"Paderborn",temperature:"6°C",humidity:"52%",windSpeed:"6 km/h",rainAmount:"4.2 mm"), 
        
    ]
    
    var filteredCities:[WeatherData]{
        if searchText.isEmpty{
            return allCities
        }else{
            return allCities.filter{ $0.city.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var body : some View{
        NavigationView{
            VStack{
                List(filteredCities,id:\.id){ city in 
                    Button(action:{
                        if !cities.contains(where:{ $0.city==city.city}){
                            cities.append(city)
                        }
                        dismiss()
                    }){
                        Text(city.city).foregroundColor(.blue)
                    }
                }
                .searchable(text:$searchText,prompt :Text ("Stadt suchen..."))
            }
            .navigationBarTitle ("Städte hinzufügen" ,displayMode:.inline)
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    Button(action:{ dismiss()}){
                        Image(systemName:"xmark").foregroundColor(.accentColor)
                    }
                }
            }
            .scrollDismissesKeyboard(/*@START_MENU_TOKEN@*/.immediately/*@END_MENU_TOKEN@*/)
        }
    }   
}

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showAddCityView = false
    @State private var showSettings = false
    @State private var selectedCityIndex = 0
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                appSettings.accentColor
                    .ignoresSafeArea()
                
                VStack {
                    if appSettings.cities.isEmpty {
                        Text("Aktuell keine Städte hier")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .onAppear {
                                showAlert = true
                            }
                    } else {
                        TabView(selection: $selectedCityIndex) {
                            ForEach(appSettings.cities.indices, id: \.self) { index in
                                ScrollView {
                                    VStack(spacing: 16) {
                                        weatherTab(
                                            title: "Stadt",
                                            icon: "building.2.fill",
                                            content: appSettings.cities[index].city
                                        )
                                        weatherTab(
                                            title: "Temperatur",
                                            icon: "thermometer.sun.fill",
                                            content: formatTemperature(appSettings.cities[index].temperature)
                                        )
                                        weatherTab(
                                            title: "Luftfeuchtigkeit",
                                            icon: "humidity.fill",
                                            content: appSettings.cities[index].humidity
                                        )
                                        weatherTab(
                                            title: "Windgeschwindigkeit",
                                            icon: "wind",
                                            content: appSettings.cities[index].windSpeed
                                        )
                                        weatherTab(
                                            title: "Niederschlag",
                                            icon: "cloud.rain.fill",
                                            content: appSettings.cities[index].rainAmount
                                        )
                                    }
                                    .padding()
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                    }
                }
            }
            .navigationTitle("Wetterübersicht")
            .navigationBarItems(
                leading: Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .foregroundColor(.black)
                }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    },
                trailing: Button(action: { showAddCityView = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                }
                    .sheet(isPresented: $showAddCityView) {
                        AddCityView(cities: $appSettings.cities)
                    }
            )
            .alert("Kleiner Hinweis", isPresented: $showAlert) {
                Button("Nein, danke", role: .cancel) {}
                Button("Stadt hinzufügen") {
                    showAddCityView = true
                }
            } message: {
                Text("Wenn du möchtest, kannst du weitere Wetterdaten aus anderen Städten anzeigen. (Daten stammen aus unserer Community)")
            }
        }
    }
    
    // Hier ist die weatherTab-Funktion definiert
    private func weatherTab(title: String, icon: String, content: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(content)
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 80)
    }
    
    private func formatTemperature(_ temperature: String) -> String {
        guard let value = Int(temperature.replacingOccurrences(of: "°C", with: "")) else {
            return temperature
        }
        if appSettings.temperatureUnit == "Celsius" {
            return "\(value)°C"
        } else {
            let fahrenheit = Int(Double(value) * 9 / 5 + 32)
            return "\(fahrenheit)°F"
        }
    }
} 
