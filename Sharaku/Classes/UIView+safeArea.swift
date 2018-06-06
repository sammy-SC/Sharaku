extension UIView {
  /// Returns `safeAreaLayoutGuide.bottomAnchor` on iOS 11,
  /// otherwise returns `bottomAnchor`.
  var safeBottom: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.bottomAnchor
    } else {
      return bottomAnchor
    }
  }

  /// Returns `safeAreaLayoutGuide.topAnchor` on iOS 11,
  /// otherwise returns `topAnchor`.
  var safeTop: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.topAnchor
    } else {
      return topAnchor
    }
  }
}
