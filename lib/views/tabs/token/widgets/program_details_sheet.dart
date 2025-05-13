import 'package:flutter/material.dart';
import 'package:unicorn_app_frontend/models/program_model.dart';
import 'package:unicorn_app_frontend/models/token_balance_model.dart';

class ProgramDetailsSheet extends StatelessWidget {
  final Program program;
  final TokenBalance? balance;
  final String Function(String) getTokenImagePath;

  const ProgramDetailsSheet({
    super.key,
    required this.program,
    required this.balance,
    required this.getTokenImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwned = balance?.tokenAmount != null && balance!.tokenAmount > 0;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: isOwned
                    ? Image.asset(
                        getTokenImagePath(program.id),
                        height: 120,
                        width: 120,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: program.frameColor != null 
                                  ? Color(int.parse(program.frameColor!.replaceAll('#', '0xFF')))
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
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
                      )
                    : ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(
                          getTokenImagePath(program.id),
                          height: 120,
                          width: 120,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: program.frameColor != null 
                                    ? Color(int.parse(program.frameColor!.replaceAll('#', '0xFF')))
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
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
                const SizedBox(height: 20),
                Text(
                  program.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isOwned ? null : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (!isOwned) ...[
                  Center(
                    child: Text(
                      'Not Owned',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (program.briefDescription.isNotEmpty) ...[
                  Text(
                    program.briefDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isOwned ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Company: ${program.companyName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isOwned ? null : Colors.grey,
                  ),
                ),
                Text(
                  'Status: ${program.status}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isOwned ? (program.active && program.status == 'ACTIVE' ? Colors.green : Colors.grey) : Colors.grey,
                  ),
                ),
                if (isOwned && balance?.person != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Recipient Information:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${balance?.person?.firstName ?? ''} ${balance?.person?.lastName ?? ''}'),
                  Text('Country: ${balance?.person?.addressCountryCode ?? ''}'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 