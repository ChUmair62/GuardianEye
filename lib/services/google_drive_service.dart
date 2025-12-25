import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class DriveService {
  DriveService._internal();
  static final DriveService instance = DriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive',
    ],
  );

  // --------------------------------------------------------------------
  // GET GOOGLE ACCESS TOKEN
  // --------------------------------------------------------------------
  Future<String?> _getAccessToken() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      print("❌ Failed to get Google token: $e");
      return null;
    }
  }

  // --------------------------------------------------------------------
  // CREATE FOLDER (ROOT OR CHILD)
  // --------------------------------------------------------------------
  Future<String?> _createFolder({
    required String token,
    required String name,
    String? parentId,
  }) async {
    final url = Uri.parse("https://www.googleapis.com/drive/v3/files");

    final body = {
      "name": name,
      "mimeType": "application/vnd.google-apps.folder",
      if (parentId != null) "parents": [parentId]
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)["id"];
    }

    print("❌ Folder creation failed: ${response.body}");
    return null;
  }

  // --------------------------------------------------------------------
  // UPLOAD ANY FILE USING RAW MULTIPART/RELATED (GOOGLE APPROVED)
  // --------------------------------------------------------------------
  Future<String?> _uploadFileRaw({
    required String token,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
    required String parentId,
  }) async {
    final uri = Uri.parse(
        "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart");

    const boundary = "gc0p4Jq0M2Yt08jU534c0p";

    final metadata = jsonEncode({
      "name": fileName,
      "parents": [parentId]
    });

    final List<int> bodyBytes = [];

    // ------------------ PART 1: Metadata ---------------------
    bodyBytes.addAll(utf8.encode("--$boundary\r\n"));
    bodyBytes.addAll(utf8.encode("Content-Type: application/json; charset=UTF-8\r\n\r\n"));
    bodyBytes.addAll(utf8.encode(metadata));
    bodyBytes.addAll(utf8.encode("\r\n"));

    // ------------------ PART 2: File binary ------------------
    bodyBytes.addAll(utf8.encode("--$boundary\r\n"));
    bodyBytes.addAll(utf8.encode("Content-Type: $mimeType\r\n\r\n"));
    bodyBytes.addAll(fileBytes);
    bodyBytes.addAll(utf8.encode("\r\n"));

    // ------------------ END BOUNDARY -------------------------
    bodyBytes.addAll(utf8.encode("--$boundary--"));

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/related; boundary=$boundary",
      },
      body: Uint8List.fromList(bodyBytes),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final id = json["id"];
      return "https://drive.google.com/file/d/$id/view";
    }

    print("❌ RAW Upload FAILED: ${response.body}");
    return null;
  }

  // --------------------------------------------------------------------
  // MAIN FULL WORKFLOW: CREATE FOLDERS + UPLOAD 3 FILES + SAVE FIRESTORE
  // --------------------------------------------------------------------
  Future<Map<String, dynamic>?> uploadInterviewFullFlow({
    required Uint8List videoBytes,
    required String transcriptText,
    required Map<String, dynamic> metadataJson,
    required String interviewId,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      print("❌ No Google token available");
      return null;
    }

    // --------------------------------------------------
    // 1. Create ROOT FOLDER (GuardianEye)
    // --------------------------------------------------
    final rootId = await _createFolder(
      token: token,
      name: "GuardianEye",
    );

    if (rootId == null) {
      print("❌ Could not create GuardianEye folder");
      return null;
    }

    // --------------------------------------------------
    // 2. Create Interview Folder (INT-xxxxx)
    // --------------------------------------------------
    final interviewFolderId =
        await _createFolder(token: token, name: interviewId, parentId: rootId);

    if (interviewFolderId == null) {
      print("❌ Could not create interview folder");
      return null;
    }

    // --------------------------------------------------
    // 3. Upload VIDEO
    // --------------------------------------------------
    final videoUrl = await _uploadFileRaw(
      token: token,
      fileBytes: videoBytes,
      fileName: "$interviewId.mp4",
      mimeType: "video/mp4",
      parentId: interviewFolderId,
    );

    // --------------------------------------------------
    // 4. Upload transcript.json
    // --------------------------------------------------
    final transcriptBytes = Uint8List.fromList(
      utf8.encode(jsonEncode({"transcript": transcriptText})),
    );

    final transcriptUrl = await _uploadFileRaw(
      token: token,
      fileBytes: transcriptBytes,
      fileName: "transcript.json",
      mimeType: "application/json",
      parentId: interviewFolderId,
    );

    // --------------------------------------------------
    // 5. Upload metadata.json
    // --------------------------------------------------
    final metadataBytes =
        Uint8List.fromList(utf8.encode(jsonEncode(metadataJson)));

    final metadataUrl = await _uploadFileRaw(
      token: token,
      fileBytes: metadataBytes,
      fileName: "metadata.json",
      mimeType: "application/json",
      parentId: interviewFolderId,
    );

    // --------------------------------------------------
    // 6. Save Firestore record
    // --------------------------------------------------
    await FirebaseFirestore.instance
        .collection("interviews")
        .doc(interviewId)
        .set({
      "interviewId": interviewId,
      "videoUrl": videoUrl,
      "transcriptUrl": transcriptUrl,
      "metadataUrl": metadataUrl,
      "folderId": interviewFolderId,
      "uploadedBy": FirebaseAuth.instance.currentUser?.email,
      "uploadedAt": DateTime.now().toIso8601String(),
      ...metadataJson,
    });

    return {
      "videoUrl": videoUrl,
      "transcriptUrl": transcriptUrl,
      "metadataUrl": metadataUrl,
      "folderId": interviewFolderId,
    };
  }
}
