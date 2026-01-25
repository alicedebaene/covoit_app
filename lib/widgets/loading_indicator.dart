import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cercle principal
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary, // vert Ovalink
              ),
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.25), // jaune clair
            ),
          ),

          const SizedBox(height: 16),

          // Message optionnel
          if (message != null)
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground.withOpacity(0.75),
              ),
            ),
        ],
      ),
    );
  }
}
