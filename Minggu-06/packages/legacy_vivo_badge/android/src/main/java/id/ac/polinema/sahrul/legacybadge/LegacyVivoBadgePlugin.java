package id.ac.polinema.sahrul.legacybadge;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.media.AudioManager;
import java.util.HashMap;
import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public final class LegacyVivoBadgePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private Context context;
    private MethodChannel channel;
    @Override public void onAttachedToEngine(FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "campus_notify/legacy_vivo_badge");
        channel.setMethodCallHandler(this);
    }
    private String homePackage() {
        Intent home = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME);
        ResolveInfo resolved = context.getPackageManager().resolveActivity(home, PackageManager.MATCH_DEFAULT_ONLY);
        return resolved == null ? "" : resolved.activityInfo.packageName;
    }
    @Override public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        String home = homePackage();
        boolean legacy = home.equals("com.bbk.launcher2") || home.equals("com.bbk.launcher");
        if (call.method.equals("supported")) {
            result.success(legacy);
        } else if (call.method.equals("update")) {
            if (!legacy) { result.success(null); return; }
            Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            if (launch == null || launch.getComponent() == null) { result.error("NO_LAUNCHER", "Ikon aplikasi tidak ditemukan", null); return; }
            int count = call.arguments instanceof Number ? Math.max(0, ((Number) call.arguments).intValue()) : 0;
            Intent badge = new Intent("launcher.action.CHANGE_APPLICATION_NOTIFICATION_NUM");
            badge.setPackage(home);
            badge.putExtra("packageName", context.getPackageName());
            badge.putExtra("className", launch.getComponent().getClassName());
            badge.putExtra("notificationNum", count);
            badge.addFlags(0x01000000); // FLAG_RECEIVER_INCLUDE_BACKGROUND, seperti implementasi Vivo.
            context.sendBroadcast(badge);
            result.success(null);
        } else if (call.method.equals("audio")) {
            AudioManager audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            Map<String,Object> values = new HashMap<>();
            values.put("ringer_normal", audio.getRingerMode() == AudioManager.RINGER_MODE_NORMAL);
            values.put("notification_volume", audio.getStreamVolume(AudioManager.STREAM_NOTIFICATION));
            values.put("max_volume", audio.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION));
            result.success(values);
        } else { result.notImplemented(); }
    }
    @Override public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        context = null;
    }
}
