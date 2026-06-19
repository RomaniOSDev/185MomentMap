import SwiftUI

enum TripsModuleBuilder {
    @MainActor
    static func build() -> TripsView {
        TripsView(presenter: TripsPresenter(interactor: TripsInteractor()))
    }
}

struct TripsView: View {
    @ObservedObject var presenter: TripsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if presenter.showCreateForm {
                    createFormCard
                } else {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            presenter.showCreateForm = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Create New Trip")
                                .font(.headline)
                            Spacer()
                        }
                        .foregroundStyle(AppColors.accent)
                        .appCard()
                    }
                    .buttonStyle(.plain)
                }

                if presenter.trips.isEmpty {
                    EmptyStateView(
                        message: "No trips yet.\nOrganize your memories into journeys.",
                        icon: "suitcase",
                        actionTitle: nil,
                        action: nil
                    )
                    .frame(height: 260)
                } else {
                    SectionHeaderView(
                        title: "Your Trips",
                        icon: "suitcase.fill",
                        subtitle: "\(presenter.trips.count) collections"
                    )

                    ForEach(presenter.trips, id: \.trip.id) { item in
                        TripCellView(trip: item.trip, memoryCount: item.count)
                            .contextMenu {
                                Button(role: .destructive) {
                                    presenter.didTapDelete(trip: item.trip)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Trips")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { presenter.viewDidLoad() }
        .alert("Delete Trip?", isPresented: Binding(
            get: { presenter.tripToDelete != nil },
            set: { if !$0 { presenter.tripToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) { presenter.confirmDelete() }
            Button("Cancel", role: .cancel) { presenter.tripToDelete = nil }
        } message: {
            Text("Memories will not be deleted, only unlinked from this trip.")
        }
    }

    private var createFormCard: some View {
        FormSectionCard(title: "New Trip", icon: "suitcase.fill") {
            VStack(spacing: 12) {
                AppTextField(placeholder: "Trip name", text: $presenter.form.name)
                AppTextField(placeholder: "Note (optional)", text: $presenter.form.note)
                Toggle("Set dates", isOn: $presenter.form.hasDates).tint(AppColors.accent)
                if presenter.form.hasDates {
                    DatePicker("Start", selection: $presenter.form.startDate, displayedComponents: .date)
                    DatePicker("End", selection: $presenter.form.endDate, displayedComponents: .date)
                }
                HStack(spacing: 12) {
                    Button("Cancel") {
                        withAnimation { presenter.showCreateForm = false }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    Button("Create") { presenter.didTapSaveTrip() }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: presenter.form.name.trimmingCharacters(in: .whitespaces).isEmpty))
                        .disabled(presenter.form.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
