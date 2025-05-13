import 'package:flutter/material.dart';
import 'package:unicorn_app_frontend/models/program_model.dart';
import 'package:unicorn_app_frontend/models/token_balance_model.dart';

class TokenCard extends StatelessWidget {
  final Program program;
  final TokenBalance? balance;
  final String Function(String) getTokenImagePath;
  final VoidCallback onTap;

  const TokenCard({
    super.key,
    required this.program,
    required this.balance,
    required this.getTokenImagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: balance?.tokenAmount == 0
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.asset(
                        getTokenImagePath(program.id),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image for program ${program.id}: $error');
                          return Container(
                            decoration: BoxDecoration(
                              color: program.frameColor != null 
                                  ? Color(int.parse(program.frameColor!.replaceAll('#', '0xFF')))
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                program.shortName?.substring(0, 1).toUpperCase() ?? 
                                program.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      getTokenImagePath(program.id),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image for program ${program.id}: $error');
                        return Container(
                          decoration: BoxDecoration(
                            color: program.frameColor != null 
                                ? Color(int.parse(program.frameColor!.replaceAll('#', '0xFF')))
                                : Colors.grey[300],
                          ),
                          child: Center(
                            child: Text(
                              program.shortName?.substring(0, 1).toUpperCase() ?? 
                              program.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                program.shortName ?? program.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: balance?.tokenAmount == 0 ? Colors.grey : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 