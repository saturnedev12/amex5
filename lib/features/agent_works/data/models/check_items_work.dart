class CheckItemsWork {
  final String? checkItemCode;
  final String? woDesc;
  final String? woCode;
  final String? woMobileUuid;

  const CheckItemsWork({
    this.checkItemCode,
    this.woDesc,
    this.woCode,
    this.woMobileUuid,
  });

  factory CheckItemsWork.fromJson(Map<String, dynamic> json) {
    return CheckItemsWork(
      checkItemCode: _readString(json['checkItemCode']),
      woDesc: _readString(json['woDesc']),
      woCode: _readString(json['woCode']),
      woMobileUuid: _readString(json['woMobileUuid']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'checkItemCode': checkItemCode,
    'woDesc': woDesc,
    'woCode': woCode,
    'woMobileUuid': woMobileUuid,
  };
}

String? _readString(dynamic value) => value?.toString();
