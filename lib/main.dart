import 'dart:html';
import 'package:btb/Order%20Module/order%20view.dart';
import 'package:btb/admin/admin%20edit.dart';
import 'package:btb/admin/admin%20list.dart';
import 'package:btb/admin/create%20login.dart';
import 'package:btb/customer%20login/order/create%20order.dart';
import 'package:btb/customer%20module/create%20customer.dart';
import 'package:btb/customer%20module/customer%20view.dart';
import 'package:btb/login/login.dart';
import 'package:btb/Order%20Module/firstpage.dart';
import 'package:btb/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Product/product list.dart';
import 'admin/Create_users.dart';
import 'admin/sign up.dart';
import 'customer login/home/home.dart';
import 'customer login/order/order list.dart';
import 'customer login/order/order view screen.dart';
import 'customer module/customer list.dart';

void main() async {
  runApp(MyApp(),);
}

abstract class PageName {
  static const homeRoute = '/';
  static const dashboardRoute = '/Home';
  static const subpage1 = 'subpage1';
  static const subpage2 = 'subpage2';
  static const subsubPage1 = 'subsubPage1';
  static const main = '/main';
  static const subpage1Main = 'subpage1Main';
  static const subpage2Main = 'subpage2Main';
  static const subpage22main = 'subpage22main';
  static const subsubpage2Main = 'subsubpage2Main';
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: window.sessionStorage.containsKey('token') ? '/Home' : '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
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
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/SignUp',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: comLog(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/User_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AdminList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5), // Adjust transition duration if needed
          );
        },
      ),
      GoRoute(
        path: '/Create_User',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const Createuser(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
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
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Edit_User',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: useredit(
              edituser: extra['EditUser' ?? ''] ?? {},
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Cus_Home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardPage1(), //dashboard1MainScreen
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Cus_Create_Order',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CreateOrder(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Customer_Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CusOrderPage(), //cusorderpage  ResponsiveOrdersPage
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Customer_Order_View',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return CustomTransitionPage(
              child: const CusOrderPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 5),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderView(
              orderId: extra['orderId'] ?? '',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Product_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ProductPage(
              product: null,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Customer',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CusList(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),

      GoRoute(
        path: '/Home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const Orderspage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Order_View',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderView2(
              orderId: extraData['orderId'] ?? '',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Order_List',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const Orderspage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),
      GoRoute(
        path: '/Cus_Details',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          if (data == null) {
            return CustomTransitionPage(
              child: const CusList(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 5),
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
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),

      GoRoute(
        path: '/Create_Cus',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CreateCustomer(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(
                milliseconds: 5),
          );
        },
      ),

    ],
    redirect: (context, state) {
      final bool isLoggedIn = window.sessionStorage.containsKey('token');
      final String currentPath = state.matchedLocation;

      final List<String> exemptedPaths = ['/SignUp', '/Create_Account'];

      if (!isLoggedIn && !exemptedPaths.contains(currentPath)) {
        return '/';
      }

      return null;
    },

  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
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
    return child;
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


