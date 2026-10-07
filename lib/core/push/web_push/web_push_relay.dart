/// Where relay URLs are addressed. Override with `--dart-define=PUSH_RELAY_ORIGIN=`
// for a self-hosted relay.
// ignore: do_not_use_environment -- compile-time relay origin
const String kPushRelayOrigin = String.fromEnvironment(
  'PUSH_RELAY_ORIGIN',
  defaultValue: 'https://push.fluxer.com',
);

/// The relay Fluxer operates. Kept separate from [kPushRelayOrigin] so a
/// self-hosted relay is not reported as a Fluxer relay by
/// [isFluxerPushRelayUrl], which gates the in-app relay consent notice.
const String kOfficialPushRelayOrigin = 'https://push.fluxer.com';

String fcmRelayUrl({required String appId, required String deviceToken}) {
  return '$kPushRelayOrigin/relay/v1/fcm/${_segment(appId)}/${_segment(deviceToken)}';
}

String apnsRelayUrl({
  required String appId,
  required String environment,
  required String deviceTokenHex,
}) {
  return '$kPushRelayOrigin/relay/v1/apns/'
      '${_segment(appId)}/${_segment(environment)}/${_segment(deviceTokenHex)}';
}

String apnsVoipRelayUrl({
  required String appId,
  required String environment,
  required String deviceTokenHex,
}) {
  return '$kPushRelayOrigin/relay/v1/apns-voip/'
      '${_segment(appId)}/${_segment(environment)}/${_segment(deviceTokenHex)}';
}

bool isFluxerPushRelayUrl(String token) {
  final Uri? parsed = Uri.tryParse(token);
  if (parsed == null) {
    return false;
  }
  final List<String> segments = parsed.pathSegments;
  if (segments.length < 3) {
    return false;
  }
  if (segments[0] != 'relay' || segments[1] != 'v1') {
    return false;
  }
  if (segments[2] != 'fcm' &&
      segments[2] != 'apns' &&
      segments[2] != 'apns-voip') {
    return false;
  }
  return _isOrigin(parsed, kOfficialPushRelayOrigin);
}

bool _isOrigin(Uri url, String origin) {
  final Uri? expected = Uri.tryParse(origin);
  if (expected == null) {
    return false;
  }
  if (url.scheme != expected.scheme || url.host != expected.host) {
    return false;
  }
  if (url.hasPort && url.port != expected.port) {
    return false;
  }
  return true;
}

String _segment(String value) => Uri.encodeComponent(value);

const String kPushRelayProviderApple = 'Apple';
const String kPushRelayProviderGoogle = 'Google';

String pushRelayProviderName({required bool isApple}) =>
    isApple ? kPushRelayProviderApple : kPushRelayProviderGoogle;
