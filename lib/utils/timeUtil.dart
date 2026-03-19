class TimeUtils {
  static String getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return "";

    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) {
      return "just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}