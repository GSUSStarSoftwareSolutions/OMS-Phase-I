import 'dart:html';
import 'package:btb/Order%20Module/order%20view.dart';
import 'package:btb/admin/admin%20edit.dart';
import 'package:btb/admin/admin%20list.dart';
import 'package:btb/admin/create%20login.dart';
import 'package:btb/customer%20login/order/create%20order.dart';
import 'package:btb/customer%20login/order/order%20view%20responsive.dart';
import 'package:btb/customer%20module/create%20customer.dart';
import 'package:btb/customer%20module/customer%20view.dart';
import 'package:btb/dashboard/pay%20complete.dart';
import 'package:btb/login/login.dart';
import 'dart:html' as html;
import 'package:btb/Order%20Module/add%20productmaster%20sample.dart';
import 'package:btb/Order%20Module/eighthpage.dart';
import 'package:btb/Order%20Module/fifthpage.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/Order%20Module/fourthpage.dart';
import 'package:btb/Order%20Module/secondpage.dart';
import 'package:btb/Order%20Module/seventhpage%20.dart';
import 'package:btb/Order%20Module/sixthpage.dart';
import 'package:btb/Order%20Module/thirdpage.dart';
import 'package:btb/dashboard/dashboard.dart';
import 'package:btb/dashboard/openinvoice%20screen.dart';
import 'package:btb/dashboard/openorder%20screen.dart';
import 'package:btb/dashboard/order%20completedlistscreen.dart';
import 'package:btb/customer%20login/home/admin%20dash.dart';
import 'package:btb/sample/notifier.dart';
import 'package:btb/sample/size.dart';
//import 'package:btb/customer%20login/home/order%20list.dart';
import 'package:btb/widgets/productclass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'Order Module/responsive order view.dart';
import 'Order Module/responsiveorderfirstpage.dart';
import 'Product/product list.dart';
import 'Product/responsiveproductlist.dart';
import 'admin/admin.dart';
import 'admin/create users.dart';
import 'customer login/home/home.dart';
import 'customer login/order/create order responsive.dart';
import 'customer login/order/order list.dart';
import 'customer login/order/order view screen.dart';
import 'customer login/order/responsiveorder list.dart';
import 'customer module/customer list.dart';
import 'customer module/responsivecustomerlist.dart';
import 'dashboard/responsivedashboard.dart';

void main() async {
  // configureApp();
// PathUrlStrategy();
  //useHashUrlStrategy();
  // WidgetsFlutterBinding.ensureInitialized();
  // final productProvider = ProductProvider();
  // await productProvider.init();
  // final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuProvider(),
      child: MyApp(),
    ),

    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => ExtraDataProvider()),
    //     ChangeNotifierProvider(create: (_) => DataProvider()),
    //     ChangeNotifierProvider(create: (_) => ProductProvider()),
    //     ChangeNotifierProvider(create: (_) => ProductdetailProvider()),
    //     ChangeNotifierProvider(create: (_) => OrderProvider(prefs)),
    //     ChangeNotifierProvider(create: (_) => NavigationProvider()),
    //   ],
    // child:
    // MyApp(),
    //),
  );
}

abstract class PageName {
  static const homeRoute = '/';
  static const dashboardRoute = '/Home';
  static const subpage1 = 'subpage1'; // Relative path, no leading slash
  static const subpage2 = 'subpage2'; // Relative path, no leading slash
  static const subsubPage1 = 'subsubPage1';
  static const main = '/main';

//  static const dashboardRoute1 = '/dashboard1';
  static const subpage1Main = 'subpage1Main'; // Relative path, no leading slash
  static const subpage2Main = 'subpage2Main';
  static const subpage22main = 'subpage22main';
  static const subsubpage2Main =
      'subsubpage2Main'; // Relative path, no leading slash
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    // useHash: false,
    // routerNeglect: true,
    //  useHash: false,f

