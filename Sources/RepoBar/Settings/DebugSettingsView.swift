import RepoBarCore
import SwiftUI

struct DebugSettingsView: View {
    @Bindable var session: Session
    let appState: AppState
    @State private var diagnostics = DiagnosticsSummary.empty
    @State private var gitExecutableInfo = LocalProjectsService.gitExecutableInfo()

    var body: some View {
        Form {
            Section(AppLocalizer().string("Debug")) {
                Button(AppLocalizer().string("Clear cache")) {
                    Task {
                        await self.appState.clearCaches()
                        await self.loadDiagnosticsIfEnabled()
                    }
                }
                Button(AppLocalizer().string("Clear repo detail cache")) {
                    Task {
                        await self.appState.github.clearRepoDetailCache()
                        await self.loadDiagnosticsIfEnabled()
                    }
                }
                Button(AppLocalizer().string("Clear contribution heatmap cache")) {
                    self.appState.clearContributionCache()
                }
                Button(AppLocalizer().string("Clear release cache")) {
                    Task {
                        await self.appState.github.clearCache()
                        self.appState.requestRefresh(cancelInFlight: true)
                    }
                }
                Button(AppLocalizer().string("Force refresh")) {
                    self.appState.requestRefresh(cancelInFlight: true)
                }
                Toggle(AppLocalizer().string("Show diagnostics overlay"), isOn: self.$session.settings.diagnosticsEnabled)
                    .onChange(of: self.session.settings.diagnosticsEnabled) { _, newValue in
                        self.appState.persistSettings()
                        Task {
                            await DiagnosticsLogger.shared.setEnabled(newValue)
                            await self.loadDiagnosticsIfEnabled()
                        }
                    }
            }

            Section(AppLocalizer().string("Logging")) {
                Picker(AppLocalizer().string("Verbosity"), selection: self.$session.settings.loggingVerbosity) {
                    ForEach(LogVerbosity.allCases, id: \.self) { level in
                        Text(AppLocalizer().string(level.label)).tag(level)
                    }
                }
                Toggle(AppLocalizer().string("Log to file"), isOn: self.$session.settings.fileLoggingEnabled)
            }
            .onChange(of: self.session.settings.loggingVerbosity) { _, _ in
                self.applyLoggingSettings()
            }
            .onChange(of: self.session.settings.fileLoggingEnabled) { _, _ in
                self.applyLoggingSettings()
            }

            Section(AppLocalizer().string("Diagnostics")) {
                LabeledContent(AppLocalizer().string("Git binary")) {
                    Text(self.gitExecutableInfo.path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                LabeledContent(AppLocalizer().string("Git version")) {
                    Text(self.gitExecutableInfo.version ?? "—")
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                LabeledContent(AppLocalizer().string("Git sandboxed")) {
                    Text(self.gitExecutableInfo.isSandboxed ? "Yes" : "No")
                }
                if let error = self.gitExecutableInfo.error, !error.isEmpty {
                    LabeledContent(AppLocalizer().string("Git error")) {
                        Text(error)
                            .lineLimit(2)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)
                    }
                }
                LabeledContent(AppLocalizer().string("API host")) {
                    Text(self.diagnostics.apiHost.absoluteString)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                LabeledContent(AppLocalizer().string("REST rate limit")) {
                    Text(
                        self.diagnostics.restRateLimit.map(self.formatRate)
                            ?? "— (not fetched yet)"
                    )
                }
                LabeledContent(AppLocalizer().string("GraphQL rate limit")) {
                    Text(
                        self.diagnostics.graphQLRateLimit.map(self.formatRate)
                            ?? "— (not fetched yet)"
                    )
                }
                if let reset = diagnostics.rateLimitReset {
                    LabeledContent(AppLocalizer().string("Rate limit resets")) {
                        Text(RelativeFormatter.string(from: reset, relativeTo: Date()))
                    }
                }
                if let error = diagnostics.lastRateLimitError {
                    LabeledContent(AppLocalizer().string("Last API notice")) { Text(error).foregroundStyle(.red) }
                }
                if self.diagnostics.endpointCooldowns.isEmpty == false {
                    LabeledContent(AppLocalizer().string("Endpoint cooldowns")) {
                        VStack(alignment: .trailing, spacing: 3) {
                            ForEach(self.diagnostics.endpointCooldowns, id: \.url) { cooldown in
                                Text(self.endpointCooldownText(cooldown))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                LabeledContent(AppLocalizer().string("Backoff entries")) { Text("\(self.diagnostics.backoffEntries)") }
                LabeledContent(AppLocalizer().string("ETag entries")) { Text("\(self.diagnostics.etagEntries)") }
                Button(AppLocalizer().string("Refresh diagnostics")) { Task { await self.loadDiagnosticsIfEnabled() } }
            }
            .opacity(self.session.settings.diagnosticsEnabled ? 1 : 0.4)
            .disabled(!self.session.settings.diagnosticsEnabled)
        }
        .padding()
        .task {
            self.gitExecutableInfo = LocalProjectsService.gitExecutableInfo()
            await self.loadDiagnosticsIfEnabled()
        }
    }

    private func loadDiagnosticsIfEnabled() async {
        guard self.session.settings.diagnosticsEnabled else {
            self.diagnostics = .empty
            return
        }

        self.diagnostics = await self.appState.diagnostics()
    }

    private func applyLoggingSettings() {
        self.appState.persistSettings()
        RepoBarLogging.configure(
            verbosity: self.session.settings.loggingVerbosity,
            fileLoggingEnabled: self.session.settings.fileLoggingEnabled
        )
    }

    private func formatRate(_ snapshot: RateLimitSnapshot) -> String {
        var parts: [String] = []
        if let resource = snapshot.resource?.uppercased() {
            parts.append(resource)
        }
        if let remaining = snapshot.remaining, let limit = snapshot.limit {
            parts.append("\(remaining)/\(limit) left")
        } else if let remaining = snapshot.remaining {
            parts.append("\(remaining) remaining")
        } else if let limit = snapshot.limit {
            parts.append("limit \(limit)")
        }
        if let used = snapshot.used {
            parts.append("\(used) used")
        }
        if let reset = snapshot.reset {
            parts.append("resets \(RelativeFormatter.string(from: reset, relativeTo: Date()))")
        }
        let text = parts.joined(separator: " • ")
        return text.isEmpty ? "—" : text
    }

    private func endpointCooldownText(_ cooldown: EndpointCooldownSummary) -> String {
        let label = if let repository = cooldown.repository {
            "\(repository) \(cooldown.endpoint)"
        } else {
            cooldown.endpoint
        }
        return "\(label), retry \(RelativeFormatter.string(from: cooldown.retryAfter, relativeTo: Date()))"
    }
}
