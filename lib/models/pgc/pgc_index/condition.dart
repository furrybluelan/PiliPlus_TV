class PgcIndexCondition {
  List<Filter>? filter;
  List<Order>? order;

  PgcIndexCondition({
    this.filter,
    this.order,
  });

  PgcIndexCondition.fromJson(Map json) {
    filter = (json['filter'] as List?)
        ?.map((item) => Filter.fromJson(item))
        .toList();
    order =
        (json['order'] as List?)?.map((item) => Order.fromJson(item)).toList();
  }
}

class Order {
  String? field;
  String? name;
  String? sort;

  Order({
    this.field,
    this.name,
    this.sort,
  });

  Order.fromJson(Map json) {
    field = json['field'];
    name = json['name'];
    sort = json['sort'];
  }
}

class Filter {
  String? field;
  String? name;
  List<Values>? values;

  Filter({
    this.field,
    this.name,
    this.values,
  });

  Filter.fromJson(Map json) {
    field = json['field'];
    name = json['name'];
    values = (json['values'] as List?)
        ?.map((item) => Values.fromJson(item))
        .toList();
  }
}

class Values {
  String? keyword;
  String? name;

  Values({
    this.keyword,
    this.name,
  });

  Values.fromJson(Map json) {
    keyword = json['keyword'];
    name = json['name'];
  }
}
