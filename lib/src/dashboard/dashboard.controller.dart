import 'package:flutter/material.dart';
import 'package:puvipureadmin/src/common/apiservice.dart';
import 'package:puvipureadmin/src/common/urls.dart';
import 'package:puvipureadmin/src/models/dashboardmodel.dart';

class DashboardController with ChangeNotifier {
  bool loading = false;
  DashboardModel? dashboard;

  Future<void> fetchDashboard({Map<String, String>? params}) async {
    loading = true;
    notifyListeners();

    try {
      final res = await ApiService.get<DashboardModel>(
        url: Urls.dashBoardData,          // required
        queryParams: params ?? {},
        fromJson: (data) => DashboardModel.fromJson(data),  // required
      );

      if (res.status) { // check res.status
        dashboard = res.returnObject;
      } else {
        throw Exception(res.message);
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
