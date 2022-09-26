// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../../android_webview.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewCookieManagerCreationParams] for
/// more information.
@immutable
class AndroidWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Creates a new [AndroidWebViewCookieManagerCreationParams] instance.
  const AndroidWebViewCookieManagerCreationParams._(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params,
  ) : super();

  /// Creates a [AndroidWebViewCookieManagerCreationParams] instance based on [PlatformWebViewCookieManagerCreationParams].
  factory AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
      PlatformWebViewCookieManagerCreationParams params) {
    return AndroidWebViewCookieManagerCreationParams._(params);
  }
}

/// Handles all cookie operations for the Android platform.
class AndroidWebViewCookieManager extends PlatformWebViewCookieManager {
  /// Creates a new [AndroidWebViewCookieManager].
  AndroidWebViewCookieManager(AndroidWebViewCookieManagerCreationParams params)
      : this.fromNativeApi(
          params,
          cookieManager: CookieManager.instance,
        );

  /// Creates a new [AndroidWebViewCookieManager] using the Android native [CookieManager] implementation.
  ///
  /// This constructor is only used for testing. An instance should be obtained
  /// with the default [AndroidWebViewCookieManager] constructor.
  @visibleForTesting
  AndroidWebViewCookieManager.fromNativeApi(
    AndroidWebViewCookieManagerCreationParams params, {
    required CookieManager cookieManager,
  })  : _cookieManager = cookieManager,
        super.implementation(params);

  final CookieManager _cookieManager;

  @override
  Future<bool> clearCookies() {
    return _cookieManager.clearCookies();
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
          'The path property for the provided cookie was not given a legal value.');
    }
    return _cookieManager.setCookie(
      cookie.domain,
      '${Uri.encodeComponent(cookie.name)}=${Uri.encodeComponent(cookie.value)}; path=${cookie.path}',
    );
  }

  bool _isValidPath(String path) {
    // Permitted ranges based on RFC6265bis: https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-02#section-4.1.1
    for (final int char in path.codeUnits) {
      if ((char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E)) {
        return false;
      }
    }
    return true;
  }
}
