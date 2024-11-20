import 'dart:html';
import 'package:btb/Return%20Module/return%20first%20page.dart';
import 'package:btb/Product%20Module/Edit.dart';
import 'package:btb/Product Module/Product Screen.dart';
import 'package:btb/admin/admin%20edit.dart';
import 'package:btb/admin/admin%20list.dart';
import 'package:btb/admin/create%20login.dart';
import 'package:btb/customer%20login/credit/credit%20list.dart';
import 'package:btb/customer%20login/delivery/delivery.dart';
import 'package:btb/customer%20login/invoice/invoice%20list.dart';
import 'package:btb/customer%20login/order/create%20order%20button.dart';
import 'package:btb/customer%20login/order/drast%20to%20go.dart';
import 'package:btb/customer%20login/order/edit%20draft%20order.dart';
import 'package:btb/customer%20login/order/fourthpage%20order%20cus.dart';
import 'package:btb/customer%20login/order/order%20list.dart';
import 'package:btb/customer%20login/order/view%20screen.dart';
import 'package:btb/customer%20login/payment/pay%20cus.dart';
import 'package:btb/customer%20login/return/return%20list.dart';
import 'package:btb/delivery%20module/delivery%20list.dart';
import 'package:btb/payment%20module/pay%20screen.dart';
import 'package:btb/payment%20module/payment.dart';
import 'package:btb/report/report%20bill.dart';
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
import 'package:btb/widgets/productclass.dart';
import 'package:btb/Product%20Module/thirdpage%201.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'Invoice Module/invoice list.dart';
import 'Product Module/Create Product.dart';
import 'Return Module/return image.dart';
import 'Return Module/return module design.dart';
import 'Return Module/return ontap.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'admin/create users.dart';
import 'customer login/cus_dashboard/dash_cus.dart';
import 'customer login/order/add to cart.dart';
import 'customer login/order/draft list.dart';
import 'customer login/order/editable view screen.dart';
import 'customer login/order/search for products.dart';
import 'customer login/payment/payment.dart';
import 'customer login/return/create return.dart';
import 'customer login/return/return image.dart';
import 'customer module/customer list.dart';
import 'delivery module/delivery detail.dart';
import 'delivery module/detail confirm screen.dart';

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
      create: (context) => UserRoleProvider(),
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
            child: userEdit(EditUser: extra['EditUser'] ?? {},),
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
            child: CusOrderPage(),
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
        path: '/Customer_Draft_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusDraftPage(),
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
            child: CusList(),
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
        path: '/Payment_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: PaymentList(),
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
        path: '/Pay',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final productMap = extra['productMap'] as Map<String, dynamic>? ?? {};

          if (extra == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: PaymentList(),
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

          return CustomTransitionPage(
            key: state.pageKey,
            child: Payment(
              productMap: productMap,
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
        path: '/PayCus',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final productMap = extra['productMap'] as Map<String, dynamic>? ?? {};

          if (extra == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: CusPaymentList(),
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

          return CustomTransitionPage(
            key: state.pageKey,
            child: CusPayment(
              productMap: productMap,
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
      // GoRoute(
      //   path: '/Pay',
      //   pageBuilder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>? ?? {};
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: Payment(
      //         productMap: extra['productMap'] ?? {},
      //       ),
      //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(
      //           opacity: animation,
      //           child: child,
      //         );
      //       },
      //       transitionDuration: Duration(milliseconds: 5), // Adjust transition duration if needed
      //     );
      //   },
      // ),
      GoRoute(
        path: '/Report_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Reportspage(),
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
        path: '/Delivery_View',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            // key: state.pageKey,
            child: DeliveryConfirm(
              //deliverymasterId: extra['deliverymasterId'],
              deliveryId: extra['deliveryId'] ?? '',
              invoice: extra['invoice'] ?? '',
              deliverystatus: extra['deliveryStatus'] ?? '',
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
        path: '/Delivery_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: DeliveryList(),
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
        path: '/Customer_Invoice_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusInvoiceList(),
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
        path: '/Customer_Payment_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusPaymentList(),
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
        path: '/Create_return_request',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ReqReturn(
              storeImages: const [],
              storeImage: '',
              imageSizeStrings: const [],
              imageSizeString: [],
              orderDetailsMap: const {},
              orderDetails: const [],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 5),
            // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Cus_Add_Image',
        pageBuilder: (context, state) {
          // Safely retrieve and provide default empty values if null
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final orderDetails = extra['orderDetails'] as List<dynamic>? ?? [];
          final storeImages = extra['storeImages'] as List<String>? ?? [];
          final imageSizeString =
              extra['imageSizeString'] as List<String>? ?? [];
          final imageSizeStrings =
              extra['imageSizeStrings'] as List<String>? ?? [];
          final orderDetailsMap =
              extra['orderDetailsMap'] as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusRturnImage(
              imageSizeString: imageSizeString,
              orderDetails: orderDetails,
              storeImages: storeImages,
              imageSizeStrings: imageSizeStrings,
              orderDetailsMap: orderDetailsMap,
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
        path: '/Request_return_back',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ReqReturn(
              storeImage: extra['storeImage'] as String,
              imageSizeString: extra['imageSizeString'] as List<String>,
              imageSizeStrings: extra['imageSizeStrings'] as List<String>,
              storeImages: extra['storeImages'] as List<String>,
              orderDetails: extra['orderDetails'] as List<dynamic>,
              orderDetailsMap: extra['orderDetailsMap'] as Map<String, dynamic>,
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
        path: '/Customer_Return_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusReturnpage(),
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
        path: '/Customer_Delivery_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusDeliveryList(),
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
        path: '/Customer_Credit_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusCreditPage(),
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
        path: '/Invoice',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvoiceList(),
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
        path: '/Create_Delivery',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: DeliveryDetail(),
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
        path: '/Open_Invoice',
        pageBuilder: (context, state) {
          final cameFromRoute = state.extra != null
              ? (state.extra as Map<String, dynamic>)['cameFromRoute'] ?? false
              : false;
          return CustomTransitionPage(
            key: state.pageKey,
            child: OpenInvoice(),
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
            child: DashboardPage(),
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
            child: DashboardPage1(),
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
        path: '/return-view',
        pageBuilder: (context, state) {
          final returnMaster = state.extra as ReturnMaster?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ReturnView(returnMaster: returnMaster),
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
        path: '/Add_Image',
        pageBuilder: (context, state) {
          // Safely retrieve and provide default empty values if null
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final orderDetails = extra['orderDetails'] as List<dynamic>? ?? [];
          final storeImages = extra['storeImages'] as List<String>? ?? [];
          final imageSizeString =
              extra['imageSizeString'] as List<String>? ?? [];
          final imageSizeStrings =
              extra['imageSizeStrings'] as List<String>? ?? [];
          final orderDetailsMap =
              extra['orderDetailsMap'] as Map<String, dynamic>? ?? {};

          return CustomTransitionPage(
            key: state.pageKey,
            child: ReturnImage(
              imageSizeString: imageSizeString,
              orderDetails: orderDetails,
              storeImages: storeImages,
              imageSizeStrings: imageSizeStrings,
              orderDetailsMap: orderDetailsMap,
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
        path: '/Return_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Returnpage(),
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
            child: ProductPage(
              product: null,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(
                milliseconds: 1), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Return_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Returnpage(),
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
        path: '/Return',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Returnpage(),
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
        path: '/Draft_Placed_List',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          // Check if extra is null and navigate to OrdersPage if so
          if (extra == null) {
            return CustomTransitionPage(
              child: CusOrderPage(), // Navigate to OrdersPage on refresh
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
          }
          // If extra is not null, load the SixthPage
          return CustomTransitionPage(
            child: CusViewScreen(
              InvNo: extra['InvNo'] ?? '',
              arrow: extra['arrow'] ?? '',
              status: extra['status'] ?? '',
              paymentStatus: extra['paymentStatus'] ?? {},
              product: extra['product'] as detail?,
              item: List<Map<String, dynamic>>.from(extra['item']),
              body: Map<String, dynamic>.from(extra['body']),
              itemsList: List<Map<String, dynamic>>.from(extra['itemsList']),
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
                Duration(milliseconds: 300), // Adjust transition duration
          );
        },
      ),
      GoRoute(
        path: '/Draft_Placed_List1',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          // Check if extra is null and navigate to OrdersPage if so
          if (extra == null) {
            return CustomTransitionPage(
              child: CusDraftPage(), // Navigate to OrdersPage on refresh
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
          }
          // If extra is not null, load the SixthPage
          return CustomTransitionPage(
            child: CusDraftScreen(
              InvNo: extra['InvNo'] ?? '',
              arrow: extra['arrow'] ?? '',
              status: extra['status'] ?? '',
              paymentStatus: extra['paymentStatus'] ?? {},
              product: extra['product'] as detail?,
              item: List<Map<String, dynamic>>.from(extra['item']),
              body: Map<String, dynamic>.from(extra['body']),
              itemsList: List<Map<String, dynamic>>.from(extra['itemsList']),
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
            Duration(milliseconds: 300), // Adjust transition duration
          );
        },
      ),
      GoRoute(
        path: '/Order_Placed_List',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          // Check if extra is null and navigate to OrdersPage if so
          if (extra == null) {
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
          }
          // If extra is not null, load the SixthPage
          return CustomTransitionPage(
            child: SixthPage(
              InvNo: extra['InvNo'] ?? '',
              arrow: extra['arrow'] ?? '',
              status: extra['status'] ?? '',
              paymentStatus: extra['paymentStatus'] ?? {},
              product: extra['product'] as detail?,
              item: List<Map<String, dynamic>>.from(extra['item']),
              body: Map<String, dynamic>.from(extra['body']),
              itemsList: List<Map<String, dynamic>>.from(extra['itemsList']),
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
                Duration(milliseconds: 300), // Adjust transition duration
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
        path: '/Add_to_cart',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final selectedProducts =
              extraData['selectedProducts'] as List<Product>? ?? [];
          final data = extraData['data'] as Map<String, dynamic>? ?? {};

          return CustomTransitionPage(
            key: state.pageKey,
            child: CusAddtoCart(
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
        path: '/Create_New_Product',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: SecondPage(),
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
      // GoRoute(
      //   path: '/Documents',
      //   pageBuilder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //    // Map<String, dynamic>? selectedProductsMap;
      //    // final extra = state.extra as Map<String, dynamic>;
      //
      //     return CustomTransitionPage(
      //         key: state.pageKey,
      //         child:
      //         EighthPage(
      //           paymentStatus: extra!['paymentStatus'] ?? {},
      //          // string: extra!['string'] ?? '',
      //         //  selectedProductMap: extra!['selectedProudctMap'] ?? {},
      //           deliveryStatus: extra['deliveryStatus'] ?? '',
      //           //status: extra['status'] ?? '',
      //           orderId: extra['orderId'] ?? '',
      //           orderDetails: List<OrderDetail>.from(extra['orderDetails']),),
      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(
      //         opacity: animation,
      //         child: child,
      //       );
      //     },
      //     transitionDuration: Duration(milliseconds: 5), // Adjust transition duration if needed
      //     );
      //   },
      // ),
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
        path: '/Add_Product_items',
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
            child: CusSelectedProducts(
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
          path: '/Draft_Edit',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return CustomTransitionPage(
              key: state.pageKey,
              child: EditDraftOrder(
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
        path: '/Edit_View_Screen',
        pageBuilder: (context, state) {
          // Safely check if state.extra is null and redirect to ProductPage
          final params = state.extra as Map<String, dynamic>?;

          // If params is null, navigate to ProductPage
          if (params == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: ProductPage(product: null),
              // Redirect to ProductPage on refresh
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

          // Create a mutable copy of the params map if params is not null
          final mutableParams = Map<String, dynamic>.from(params);

          final extraMap = state.extra as Map<String, dynamic>;
          final orderDetails = extraMap['orderDetails'] as List<OrderDetail>;

          // Load ProductForm1 with valid params
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductForm1(
              orderDetails: orderDetails,
              product: null,
              prodId: mutableParams['prodId'] ?? '',
              priceText: mutableParams['priceText'] ?? '',
              productText: mutableParams['productText'] ?? '',
              selectedvalue2: mutableParams['selectedvalue2'] ?? '',
              discountText: mutableParams['discountText'] ?? '',
              selectedValue: mutableParams['selectedValue'] ?? '',
              selectedValue1: mutableParams['selectedValue1'] ?? '',
              selectedValue3: mutableParams['selectedValue3'] ?? '',
              imagePath: mutableParams['imagePath'] ?? '',
              displayData: mutableParams['displayData'] ?? {},
            ),
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
        },
      ),
      GoRoute(
        path: '/Product_View',
        pageBuilder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>? ?? {};
          final product = extraMap['product'] as Product?;
          final orderDetails = extraMap['orderDetails'] as List<OrderDetail>?;
          final isRefreshed = state.extra == null;

          if (isRefreshed || product == null) {
            // Navigate to ProductPage if no product is passed or page is refreshed
            return CustomTransitionPage(
              key: state.pageKey,
              child: ProductPage(
                product: null,
              ),
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
          // If product is not null, load the original ProductForm1 page
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductForm1(
              displayData: const {},
              prodId: product.prodId,
              imagePath: null,
              productText: null,
              orderDetails: orderDetails ?? [],
              priceText: null,
              selectedValue: null,
              selectedValue1: null,
              selectedValue3: null,
              selectedvalue2: null,
              discountText: null,
              product: product, // Use the existing product object
            ),
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
        },
      ),
      // GoRoute(
      //   path: '/Product_View',
      //   pageBuilder: (context, state) {
      //     final extraMap = state.extra as Map<String, dynamic>? ?? {};
      //     final product = extraMap['product'] as Product?;
      //     //final product = state.extra as Product?;
      //     final orderDetails = extraMap['orderDetails'] as List<OrderDetail>;
      //
      //     // Check if the extra data (product) is null
      //     if (product == null) {
      //       // Navigate to ProductForm if no product is passed
      //       return CustomTransitionPage(
      //         key: state.pageKey,
      //         child: ProductPage(
      //           product: null,), // Navigate to the different page when refreshed
      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //           return FadeTransition(
      //             opacity: animation,
      //             child: child,
      //           );
      //         },
      //         transitionDuration: Duration(milliseconds: 300), // Adjust transition duration if needed
      //       );
      //     }
      //     // If product is not null, load the original ProductForm1 page
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: ProductForm1(
      //         displayData: const {},
      //         prodId: product.prodId,
      //         imagePath: null,
      //         productText: null,
      //         orderDetails: orderDetails,
      //         priceText: null,
      //         selectedValue: null,
      //         selectedValue1: null,
      //         selectedValue3: null,
      //         selectedvalue2: null,
      //         discountText: null,
      //         product: product, // Use the existing product object
      //       ),
      //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(
      //           opacity: animation,
      //           child: child,
      //         );
      //       },
      //       transitionDuration: Duration(milliseconds: 300), // Adjust transition duration if needed
      //     );
      //   },
      // ),
      GoRoute(
        path: '/View_Draft_Order',
        pageBuilder: (context, state) {
          if (state.extra == null) {
            return CustomTransitionPage(
              child: CusOrderPage(), // Navigate to OrdersPage on refresh
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
              child: CusEditViewScreen(
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
        path: '/Update_Product_View',
        pageBuilder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>;
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          final orderDetails = extraMap['orderDetails'] as List<OrderDetail>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductForm1(
              displayData: extra['displayData'],
              product: extra['product'],
              orderDetails: orderDetails,
              imagePath: extra['imagePath'],
              productText: extra['productText'],
              selectedValue: extra['selectedValue'],
              selectedValue1: extra['selectedValue1'],
              selectedValue3: extra['selectedValue3'],
              selectedvalue2: extra['selectedvalue2'],
              priceText: extra['priceText'],
              discountText: extra['discountText'],
              prodId: extra['prodId'],
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
        path: '/Search_Products',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusOrderPage3(
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
        name: 'editProductRoute',
        path: '/Edit_Product',
        pageBuilder: (context, state) {
          //  final extraMap = state.extra as Map<String, dynamic>;
          final params =
              state.extra as Map<String, dynamic>?; // Make it nullable
          //final orderDetails = extraMap['orderDetails'] as List<OrderDetail>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: params == null
                ? EditOrder(
                    prodId: '',
                    //  orderDetails: orderDetails,
                    textInput: '',
                    priceInput: '',
                    discountInput: '',
                    inputText: '',
                    subText: '',
                    unitText: '',
                    taxText: '',
                    imagePath: null,
                    imageId: '',
                    productData: {},
                  )
                : EditOrder(
                    prodId: params['prodId'] ?? '',
                    textInput: params['textInput'] ?? '',
                    priceInput: params['priceInput'] ?? '',
                    discountInput: params['discountInput'] ?? '',
                    inputText: params['inputText'] ?? '',
                    subText: params['subText'] ?? '',
                    unitText: params['unitText'] ?? '',
                    taxText: params['taxText'] ?? '',
                    imagePath: params['imagePath'] ?? '',
                    imageId: params['imageId'] ?? '',
                    productData: params['productData'] ?? {},
                  ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration:
                Duration(milliseconds: 5), // Adjust duration as needed
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
        path: '/Edit_Draft_Order',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditDraftOrder(
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
        path: '/Cus_Create_Order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusCreateOrderPage(),
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
        path: '/Draft_Placed',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          // Extracting the passed arguments
          return CustomTransitionPage(
            key: state.pageKey,
            child: CusViewScreen(
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
        path: '/Create_return_image',
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: CreateReturn(
                storeImage: '',
                imageSizeString: [],
                imageSizeStrings: [],
                storeImages: [],
                orderDetails: [],
                orderDetailsMap: {},
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
          } else {
            final extraMap = extra as Map<String, dynamic>;
            return CustomTransitionPage(
              key: state.pageKey,
              child: CreateReturn(
                storeImage: extraMap['storeImage'] as String,
                imageSizeString: extraMap['imageSizeString'] as List<String>,
                imageSizeStrings: extraMap['imageSizeStrings'] as List<String>,
                storeImages: extraMap['storeImages'] as List<String>,
                orderDetails: extraMap['orderDetails'] as List<dynamic>,
                orderDetailsMap:
                    extraMap['orderDetailsMap'] as Map<String, dynamic>,
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
        path: '/Create_return_back',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreateReturn(
              storeImage: extra['storeImage'] as String,
              imageSizeString: extra['imageSizeString'] as List<String>,
              imageSizeStrings: extra['imageSizeStrings'] as List<String>,
              storeImages: extra['storeImages'] as List<String>,
              orderDetails: extra['orderDetails'] as List<dynamic>,
              orderDetailsMap: extra['orderDetailsMap'] as Map<String, dynamic>,
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
        path: '/Create_return',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CreateReturn(
              storeImages: const [],
              storeImage: '',
              imageSizeStrings: const [],
              imageSizeString: [],
              orderDetailsMap: const {},
              orderDetails: const [],
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
      GoRoute(
        path: '/Selected_product_item',
        pageBuilder: (context, state) {
          // Check if the 'extra' parameter is null
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: CusOrderPage3(
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
            child: CusSelectedProducts(
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
