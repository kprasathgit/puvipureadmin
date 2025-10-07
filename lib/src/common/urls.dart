class Urls {
  //Live
  static const serviceUrl = "https://service.clontalk.com";

  //Test
  // static const serviceUrl = "https://webhook.clontalk.com";

  //AdminInventoryController Urls
  static const inventoryMappingUrl =
      '$serviceUrl/admin/products'; // controller mapping
  static const allProducts = '$inventoryMappingUrl/all';
  static const addProducts = '$inventoryMappingUrl/add';
  static const updateProducts = '$inventoryMappingUrl/update';
  static const deleteProducts = '$inventoryMappingUrl/delete';
  static const getLowStockProducts = '$inventoryMappingUrl/lowstock';

  // AdminOrderController Urlsx
  static const orderMappingUrl =
      '$serviceUrl/admin/orders'; // controller mapping
  static const getAllOrders = '$orderMappingUrl/getallorders';
  static const getSingleOrder = '$orderMappingUrl/getsingleorder';
  static const getOrderSummary = '$orderMappingUrl/summary';

  //AdminUserController Urls
  static const userMappingUrl = '$serviceUrl/admin/users'; // controller mapping
  static const getAllUsers = '$userMappingUrl/getallusers';

  //Admin Auth Controller Urls
  static const adminAuthMappingUrl =
      '$serviceUrl/adminauth'; // controller mapping
  static const adminLogin = '$adminAuthMappingUrl/login';
  static const adminLogout = '$adminAuthMappingUrl/logout';
  static const adminProfile = '$adminAuthMappingUrl/me';
  static const adminAddFcm = '$adminAuthMappingUrl/fcm/add';
  static const adminRemoveFcm = '$adminAuthMappingUrl/fcm/remove';
  static const adminRefershToken = '$adminAuthMappingUrl/refresh';

  //DashBoard Urls
  static const dashboardMappingUrl =
      '$serviceUrl/admin/dashboard'; // controller mapping
  static const dashBoardData = '$dashboardMappingUrl/all'; // controller mapping
}
