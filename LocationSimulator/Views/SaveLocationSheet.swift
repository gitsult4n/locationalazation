import CoreLocation
import SwiftUI

struct SaveLocationSheet: View {
    let coordinate: CLLocationCoordinate2D
    let suggestedName: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Home, Office, Dubai Mall", text: $name)
                }
                Section("Coordinates") {
                    LabeledContent("Latitude", value: SimulatorViewModel.format(coordinate.latitude))
                        .monospacedDigit()
                    LabeledContent("Longitude", value: SimulatorViewModel.format(coordinate.longitude))
                        .monospacedDigit()
                }
            }
            .navigationTitle("Save Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedName)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear {
                if name.isEmpty {
                    name = suggestedName
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SaveLocationSheet(
        coordinate: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708),
        suggestedName: "Dubai",
        onSave: { _ in }
    )
}
