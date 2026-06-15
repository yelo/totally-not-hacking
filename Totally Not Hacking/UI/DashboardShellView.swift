import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DashboardStore

    var body: some View {
        DashboardShellView(store: store)
    }
}

struct DashboardShellView: View {
    @ObservedObject var store: DashboardStore
    @State private var editingWidgetTarget: WidgetEditorTarget?

    var body: some View {
        NavigationSplitView {
            DashboardControlPanel(
                store: store,
                editWidget: { editingWidgetTarget = WidgetEditorTarget(id: $0) }
            )
            .navigationTitle("Totally Not Hacking")
        } detail: {
            DashboardCanvasView(
                store: store,
                editWidget: { editingWidgetTarget = WidgetEditorTarget(id: $0) }
            )
        }
        .sheet(item: $editingWidgetTarget) { target in
            WidgetSettingsSheet(widgetID: target.id, store: store)
        }
    }
}

private struct WidgetEditorTarget: Identifiable {
    let id: UUID
}

struct DashboardControlPanel: View {
    @ObservedObject var store: DashboardStore
    let editWidget: (UUID) -> Void

    private var sortedDescriptors: [AnyWidgetDescriptor] {
        store.registry.descriptors.sorted {
            if $0.metadata.category == $1.metadata.category {
                $0.metadata.name < $1.metadata.name
            } else {
                $0.metadata.category.displayName < $1.metadata.category.displayName
            }
        }
    }

