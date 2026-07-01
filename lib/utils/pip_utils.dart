class PipUtils {
  const PipUtils._();

  static bool shouldAutoEnterPiPOnBackground({
    required bool continuePlayInBackground,
    required bool isPlaying,
    required bool isCurrentPage,
    required bool isIOS,
  }) {
    if (!continuePlayInBackground || !isPlaying || !isCurrentPage) {
      return false;
    }
    return isIOS;
  }
}
