Duration convertStringToDuration(String? duration) {
  final videoDuration = duration?.split(':');
  Duration convertedDuration = Duration(
    minutes: videoDuration != null ? int.parse(videoDuration[0]) : 0, 
    seconds: videoDuration != null ? int.parse(videoDuration[1]) : 0
  );

  return convertedDuration;
}

String convertDurationToString(Duration? duration) {
  final second = duration?.inSeconds.remainder(60) ?? 0;
  final minute = duration?.inMinutes.remainder(60) ?? 0;

  return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
}