    var body: some View {
        List {
            Section("Layout") {
                Picker("Layout Mode", selection: Binding(
                    get: { store.state.layoutMode },
                    set: { store.setLayoutMode($0) }
                )) {
                    ForEach(DashboardLayoutMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if let issue = store.persistenceMessage {
                    Label(issue, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Button("Reset Dashboard Layout") {
                    store.resetLayout()
                }
            }

            Section("Theme") {
                Picker("Theme", selection: Binding(
                    get: { store.state.activeThemeID },
                    set: { store.setTheme($0) }
                )) {
                    ForEach(store.themes) { theme in
                        Text(theme.name).tag(theme.id)
                    }
                }
            }

            Section("Widget Library") {
                ForEach(sortedDescriptors) { descriptor in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Image(systemName: descriptor.metadata.iconSystemName)
                                .foregroundStyle(store.activeTheme.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(descriptor.metadata.name)
                                    .font(.headline)
                                Text(descriptor.metadata.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Add") {
                                store.addWidget(widgetID: descriptor.id)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("Active Widgets") {
                ForEach(store.state.widgets.sorted(by: { $0.placement.zIndex < $1.placement.zIndex })) { widget in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.descriptor(for: widget.widgetID)?.metadata.name ?? widget.widgetID)
                            Text(widget.presentationMode.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Edit") {
                            editWidget(widget.id)
                        }
                        Button("Duplicate") {
                            store.duplicateWidget(id: widget.id)
                        }
                        Button(role: .destructive) {
                            store.removeWidget(id: widget.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct DashboardCanvasView: View {
    @ObservedObject var store: DashboardStore
    let editWidget: (UUID) -> Void

    var body: some View {
        GeometryReader { proxy in
            let containerSize = proxy.size
            let theme = store.activeTheme

            ZStack {
                theme.background.ignoresSafeArea()

                DashboardBackdropGrid(theme: theme, layoutMode: store.state.layoutMode)

                if store.state.layoutMode == .hybrid {
                    ForEach(backgroundWidgets) { widget in
                        if let descriptor = store.descriptor(for: widget.widgetID) {
                            WidgetBackdropHost(
                                descriptor: descriptor,
                                widget: widget,
                                store: store,
                                containerSize: containerSize
                            )
                            .zIndex(widget.placement.zIndex)
                        }
                    }
                }

                ForEach(foregroundWidgets) { widget in
                    if let descriptor = store.descriptor(for: widget.widgetID) {
                        WidgetHostView(
                            descriptor: descriptor,
                            widget: widget,
                            store: store,
                            containerSize: containerSize,
                            editWidget: editWidget
                        )
                        .zIndex(widget.placement.zIndex)
                    }
                }

                FloatingWidgetConnectorOverlay(
                    widgets: connectorWidgets,
                    theme: theme
                )
                .zIndex(10_000)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    private var backgroundWidgets: [DashboardWidgetInstance] {
        store.state.widgets.filter { $0.presentationMode == .background && $0.isVisible }
    }

    private var foregroundWidgets: [DashboardWidgetInstance] {
        store.state.widgets.filter { $0.presentationMode != .background && $0.isVisible }
    }

    private var connectorWidgets: [DashboardWidgetInstance] {
        store.state.widgets.filter { widget in
            guard widget.isVisible, widget.presentationMode != .background else { return false }
            guard let descriptor = store.descriptor(for: widget.widgetID) else { return false }
            return descriptor.metadata.category == .telemetry || descriptor.metadata.category == .maps
        }
    }
}

struct FloatingWidgetConnectorOverlay: View {
    let widgets: [DashboardWidgetInstance]
    let theme: DashboardTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                let orderedWidgets = widgets.sorted { $0.placement.zIndex < $1.placement.zIndex }
                let frames = orderedWidgets.map { widget -> CGRect in
                    widget.placement.rect(in: size)
                }

                guard frames.count > 1 else { return }

                for index in 0..<(frames.count - 1) {
                    let startFrame = frames[index]
                    let endFrame = frames[index + 1]
                    let startCenter = CGPoint(x: startFrame.midX, y: startFrame.midY)
                    let endCenter = CGPoint(x: endFrame.midX, y: endFrame.midY)
                    let start = edgeAnchor(in: startFrame, toward: endCenter)
                    let end = edgeAnchor(in: endFrame, toward: startCenter)

                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)
                    context.stroke(path, with: .color(theme.primary.opacity(0.30)), lineWidth: 2)
                    context.stroke(path, with: .color(theme.glow.opacity(0.20)), lineWidth: 6)
                }

                for (index, frame) in frames.enumerated() {
                    let nextCenter = index < frames.count - 1
                        ? CGPoint(x: frames[index + 1].midX, y: frames[index + 1].midY)
                        : (index > 0
                            ? CGPoint(x: frames[index - 1].midX, y: frames[index - 1].midY)
                            : CGPoint(x: frame.midX, y: frame.midY))
                    let node = edgeAnchor(in: frame, toward: nextCenter)
                    let pulse = 5 + CGFloat((sin(phase * 2.0 + Double(index)) + 1) * 2)
                    let glowRadius = pulse * 2.2
                    let nodeColor = index % 2 == 0 ? theme.accent : theme.primary

                    context.fill(
                        Path(ellipseIn: CGRect(x: node.x - glowRadius, y: node.y - glowRadius, width: glowRadius * 2, height: glowRadius * 2)),
                        with: .color(theme.glow.opacity(0.12))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(x: node.x - pulse, y: node.y - pulse, width: pulse * 2, height: pulse * 2)),
                        with: .color(nodeColor)
                    )
                }
            }
            .allowsHitTesting(false)
            .blendMode(.screen)
        }
    }

    private func edgeAnchor(in rect: CGRect, toward point: CGPoint) -> CGPoint {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y

        guard deltaX != 0 || deltaY != 0 else { return center }

        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2

        let scaleX = deltaX == 0 ? .infinity : halfWidth / abs(deltaX)
        let scaleY = deltaY == 0 ? .infinity : halfHeight / abs(deltaY)
        let scale = min(scaleX, scaleY)

        return CGPoint(
            x: center.x + deltaX * scale,
            y: center.y + deltaY * scale
        )
    }
}

struct WidgetBackdropHost: View {
    let descriptor: AnyWidgetDescriptor
    let widget: DashboardWidgetInstance
    @ObservedObject var store: DashboardStore
    let containerSize: CGSize

    var body: some View {
        let context = WidgetContext(theme: store.activeTheme, layoutMode: store.state.layoutMode, containerSize: containerSize)
        descriptor.makeView(widget.configurationData, context)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .allowsHitTesting(false)
    }
}

struct WidgetHostView: View {
    let descriptor: AnyWidgetDescriptor
    let widget: DashboardWidgetInstance
    @ObservedObject var store: DashboardStore
    let containerSize: CGSize
    let editWidget: (UUID) -> Void

    @State private var dragOrigin: WidgetPlacement?
    @State private var resizeOrigin: WidgetPlacement?

    private var rect: CGRect {
        widget.placement.rect(in: containerSize)
    }

    var body: some View {
        let context = WidgetContext(theme: store.activeTheme, layoutMode: store.state.layoutMode, containerSize: containerSize)
        let content = descriptor.makeView(widget.configurationData, context)

        WidgetChromeView(
            descriptor: descriptor,
            widget: widget,
            theme: store.activeTheme,
            content: content,
            onConfigure: { editWidget(widget.id) },
            onDelete: { store.removeWidget(id: widget.id) },
            onDuplicate: { store.duplicateWidget(id: widget.id) },
            onBringToFront: { store.bringToFront(id: widget.id) }
        )
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
        .onTapGesture {
            store.selectExclusive(id: widget.id)
            store.bringToFront(id: widget.id)
        }
        .gesture(moveGesture)
        .overlay(alignment: .bottomTrailing) {
            ResizeHandle(
                theme: store.activeTheme,
                onResize: { translation in
                    if resizeOrigin == nil {
                        resizeOrigin = widget.placement
                    }
                    guard let start = resizeOrigin else { return }

                    let width = max(containerSize.width, 1)
                    let height = max(containerSize.height, 1)
                    var placement = start
                    placement.width += translation.width / width
                    placement.height += translation.height / height
                    store.updatePlacement(id: widget.id, to: placement)
                },
                onResizeEnded: {
                    resizeOrigin = nil
                }
            )
            .opacity(widget.isSelected ? 1 : 0.75)
        }
    }

    private var moveGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if dragOrigin == nil {
                    dragOrigin = widget.placement
                }
                guard let start = dragOrigin else { return }

                let width = max(containerSize.width, 1)
                let height = max(containerSize.height, 1)
                var placement = start
                placement.x += value.translation.width / width
                placement.y += value.translation.height / height
                store.updatePlacement(id: widget.id, to: placement)
            }
            .onEnded { _ in
                dragOrigin = nil
            }
    }

}

struct WidgetChromeView<Content: View>: View {
    let descriptor: AnyWidgetDescriptor
    let widget: DashboardWidgetInstance
    let theme: DashboardTheme
    let content: Content
    let onConfigure: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onBringToFront: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: descriptor.metadata.iconSystemName)
                    .foregroundStyle(theme.primary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(descriptor.metadata.name)
                        .font(.caption.weight(.semibold))
                    Text(descriptor.metadata.category.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                Button(action: onBringToFront) {
                    Image(systemName: "arrow.up.to.line")
                }
                Button(action: onDuplicate) {
                    Image(systemName: "plus.square.on.square")
                }
                Button(action: onConfigure) {
                    Image(systemName: "slider.horizontal.3")
                }
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }
            .font(.caption2)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.surface.opacity(0.96))

            Divider().overlay(theme.primary.opacity(0.35))

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
                .background(theme.surface.opacity(0.74))
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.surface.opacity(widget.isSelected ? 0.95 : 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(theme.primary.opacity(widget.isSelected ? 0.95 : 0.35), lineWidth: widget.isSelected ? 2 : 1)
                )
                .shadow(color: theme.glow.opacity(theme.glowIntensity * 0.35), radius: widget.isSelected ? 18 : 10, x: 0, y: 0)
        )
    }
}

struct ResizeHandle: View {
    let theme: DashboardTheme
    let onResize: (CGSize) -> Void
    let onResizeEnded: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(theme.primary.opacity(0.9))
            .frame(width: 18, height: 18)
            .overlay(
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.caption2)
                    .foregroundStyle(theme.background)
            )
            .padding(8)
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { onResize($0.translation) }
                    .onEnded { _ in onResizeEnded() }
            )
    }
}

struct WidgetSettingsSheet: View {
    let widgetID: UUID
    @ObservedObject var store: DashboardStore
    @Environment(\.dismiss) private var dismiss
    @State private var configurationData: Data = Data()

    private var widget: DashboardWidgetInstance? {
        store.state.widgets.first { $0.id == widgetID }
    }

    private var descriptor: AnyWidgetDescriptor? {
        widget.flatMap { store.descriptor(for: $0.widgetID) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let widget, let descriptor {
                    VStack(alignment: .leading, spacing: 16) {
                        descriptor.makeSettingsView(
                            Binding(
                                get: { configurationData },
                                set: { newValue in
                                    configurationData = newValue
                                    store.updateConfiguration(id: widget.id, data: newValue)
                                }
                            ),
                            { newValue in
                                configurationData = newValue
                                store.updateConfiguration(id: widget.id, data: newValue)
                            }
                        )

                        Text("Layout mode: \(store.state.layoutMode.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding()
                } else {
                    ContentUnavailableView("Widget not found", systemImage: "questionmark.square.dashed")
                }
            }
            .navigationTitle(widget.flatMap { store.descriptor(for: $0.widgetID)?.metadata.name } ?? "Widget Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            if let widget {
                configurationData = widget.configurationData
            }
        }
    }
}

struct DashboardBackdropGrid: View {
    let theme: DashboardTheme
    let layoutMode: DashboardLayoutMode

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Canvas { context, canvasSize in
                let columns = layoutMode == .tiled ? 16 : 12
                let rows = layoutMode == .tiled ? 10 : 8
                let columnStep = canvasSize.width / CGFloat(columns)
                let rowStep = canvasSize.height / CGFloat(rows)

                for column in 0...columns {
                    var path = Path()
                    let x = CGFloat(column) * columnStep
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                    context.stroke(path, with: .color(theme.primary.opacity(0.06)), lineWidth: 1)
                }

                for row in 0...rows {
                    var path = Path()
                    let y = CGFloat(row) * rowStep
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                    context.stroke(path, with: .color(theme.primary.opacity(0.04)), lineWidth: 1)
                }

                let scanlineY = canvasSize.height * 0.33
                var scanline = Path()
                scanline.move(to: CGPoint(x: 0, y: scanlineY))
                scanline.addLine(to: CGPoint(x: canvasSize.width, y: scanlineY))
                context.stroke(scanline, with: .color(theme.accent.opacity(0.10)), lineWidth: 2)
            }
            .allowsHitTesting(false)
            .opacity(layoutMode == .hybrid ? 1 : 0.7)
            .frame(width: size.width, height: size.height)
        }
    }
}
