class KitchenQueryModel {
  const KitchenQueryModel({this.page = 1, this.limit = 10, this.search});

  final int page;
  final int limit;
  final String? search;
}
