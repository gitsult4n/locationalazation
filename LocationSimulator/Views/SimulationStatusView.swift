import SwiftUI

/// Shown while a simulation is active: what is being simulated, the GPX
/// export button, and an honest note about what the simulation covers.
struct SimulationStatusView: View {
    var viewModel: SimulatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Simulating in this app")
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            if let coordinate = viewModel.simulatedCoordinate {
                VStack(alignment: .leading, spacing: 2) {
                    if let name = viewModel.simulatedLocationName {
                        Text(name)
                            .font(.subheadline)
                    }
                    Text(SimulatorViewModel.format(coordinate))
                        .font(.footnote)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            if let url = viewModel.gpxFileURL {
                ShareLink(item: url) {
                    Label("Export GPX for Xcode", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.bordered)
            }

            Text("This marker only affects LocationSimulator itself. To simulate this position for the whole device, export the GPX file and use Xcode's Debug > Simulate Location — see the ? guide.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    let viewModel = SimulatorViewModel()
    viewModel.setLocation()
    return SimulationStatusView(viewModel: viewModel)
        .padding()
}
