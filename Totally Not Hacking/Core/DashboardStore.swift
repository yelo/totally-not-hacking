import Foundation
import Combine
import SwiftUI

@MainActor
final class DashboardStore: ObservableObject {
    @Published var state: DashboardState
    @Published var persistenceMessage: String?

    let registry: WidgetRegistry
    let themes: [DashboardTheme]
    private let persistence: DashboardPersistence

    init(registry: WidgetRegistry, persistence: DashboardPersistence) {
        self.registry = registry
        self.themes = DashboardThemes.all
        self.persistence = persistence

        if let loaded = try? persistence.load() {
            state = DashboardStore.mergedState(loaded, with: registry, themes: themes)
        } else {
            state = DashboardStore.bootstrapState(with: registry, themes: themes)
            try? persistence.save(state)
        }
    }

    var activeTheme: DashboardTheme {
        themes.first { $0.id == state.activeThemeID } ?? themes[0]
    }

    var visibleWidgets: [DashboardWidgetInstance] {
        state.widgets.filter(\.isVisible)
    }

    func descriptor(for widgetID: String) -> AnyWidgetDescriptor? {
        registry.descriptor(for: widgetID)
    }

    func setLayoutMode(_ layoutMode: DashboardLayoutMode) {
        state.layoutMode = layoutMode
        persist()
    }

    func setTheme(_ themeID: String) {
        guard themes.contains(where: { $0.id == themeID }) else { return }
        state.activeThemeID = themeID
        persist()
    }

    func addWidget(widgetID: String) {
        guard let descriptor = registry.descriptor(for: widgetID) else { return }

        let nextIndex = state.widgets.count
        let presentationMode: WidgetPresentationMode = descriptor.metadata.supportedPresentationModes.contains(.floating) ? .floating : .background
        let placement = WidgetPlacement.defaultPlacement(
            index: nextIndex,
            size: descriptor.metadata.defaultSize,
            presentationMode: presentationMode
        )

        let instance = DashboardWidgetInstance(
            widgetID: widgetID,
            placement: placement,
            presentationMode: presentationMode,
            isSelected: false,
            isVisible: true,
            configurationData: descriptor.defaultConfigurationData
        )

        state.widgets.append(instance)
        persist()
    }

    func removeWidget(id: UUID) {
        state.widgets.removeAll { $0.id == id }
        state.selectedWidgetIDs.remove(id)
        persist()
    }

    func duplicateWidget(id: UUID) {
        guard let source = state.widgets.first(where: { $0.id == id }) else { return }
        var copy = source
        copy.id = UUID()
        copy.placement.x = min(copy.placement.x + 0.04, 1 - copy.placement.width)
        copy.placement.y = min(copy.placement.y + 0.04, 1 - copy.placement.height)
        copy.placement.zIndex = highestZIndex + 1
        state.widgets.append(copy)
        persist()
    }

    func toggleSelection(id: UUID) {
        if state.selectedWidgetIDs.contains(id) {
            state.selectedWidgetIDs.remove(id)
            if let index = state.widgets.firstIndex(where: { $0.id == id }) {
                state.widgets[index].isSelected = false
            }
        } else {
            state.selectedWidgetIDs.insert(id)
            if let index = state.widgets.firstIndex(where: { $0.id == id }) {
                state.widgets[index].isSelected = true
            }
        }
        persist()
    }

    func selectExclusive(id: UUID) {
        state.selectedWidgetIDs = [id]
        for index in state.widgets.indices {
            state.widgets[index].isSelected = state.widgets[index].id == id
        }
        persist()
    }

    func bringToFront(id: UUID) {
        guard let index = state.widgets.firstIndex(where: { $0.id == id }) else { return }
        state.widgets[index].placement.zIndex = highestZIndex + 1
        persist()
    }

    func updatePlacement(id: UUID, to placement: WidgetPlacement) {
        guard let index = state.widgets.firstIndex(where: { $0.id == id }) else { return }
        state.widgets[index].placement = state.layoutMode == .tiled ? placement.snapped() : placement.clamped()
        persist()
    }

    func updatePresentationMode(id: UUID, mode: WidgetPresentationMode) {
        guard let index = state.widgets.firstIndex(where: { $0.id == id }) else { return }
        state.widgets[index].presentationMode = mode
        persist()
    }

    func updateConfiguration(id: UUID, data: Data) {
        guard let index = state.widgets.firstIndex(where: { $0.id == id }) else { return }
        state.widgets[index].configurationData = data
        persist()
    }

    func resetLayout() {
        state = DashboardStore.bootstrapState(with: registry, themes: themes)
        persist()
    }

    private var highestZIndex: Double {
        state.widgets.map(\.placement.zIndex).max() ?? 0
    }

    private func persist() {
        do {
            try persistence.save(state)
            persistenceMessage = nil
        } catch {
            persistenceMessage = error.localizedDescription
        }
    }

    private static func bootstrapState(with registry: WidgetRegistry, themes: [DashboardTheme]) -> DashboardState {
        let themeID = themes.first?.id ?? DashboardThemes.classicGreen.id
        let backgroundIDs = Set(["matrix-rain", "world-activity-map"])

        let widgets = registry.descriptors.enumerated().map { index, descriptor in
            let presentationMode: WidgetPresentationMode = backgroundIDs.contains(descriptor.id) ? .background : .floating
            let placement = WidgetPlacement.defaultPlacement(
                index: index,
                size: descriptor.metadata.defaultSize,
                presentationMode: presentationMode
            )
            return DashboardWidgetInstance(
                widgetID: descriptor.id,
                placement: placement,
                presentationMode: presentationMode,
                isSelected: index == 0,
                isVisible: true,
                configurationData: descriptor.defaultConfigurationData
            )
        }

        return DashboardState(
            layoutMode: .hybrid,
            activeThemeID: themeID,
            selectedWidgetIDs: widgets.first.map { Set([$0.id]) } ?? [],
            widgets: widgets
        )
    }

    private static func mergedState(_ state: DashboardState, with registry: WidgetRegistry, themes: [DashboardTheme]) -> DashboardState {
        var merged = state
        if !themes.contains(where: { $0.id == merged.activeThemeID }) {
            merged.activeThemeID = themes.first?.id ?? DashboardThemes.classicGreen.id
        }

        let liveWidgetIDs = Set(merged.widgets.map(\.id))
        merged.selectedWidgetIDs = merged.selectedWidgetIDs.intersection(liveWidgetIDs)

        let existingIDs = Set(merged.widgets.map(\.widgetID))
        let missingDescriptors = registry.descriptors.filter { !existingIDs.contains($0.id) }

        guard !missingDescriptors.isEmpty else {
            return merged
        }

        let additions = missingDescriptors.enumerated().map { index, descriptor in
            let presentationMode: WidgetPresentationMode = descriptor.metadata.supportedPresentationModes.contains(.background) ? .background : .floating
            return DashboardWidgetInstance(
                widgetID: descriptor.id,
                placement: WidgetPlacement.defaultPlacement(
                    index: merged.widgets.count + index,
                    size: descriptor.metadata.defaultSize,
                    presentationMode: presentationMode
                ),
                presentationMode: presentationMode,
                isSelected: false,
                isVisible: true,
                configurationData: descriptor.defaultConfigurationData
            )
        }

        merged.widgets.append(contentsOf: additions)
        return merged
    }
}
