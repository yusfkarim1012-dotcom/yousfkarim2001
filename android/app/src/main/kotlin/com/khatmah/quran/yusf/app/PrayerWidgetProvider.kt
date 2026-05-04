package com.khatmah.quran.yusf.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale

class PrayerWidgetProvider : HomeWidgetProvider() {

    private fun formatNumbers(input: String, lang: String): String {
        if (lang == "ar") {
            val arabicNumbers = arrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
            var formatted = input
            for (i in 0..9) {
                formatted = formatted.replace(i.toString(), arabicNumbers[i].toString())
            }
            return formatted
        }
        return input
    }

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
            val appLang = widgetData.getString("app_lang", Locale.getDefault().language) ?: "en"

            val fajrLabel = widgetData.getString("fajr_label", "الفجر") ?: "الفجر"
            val dhuhrLabel = widgetData.getString("dhuhr_label", "الظهر") ?: "الظهر"
            val asrLabel = widgetData.getString("asr_label", "العصر") ?: "العصر"
            val maghribLabel = widgetData.getString("maghrib_label", "المغرب") ?: "المغرب"
            val ishaLabel = widgetData.getString("isha_label", "العشاء") ?: "العشاء"

            views.setTextViewText(R.id.fajr_time, formatNumbers(fajr, appLang))
            views.setTextViewText(R.id.dhuhr_time, formatNumbers(dhuhr, appLang))
            views.setTextViewText(R.id.asr_time, formatNumbers(asr, appLang))
            views.setTextViewText(R.id.maghrib_time, formatNumbers(maghrib, appLang))
            views.setTextViewText(R.id.isha_time, formatNumbers(isha, appLang))

            views.setTextViewText(R.id.fajr_label, fajrLabel)
            views.setTextViewText(R.id.dhuhr_label, dhuhrLabel)
            views.setTextViewText(R.id.asr_label, asrLabel)
            views.setTextViewText(R.id.maghrib_label, maghribLabel)
            views.setTextViewText(R.id.isha_label, ishaLabel)

            // Highlight next prayer in green, rest white
            val green = 0xFF7DF7C0.toInt() // A nicer green
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

            // Dynamic backgrounds for the active prayer container
            views.setInt(R.id.fajr_container, "setBackgroundResource", if (nextPrayer == "fajr") R.drawable.widget_next_bg else 0)
            views.setInt(R.id.dhuhr_container, "setBackgroundResource", if (nextPrayer == "dhuhr") R.drawable.widget_next_bg else 0)
            views.setInt(R.id.asr_container, "setBackgroundResource", if (nextPrayer == "asr") R.drawable.widget_next_bg else 0)
            views.setInt(R.id.maghrib_container, "setBackgroundResource", if (nextPrayer == "maghrib") R.drawable.widget_next_bg else 0)
            views.setInt(R.id.isha_container, "setBackgroundResource", if (nextPrayer == "isha") R.drawable.widget_next_bg else 0)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
