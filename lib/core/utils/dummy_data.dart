import 'package:dokomandu/features/home/models/home_feed_model.dart';
import 'package:dokomandu/features/notifications/models/app_notification_model.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/models/kitchen_model.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:dokomandu/shared/models/user_model.dart';

class DummyData {
  const DummyData._();

  static Future<void> delay() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  static List<KitchenModel> kitchens() {
    return const [
      KitchenModel(
        id: 'kitchen_1',
        name: 'Himalayan Bowl Co.',
        imageUrl:
            'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80',
        rating: 4.6,
        distanceKm: 1.2,
        deliveryFee: 40,
        tags: ['Nepali', 'Momo', 'Thukpa'],
        isOpen: true,
        estimatedDeliveryMinutes: 28,
      ),
      KitchenModel(
        id: 'kitchen_2',
        name: 'Kathmandu Grill Hub',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=1200&q=80',
        rating: 4.4,
        distanceKm: 2.0,
        deliveryFee: 55,
        tags: ['BBQ', 'Rice Bowl', 'Spicy'],
        isOpen: true,
        estimatedDeliveryMinutes: 34,
      ),
      KitchenModel(
        id: 'kitchen_3',
        name: 'Blue Plate Bento',
        imageUrl:
            'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=1200&q=80',
        rating: 4.7,
        distanceKm: 2.5,
        deliveryFee: 60,
        tags: ['Bento', 'Sushi', 'Healthy'],
        isOpen: true,
        estimatedDeliveryMinutes: 32,
      ),
      KitchenModel(
        id: 'kitchen_4',
        name: 'Everest Pizza Room',
        imageUrl:
            'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=1200&q=80',
        rating: 4.3,
        distanceKm: 2.8,
        deliveryFee: 65,
        tags: ['Pizza', 'Pasta', 'Snacks'],
        isOpen: false,
        estimatedDeliveryMinutes: 40,
      ),
      KitchenModel(
        id: 'kitchen_5',
        name: 'Chiya & Chowmein Spot',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80',
        rating: 4.5,
        distanceKm: 0.8,
        deliveryFee: 35,
        tags: ['Street Food', 'Chowmein', 'Tea'],
        isOpen: true,
        estimatedDeliveryMinutes: 22,
      ),
    ];
  }

  static List<FoodItemModel> foods() {
    return const [
      FoodItemModel(
        id: 'food_1',
        kitchenId: 'kitchen_1',
        name: 'Steam Chicken Momo',
        description: 'Juicy chicken momo with tomato sesame achar.',
        imageUrl:
            'https://images.unsplash.com/photo-1626776876729-bab4369a5a5a?auto=format&fit=crop&w=1200&q=80',
        price: 249,
        rating: 4.7,
        isPopular: true,
        variants: [
          FoodVariant(id: 'f1_v1', name: '6 pcs', priceDelta: 0),
          FoodVariant(id: 'f1_v2', name: '10 pcs', priceDelta: 120),
        ],
        addons: [
          FoodAddon(id: 'f1_a1', name: 'Extra Achar', price: 25),
          FoodAddon(id: 'f1_a2', name: 'Soup', price: 60),
        ],
      ),
      FoodItemModel(
        id: 'food_2',
        kitchenId: 'kitchen_1',
        name: 'Buff Thukpa',
        description: 'Hot Himalayan noodle soup with veggies and buff slices.',
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80',
        price: 329,
        rating: 4.5,
        isPopular: true,
        variants: [
          FoodVariant(id: 'f2_v1', name: 'Regular', priceDelta: 0),
          FoodVariant(id: 'f2_v2', name: 'Large', priceDelta: 80),
        ],
        addons: [FoodAddon(id: 'f2_a1', name: 'Boiled Egg', price: 35)],
      ),
      FoodItemModel(
        id: 'food_3',
        kitchenId: 'kitchen_2',
        name: 'Smoky Chicken Rice Bowl',
        description: 'Grilled chicken, butter rice, pickled veggies.',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
        price: 399,
        rating: 4.4,
        isPopular: true,
        variants: [
          FoodVariant(id: 'f3_v1', name: 'Regular', priceDelta: 0),
          FoodVariant(id: 'f3_v2', name: 'Double Chicken', priceDelta: 140),
        ],
        addons: [
          FoodAddon(id: 'f3_a1', name: 'Cheese Sauce', price: 55),
          FoodAddon(id: 'f3_a2', name: 'Extra Salad', price: 40),
        ],
      ),
      FoodItemModel(
        id: 'food_4',
        kitchenId: 'kitchen_3',
        name: 'Teriyaki Bento Set',
        description: 'Teriyaki chicken with rice, greens, and dumpling.',
        imageUrl:
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1200&q=80',
        price: 519,
        rating: 4.8,
        isPopular: true,
        variants: [
          FoodVariant(id: 'f4_v1', name: 'Standard', priceDelta: 0),
          FoodVariant(id: 'f4_v2', name: 'Protein Plus', priceDelta: 110),
        ],
        addons: [FoodAddon(id: 'f4_a1', name: 'Miso Soup', price: 90)],
      ),
      FoodItemModel(
        id: 'food_5',
        kitchenId: 'kitchen_4',
        name: 'Farmhouse Pizza',
        description: 'Thin crust pizza with mushroom, olives, and corn.',
        imageUrl:
            'https://images.unsplash.com/photo-1594007654729-407eedc4be65?auto=format&fit=crop&w=1200&q=80',
        price: 649,
        rating: 4.3,
        isPopular: false,
        variants: [
          FoodVariant(id: 'f5_v1', name: 'Medium', priceDelta: 0),
          FoodVariant(id: 'f5_v2', name: 'Large', priceDelta: 180),
        ],
        addons: [FoodAddon(id: 'f5_a1', name: 'Cheese Burst', price: 120)],
      ),
      FoodItemModel(
        id: 'food_6',
        kitchenId: 'kitchen_5',
        name: 'Chicken Chowmein',
        description: 'Wok tossed noodles with chicken and crunchy veggies.',
        imageUrl:
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=1200&q=80',
        price: 279,
        rating: 4.6,
        isPopular: true,
        variants: [
          FoodVariant(id: 'f6_v1', name: 'Regular', priceDelta: 0),
          FoodVariant(id: 'f6_v2', name: 'Large', priceDelta: 90),
        ],
        addons: [FoodAddon(id: 'f6_a1', name: 'Fried Egg', price: 35)],
      ),
    ];
  }

