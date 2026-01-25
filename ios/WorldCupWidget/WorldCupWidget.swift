import WidgetKit
import SwiftUI

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

// MARK: - Provider

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
        let userDefaults = UserDefaults(suiteName: "group.com.christophercampbell.pregameworldcup")

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

// MARK: - Entry

struct WorldCupEntry: TimelineEntry {
    let date: Date
    let upcomingMatches: [MatchData]
    let liveMatches: [MatchData]
    let config: WidgetConfig
}

// MARK: - Views

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
            // Header
            HStack {
                Image(systemName: "sportscourt")
                    .foregroundColor(.green)
                Text("World Cup")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            Spacer()

            // Show live match if available, otherwise next upcoming
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
            // Header
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

            // Matches
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
            // Header
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

            // Live matches section
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

            // Upcoming matches section
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
            // Home team
            HStack(spacing: 4) {
                Text(match.homeFlag)
                Text(match.homeTeamCode)
                    .fontWeight(.semibold)
            }
            .font(.caption)

            Spacer()

            // Score or time
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

            // Away team
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

// MARK: - Widget

@main
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
