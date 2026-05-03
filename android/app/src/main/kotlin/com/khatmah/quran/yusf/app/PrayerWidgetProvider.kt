package com.khatmah.quran.yusf.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)

            val fajr = widgetData.getString("fajr", "--:--") ?: "--:--"
            val dhuhr = widgetData.getString("dhuhr", "--:--") ?: "--:--"
            val asr = widgetData.getString("asr", "--:--") ?: "--:--"
            val maghrib = widgetData.getString("maghrib", "--:--") ?: "--:--"
            val isha = widgetData.getString("isha", "--:--") ?: "--:--"
            val nextPrayer = widgetData.getString("next_prayer", "") ?: ""

            val fajrLabel = widgetData.getString("fajr_label", "Fajr") ?: "Fajr"
            val dhuhrLabel = widgetData.getString("dhuhr_label", "Dhuhr") ?: "Dhuhr"
            val asrLabel = widgetData.getString("asr_label", "Asr") ?: "Asr"
            val maghribLabel = widgetData.getString("maghrib_label", "Maghrib") ?: "Maghrib"
            val ishaLabel = widgetData.getString("isha_label", "Isha") ?: "Isha"

            views.setTextViewText(R.id.fajr_time, fajr)
            views.setTextViewText(R.id.dhuhr_time, dhuhr)
            views.setTextViewText(R.id.asr_time, asr)
            views.setTextViewText(R.id.maghrib_time, maghrib)
            views.setTextViewText(R.id.isha_time, isha)

            views.setTextViewText(R.id.fajr_label, fajrLabel)
            views.setTextViewText(R.id.dhuhr_label, dhuhrLabel)
            views.setTextViewText(R.id.asr_label, asrLabel)
            views.setTextViewText(R.id.maghrib_label, maghribLabel)
            views.setTextViewText(R.id.isha_label, ishaLabel)

            // Highlight next prayer
            val green = 0xFF4CAF50.toInt()
            val white = 0xFFFFFFFF.toInt()
            views.setTextColor(R.id.fajr_label, if (nextPrayer == "fajr") green else white)
            views.setTextColor(R.id.fajr_time, if (nextPrayer == "fajr") green else white)
            views.setTextColor(R.id.dhuhr_label, if (nextPrayer == "dhuhr") green else white)
            views.setTextColor(R.id.dhuhr_time, if (nextPrayer == "dhuhr") green else white)
            views.setTextColor(R.id.asr_label, if (nextPrayer == "asr") green else white)
            views.setTextColor(R.id.asr_time, if (nextPrayer == "asr") green else white)
            views.setTextColor(R.id.maghrib_label, if (nextPrayer == "maghrib") green else white)
            views.setTextColor(R.id.maghrib_time, if (nextPrayer == "maghrib") green else white)
            views.setTextColor(R.id.isha_label, if (nextPrayer == "isha") green else white)
            views.setTextColor(R.id.isha_time, if (nextPrayer == "isha") green else white)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
