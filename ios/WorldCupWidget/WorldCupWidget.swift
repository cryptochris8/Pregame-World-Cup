import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Shared Constants

private let appGroupId = "group.com.christophercampbell.pregameworldcup"

// MARK: - Data Models

struct MatchData: Codable, Identifiable {
    let matchId: String
    let homeTeam: String
    let awayTeam: String
    let homeTeamCode: String
    let awayTeamCode: String
    let homeFlag: String
    let awayFlag: String
    let homeScore: Int?
    let awayScore: Int?
    let matchTime: String
    let status: String
    let venue: String
    let stage: String

    var id: String { matchId }

    var isLive: Bool { status == "live" || status == "halftime" }

    var displayTime: String {
        if isLive { return status.uppercased() }

        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: matchTime) else { return "TBD" }

        let displayFormatter = DateFormatter()
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }

    var scoreDisplay: String {
        if let home = homeScore, let away = awayScore {
            return "\(home) - \(away)"
        }
        return "vs"
    }
}

struct WidgetConfig: Codable {
    let showLiveScores: Bool
    let showUpcomingMatches: Bool
    let upcomingMatchCount: Int
    let favoriteTeamCode: String?
    let compactMode: Bool
}

// MARK: - Home Screen Widget Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WorldCupEntry {
        WorldCupEntry(
            date: Date(),
            upcomingMatches: [sampleMatch],
            liveMatches: [],
            config: defaultConfig
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WorldCupEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorldCupEntry>) -> Void) {
        let entry = loadEntry()

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> WorldCupEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)

        var upcomingMatches: [MatchData] = []
        var liveMatches: [MatchData] = []
        var config = defaultConfig

        if let configData = userDefaults?.string(forKey: "config"),
           let data = configData.data(using: .utf8) {
            config = (try? JSONDecoder().decode(WidgetConfig.self, from: data)) ?? defaultConfig
        }

        if let upcomingData = userDefaults?.string(forKey: "upcomingMatches"),
           let data = upcomingData.data(using: .utf8) {
            upcomingMatches = (try? JSONDecoder().decode([MatchData].self, from: data)) ?? []
        }

        if let liveData = userDefaults?.string(forKey: "liveMatches"),
           let data = liveData.data(using: .utf8) {
            liveMatches = (try? JSONDecoder().decode([MatchData].self, from: data)) ?? []
        }

        return WorldCupEntry(
            date: Date(),
            upcomingMatches: upcomingMatches,
            liveMatches: liveMatches,
            config: config
        )
    }

    private var defaultConfig: WidgetConfig {
        WidgetConfig(
            showLiveScores: true,
            showUpcomingMatches: true,
            upcomingMatchCount: 3,
            favoriteTeamCode: nil,
            compactMode: false
        )
    }

    private var sampleMatch: MatchData {
        MatchData(
            matchId: "1",
            homeTeam: "United States",
            awayTeam: "Mexico",
            homeTeamCode: "USA",
            awayTeamCode: "MEX",
            homeFlag: "🇺🇸",
            awayFlag: "🇲🇽",
            homeScore: nil,
            awayScore: nil,
            matchTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
            status: "upcoming",
            venue: "MetLife Stadium",
            stage: "Group Stage"
        )
    }
}

// MARK: - Home Screen Widget Entry

struct WorldCupEntry: TimelineEntry {
    let date: Date
    let upcomingMatches: [MatchData]
    let liveMatches: [MatchData]
    let config: WidgetConfig
}

// MARK: - Home Screen Widget Views

