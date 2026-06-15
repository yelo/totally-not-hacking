import Foundation
import Combine
import SwiftUI

struct AnyWidgetDescriptor: Identifiable {
    let id: String
    let metadata: WidgetMetadata
    let defaultConfigurationData: Data
    let makeView: (Data, WidgetContext) -> AnyView
    let makeSettingsView: (Binding<Data>, @escaping (Data) -> Void) -> AnyView
}

@MainActor
final class WidgetRegistry: ObservableObject {
    @Published private(set) var descriptors: [AnyWidgetDescriptor] = []

    func register<Widget: DashboardWidget>(_ widget: Widget.Type) {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let defaultConfigurationData = (try? encoder.encode(Widget.defaultConfiguration)) ?? Data()

        let descriptor = AnyWidgetDescriptor(
            id: Widget.metadata.id,
            metadata: Widget.metadata,
            defaultConfigurationData: defaultConfigurationData,
            makeView: { configurationData, context in
                let configuration = (try? decoder.decode(Widget.Configuration.self, from: configurationData)) ?? Widget.defaultConfiguration
                return Widget.makeView(configuration: configuration, context: context)
            },
            makeSettingsView: { configurationBinding, onChange in
                let typedBinding = Binding<Widget.Configuration>(
                    get: {
                        (try? decoder.decode(Widget.Configuration.self, from: configurationBinding.wrappedValue)) ?? Widget.defaultConfiguration
                    },
                    set: { newValue in
                        guard let encoded = try? encoder.encode(newValue) else { return }
                        configurationBinding.wrappedValue = encoded
                        onChange(encoded)
                    }
                )
                return Widget.makeSettingsView(configuration: typedBinding)
            }
        )

        descriptors.removeAll { $0.id == descriptor.id }
        descriptors.append(descriptor)
    }

    func descriptor(for id: String) -> AnyWidgetDescriptor? {
        descriptors.first { $0.id == id }
    }

    func contains(_ id: String) -> Bool {
        descriptor(for: id) != nil
    }
}
