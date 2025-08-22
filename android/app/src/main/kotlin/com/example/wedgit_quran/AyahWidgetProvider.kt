// package com.example.wedgit_quran

// import android.app.PendingIntent
// import android.appwidget.AppWidgetManager
// import android.appwidget.AppWidgetProvider
// import android.content.Context
// import android.content.Intent
// import android.net.Uri
// import android.widget.RemoteViews
// import es.antonborri.home_widget.HomeWidgetBackgroundIntent
// import es.antonborri.home_widget.HomeWidgetPlugin

// class AyahWidgetProvider : AppWidgetProvider() {

//     override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
//         for (appWidgetId in appWidgetIds) {
//             requestWidgetUpdate(context)
//         }
//     }

//     override fun onReceive(context: Context, intent: Intent) {
//         super.onReceive(context, intent)
//         if (Intent.ACTION_USER_PRESENT == intent.action || Intent.ACTION_BOOT_COMPLETED == intent.action) {
//             requestWidgetUpdate(context)
//         }
//     }

//     private fun requestWidgetUpdate(context: Context) {
//         val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
//             context,
//             Uri.parse("ayah_widget://update_background")
//         )
//         // --- هذا هو السطر الذي تم تصحيحه ---
//         backgroundIntent.send() 
//     }

//     companion object {
//         fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
//             val widgetData = HomeWidgetPlugin.getData(context)
//             val verseText = widgetData.getString("verse_text", "اضغط لتحديث الآية")
//             val verseRef = widgetData.getString("verse_ref", "آية وتأمل")
//             val verseId = widgetData.getInt("verse_id", -1)

//             val views = RemoteViews(context.packageName, R.layout.ayah_widget_layout).apply {
//                 setTextViewText(R.id.tv_verse_text, verseText)
//                 setTextViewText(R.id.tv_verse_ref, verseRef)

//                 val intent = Intent(context, MainActivity::class.java).apply {
//                     action = Intent.ACTION_VIEW
//                     data = Uri.parse("ayah_widget://open_ayah?id=$verseId")
//                 }
                
//                 val pendingIntent = PendingIntent.getActivity(
//                     context, 
//                     appWidgetId,
//                     intent, 
//                     PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//                 )
//                 setOnClickPendingIntent(R.id.widget_root, pendingIntent)
//             }
//             appWidgetManager.updateAppWidget(appWidgetId, views)
//         }
//     }

//     // لا حاجة لـ onAppWidgetOptionsChanged في هذا الإعداد
// }

package com.example.wedgit_quran

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class AyahWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            requestWidgetUpdate(context)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (Intent.ACTION_USER_PRESENT == intent.action || Intent.ACTION_BOOT_COMPLETED == intent.action) {
            requestWidgetUpdate(context)
        }
    }

    private fun requestWidgetUpdate(context: Context) {
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("ayah_widget://update_background")
        )
        backgroundIntent.send()
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val verseText = widgetData.getString("verse_text", "اضغط لتحديث الآية")
            val verseRef = widgetData.getString("verse_ref", "آية وتأمل")
            val verseId = widgetData.getInt("verse_id", -1)

            val views = RemoteViews(context.packageName, R.layout.ayah_widget_layout).apply {
                setTextViewText(R.id.tv_verse_text, verseText)
                setTextViewText(R.id.tv_verse_ref, verseRef)

                val intent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("ayah_widget://open_ayah?id=$verseId")
                }

                val pendingIntent = PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
