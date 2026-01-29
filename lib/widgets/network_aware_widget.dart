
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/providers/connectivity_provider.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget child;

  const NetworkAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       
        child,

    
        Consumer<ConnectivityProvider>(
          builder: (context, connectivity, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: connectivity.isOnline ? -60 : 0, 
              left: 0,
              right: 0,
              child: Material(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.only(bottom: 10),
                  color: Theme.of(context).colorScheme.error,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}