struct WorldCupWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: WorldCupEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "sportscourt")
                    .foregroundColor(.green)
                Text("World Cup")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            Spacer()

            if let match = entry.liveMatches.first ?? entry.upcomingMatches.first {
                CompactMatchView(match: match)
            } else {
                Text("No matches")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct MediumWidgetView: View {
    let entry: WorldCupEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sportscourt")
                    .foregroundColor(.green)
                Text("World Cup 2026")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                if !entry.liveMatches.isEmpty {
                    LiveBadge()
                }
            }

            Divider()

            if !entry.liveMatches.isEmpty {
                ForEach(entry.liveMatches.prefix(2)) { match in
                    MatchRowView(match: match, isLive: true)
                }
            } else if !entry.upcomingMatches.isEmpty {
                ForEach(entry.upcomingMatches.prefix(2)) { match in
                    MatchRowView(match: match, isLive: false)
                }
            } else {
                Spacer()
                Text("No upcoming matches")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct LargeWidgetView: View {
    let entry: WorldCupEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sportscourt")
                    .foregroundColor(.green)
                Text("World Cup 2026")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                if !entry.liveMatches.isEmpty {
                    LiveBadge()
                }
            }

            Divider()

            if !entry.liveMatches.isEmpty {
                Text("LIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)

                ForEach(entry.liveMatches.prefix(2)) { match in
                    MatchRowView(match: match, isLive: true)
                }

                Divider()
            }

            if !entry.upcomingMatches.isEmpty {
                Text("UPCOMING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                ForEach(entry.upcomingMatches.prefix(entry.config.upcomingMatchCount)) { match in
                    MatchRowView(match: match, isLive: false)
                }
            }

            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct CompactMatchView: View {
    let match: MatchData

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(match.homeFlag)
                Text(match.homeTeamCode)
                    .fontWeight(.bold)
            }
            .font(.caption)

            Text(match.isLive ? match.scoreDisplay : "vs")
                .font(.caption2)
                .foregroundColor(match.isLive ? .red : .secondary)

            HStack {
                Text(match.awayFlag)
                Text(match.awayTeamCode)
                    .fontWeight(.bold)
            }
            .font(.caption)

            Text(match.displayTime)
                .font(.caption2)
                .foregroundColor(match.isLive ? .red : .secondary)
        }
    }
}

