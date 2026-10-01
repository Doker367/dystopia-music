package com.dystopia.dystopia

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.KeyEvent
import android.widget.RemoteViews

open class DystopiaAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateMiniWidget(context, appWidgetManager, appWidgetId, "DYSTOPIA", "Reproductor Cyberpunk", false)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        handleMediaAction(context, intent.action)
    }

    companion object {
        const val ACTION_PLAY_PAUSE = "com.dystopia.dystopia.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.dystopia.dystopia.ACTION_NEXT"
        const val ACTION_PREV = "com.dystopia.dystopia.ACTION_PREV"

        fun handleMediaAction(context: Context, action: String?) {
            val keyCode = when (action) {
                ACTION_PLAY_PAUSE -> KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE
                ACTION_NEXT -> KeyEvent.KEYCODE_MEDIA_NEXT
                ACTION_PREV -> KeyEvent.KEYCODE_MEDIA_PREVIOUS
                else -> return
            }

            try {
                val mediaReceiver = ComponentName(context, "com.ryanheise.audioservice.MediaButtonReceiver")
                
                val downIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                    component = mediaReceiver
                    putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
                }
                context.sendBroadcast(downIntent)

                val upIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                    component = mediaReceiver
                    putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_UP, keyCode))
                }
                context.sendBroadcast(upIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun createMediaPendingIntent(context: Context, action: String, requestCode: Int): PendingIntent {
            val intent = Intent(context, DystopiaAppWidgetProvider::class.java).apply {
                this.action = action
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun createAppLaunchPendingIntent(context: Context, route: String? = null, genre: String? = null, requestCode: Int = 100): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                if (route != null) putExtra("route", route)
                if (genre != null) putExtra("genre", genre)
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun updateMiniWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            title: String,
            artist: String,
            isPlaying: Boolean
        ) {
            val views = RemoteViews(context.packageName, R.layout.dystopia_app_widget)

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_artist, artist)

            val playPauseRes = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
            views.setImageViewResource(R.id.widget_btn_play_pause, playPauseRes)

            views.setOnClickPendingIntent(R.id.widget_container, createAppLaunchPendingIntent(context))
            views.setOnClickPendingIntent(R.id.widget_btn_play_pause, createMediaPendingIntent(context, ACTION_PLAY_PAUSE, 201))
            views.setOnClickPendingIntent(R.id.widget_btn_next, createMediaPendingIntent(context, ACTION_NEXT, 202))

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateMediumWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            title: String,
            artist: String,
            isPlaying: Boolean
        ) {
            val views = RemoteViews(context.packageName, R.layout.dystopia_widget_medium)

            views.setTextViewText(R.id.widget_medium_title, title)
            views.setTextViewText(R.id.widget_medium_artist, artist)

            val playPauseRes = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
            views.setImageViewResource(R.id.widget_medium_btn_play_pause, playPauseRes)

            views.setOnClickPendingIntent(R.id.widget_medium_container, createAppLaunchPendingIntent(context, requestCode = 300))
            views.setOnClickPendingIntent(R.id.widget_medium_btn_prev, createMediaPendingIntent(context, ACTION_PREV, 301))
            views.setOnClickPendingIntent(R.id.widget_medium_btn_play_pause, createMediaPendingIntent(context, ACTION_PLAY_PAUSE, 302))
            views.setOnClickPendingIntent(R.id.widget_medium_btn_next, createMediaPendingIntent(context, ACTION_NEXT, 303))

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateHubWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            title: String,
            artist: String,
            isPlaying: Boolean
        ) {
            val views = RemoteViews(context.packageName, R.layout.dystopia_widget_hub)

            views.setTextViewText(R.id.widget_hub_title, title)
            views.setTextViewText(R.id.widget_hub_artist, artist)

            val playPauseRes = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
            views.setImageViewResource(R.id.widget_hub_btn_play_pause, playPauseRes)

            views.setOnClickPendingIntent(R.id.widget_hub_container, createAppLaunchPendingIntent(context, requestCode = 400))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_prev, createMediaPendingIntent(context, ACTION_PREV, 401))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_play_pause, createMediaPendingIntent(context, ACTION_PLAY_PAUSE, 402))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_next, createMediaPendingIntent(context, ACTION_NEXT, 403))

            // Quick Launcher Shortcuts
            views.setOnClickPendingIntent(R.id.widget_hub_btn_rock, createAppLaunchPendingIntent(context, route = "/explore", genre = "Rock", requestCode = 404))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_pop, createAppLaunchPendingIntent(context, route = "/explore", genre = "Pop", requestCode = 405))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_reggae, createAppLaunchPendingIntent(context, route = "/explore", genre = "Reggae", requestCode = 406))
            views.setOnClickPendingIntent(R.id.widget_hub_btn_downloads, createAppLaunchPendingIntent(context, route = "/downloads", requestCode = 407))

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context, title: String, artist: String, isPlaying: Boolean) {
            val appWidgetManager = AppWidgetManager.getInstance(context)

            // 1. Update Mini Widgets
            val miniComponent = ComponentName(context, DystopiaAppWidgetProvider::class.java)
            for (widgetId in appWidgetManager.getAppWidgetIds(miniComponent)) {
                updateMiniWidget(context, appWidgetManager, widgetId, title, artist, isPlaying)
            }

            // 2. Update Medium (2x2) Widgets
            val mediumComponent = ComponentName(context, DystopiaMediumWidgetProvider::class.java)
            for (widgetId in appWidgetManager.getAppWidgetIds(mediumComponent)) {
                updateMediumWidget(context, appWidgetManager, widgetId, title, artist, isPlaying)
            }

            // 3. Update Hub (4x2 / 4x3) Widgets
            val hubComponent = ComponentName(context, DystopiaHubWidgetProvider::class.java)
            for (widgetId in appWidgetManager.getAppWidgetIds(hubComponent)) {
                updateHubWidget(context, appWidgetManager, widgetId, title, artist, isPlaying)
            }
        }
    }
}

class DystopiaMediumWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            DystopiaAppWidgetProvider.updateMediumWidget(context, appWidgetManager, appWidgetId, "DYSTOPIA", "Reproductor Cyberpunk", false)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        DystopiaAppWidgetProvider.handleMediaAction(context, intent.action)
    }
}

class DystopiaHubWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            DystopiaAppWidgetProvider.updateHubWidget(context, appWidgetManager, appWidgetId, "DYSTOPIA", "Control Hub Cyberpunk", false)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        DystopiaAppWidgetProvider.handleMediaAction(context, intent.action)
    }
}
