import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/program.dart';
import '../../../models/token_balance.dart';
import '../../../providers/koos_api_provider.dart';
import '../../../providers/authentication_provider.dart';

class TokensView extends ConsumerStatefulWidget {
  const TokensView({super.key});

  @override
  ConsumerState<TokensView> createState() => _TokensViewState();
}

class _TokensViewState extends ConsumerState<TokensView> {
  List<Program> programs = [];
  Map<String, TokenBalance> tokenBalances = {};
  bool isLoading = true;
  String? error;

  String _getTokenImagePath(String programId) {
    // Map program IDs to image names
    final Map<String, String> imageMap = {
      dotenv.env['course_1'] ?? '': 'course_1.png',
      dotenv.env['course_2'] ?? '': 'course_2.png',
      dotenv.env['course_3'] ?? '': 'course_3.png',
      dotenv.env['course_4'] ?? '': 'course_4.png',
      dotenv.env['course_5'] ?? '': 'course_5.png',
      dotenv.env['course_6'] ?? '': 'course_6.png',
      dotenv.env['camp_1'] ?? '': 'camp_1.png',
      dotenv.env['camp_2'] ?? '': 'camp_2.png',
      dotenv.env['camp_3'] ?? '': 'camp_3.png',
      dotenv.env['camp_4'] ?? '': 'camp_4.png',
      dotenv.env['juhendaja'] ?? '': 'juhendaja.png',
      dotenv.env['pro_1'] ?? '': 'pro_1.png',
      dotenv.env['pro_2'] ?? '': 'pro_2.png',
    };

    final imageName = imageMap[programId] ?? 'default_token.png';
    print('Loading image for program $programId: assets/images/tokens/$imageName');
    return 'assets/images/tokens/$imageName';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ref.read(koosApiServiceProvider);
      final authState = ref.read(authenticationProvider);
      final userEmail = authState.userInfo?['email'];

      if (userEmail == null) {
        throw Exception('User email not found. Please log in again.');
      }

      // Get program IDs from environment variables
      final programIds = [
        dotenv.env['course_1'],
        dotenv.env['course_2'],
        dotenv.env['course_3'],
        dotenv.env['course_4'],
        dotenv.env['course_5'],
        dotenv.env['course_6'],
        dotenv.env['camp_1'],
        dotenv.env['camp_2'],
        dotenv.env['camp_3'],
        dotenv.env['camp_4'],
        dotenv.env['pro_1'],
        dotenv.env['pro_2'],
        dotenv.env['juhendaja'],
      ].where((id) => id != null).toList();

      for (final programId in programIds) {
        try {
          final program = await apiService.getProgram(programId!);
          
          // Try to get token balance, but don't fail if it doesn't exist
          TokenBalance balance;
          try {
            balance = await apiService.getTokenBalance(programId, userEmail);
          } catch (e) {
            print('No token balance found for program $programId: $e');
            // Create a default balance with 0 tokens
            balance = TokenBalance(
              type: 'UNKNOWN',
              tokenAmount: 0,
              participationStatus: 'NOT_PARTICIPATED',
            );
          }
          
          setState(() {
            programs.add(program);
            tokenBalances[programId] = balance;
          });
        } catch (e) {
          print('Error loading program $programId: $e');
        }
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showProgramDetails(BuildContext context, Program program, TokenBalance? balance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
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
                    child: Image.asset(
                      _getTokenImagePath(program.id),
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
                  const SizedBox(height: 20),
                  Text(
                    program.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (program.briefDescription.isNotEmpty) ...[
                    Text(
                      program.briefDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Company: ${program.companyName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Status: ${program.status}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: program.active && program.status == 'ACTIVE' 
                          ? Colors.green 
                          : Colors.grey,
                    ),
                  ),
                  if (balance?.person != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Recipient Information:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${balance!.person!.firstName} ${balance.person!.lastName}'),
                    Text('Country: ${balance.person!.addressCountryCode}'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (programs.isEmpty) {
      return const Center(
        child: Text('No programs available'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        final balance = tokenBalances[program.id];
        final isActive = program.active && program.status == 'ACTIVE';

        return GestureDetector(
          onTap: () => _showProgramDetails(context, program, balance),
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
                          colorFilter: ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Image.asset(
                            _getTokenImagePath(program.id),
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
                          _getTokenImagePath(program.id),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
