import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class AgoraTokenGenerator {
  static String buildTokenWithUid({
    required String appId,
    required String appCertificate,
    required String channelName,
    required int uid,
    int? expireSeconds,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTs = now + (expireSeconds ?? 3600);
    final salt = (DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF) % 99999999 + 1;

    // 1. Derivation of signing key:
    // key1 = HMac(appCertificate, uint32_le(issueTs))
    // signingKey = HMac(key1, uint32_le(salt))
    final issueTsBytes = Uint8List(4)..buffer.asByteData().setUint32(0, now, Endian.little);
    final saltBytes = Uint8List(4)..buffer.asByteData().setUint32(0, salt, Endian.little);
    final certBytes = utf8.encode(appCertificate);

    final key1 = Hmac(sha256, certBytes).convert(issueTsBytes).bytes;
    final signingKey = Hmac(sha256, key1).convert(saltBytes).bytes;

    // 2. Build signing_info payload:
    final builder = BytesBuilder();

    // putString(appId) -> uint16_le(32) + 32 bytes ASCII appId
    final appIdBytes = ascii.encode(appId);
    builder.add((ByteData(2)..setUint16(0, appIdBytes.length, Endian.little)).buffer.asUint8List());
    builder.add(appIdBytes);

    // issueTs, expireTs, salt, serviceCount=1
    final tsData = ByteData(4 + 4 + 4 + 2);
    tsData.setUint32(0, now, Endian.little);
    tsData.setUint32(4, expireTs, Endian.little);
    tsData.setUint32(8, salt, Endian.little);
    tsData.setUint16(12, 1, Endian.little); // service_count = 1
    builder.add(tsData.buffer.asUint8List());

    // Service RTC (type = 1):
    final rtcServiceBuilder = BytesBuilder();
    rtcServiceBuilder.add((ByteData(2)..setUint16(0, 1, Endian.little)).buffer.asUint8List()); // service_type = 1

    // Privileges Map: count=4 (Join, PublishAudio, PublishVideo, PublishData)
    final privData = ByteData(2 + (2 + 4) * 4);
    privData.setUint16(0, 4, Endian.little); // 4 privileges
    
    // Priv 1: JoinChannel (1)
    privData.setUint16(2, 1, Endian.little);
    privData.setUint32(4, expireTs, Endian.little);
    // Priv 2: PublishAudioStream (2)
    privData.setUint16(8, 2, Endian.little);
    privData.setUint32(10, expireTs, Endian.little);
    // Priv 3: PublishVideoStream (3)
    privData.setUint16(14, 3, Endian.little);
    privData.setUint32(16, expireTs, Endian.little);
    // Priv 4: PublishDataStream (4)
    privData.setUint16(20, 4, Endian.little);
    privData.setUint32(22, expireTs, Endian.little);

    rtcServiceBuilder.add(privData.buffer.asUint8List());

    // putString(channelName) -> uint16_le(len) + UTF8 bytes
    final chanBytes = utf8.encode(channelName);
    rtcServiceBuilder.add((ByteData(2)..setUint16(0, chanBytes.length, Endian.little)).buffer.asUint8List());
    rtcServiceBuilder.add(chanBytes);

    // putString(uid) -> uint16_le(len) + UTF8 bytes (uid as string, e.g. "2" or "" if 0)
    final uidStr = uid == 0 ? '' : uid.toString();
    final uidBytes = utf8.encode(uidStr);
    rtcServiceBuilder.add((ByteData(2)..setUint16(0, uidBytes.length, Endian.little)).buffer.asUint8List());
    rtcServiceBuilder.add(uidBytes);

    builder.add(rtcServiceBuilder.toBytes());

    final signingInfo = builder.toBytes();

    // 3. Compute HMAC-SHA256 signature using derived signingKey
    final sigBytes = Hmac(sha256, signingKey).convert(signingInfo).bytes;

    // 4. Pack content = putString(signature) + signingInfo
    final finalContentBuilder = BytesBuilder();
    finalContentBuilder.add((ByteData(2)..setUint16(0, sigBytes.length, Endian.little)).buffer.asUint8List());
    finalContentBuilder.add(sigBytes);
    finalContentBuilder.add(signingInfo);

    // 5. Compress content using zlib (deflate)
    final compressed = zlib.encode(finalContentBuilder.toBytes());

    // Return "007" + base64(compressed)
    return '007${base64Encode(compressed)}';
  }
}