    // urlPathStrategy: UrlPathStrategy.path,
    initialLocation: window.sessionStorage.containsKey('token') ? '/Home' : '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          final cameFromRoute = state.extra != null
              ? (state.extra as Map<String, dynamic>)['cameFromRoute'] ?? false
              : false;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LoginScr(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/User_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Create_User',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Createusr(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Create_Account',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreateLogin(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Edit_User',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: userEdit(
              EditUser: extra['EditUser'] ?? {},
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Cus_Home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: MainScreen(), //dashboard1
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Cus_Create_Order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsivecreateOrdersPage(),//CreateOrder
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Customer_Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveOrdersPage(),//cusorderpage
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Customer_Order_View',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return CustomTransitionPage(
              child: CusOrderPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 5),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child:
            ResponsiveeditOrdersPage(
              orderId: extra['orderId'] ?? '',
            ),
            // OrderView(
            //   orderId: extra!['orderId'] ?? '',
            // ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Product_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveEmpproductPage(),//ProductPage(product: null,)
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Customer',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveEmpcustomerPage(),//CusList
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Open_Order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: OpenorderList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Picked_order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: OpenpickList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Pay_Complete',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PayCompleteList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Order_Complete',
        pageBuilder: (context, state) {
          final cameFromRoute = state.extra != null
              ? (state.extra as Map<String, dynamic>)['cameFromRoute'] ?? false
              : false;
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveEmpdashboard(),//DashboardPage
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveEmpOrdersPage(),//Orderspage
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Order_View',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResponsiveeditviewOrdersPage(
              orderId: extraData['orderId'] ?? '',
            ),

            // OrderView2(
            //   orderId: extraData['orderId'] ?? '',
            // ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Added_to_cart',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final selectedProducts =
              extraData['selectedProducts'] as List<Product>? ?? [];
          final data = extraData['data'] as Map<String, dynamic>? ?? {};

          return CustomTransitionPage(
            key: state.pageKey,
            child: FifthPage(
              selectedProducts: selectedProducts,
              data: data,
              select: '',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration:
            Duration(milliseconds: 5), // Adjust the duration as needed
          );
        },
      ),
      GoRoute(
        path: '/Documents',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // Map<String, dynamic>? selectedProductsMap;
          // final extra = state.extra as Map<String, dynamic>;

          if (extra == null) {
            return CustomTransitionPage(
              child: Orderspage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 5),
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: EighthPage(
              // string: extra!['string'] ?? '',
              selectedProductMap: extra!['selectedProudctMap'] ?? {},
              deliveryStatus: extra['deliveryStatus'] ?? '',
              paymentStatus: extra['paymentStatus'] ?? {},
              InvNo: extra['InvNo'] ?? '',
              Location: extra['Location'] ?? '',
              Date: extra['Date'] ?? '',
              Total: extra['Total'] ?? '',
              contactNo: extra['contactNo'] ?? '',
              orderId: extra['orderId'] ?? '',
              orderDetails: List<OrderDetail>.from(extra!['orderDetails']),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Cart_Selected_Products',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final product = extra['product'] as Product;
          final products = (extra['products'] as List<dynamic>).cast<Product>();
          final data = extra['data'] as Map<String, dynamic>;
          final selectedProducts =
          (extra['selectedProducts'] as List<dynamic>).cast<Product>();
          final inputText = extra['inputText'] as String;
          final subText = extra['subText'] as String;
          final notselect = extra['notselect'] as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: NextPage(
              product: product,
              products: products,
              data: data,
              selectedProducts: selectedProducts,
              inputText: inputText,
              subText: subText,
              notselect: notselect,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Add_Products',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final product = extra['product'] as Product;
          final products = (extra['products'] as List<dynamic>).cast<Product>();
          final data = extra['data'] as Map<String, dynamic>;
          final selectedProducts =
          (extra['selectedProducts'] as List<dynamic>).cast<Product>();
          final inputText = extra['inputText'] as String;
          final subText = extra['subText'] as String;
          final notselect = extra['notselect'] as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: NextPage(
              product: product,
              products: products,
              data: data,
              selectedProducts: selectedProducts,
              inputText: inputText,
              subText: subText,
              notselect: notselect,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
          path: '/Edit',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return CustomTransitionPage(
              key: state.pageKey,
              child: SelectedProductPage(
                selectedProducts: extra['selectedProducts'],
                data: extra['data'],
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          }),
      GoRoute(
        path: '/View_Order',
        pageBuilder: (context, state) {
          if (state.extra == null) {
            return CustomTransitionPage(
              child: Orderspage(), // Navigate to OrdersPage on refresh
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration:
              Duration(milliseconds: 300), // Adjust transition duration
            );
          } else {
            final extra = state.extra as Map<String, dynamic>;
            Map<String, dynamic>? selectedProductsMap =
            extra['selectedProducts'] as Map<String, dynamic>?;
            return CustomTransitionPage(
              key: state.pageKey,
              child: SeventhPage(
                selectedProducts: selectedProductsMap ?? {},
                product: null,
                orderId: extra['orderId'] as String,
                orderDetails: List<OrderDetail>.from(extra['orderDetails']),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(
                  milliseconds: 5), // Adjust transition duration if needed
            );
          }
        },
      ),
      GoRoute(
        path: '/Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Orderspage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Cus_Details',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          if (data == null) {
            return CustomTransitionPage(
              child: CusList(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 5),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: CustomerDetails(
              orderId: data['orderId'],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Search_For_Products_',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderPage3(
              data: data ?? {},
              string: 'arrow_back',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Search_For_Products',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderPage3(
              data: data ?? {},
              string: '',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Edit_Order',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: SelectedProductPage(
              data: data ?? {}, // If data is null, use an empty map
              selectedProducts: const [],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Create_New_Order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrdersSecond(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Create_Cus',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreateCustomer(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Order_Placed',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          // Extracting the passed arguments
          return CustomTransitionPage(
            key: state.pageKey,
            child: SixthPage(
              InvNo: extra['InvNo'] ?? '',
              status: extra['status'] ?? '',
              paymentStatus: extra['paymentStatus'] ?? {},
              product: extra['product'] as detail?,
              item: extra['item'] as List<Map<String, dynamic>>?,
              body: extra['body'] as Map<String, dynamic>,
              itemsList: extra['itemsList'] as List<Map<String, dynamic>>,
              orderDetails: List<OrderDetail>.from(extra['orderDetails']),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration:
            Duration(milliseconds: 200), // Adjust duration as needed
          );
        },
      ),
      GoRoute(
        path: '/Selected_Products',
        pageBuilder: (context, state) {
          // Check if the 'extra' parameter is null
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: OrderPage3(
                data: {},
                string: '',
              ),
              // Navigate to the different page when refreshed
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(
                  milliseconds: 300), // Adjust transition duration if needed
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: NextPage(
              selectedProducts:
              extra['selectedProducts'] as List<Product>? ?? [],
              // Provide an empty list if null
              product: extra['product'] as Product? ??
                  Product(
                      prodId: '',
                      productName: '',
                      imageId: '',
                      subCategory: '',
                      selectedUOM: '',
                      selectedVariation: '',
                      totalamount: 0,
                      total: 0,
                      tax: '',
                      totalAmount: 0,
                      unit: '',
                      discount: '',
                      category: '',
                      price: 0,
                      qty: 0,
                      quantity: 0),
              // Provide a default Product if null
              data: extra['data'] as Map<String, dynamic>? ?? {},
              // Provide an empty map if null
              inputText: extra['inputText'] as String? ?? '',
              // Provide an empty string if null
              subText: extra['subText'] as String? ?? '',
              // Provide an empty string if null
              products: extra['products'] as List<Product>? ?? [],
              // Provide an empty list if null
              notselect: extra['notselect'] as String? ??
                  '', // Provide an empty string if null
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
    ],
    // useHash: true,
  );

  MyApp({super.key});

  @override
  //import 'dart:html' as html;

  Widget build(BuildContext context) {
    // Disable browser navigation gestures in web

    return MaterialApp.router(
      routerConfig: _router,
      // routerDelegate: _router.routerDelegate,
      //routeInformationParser: _router.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child; // No animations, no swipe gestures
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text('An error occurred.'),
      ),
    );
  }
}

//
// class ExtraDataProvider with ChangeNotifier {
//   Map<String, dynamic> _extraData = {'data': {}, 'inputText': '', 'ubText': ''}; // Initialize with default values
//
//   Map<String, dynamic> get extraData => _extraData;
//
//   void setExtraData(Map<String, dynamic> data) {
//     _extraData = data;
//     notifyListeners();
//   }
//
//   @override
//   String toString() {
//     return 'ExtraDataProvider: $_extraData';
//   }
// }
//
// class DataProvider extends ChangeNotifier {
//   List<Product> _selectedProducts = [];
//   Map<String, dynamic> _data = {};
//
//   List<Product> get selectedProducts => _selectedProducts;
//   Map<String, dynamic> get data => _data;
//
//   void setSelectedProducts(List<Product> products) {
//     _selectedProducts = products;
//     notifyListeners();
//   }
//
//   void setData(Map<String, dynamic> newData) {
//     _data = newData;
//     notifyListeners();
//   }
// }
//
// class ProductProvider with ChangeNotifier {
//   bool _initialized = false;
//   List<Product> _selectedProducts = [];
//   Map<String, dynamic> _data = {};
//   String _deliveryLocation = '';
//   String _contactName = '';
//   String _address = '';
//   String _contactNumber = '';
//   String _comments = '';
//   String _date = '';
//   String _totalAmount = '';
//
//   List<Product> get selectedProducts => _selectedProducts;
//   Map<String, dynamic> get data => _data;
//
//
//
//   String get deliveryLocation => _deliveryLocation;
//   set deliveryLocation(String value) {
//     _deliveryLocation = value;
//     notifyListeners();
//   }
//
//
//   String get contactName => _contactName;
//   set contactName(String value) {
//     _contactName = value;
//     notifyListeners();
//   }
//
//
//   String get totalAmount => _totalAmount;
//   set totalAmount(String value) {
//     _totalAmount = value;
//     notifyListeners();
//   }
//
//
//   String get address => _address;
//   set address(String value) {
//     _address = value;
//     notifyListeners();
//   }
//
//
//
//   String get contactNumber => _contactNumber;
//   set contactNumber(String value) {
//     _contactNumber = value;
//     notifyListeners();
//   }
//
//
//   String get comments => _comments;
//   set comments(String value) {
//     _comments = value;
//     notifyListeners();
//   }
//
//
//   String get date => _date;
//   set date(String value) {
//     _date = value;
//     notifyListeners();
//   }
//
//   ProductProvider(){
//     init();
//   }
//
//   Future<void> init() async {
//     if (_initialized) return;
//     _initialized = true;
//
//     final prefs = await SharedPreferences.getInstance();
//     final selectedProductsJson = prefs.getString('selectedProducts');
//     final dataJson = prefs.getString('data');
//
//     if (selectedProductsJson != null) {
//       _selectedProducts = (jsonDecode(selectedProductsJson) as List)
//           .map((e) => Product.fromJson(e))
//           .toList();
//       print('Selected products loaded: $_selectedProducts');
//     }
//
//     if (dataJson != null) {
//       _data = jsonDecode(dataJson);
//       print('Data loaded: $_data');
//     }
//
//     notifyListeners();
//   }
//
//   void updateSelectedProducts(List<Product> products) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedProducts', jsonEncode(products.map((e) => e.toJson()).toList()));
//     _selectedProducts = products;
//     notifyListeners();
//   }
//
//   void updateData(Map<String, dynamic> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('data', jsonEncode(data));
//     _data = data;
//     notifyListeners();
//   }
//
//
// }
//
//
// class ProductdetailProvider with ChangeNotifier {
//   Product? _product;
//
//   Product? get product => _product;
//
//   void setProduct(Product product) {
//     _product = product;
//     notifyListeners();
//   }
// }
//
// class OrderProvider with ChangeNotifier {
//   final SharedPreferences _prefs;
//
//   detail? _product;
//   List<Map<String, dynamic>>? _item;
//   Map<String, dynamic>? _body;
//   List<Map<String, dynamic>>? _itemsList;
//
//   OrderProvider(this._prefs) {
//     init(); // Initialize data on provider creation
//   }
//
//   detail? get product => _product;
//
//   List<Map<String, dynamic>>? get item => _item;
//
//   Map<String, dynamic>? get body => _body;
//
//   List<Map<String, dynamic>>? get itemsList => _itemsList;
//
//   Future<void> init() async {
//     try {
//       // Print the loaded data
//       print('Loaded Data:');
//       print('Product: $_product');
//       print('Item: $_item');
//       print('Body: $_body');
//       print('Items List: $_itemsList');
//
//       // Save data to SharedPreferences
//
//       //convert jsonencode first
//
//       print('Product save: $_product');
//       print('Item: $_item');
//       print('Body: $_body');
//       print('Items List: $itemsList');
//
//       String productJson = _product?.toJson() ?? '';
//       String itemJson = jsonEncode(_item);
//       String bodyJson = jsonEncode(_body);
//       String itemsListJson = jsonEncode(_itemsList);
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('product', productJson);
//       await prefs.setString('item', itemJson);
//       await prefs.setString('body', bodyJson);
//       await prefs.setString('itemsList', itemsListJson);
//
//
//
//
//
//       notifyListeners();
//
//       await printSavedDetails;
//     } catch (e) {
//       print('Error loaading data: $e');
//     }
//   }
//
//
//   Future<void> printSavedDetails() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // Retrieve data from SharedPreferences
//       String? productJson = prefs.getString('product');
//       String? itemJson = prefs.getString('item');
//       String? bodyJson = prefs.getString('body');
//       String? itemsListJson = prefs.getString('itemsList');
//
//       if (productJson != null) {
//         detail product = detail.fromString(productJson);
//         print('Products: $product');
//       } else {
//         print('Products: null');
//       }
//
//       if (itemJson != null) {
//         var item = jsonDecode(itemJson);
//         print('Item: $item');
//       } else {
//         print('Item: null');
//       }
//
//       if (bodyJson != null) {
//         var body = jsonDecode(bodyJson);
//         print('Body: $body');
//       } else {
//         print('Body: null');
//       }
//
//       if (itemsListJson != null) {
//         List<dynamic> itemsList = jsonDecode(itemsListJson);
//         print('Items List: $itemsList');
//       } else {
//         print('Items List: null');
//       }
//     } catch (e) {
//       print('Error retrieving data: $e');
//     }
//   }
// // after it shows null
//   Future<void> loadData() async {
//     final productJson = _prefs.getString('product');
//     final itemJson = _prefs.getString('item');
//     final bodyJson = _prefs.getString('body');
//     final itemsListJson = _prefs.getString('itemsList');
//
//     if (productJson != null) {
//       _product = detail.fromJson(jsonDecode(productJson));
//     }
//     if (itemJson != null) {
//       _item = List<Map<String, dynamic>>.from(jsonDecode(itemJson));
//     }
//     if (bodyJson != null) {
//       _body = Map<String, dynamic>.from(jsonDecode(bodyJson));
//     }
//     if (itemsListJson != null) {
//       _itemsList = List<Map<String, dynamic>>.from(jsonDecode(itemsListJson));
//     }
//
//     notifyListeners(); // Don't forget to notify the listeners
//   }
//
//   void setItem(savedItem) {}
//
//
// }
//
// class NavigationProvider with ChangeNotifier {
//   detail? _details;
//   List<Map<String, dynamic>>? _items;
//   Map<String, dynamic>? _body;
//   List<Map<String, dynamic>>? _itemsList;
//
//   detail? get details => _details;
//   List<Map<String, dynamic>>? get items => _items;
//   Map<String, dynamic>? get body => _body;
//   List<Map<String, dynamic>>? get itemsList => _itemsList;
//
//   void setDetails({
//     required detail? detail,
//     required List<Map<String, dynamic>>? item,
//     required Map<String, dynamic>? body,
//     required List<Map<String, dynamic>>? itemsList,
//   }) {
//     _details = detail;
//     _items = items;
//     _body = body;
//     _itemsList = itemsList;
//     notifyListeners();
//     saveData();
//   }
//
//
//   void saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final details = {
//       'product': _details,
//       'item': _items,
//       'body': _body,
//       'itemsList': _itemsList,
//     };
//     prefs.setString('details', jsonEncode(details));
//   }
//
//   void loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getString('details');
//     if (data != null) {
//       final details = jsonDecode(data);
//       _details = details['product'];
//       _items = details['item'];
//       _body = details['body'];
//       _itemsList = List<Map<String, dynamic>>.from(details['itemsList']);
//       notifyListeners();
//     }
//   }
//
//
//   void setProduct(detail product) {
//     _details = product;
//     notifyListeners();
//   }
//
//   void setItem(dynamic item) {
//     _items = item;
//     notifyListeners();
//   }
//
//   void setBody(dynamic body) {
//     _body = body;
//     notifyListeners();
//   }
//
//   void setItemsList(List<dynamic> itemsList) {
//     _itemsList = itemsList.cast<Map<String, dynamic>>();
//     notifyListeners();
//   }
//
//
//
//   Future<void> savedetails() async {
//     try {
//       // Load data from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       String? savedProductJson = prefs.getString('product');
//       String? savedItemJson = prefs.getString('item');
//       String? savedBodyJson = prefs.getString('body');
//       String? savedItemsListJson = prefs.getString('itemsList');
//
//       if (savedProductJson != null) {
//         _details = detail.fromString(savedProductJson);
//       }
//       if (savedItemJson != null) {
//         _items = jsonDecode(savedItemJson);
//       }
//       if (savedBodyJson != null) {
//         _body = jsonDecode(savedBodyJson);
//       }
//       if (savedItemsListJson != null) {
//         _itemsList = jsonDecode(savedItemsListJson);
//       }
//
//       // Print the loaded data
//       print('Loaded Data from the fifth page:');
//       print('Product: $_details');
//       print('Item: $_items');
//       print('Body: $_body');
//       print('Items List: $_itemsList');
//
//       // ... rest of your code ...
//
//     } catch (e) {
//       print('Error loading data: $e');
//     }
//   }
//
//
//
//
//
//   void updateNavigationData(detail? details, List<Map<String, dynamic>>? items, Map<String, dynamic>? body, List<Map<String, dynamic>>? itemsList,) {
//     _details = details;
//     _items = items;
//     _body = body;
//     _itemsList = itemsList;
//     notifyListeners();
//   }
// }

class UserRoleProvider with ChangeNotifier {
  String _role = '';

  String get role => _role;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }
}
// responsive workon main file carefully handle 2