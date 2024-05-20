import SwiftUI
import CoreMotion

struct ContentView: View {
    @State private var stepCount = 0
    @State private var calorieCount = 0.0
    @State private var dailyStepGoal = 5000
    @State private var dailyCalorieGoal = 2000.0
    @State private var stepHistory: [Int] = []
    @State private var userPoints = 0
    @State private var showModal = false
    private let pedometer = CMPedometer()
    private let infoURL = URL(string: "https://www.nationalgeographic.es/ciencia/2024/03/10-000-pasos-diarios-necesidad-real-explicacion-cientifica")!
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("CORRECAMINOS")
                    .font(.custom("Chalkduster", size: 37))
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .shadow(color: .gray, radius: 3, x: 0, y: 2)
                    .padding()
                
                Spacer()
                
                SummaryView(stepCount: $stepCount, calorieCount: $calorieCount, dailyStepGoal: $dailyStepGoal, userPoints: $userPoints)
                
                //La funcion para que el boton sume los pasos, Kcal, Meta y puntos
                
                ActionButtonsView(incrementStepCount: incrementStepCount, checkForRewards: checkForRewards)
                
                CustomProgressView(stepCount: $stepCount, dailyStepGoal: $dailyStepGoal)
                
                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.2)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            .onAppear {
                self.startCountingSteps()
            }
            .navigationBarItems(trailing:
                Button(action: {
                    self.showModal = true
                }) {
                    Image(systemName: "gear")
                        .font(.title3)
                        .foregroundColor(Color.red)
                        .padding(0)
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: 3, x: 0, y: 2)
                }
            )
        }
        .sheet(isPresented: $showModal) {
            ModalView(dailyStepGoal: $dailyStepGoal, dailyCalorieGoal: $dailyCalorieGoal, dailySteps: $stepHistory, userPoints: $userPoints)
        }
        .overlay(
            Button(action: {
                UIApplication.shared.open(infoURL)
            }) {
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding(0)
                    .background(Color.white.opacity(0.1)) // Fondo transparente
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
            , alignment: .bottomTrailing
        )
    }
    
    private func startCountingSteps() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { (data, error) in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.stepCount = data.numberOfSteps.intValue
                    self.calorieCount = Double(self.stepCount) * 0.04
                    if self.stepCount % 50 == 0 {
                        self.userPoints += 1
                    }
                    if self.stepCount % 10 == 0 && !self.stepHistory.contains(self.stepCount) {
                        self.stepHistory.append(self.stepCount)
                    }
                }
            }
        }
    }
    
    private func incrementStepCount() {
        stepCount += 1
        if stepCount % 50 == 0 {
            userPoints += 1
        }
        if stepCount % 10 == 0 && !stepHistory.contains(stepCount) {
            stepHistory.append(stepCount)
        }
        incrementCalories()
    }
    
    private func checkForRewards() {
        // No se necesitan cambios aquí, ya que los puntos se agregan automáticamente al caminar.
    }
    
    private func incrementCalories() {
        let caloriesPerStep = 0.04
        calorieCount += caloriesPerStep
    }
}

struct ModalView: View {
    @Binding var dailyStepGoal: Int
    @Binding var dailyCalorieGoal: Double
    @Binding var dailySteps: [Int]
    @Binding var userPoints: Int
    
    var body: some View {
        VStack {
            Text("Historial")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            HStack {
                ForEach(0..<userPoints, id: \.self) { _ in
                    Text("•")
                        .font(.headline)
                        .foregroundColor(.purple)
                        .padding(.trailing, 4)
                }
            }
            
            List {
                ForEach(dailySteps, id: \.self) { steps in
                    let caloriesBurned = Double(steps) * 0.04
                    let caloriesText = "\(Int(caloriesBurned)) kcal"
                    let stepsText = "\(steps) pasos"
                    let pointsText = "\(steps / 50) puntos"
                    
                    HStack {
                        Text(caloriesText)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Text(stepsText)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.blue.opacity(0.3))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Text(pointsText)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.purple.opacity(0.3))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            
            Spacer()
            
            Text("Meta diaria:")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Pasos", value: $dailyStepGoal, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
        }
        .padding()
        .frame(maxWidth: 400)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


struct CustomProgressView: View {
    @Binding var stepCount: Int
    @Binding var dailyStepGoal: Int
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 30) // Ajusta el ancho del trazo para hacer el círculo más grande
                    .opacity(0.3)
                    .foregroundColor(.green)
                
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(stepCount) / CGFloat(dailyStepGoal), 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.pink)
                    .rotationEffect(Angle(degrees: -90))
                
                Text("\(Int((min(CGFloat(stepCount) / CGFloat(dailyStepGoal), 1.0)) * 100.0))%")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding()
            .onReceive([stepCount].publisher.first()) { _ in
                if stepCount >= dailyStepGoal {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.stepCount = 0
                        }
                    }
                }
            }
        }
    }
}


struct SummaryView: View {
    @Binding var stepCount: Int
    @Binding var calorieCount: Double
    @Binding var dailyStepGoal: Int
    @Binding var userPoints: Int
    
    var body: some View {
        HStack(spacing: 13) {
            SummaryItemView(title: "PASOS", value: "\(stepCount)", color: .blue, icon: "figure.walk")
            SummaryItemView(title: "Kcal", value: String(format: "%.2f", calorieCount), color: .orange, icon: "flame")
            SummaryItemView(title: "META", value: "\(dailyStepGoal)", color: .green, icon: "target")
            SummaryItemView(title: "PUNTOS", value: "\(userPoints)", color: .purple, icon: "star")
        }
    }
}
//Funcion de dar un paso

struct ActionButtonsView: View {
    var incrementStepCount: () -> Void
    var checkForRewards: () -> Void
    
    var body: some View {
        Button(action: {
            self.incrementStepCount()
            self.checkForRewards()
        }) {
            Text("Dar un paso")
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 3, x: 0, y: 2)
        }
    }
}

struct SummaryItemView: View {
    var title: String
    var value: String
    var color: Color
    var icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(.black)
                .padding(10)
                .background(color)
                .cornerRadius(10)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 5)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 5)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(10)
        .shadow(color: .gray, radius: 3, x: 0, y: 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}










































