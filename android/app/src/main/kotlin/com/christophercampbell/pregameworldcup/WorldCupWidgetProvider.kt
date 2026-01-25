package com.christophercampbell.pregameworldcup

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.view.View
import android.app.PendingIntent
import android.content.Intent
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

/**
 * World Cup widget provider for Android home screen widget.
 * Displays live scores and upcoming matches.
 */
class WorldCupWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget first enabled
    }

    override fun onDisabled(context: Context) {
        // Widget disabled
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.world_cup_widget)
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            // Parse matches from shared preferences
            val liveMatches = parseMatches(prefs.getString("flutter.liveMatches", "[]") ?: "[]")
            val upcomingMatches = parseMatches(prefs.getString("flutter.upcomingMatches", "[]") ?: "[]")

            // Combine live and upcoming matches
            val allMatches = liveMatches + upcomingMatches
            val hasLiveMatches = liveMatches.isNotEmpty()

            // Show/hide live badge
            views.setViewVisibility(
                R.id.live_badge,
                if (hasLiveMatches) View.VISIBLE else View.GONE
            )

            // Update match rows
            if (allMatches.isEmpty()) {
                views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                views.setViewVisibility(R.id.match_1, View.GONE)
                views.setViewVisibility(R.id.match_2, View.GONE)
                views.setViewVisibility(R.id.match_3, View.GONE)
            } else {
                views.setViewVisibility(R.id.empty_state, View.GONE)

                // Match 1
                if (allMatches.isNotEmpty()) {
                    updateMatchRow(views, allMatches[0], 1)
                    views.setViewVisibility(R.id.match_1, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.match_1, View.GONE)
                }

                // Match 2
                if (allMatches.size > 1) {
                    updateMatchRow(views, allMatches[1], 2)
                    views.setViewVisibility(R.id.match_2, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.match_2, View.GONE)
                }

                // Match 3
                if (allMatches.size > 2) {
                    updateMatchRow(views, allMatches[2], 3)
                    views.setViewVisibility(R.id.match_3, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.match_3, View.GONE)
                }
            }

            // Set click intent to open app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.match_1, pendingIntent)
            views.setOnClickPendingIntent(R.id.match_2, pendingIntent)
            views.setOnClickPendingIntent(R.id.match_3, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun parseMatches(json: String): List<MatchData> {
            val matches = mutableListOf<MatchData>()
            try {
                val array = JSONArray(json)
                for (i in 0 until array.length()) {
                    val obj = array.getJSONObject(i)
                    matches.add(MatchData.fromJson(obj))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return matches
        }

        private fun updateMatchRow(views: RemoteViews, match: MatchData, rowNum: Int) {
            val homeFlagId = getResourceId("match_${rowNum}_home_flag")
            val homeCodeId = getResourceId("match_${rowNum}_home_code")
            val awayFlagId = getResourceId("match_${rowNum}_away_flag")
            val awayCodeId = getResourceId("match_${rowNum}_away_code")
            val scoreId = getResourceId("match_${rowNum}_score")
            val timeId = getResourceId("match_${rowNum}_time")

            views.setTextViewText(homeFlagId, match.homeFlag)
            views.setTextViewText(homeCodeId, match.homeTeamCode)
            views.setTextViewText(awayFlagId, match.awayFlag)
            views.setTextViewText(awayCodeId, match.awayTeamCode)
            views.setTextViewText(scoreId, match.scoreDisplay)
            views.setTextViewText(timeId, match.timeDisplay)

            // Set text color for live matches
            if (match.isLive) {
                views.setTextColor(scoreId, 0xFFFF0000.toInt())
                views.setTextColor(timeId, 0xFFFF0000.toInt())
            } else {
                views.setTextColor(scoreId, 0xFF000000.toInt())
                views.setTextColor(timeId, 0xFF888888.toInt())
            }
        }

        private fun getResourceId(name: String): Int {
            return when (name) {
                "match_1_home_flag" -> R.id.match_1_home_flag
                "match_1_home_code" -> R.id.match_1_home_code
                "match_1_away_flag" -> R.id.match_1_away_flag
                "match_1_away_code" -> R.id.match_1_away_code
                "match_1_score" -> R.id.match_1_score
                "match_1_time" -> R.id.match_1_time
                "match_2_home_flag" -> R.id.match_2_home_flag
                "match_2_home_code" -> R.id.match_2_home_code
                "match_2_away_flag" -> R.id.match_2_away_flag
                "match_2_away_code" -> R.id.match_2_away_code
                "match_2_score" -> R.id.match_2_score
                "match_2_time" -> R.id.match_2_time
                "match_3_home_flag" -> R.id.match_3_home_flag
                "match_3_home_code" -> R.id.match_3_home_code
                "match_3_away_flag" -> R.id.match_3_away_flag
                "match_3_away_code" -> R.id.match_3_away_code
                "match_3_score" -> R.id.match_3_score
                "match_3_time" -> R.id.match_3_time
                else -> 0
            }
        }
    }

    data class MatchData(
        val matchId: String,
        val homeTeam: String,
        val awayTeam: String,
        val homeTeamCode: String,
        val awayTeamCode: String,
        val homeFlag: String,
        val awayFlag: String,
        val homeScore: Int?,
        val awayScore: Int?,
        val matchTime: String,
        val status: String,
        val venue: String,
        val stage: String
    ) {
        val isLive: Boolean
            get() = status == "live" || status == "halftime"

        val scoreDisplay: String
            get() = if (homeScore != null && awayScore != null) {
                "$homeScore - $awayScore"
            } else {
                "vs"
            }

        val timeDisplay: String
            get() {
                if (isLive) return status.uppercase()

                return try {
                    val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                    val outputFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
                    val date = inputFormat.parse(matchTime)
                    date?.let { outputFormat.format(it) } ?: "TBD"
                } catch (e: Exception) {
                    "TBD"
                }
            }

        companion object {
            fun fromJson(json: JSONObject): MatchData {
                return MatchData(
                    matchId = json.optString("matchId", ""),
                    homeTeam = json.optString("homeTeam", ""),
                    awayTeam = json.optString("awayTeam", ""),
                    homeTeamCode = json.optString("homeTeamCode", ""),
                    awayTeamCode = json.optString("awayTeamCode", ""),
                    homeFlag = json.optString("homeFlag", ""),
                    awayFlag = json.optString("awayFlag", ""),
                    homeScore = if (json.isNull("homeScore")) null else json.optInt("homeScore"),
                    awayScore = if (json.isNull("awayScore")) null else json.optInt("awayScore"),
                    matchTime = json.optString("matchTime", ""),
                    status = json.optString("status", "upcoming"),
                    venue = json.optString("venue", ""),
                    stage = json.optString("stage", "")
                )
            }
        }
    }
}
