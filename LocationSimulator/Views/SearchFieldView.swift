import SwiftUI

/// Search field backed by MKLocalSearch (Apple Maps) — no external API keys.
struct SearchFieldView: View {
    @Bindable var viewModel: SimulatorViewModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search for a city, address, or landmark", text: $viewModel.searchQuery)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.runSearch() }
                }

            if viewModel.isSearching {
                ProgressView()
            } else if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SearchFieldView(viewModel: SimulatorViewModel())
        .padding()
}
