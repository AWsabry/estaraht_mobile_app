class IncomeReportRes {
  int? success;
  String? register;
  IncomeData? data;

  IncomeReportRes({this.success, this.register, this.data});

  IncomeReportRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'];
    data = json['data'] != null ? IncomeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['register'] = register;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class IncomeData {
  List<IncomeRecord>? incomeRecord;
  int? totalIncome;

  IncomeData({this.incomeRecord, this.totalIncome});

  IncomeData.fromJson(Map<String, dynamic> json) {
    if (json['income_record'] != null) {
      incomeRecord = <IncomeRecord>[];
      json['income_record'].forEach((v) {
        incomeRecord!.add(IncomeRecord.fromJson(v));
      });
    }
    totalIncome = json['total_income'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (incomeRecord != null) {
      data['income_record'] = incomeRecord!.map((v) => v.toJson()).toList();
    }
    data['total_income'] = totalIncome;
    return data;
  }
}

class IncomeRecord {
  String? date;
  int? amount;

  IncomeRecord({this.date, this.amount});

  IncomeRecord.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['amount'] = amount;
    return data;
  }
}