struct MatchRowView: View {
    let match: MatchData
    let isLive: Bool

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text(match.homeFlag)
                Text(match.homeTeamCode)
                    .fontWeight(.semibold)
            }
            .font(.caption)

            Spacer()

            VStack(spacing: 2) {
                Text(match.scoreDisplay)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isLive ? .red : .primary)

                Text(match.displayTime)
                    .font(.caption2)
                    .foregroundColor(isLive ? .red : .secondary)
            }
            .frame(width: 60)

            Spacer()

            HStack(spacing: 4) {
                Text(match.awayTeamCode)
                    .fontWeight(.semibold)
                Text(match.awayFlag)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isLive ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

struct LiveBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
            Text("LIVE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Home Screen Widget Definition

struct WorldCupWidget: Widget {
    let kind: String = "WorldCupWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WorldCupWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("World Cup 2026")
        .description("Stay updated with live scores and upcoming matches.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// ============================================================================
// MARK: - Live Activity (Dynamic Island + Lock Screen)
// ============================================================================

/// Required by the live_activities Flutter plugin.
/// The struct name MUST be exactly "LiveActivitiesAppAttributes".
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

// MARK: - Live Activity Helper

/// Reads Live Activity data from App Group UserDefaults.
/// The live_activities plugin writes each field as "{activityUUID}_{key}".
struct LiveActivityData {
    let sharedDefault: UserDefaults
    let context: ActivityViewContext<LiveActivitiesAppAttributes>

    private func key(_ name: String) -> String {
        context.attributes.prefixedKey(name)
    }

    var homeTeam: String { sharedDefault.string(forKey: key("homeTeam")) ?? "TBD" }
    var awayTeam: String { sharedDefault.string(forKey: key("awayTeam")) ?? "TBD" }
    var homeTeamName: String { sharedDefault.string(forKey: key("homeTeamName")) ?? "" }
    var awayTeamName: String { sharedDefault.string(forKey: key("awayTeamName")) ?? "" }
    var homeScore: Int { sharedDefault.integer(forKey: key("homeScore")) }
    var awayScore: Int { sharedDefault.integer(forKey: key("awayScore")) }
    var matchMinute: String { sharedDefault.string(forKey: key("matchMinute")) ?? "" }
    var matchStatus: String { sharedDefault.string(forKey: key("matchStatus")) ?? "Upcoming" }
    var homeFlag: String { sharedDefault.string(forKey: key("homeFlag")) ?? "" }
    var awayFlag: String { sharedDefault.string(forKey: key("awayFlag")) ?? "" }
    var venue: String { sharedDefault.string(forKey: key("venue")) ?? "" }
    var stage: String { sharedDefault.string(forKey: key("stage")) ?? "" }
    var matchId: String { sharedDefault.string(forKey: key("matchId")) ?? "" }

    var isLive: Bool {
        let s = matchStatus.lowercased()
        return s == "in progress" || s == "half time" || s == "extra time" || s == "penalties"
    }

    var statusColor: Color {
        if isLive { return .green }
        if matchStatus == "Full Time" { return .secondary }
        return .orange
    }
}

// MARK: - Lock Screen Live Activity View

struct MatchLockScreenView: View {
    let data: LiveActivityData

    var body: some View {
        HStack(spacing: 0) {
            // Home team
            VStack(spacing: 4) {
                Text(data.homeFlag)
                    .font(.title2)
                Text(data.homeTeam)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)

            // Score + status
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    Text("\(data.homeScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("-")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(data.awayScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                HStack(spacing: 4) {
                    if data.isLive {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                    if !data.matchMinute.isEmpty {
                        Text(data.matchMinute)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(data.statusColor)
                    }
                    Text(data.matchStatus)
                        .font(.caption2)
                        .foregroundColor(data.statusColor)
                }

                if !data.venue.isEmpty {
                    Text(data.venue)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)

            // Away team
            VStack(spacing: 4) {
                Text(data.awayFlag)
                    .font(.title2)
                Text(data.awayTeam)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .activityBackgroundTint(.black.opacity(0.85))
    }
}

// MARK: - Live Activity Widget

struct MatchLiveActivity: Widget {
    let sharedDefault = UserDefaults(suiteName: appGroupId)!

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen presentation
            let data = LiveActivityData(sharedDefault: sharedDefault, context: context)
            MatchLockScreenView(data: data)

        } dynamicIsland: { context in
            let data = LiveActivityData(sharedDefault: sharedDefault, context: context)

            DynamicIsland {
                // EXPANDED view (long press on Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    VStack(spacing: 2) {
                        Text(data.homeFlag)
                            .font(.title3)
                        Text(data.homeTeam)
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text("\(data.homeScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 2) {
                        Text(data.awayFlag)
                            .font(.title3)
                        Text(data.awayTeam)
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text("\(data.awayScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text("vs")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 6) {
                        if data.isLive {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        }
                        if !data.matchMinute.isEmpty {
                            Text(data.matchMinute)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(data.statusColor)
                        }
                        Text(data.matchStatus)
                            .font(.caption)
                            .foregroundColor(data.statusColor)

                        if !data.stage.isEmpty {
                            Text("·")
                                .foregroundColor(.secondary)
                            Text(data.stage)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

            } compactLeading: {
                // COMPACT leading (pill left side)
                HStack(spacing: 4) {
                    Text(data.homeFlag)
                    Text("\(data.homeScore)")
                        .fontWeight(.bold)
                }
                .font(.caption)

            } compactTrailing: {
                // COMPACT trailing (pill right side)
                HStack(spacing: 4) {
                    Text("\(data.awayScore)")
                        .fontWeight(.bold)
                    Text(data.awayFlag)
                }
                .font(.caption)

            } minimal: {
                // MINIMAL (when multiple activities are active)
                Text("\(data.homeScore)-\(data.awayScore)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }
}

// ============================================================================
// MARK: - Widget Bundle (Entry Point)
// ============================================================================

@main
struct WorldCupWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Home Screen Widgets
        WorldCupWidget()
        // Live Activity (Dynamic Island + Lock Screen)
        MatchLiveActivity()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WorldCupWidget()
} timeline: {
    WorldCupEntry(
        date: Date(),
        upcomingMatches: [
            MatchData(
                matchId: "1",
                homeTeam: "United States",
                awayTeam: "Mexico",
                homeTeamCode: "USA",
                awayTeamCode: "MEX",
                homeFlag: "🇺🇸",
                awayFlag: "🇲🇽",
                homeScore: nil,
                awayScore: nil,
                matchTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
                status: "upcoming",
                venue: "MetLife Stadium",
                stage: "Group Stage"
            )
        ],
        liveMatches: [],
        config: WidgetConfig(
            showLiveScores: true,
            showUpcomingMatches: true,
            upcomingMatchCount: 3,
            favoriteTeamCode: nil,
            compactMode: false
        )
    )
}