  static HomeFeedModel homeFeed() {
    return HomeFeedModel(
      categories: const [
        FoodCategory(id: 'cat_1', name: 'Momo'),
        FoodCategory(id: 'cat_2', name: 'Biryani'),
        FoodCategory(id: 'cat_3', name: 'Pizza'),
        FoodCategory(id: 'cat_4', name: 'Healthy'),
        FoodCategory(id: 'cat_5', name: 'Snacks'),
      ],
      offers: const [
        OfferBanner(
          id: 'offer_1',
          title: 'Flat 20% Off on First 3 Orders',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
        ),
        OfferBanner(
          id: 'offer_2',
          title: 'Free Delivery Above Rs 700',
          imageUrl:
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80',
        ),
      ],
      nearbyKitchens: kitchens(),
      popularFoods: foods().where((f) => f.isPopular).toList(),
    );
  }

  static List<FoodItemModel> searchFoods(String query) {
    final keyword = query.toLowerCase().trim();
    if (keyword.isEmpty) return const [];

    return foods().where((food) {
      return food.name.toLowerCase().contains(keyword) ||
          food.description.toLowerCase().contains(keyword);
    }).toList();
  }

  static List<FoodItemModel> menuForKitchen(String kitchenId) {
    return foods().where((food) => food.kitchenId == kitchenId).toList();
  }

  static KitchenModel? kitchenById(String id) {
    for (final kitchen in kitchens()) {
      if (kitchen.id == id) return kitchen;
    }
    return null;
  }

  static List<OrderModel> activeOrders() {
    return [
      OrderModel(
        id: 'ORD-8421',
        items: const [
          OrderLineItem(
            foodName: 'Steam Chicken Momo',
            quantity: 2,
            price: 249,
          ),
          OrderLineItem(foodName: 'Buff Thukpa', quantity: 1, price: 329),
        ],
        subtotal: 827,
        deliveryFee: 40,
        tax: 107.51,
        total: 974.51,
        status: OrderStatus.preparing,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        deliveryAddress: 'Pulchowk, Lalitpur',
      ),
      OrderModel(
        id: 'ORD-8393',
        items: const [
          OrderLineItem(foodName: 'Chicken Chowmein', quantity: 1, price: 279),
        ],
        subtotal: 279,
        deliveryFee: 60,
        tax: 36.27,
        total: 375.27,
        status: OrderStatus.onTheWay,
        createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
        deliveryAddress: 'Jawalakhel, Lalitpur',
      ),
    ];
  }

  static List<OrderModel> historyOrders() {
    return [
      OrderModel(
        id: 'ORD-8201',
        items: const [
          OrderLineItem(
            foodName: 'Teriyaki Bento Set',
            quantity: 1,
            price: 519,
          ),
        ],
        subtotal: 519,
        deliveryFee: 40,
        tax: 72.67,
        total: 631.67,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        deliveryAddress: 'Baneswor, Kathmandu',
      ),
      OrderModel(
        id: 'ORD-8088',
        items: const [
          OrderLineItem(foodName: 'Farmhouse Pizza', quantity: 1, price: 649),
        ],
        subtotal: 649,
        deliveryFee: 0,
        tax: 84.37,
        total: 733.37,
        status: OrderStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        deliveryAddress: 'Sanepa, Lalitpur',
      ),
    ];
  }

  static OrderModel? orderById(String id) {
    for (final order in [...activeOrders(), ...historyOrders()]) {
      if (order.id == id) return order;
    }
    return null;
  }

  static List<AppNotificationModel> notifications() {
    return [
      AppNotificationModel(
        id: 'n1',
        title: 'Order Update',
        body: 'Your order ORD-8393 is on the way.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      AppNotificationModel(
        id: 'n2',
        title: 'New Offer',
        body: 'Use code HELLO20 and get 20% off on selected kitchens.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotificationModel(
        id: 'n3',
        title: 'Reorder Reminder',
        body: 'Your favorite momo combo is back at a discounted rate.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  static UserModel profile() {
    return const UserModel(
      id: 'guest-user',
      phone: '+977-9800000000',
      name: 'Demo Customer',
      email: 'demo@dokomandu.com',
      avatarUrl: null,
    );
  }

  static List<AddressModel> addresses() {
    return const [
      AddressModel(
        id: 'addr_1',
        label: 'Home',
        fullAddress: 'Pulchowk, Lalitpur, Nepal',
        latitude: 27.6710,
        longitude: 85.3167,
        landmark: 'Near Pulchowk Campus',
        isDefault: true,
      ),
      AddressModel(
        id: 'addr_2',
        label: 'Office',
        fullAddress: 'Baneshwor, Kathmandu, Nepal',
        latitude: 27.6915,
        longitude: 85.3438,
        landmark: 'Opposite Eyeplex Mall',
      ),
    ];
  }
}
