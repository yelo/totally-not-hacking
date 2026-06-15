import Foundation
import SwiftUI

enum DashboardLayoutMode: String, Codable, CaseIterable, Identifiable {
    case tiled
    case floating
    case hybrid

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .tiled: "Tiled Dashboard"
        case .floating: "Floating Desktop"
        case .hybrid: "Hybrid Mode"
        }
    }
}

enum WidgetCategory: String, Codable, CaseIterable, Identifiable {
    case terminal
    case telemetry
    case maps
    case diagnostics
    case logs
    case background

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

enum WidgetPresentationMode: String, Codable, CaseIterable, Identifiable {
    case tiled
    case floating
    case background

    var id: String { rawValue }
}

struct WidgetMetadata: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var category: WidgetCategory
    var iconSystemName: String
    var defaultSize: WidgetFractionalSize
    var supportedPresentationModes: Set<WidgetPresentationMode>

    init(
        id: String,
        name: String,
        description: String,
        category: WidgetCategory,
        iconSystemName: String,
        defaultSize: WidgetFractionalSize,
        supportedPresentationModes: Set<WidgetPresentationMode>
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.iconSystemName = iconSystemName
        self.defaultSize = defaultSize
        self.supportedPresentationModes = supportedPresentationModes
    }
}

struct WidgetFractionalSize: Codable, Hashable {
    var width: Double
    var height: Double

    static let standard = WidgetFractionalSize(width: 0.28, height: 0.22)
    static let wide = WidgetFractionalSize(width: 0.38, height: 0.20)
    static let tall = WidgetFractionalSize(width: 0.24, height: 0.30)
    static let background = WidgetFractionalSize(width: 1.0, height: 1.0)
}

struct WidgetPlacement: Codable, Hashable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var zIndex: Double

    static func background(zIndex: Double = 0) -> WidgetPlacement {
        WidgetPlacement(x: 0, y: 0, width: 1, height: 1, zIndex: zIndex)
    }

    func rect(in size: CGSize) -> CGRect {
        CGRect(
            x: x * size.width,
            y: y * size.height,
            width: width * size.width,
            height: height * size.height
        )
    }

    func clamped() -> WidgetPlacement {
        var copy = self
        copy.width = min(max(copy.width, 0.08), 1)
        copy.height = min(max(copy.height, 0.08), 1)
        copy.x = min(max(copy.x, 0), 1 - copy.width)
        copy.y = min(max(copy.y, 0), 1 - copy.height)
        return copy
    }

    func snapped(to columns: Int = 12, rows: Int = 8) -> WidgetPlacement {
        let columnStep = 1.0 / Double(columns)
        let rowStep = 1.0 / Double(rows)

        func snap(_ value: Double, to step: Double) -> Double {
            (value / step).rounded() * step
        }

        var copy = self
        copy.x = snap(copy.x, to: columnStep)
        copy.y = snap(copy.y, to: rowStep)
        copy.width = max(columnStep * 2, snap(copy.width, to: columnStep))
        copy.height = max(rowStep * 2, snap(copy.height, to: rowStep))
        return copy.clamped()
    }

    static func defaultPlacement(
        index: Int,
        size: WidgetFractionalSize,
        presentationMode: WidgetPresentationMode
    ) -> WidgetPlacement {
        if presentationMode == .background {
            return .background(zIndex: 0)
        }

        let column = index % 3
        let row = index / 3
        let width = min(size.width, 0.42)
        let height = min(size.height, 0.34)
        let x = 0.06 + Double(column) * 0.30
        let y = 0.08 + Double(row) * 0.24
        return WidgetPlacement(x: x, y: y, width: width, height: height, zIndex: Double(index + 1)).clamped()
    }
}

struct DashboardWidgetInstance: Codable, Hashable, Identifiable {
    var id: UUID
    var widgetID: String
    var placement: WidgetPlacement
    var presentationMode: WidgetPresentationMode
    var isSelected: Bool
    var isVisible: Bool
    var configurationData: Data

    init(
        id: UUID = UUID(),
        widgetID: String,
        placement: WidgetPlacement,
        presentationMode: WidgetPresentationMode,
        isSelected: Bool = false,
        isVisible: Bool = true,
        configurationData: Data
    ) {
        self.id = id
        self.widgetID = widgetID
        self.placement = placement
        self.presentationMode = presentationMode
        self.isSelected = isSelected
        self.isVisible = isVisible
        self.configurationData = configurationData
    }
}

struct DashboardState: Codable, Hashable {
    var layoutMode: DashboardLayoutMode
    var activeThemeID: String
    var selectedWidgetIDs: Set<UUID>
    var widgets: [DashboardWidgetInstance]
}

struct WidgetContext: Sendable {
    var theme: DashboardTheme
    var layoutMode: DashboardLayoutMode
    var containerSize: CGSize
}

protocol DashboardWidget {
    associatedtype Configuration: Codable & Hashable

    static var metadata: WidgetMetadata { get }
    static var defaultConfiguration: Configuration { get }
    static func makeView(configuration: Configuration, context: WidgetContext) -> AnyView
    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView
}

extension DashboardWidget {
    static func makeSettingsView(configuration: Binding<Configuration>) -> AnyView {
        AnyView(EmptyView())
    }
}

