class UpdateBankDetails {
  int? status;
  String? msg;
  int? success;

  UpdateBankDetails({this.status, this.msg, this.success});

  UpdateBankDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['success'] = success;
    return data;
  }
}

class GetBankDetails {
  int? status;
  String? msg;
  int? success;
  BankData? data;

  GetBankDetails({this.status, this.msg, this.success, this.data});

  GetBankDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    success = json['success'];
    data = json['data'] != null ? BankData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BankData {
  dynamic bankName;
  dynamic ifscCode;
  dynamic accountNo;
  dynamic accountHolderName;

  BankData({
    this.bankName,
    this.ifscCode,
    this.accountNo,
    this.accountHolderName,
  });

  BankData.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    ifscCode = json['ifsc_code'];
    accountNo = json['account_no'];
    accountHolderName = json['account_holder_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank_name'] = bankName;
    data['ifsc_code'] = ifscCode;
    data['account_no'] = accountNo;
    data['account_holder_name'] = accountHolderName;
    return data;
  }
}
