import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}




class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      // Redirect to login screen if not authenticated
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return SizedBox.shrink(); // Prevent rendering of the protected page
    }

    return child;
  }
}
