import SwiftUI

struct ActionButtonsView: View {
    var viewModel: SimulatorViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.setLocation()
            } label: {
                Label("Set Location", systemImage: "location.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(role: .destructive) {
                viewModel.stopSimulation()
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!viewModel.isSimulating)
        }
    }
}

#Preview {
    ActionButtonsView(viewModel: SimulatorViewModel())
        .padding()
}
