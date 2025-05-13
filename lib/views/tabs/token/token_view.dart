import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/program_model.dart';
import '../../../models/token_balance_model.dart';
import '../../../providers/koos_api_provider.dart';
import '../../../providers/authentication_provider.dart';
import 'widgets/program_details_sheet.dart';
import 'widgets/token_card.dart';

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
    if (!mounted) return;
    
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

      List<Program> loadedPrograms = [];
      Map<String, TokenBalance> loadedBalances = {};

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
          
          loadedPrograms.add(program);
          loadedBalances[programId] = balance;
        } catch (e) {
          print('Error loading program $programId: $e');
        }
      }

      // Sort programs so owned tokens appear first
      loadedPrograms.sort((a, b) {
        final balanceA = loadedBalances[a.id]?.tokenAmount ?? 0;
        final balanceB = loadedBalances[b.id]?.tokenAmount ?? 0;
        return balanceB.compareTo(balanceA); // Sort in descending order
      });
      
      if (!mounted) return;
      setState(() {
        programs = loadedPrograms;
        tokenBalances = loadedBalances;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    } finally {
      if (!mounted) return;
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
      builder: (context) => ProgramDetailsSheet(
        program: program,
        balance: balance,
        getTokenImagePath: _getTokenImagePath,
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

        return TokenCard(
          program: program,
          balance: balance,
          getTokenImagePath: _getTokenImagePath,
          onTap: () => _showProgramDetails(context, program, balance),
        );
      },
    );
  }
}
