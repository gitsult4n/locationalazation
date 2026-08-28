import SwiftUI

struct SavedLocationsSection: View {
    let locations: [SavedLocation]
    let canSaveCurrent: Bool
    let onSaveCurrent: () -> Void
    let onSelect: (SavedLocation) -> Void
    let onDelete: (SavedLocation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved Locations")
                    .font(.title3.bold())
                Spacer()
                Button(action: onSaveCurrent) {
                    Label("Save Current", systemImage: "plus")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(!canSaveCurrent)
            }

            if locations.isEmpty {
                ContentUnavailableView(
                    "No Saved Locations",
                    systemImage: "bookmark",
                    description: Text("Save the currently selected coordinates to reuse them later.")
                )
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(locations) { location in
                        row(for: location)
                        if location.persistentModelID != locations.last?.persistentModelID {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func row(for location: SavedLocation) -> some View {
        HStack(spacing: 8) {
            Button {
                onSelect(location)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(SimulatorViewModel.format(location.coordinate))
                            .font(.footnote)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(role: .destructive) {
                onDelete(location)
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Delete \(location.name)")
        }
        .padding(12)
    }
}
