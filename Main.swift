import SwiftUI

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

protocol WeatherStationInfo {
    var id: UUID { get }
    var Name: String { get }
    var temperature: String { get }
    var humidity: String { get }
    var windSpeed: String { get }
    var rainAmount: String { get }
    var collectedwater: String { get }
}

struct WeatherData: Identifiable, WeatherDataProtocol {
    let id = UUID()
    let city: String
    let temperature: String
    let humidity: String
    let windSpeed: String
    let rainAmount: String
}

struct WeatherStationInformation: Identifiable, WeatherStationInfo {
    let id = UUID()
    let Name: String
    let temperature: String
    let humidity: String
    let windSpeed: String
    let rainAmount: String
    let collectedwater: String
}


class AppSettings: ObservableObject {
    @Published var accentColor: Color = .blue 
    @Published var temperatureUnit: String = "Celsius"
    @Published var capitalCity: String? = nil
    @Published var cities: [WeatherData] = []
    @Published var currentStation: WeatherStationInformation? = WeatherStationInformation(
        Name: "Lokation: Bünde",
        temperature: "8°C",
        humidity: "60%",
        windSpeed: "15 km/h",
        rainAmount: "0 mm",
        collectedwater: "20 L"
    )
    @Published var stationname: String = ""
}


struct AccentColorSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    

    let accentColors: [Color] = [
        .blue, .green, .red, .orange, .purple, .pink
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List(accentColors, id: \.self) { color in
                    Button(action: {
                        appSettings.accentColor = color
                        dismiss()  
                    }) {
                        HStack {
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                            Text(color.description.capitalized)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Akzentfarbe")
            }
    }
}
struct AddCityView: View {
    @Binding var citieindex: [WeatherData]
    @Binding var WeatherStation: [WeatherStationInformation]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    let CitieIndex = [
        WeatherData(city: "Berlin", temperature: "5°C", humidity: "70%", windSpeed: "10 km/h", rainAmount: "0 mm"),
        WeatherData(city: "Hamburg", temperature: "4°C", humidity: "75%", windSpeed: "12 km/h", rainAmount: "0.2 mm"),
        WeatherData(city: "München", temperature: "4°C", humidity: "53%", windSpeed: "8 km/h", rainAmount: "4 mm"),
        WeatherData(city: "Bremen", temperature: "3°C", humidity: "45%", windSpeed: "12 km/h", rainAmount: "4 mm"),
        WeatherData(city: "Köln", temperature: "6°C", humidity: "65%", windSpeed: "14 km/h", rainAmount: "0.1 mm"),
        WeatherData(city: "Bünde", temperature: "8°C", humidity: "62%", windSpeed: "13 km/h", rainAmount: "0.2 mm")
    ]
    
    var filteredCities: [WeatherData] {
        if searchText.isEmpty {
            return CitieIndex
        } else {
            return CitieIndex.filter { $0.city.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredCities, id: \.id) { city in
                    Button(action: {
                        if !citieindex.contains(where: { $0.city == city.city }) {
                            citieindex.append(city)
                        }
                        dismiss()
                    }) {
                        Text(city.city).foregroundColor(.blue)
                    }
                }
                .searchable(text: $searchText, prompt: Text("Stadt suchen..."))
            }
            .navigationBarTitle("Städte hinzufügen", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").foregroundColor(.accentColor)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showAddCityView = false
    @State private var showSettings = false
    @State private var selectedCityIndex = 0
    @State private var showAlert = true 
    
    var body: some View {
        NavigationView {
            ZStack {
                appSettings.accentColor
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        let currentStation = appSettings.currentStation ?? WeatherStationInformation(
                            Name: "Keine Station",
                            temperature: "0°C",
                            humidity: "0%",
                            windSpeed: "0 km/h",
                            rainAmount: "0 mm",
                            collectedwater: "0 L"
                        )
                        
                        VStack(spacing: 25) {
                            weatherTab(title: "Stationsname", icon: "building.2.fill", content: currentStation.Name)
                            weatherTab(title: "Aktuelle Temperatur", icon: "thermometer.sun.fill", content: currentStation.temperature)
                            weatherTab(title: "Luftfeuchtigkeit", icon: "humidity.fill", content: currentStation.humidity)
                            weatherTab(title: "Windgeschwindigkeit", icon: "wind", content: currentStation.windSpeed)
                            weatherTab(title: "Niederschlag (pro mm)", icon: "cloud.rain.fill", content: currentStation.rainAmount)
                            weatherTab(title: "Gesammeltes Wasser", icon: "waterbottle.fill", content: currentStation.collectedwater)
                        }
                        .padding()
                        
                        if !appSettings.cities.isEmpty {
                            TabView(selection: $selectedCityIndex) {
                                ForEach(appSettings.cities.indices, id: \.self) { index in
                                    ScrollView {
                                        VStack(spacing: 16) {
                                            weatherTab(title: "Stadt", icon: "building.2.fill", content: appSettings.cities[index].city)
                                            weatherTab(title: "Temperatur", icon: "thermometer.sun.fill", content: formatTemperature(appSettings.cities[index].temperature))
                                            weatherTab(title: "Luftfeuchtigkeit", icon: "humidity.fill", content: appSettings.cities[index].humidity)
                                            weatherTab(title: "Windgeschwindigkeit", icon: "wind", content: appSettings.cities[index].windSpeed)
                                            weatherTab(title: "Niederschlag", icon: "cloud.rain.fill", content: appSettings.cities[index].rainAmount)
                                        }
                                        .padding()
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                        } else {
                            Text("Keine Städte hinzugefügt.")
                        }
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
                        AddCityView(citieindex: $appSettings.cities, WeatherStation: .constant([]))
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
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personalisierung")) {
                    NavigationLink(destination: AccentColorSelectionView()) {
                        Text("Akzentfarbe ändern")
                            .font(.body) 
                            .foregroundColor(.accentColor)
                    }

                    
                    Picker("Einheit", selection: $appSettings.temperatureUnit) {
                        Text("Celsius").tag("Celsius")
                        Text("Fahrenheit").tag("Fahrenheit")
                    }
                }
                Section(header: Text("Wetterstation")) {
                    HStack {
                        Text("Akkustand")
                        Spacer()
                        Text("87%").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Update Status")
                        Spacer()
                        Text("Kein Update verfügbar 😀").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Stationsname")
                        TextField("Name eingeben", text: $appSettings.stationname)
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
