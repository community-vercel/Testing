import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_structure/core/model/call_minutes.dart';

class AppUser {
  String? uid;

  String? userName;
  List<String?>? images = [
    null,
    null,
    null,
    null,
    null,
    null,
  ];
  DateTime? createdAt;
  DateTime? dob;
  String? gender;
  int? height;
  int? weight;
  String? relationshipStatus;
  String? about;

  bool? isOnline;
  DateTime? lastOnline;

  // Location fields
  double? latitude;
  double? longitude;
  String? address;
  String? city;
  String? country;

  List<String>? interests;
  List<String>? lookingFor;

  List<String>? likes;
  List<String>? superLikes;
  List<String>? matches;
  List<String>? visits;

  List<String>? liked;
  List<String>? superLiked;
  List<String>? matched;
  List<String>? visited;

  String? fcmToken;

  // Subscription fields
  bool? isVip;
  DateTime? vipStartDate;
  DateTime? vipEndDate;
  String? subscriptionId;
  String? subscriptionStatus;

  // Added callMinutes field
  CallMinutes? callMinutes;

  // Added spotlight field
  bool? inSpotlight;

  AppUser({
    this.uid,
    this.userName,
    this.images = const [
      null,
      null,
      null,
      null,
      null,
      null,
    ],
    this.createdAt,
    this.dob,
    this.gender,
    this.height,
    this.weight,
    this.relationshipStatus,
    this.about,
    this.isOnline,
    this.lastOnline,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.interests,
    this.lookingFor,
    this.likes,
    this.superLikes,
    this.matches,
    this.visits,
    this.liked,
    this.superLiked,
    this.matched,
    this.visited,
    this.fcmToken,
    this.isVip,
    this.vipStartDate,
    this.vipEndDate,
    this.subscriptionId,
    this.subscriptionStatus,
    this.callMinutes,
    this.inSpotlight,
  });

  AppUser copyWith({
    String? uid,
    String? userName,
    List<String?>? images,
    DateTime? createdAt,
    DateTime? dob,
    String? gender,
    int? height,
    int? weight,
    String? relationshipStatus,
    String? about,
    bool? isOnline,
    DateTime? lastOnline,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    List<String>? interests,
    List<String>? lookingFor,
    List<String>? likes,
    List<String>? superLikes,
    List<String>? matches,
    List<String>? visits,
    List<String>? liked,
    List<String>? superLiked,
    List<String>? matched,
    List<String>? visited,
    String? fcmToken,
    bool? isVip,
    DateTime? vipStartDate,
    DateTime? vipEndDate,
    String? subscriptionId,
    String? subscriptionStatus,
    CallMinutes? callMinutes,
    bool? inSpotlight,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      about: about ?? this.about,
      isOnline: isOnline ?? this.isOnline,
      lastOnline: lastOnline ?? this.lastOnline,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      lookingFor: lookingFor ?? this.lookingFor,
      likes: likes ?? this.likes,
      superLikes: superLikes ?? this.superLikes,
      matches: matches ?? this.matches,
      visits: visits ?? this.visits,
      liked: liked ?? this.liked,
      superLiked: superLiked ?? this.superLiked,
      matched: matched ?? this.matched,
      visited: visited ?? this.visited,
      fcmToken: fcmToken ?? this.fcmToken,
      isVip: isVip ?? this.isVip,
      vipStartDate: vipStartDate ?? this.vipStartDate,
      vipEndDate: vipEndDate ?? this.vipEndDate,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      callMinutes: callMinutes ?? this.callMinutes,
      inSpotlight: inSpotlight ?? this.inSpotlight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName ?? '',
      'images': images,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : DateTime.now(),
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'gender': gender ?? '',
      'height': height ?? 0,
      'weight': weight ?? 0,
      'relationshipStatus': relationshipStatus ?? '',
      'about': about ?? '',
      'isOnline': isOnline ?? true,
      'lastOnline':
          lastOnline != null ? Timestamp.fromDate(lastOnline!) : DateTime.now(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address ?? '',
      'city': city ?? '',
      'country': country ?? '',
      'interests': interests ?? [],
      'lookingFor': lookingFor ?? [],
      'likes': likes ?? [],
      'superLikes': superLikes ?? [],
      'matches': matches ?? [],
      'visits': visits ?? [],
      'liked': liked ?? [],
      'superLiked': superLiked ?? [],
      'matched': matched ?? [],
      'visited': visited ?? [],
      'fcmToken': fcmToken ?? '',
      'isVip': isVip ?? false,
      'vipStartDate':
          vipStartDate != null ? Timestamp.fromDate(vipStartDate!) : null,
      'vipEndDate': vipEndDate != null ? Timestamp.fromDate(vipEndDate!) : null,
      'subscriptionId': subscriptionId ?? '',
      'subscriptionStatus': subscriptionStatus ?? '',
      'callMinutes': callMinutes?.toMap() ?? CallMinutes().toMap(),
      'inSpotlight': inSpotlight ?? false,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      userName: json['userName'],
      images: List<String?>.from(json['images']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      dob: json['dob'] != null ? (json['dob'] as Timestamp).toDate() : null,
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      relationshipStatus: json['relationshipStatus'],
      about: json['about'],
      isOnline: json['isOnline'],
      lastOnline: (json['lastOnline'] as Timestamp).toDate(),
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      interests: List<String>.from(json['interests'] ?? []),
      lookingFor: List<String>.from(json['lookingFor'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      superLikes: List<String>.from(json['superLikes'] ?? []),
      matches: List<String>.from(json['matches'] ?? []),
      visits: List<String>.from(json['visits'] ?? []),
      liked: List<String>.from(json['liked'] ?? []),
      superLiked: List<String>.from(json['superLiked'] ?? []),
      matched: List<String>.from(json['matched'] ?? []),
      visited: List<String>.from(json['visited'] ?? []),
      fcmToken: json['fcmToken'],
      isVip: json['isVip'],
      vipStartDate: json['vipStartDate'] != null
          ? (json['vipStartDate'] as Timestamp).toDate()
          : null,
      vipEndDate: json['vipEndDate'] != null
          ? (json['vipEndDate'] as Timestamp).toDate()
          : null,
      subscriptionId: json['subscriptionId'],
      subscriptionStatus: json['subscriptionStatus'],
      callMinutes: CallMinutes.fromMap(json['callMinutes']),
      inSpotlight: json['inSpotlight'] ?? false,
    );
  }
}
