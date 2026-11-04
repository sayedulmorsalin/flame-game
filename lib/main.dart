import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/game_state.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/top_hud.dart';
import 'ui/widgets/offline_earnings_dialog.dart';
import 'ui/widgets/airdrop_modal.dart';
import 'ui/screens/arcade_screen.dart';
import 'ui/screens/miners_screen.dart';
import 'ui/screens/vault_screen.dart';
import 'ui/screens/tasks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BTMinerApp());
}

class BTMinerApp extends StatelessWidget {
  const BTMinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Miner - Gold Diggers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GameMainScreen(),
    );
  }
}

class GameMainScreen extends StatefulWidget {
  const GameMainScreen({super.key});

  @override
  State<GameMainScreen> createState() => _GameMainScreenState();
}

class _GameMainScreenState extends State<GameMainScreen> with WidgetsBindingObserver {
  late final GameState gameState;
  int currentTabIndex = 0; // Starts at Games Arcade screen
  Timer? gameTickTimer;
  Timer? airdropTimer;
  Timer? autoSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    gameState = GameState();

    _initSaveAndOffline();

    // Background idle tick (power drain, auto-tapper, boost & frenzy countdowns)
    gameTickTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      gameState.idleTick(0.2);
    });

    // Occasional surprise airdrop crates
    airdropTimer = Timer.periodic(const Duration(seconds: 50), (_) {
      if (!mounted) return;
      if (Random().nextBool()) {
        final reward = gameState.claimAirdropCrate();
        AudioService.instance.playAirdrop();
        _showAirdropDialog(reward);
      }
    });

    // Auto-save game state every 10 seconds
    autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      StorageService.saveGame(gameState);
    });
  }

  Future<void> _initSaveAndOffline() async {
    final lastTime = await StorageService.loadGame(gameState);
    if (lastTime != null) {
      final offlineSatoshis = gameState.calculateOfflineEarnings(lastTime);
      if (offlineSatoshis > 5.0) {
        final timeAway = DateTime.now().difference(lastTime);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (ctx) => OfflineEarningsDialog(
              satoshisEarned: offlineSatoshis,
              timeAway: timeAway,
              onClaimNormal: () {
                Navigator.pop(ctx);
                gameState.claimOfflineEarnings(offlineSatoshis, doubled: false);
                AudioService.instance.playCoinPickup();
              },
              onClaimDoubled: () {
                Navigator.pop(ctx);
                gameState.claimOfflineEarnings(offlineSatoshis, doubled: true);
                AudioService.instance.playFrenzyStart();
              },
            ),
          );
        });
      }
    }
  }

  void _showAirdropDialog(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AirdropModal(
          airdropData: data,
          onDismiss: () => Navigator.pop(ctx),
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      StorageService.saveGame(gameState);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameTickTimer?.cancel();
    airdropTimer?.cancel();
    autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF141A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x60000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.goldGradient,
                ),
                child: const Center(
                  child: Text('⚡', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.chakraPetch(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'BITCOIN ',
                      style: TextStyle(
                        color: AppTheme.bitcoinGold,
                        shadows: [
                          Shadow(
                            color: AppTheme.bitcoinGold.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: 'MINER',
                      style: TextStyle(
                        color: AppTheme.cyanNeon,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Tasks & Bounties Shortcut with Arcade Badge
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              final hasClaimable = gameState.dailyQuests.any((q) => q.isCompleted && !q.isClaimed);
              return IconButton(
                tooltip: 'Tasks & Bounties',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.task_alt, color: AppTheme.cyanNeon, size: 24),
                    if (hasClaimable)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.richRuby,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.richRuby.withValues(alpha: 0.8),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  setState(() => currentTabIndex = 2);
                },
              );
            },
          ),
          // Sound Mute Toggle with Arcade Glow
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              return IconButton(
                tooltip: 'Sound FX',
                icon: Icon(
                  gameState.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: gameState.soundEnabled ? AppTheme.bitcoinGold : AppTheme.textMuted,
                  size: 24,
                ),
                onPressed: () {
                  gameState.toggleSound();
                  AudioService.instance.soundEnabled = gameState.soundEnabled;
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Real-time Top Arcade HUD
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) => TopHud(
              gameState: gameState,
              onBoostPressed: () {
                gameState.applyBoost(multiplier: 2.0, durationSeconds: 60.0);
                AudioService.instance.playFrenzyStart();
              },
            ),
          ),
          // Preserved Tab Views via IndexedStack: Games is primary screen
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: [
                ArcadeScreen(gameState: gameState),
                MinersScreen(gameState: gameState),
                TasksScreen(gameState: gameState),
                VaultScreen(gameState: gameState),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceBorder, width: 2.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x90000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTabIndex,
          onTap: (index) {
            setState(() => currentTabIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_outlined),
              activeIcon: Icon(Icons.sports_esports, color: AppTheme.cyanNeon),
              label: 'Games',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.engineering_outlined),
              activeIcon: Icon(Icons.engineering, color: AppTheme.purpleQuantum),
              label: 'Miners',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined),
              activeIcon: Icon(Icons.task_alt, color: AppTheme.greenHash),
              label: 'Task',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_outline),
              activeIcon: Icon(Icons.lock, color: AppTheme.bitcoinGold),
              label: 'Vault',
            ),
          ],
        ),
      ),
    );
  }
}
