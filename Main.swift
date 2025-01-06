// © Farin Altenhöner 2024
// this code is availabel on Github under
//'https://www.github.com/altenfa/'

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
    var Location: String { get }
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
    let Location: String
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
        Location: " Bünde",
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
        WeatherData(city: "Bünde", temperature: "8°C", humidity: "62%", windSpeed: "13 km/h", rainAmount: "0.2 mm")]
    
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
    
    var body: some View {
        NavigationView {
            TabView {
                ScrollView {
                    let currentStation = appSettings.currentStation ?? WeatherStationInformation(
                        Location: "Keine Station",
                        temperature: "0°C",
                        humidity: "0%",
                        windSpeed: "0 km/h",
                        rainAmount: "0 mm",
                        collectedwater: "0 L"
                    )
                    
                    VStack(spacing: 25) {
                        weatherTab(title: "Standort", icon: "building.2.fill", content: currentStation.Location)
                        weatherTab(title: "Aktuelle Temperatur", icon: "thermometer.sun.fill", content: currentStation.temperature)
                        weatherTab(title: "Luftfeuchtigkeit", icon: "humidity.fill", content: currentStation.humidity)
                        weatherTab(title: "Windgeschwindigkeit", icon: "wind", content: currentStation.windSpeed)
                        weatherTab(title: "Niederschlag (pro mm)", icon: "cloud.rain.fill", content: currentStation.rainAmount)
                        weatherTab(title: "Gesammeltes Wasser", icon: "waterbottle.fill", content: currentStation.collectedwater)
                    }
                    .padding()
                }
                .tabItem {
                    Label("Hauptstation", systemImage: "house")
                }
                
                if !appSettings.cities.isEmpty {
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
                        .tabItem {
                            Label(appSettings.cities[index].city, systemImage: "map")
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Noch keine Städte hier")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .tabItem {
                        Label("Städte", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Wetterstation")
            .navigationBarItems(
                leading:
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    },
                trailing:
                    Button(action: { showAddCityView = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                    .sheet(isPresented: $showAddCityView) {
                        AddCityView(citieindex: $appSettings.cities, WeatherStation: .constant([]))
                    }
            )
        }
    }
    
    private func weatherTab(title: String, icon: String, content: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.4))
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
    
    func formatTemperature(_ temperature: String) -> String {
        guard let value = Int(temperature.replacingOccurrences(of: "°C", with: "")) else {
            return temperature
        }
        
        switch appSettings.temperatureUnit {
        case "Celsius":
            return "\(value)°C"
        case "Fahrenheit":
            // Konvertiere Celsius in Fahrenheit
            let fahrenheit = Int(Double(value) * 9 / 5 + 32)
            return "\(fahrenheit)°F"
        case "Kelvin":
            // Konvertiere Celsius in Kelvin
            let kelvin = value + 273
            return "\(kelvin)K"
        default:
            // Fallback: Gib die Temperatur in Celsius zurück, falls keine gültige Einheit definiert ist
            return "\(value)°C"
        }
    }
    
    
    struct PrivacyPoliceView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("""
                Weatherstation Company 🌦️
                Marktstraße 12
                32257 Bünde
                
                Kontakt:
                E-Mail: support@weatherstation.com
                Telefon: +49 123 456 789
                """)
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Impressum")
        }
    }
    
    struct ImpressumView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("""
                Weatherstation Company 🌦️
                Marktstraße 12
                32257 Bünde
                
                Kontakt:
                E-Mail: support@weatherstation.com
                Telefon: +49 123 456 789
                """)
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Impressum")
        }
    }
    
    struct ProfileView: View {
        @State private var username: String = ""
        @State private var email: String = ""
        @State private var password: String = ""
        @State private var profileImage: UIImage? = nil
        @State private var showImagePicker: Bool = false
        
        var body: some View {
            VStack(spacing: 20) {
                // Picture
                Button(action: {
                    showImagePicker = true
                }) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .overlay(Text("Bild").foregroundColor(.white))
                    }
                }
                
                // Username
                TextField("Benutzername", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // E-Mail
                TextField("E-Mail", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .padding()
                
                TextField("Passwort", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Save-Button
                Button(action: saveToCache) {
                    Text("Speichern")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
        
        func saveToCache() {
            let userDefaults = UserDefaults.standard
            userDefaults.set(username, forKey: "username")
            userDefaults.set(email, forKey: "email")
            userDefaults.set(password, forKey: "password")
            
            if let imageData = profileImage?.jpegData(compressionQuality: 0.8) {
                userDefaults.set(imageData, forKey: "profileImage")
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let selectedImage = info[.originalImage] as? UIImage {
                    parent.image = selectedImage
                }
                picker.dismiss(animated: true)
            }
        }
    }
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView()
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
                            Text("Kelvin").tag("Kelvin")
                        }
                        NavigationLink(destination:ProfileView()) {
                            Text("Profil")
                                .font(.body)
                                .foregroundColor(.accentColor)
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
                            Text("Standort")
                            Spacer()
                            Text("Bünde (Automatisch)").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Software Version")
                            Spacer()
                            Text(" 2024.12.22").foregroundColor(.secondary)
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
                    
                    Section(header: Text("Rechtliches")) {
                        NavigationLink(destination: PrivacyPoliceView()) {
                            Text("Datenschutz")
                                .foregroundColor(.blue)
                        }
                        
                        NavigationLink(destination: ImpressumView()) {
                            Text("Impressum")
                                .foregroundColor(.blue)
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