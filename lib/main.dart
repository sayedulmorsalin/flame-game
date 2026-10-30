import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/btminer_game.dart';
import 'models/game_state.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/top_hud.dart';
import 'ui/widgets/offline_earnings_dialog.dart';
import 'ui/widgets/airdrop_modal.dart';
import 'ui/screens/mine_screen.dart';
import 'ui/screens/arcade_screen.dart';
import 'ui/screens/rigs_screen.dart';
import 'ui/screens/miners_screen.dart';
import 'ui/screens/market_screen.dart';
import 'ui/screens/vault_screen.dart';
import 'ui/screens/quests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.darkTheme,
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
  late final BTMinerGame flameGame;
  late final Widget mineScreen;
  int currentTabIndex = 0;
  Timer? autoSaveTimer;
  Timer? marketTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    gameState = GameState();

    flameGame = BTMinerGame(
      gameState: gameState,
      onAirdropClaimed: (rewardData) {
        _showAirdropDialog(rewardData);
      },
    );

    // Cache MineScreen so FlameGame canvas surface is never re-created
    mineScreen = MineScreen(
      game: flameGame,
      gameState: gameState,
      onManualTap: () {
        gameState.manualTap();
        AudioService.instance.playTap();
      },
      onOpenArcade: () {
        setState(() => currentTabIndex = 1);
      },
    );

    _initSaveAndOffline();

    // Auto-save game state every 10 seconds
    autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      StorageService.saveGame(gameState);
    });

    // Market price tick every 8 seconds
    marketTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      gameState.tickMarket();
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
    autoSaveTimer?.cancel();
    marketTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡ ', style: TextStyle(fontSize: 18)),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                children: [
                  TextSpan(text: 'BITCOIN ', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'MINER', style: TextStyle(color: AppTheme.bitcoinGold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Quick Games Arcade Shortcut
          IconButton(
            tooltip: 'Arcade Mini-Games',
            icon: const Icon(Icons.sports_esports, color: AppTheme.orangeFrenzy),
            onPressed: () {
              setState(() => currentTabIndex = 1);
            },
          ),
          // Quests & Missions Shortcut
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              final hasClaimable = gameState.dailyQuests.any((q) => q.isCompleted && !q.isClaimed);
              return IconButton(
                tooltip: 'Missions & Streaks',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, color: AppTheme.cyanNeon),
                    if (hasClaimable)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.orangeFrenzy,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  setState(() => currentTabIndex = 6);
                },
              );
            },
          ),
          // Sound Mute Toggle
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              return IconButton(
                tooltip: 'Sound FX',
                icon: Icon(
                  gameState.soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: gameState.soundEnabled ? AppTheme.bitcoinGold : AppTheme.textMuted,
                ),
                onPressed: () {
                  gameState.toggleSound();
                  AudioService.instance.soundEnabled = gameState.soundEnabled;
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Real-time Top HUD (ListenableBuilder updates only the HUD without rebuilding the Flame canvas)
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
          // Preserved Tab Views via IndexedStack
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: [
                mineScreen,
                ArcadeScreen(gameState: gameState),
                RigsScreen(gameState: gameState),
                MinersScreen(gameState: gameState),
                MarketScreen(gameState: gameState),
                VaultScreen(gameState: gameState),
                QuestsScreen(gameState: gameState),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex > 5 ? 0 : currentTabIndex,
        onTap: (index) {
          setState(() => currentTabIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            activeIcon: Icon(Icons.videogame_asset, color: AppTheme.bitcoinGold),
            label: 'Mine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            activeIcon: Icon(Icons.sports_esports, color: AppTheme.orangeFrenzy),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            activeIcon: Icon(Icons.memory, color: AppTheme.cyanNeon),
            label: 'Rigs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.engineering),
            activeIcon: Icon(Icons.engineering, color: AppTheme.purpleQuantum),
            label: 'Miners',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            activeIcon: Icon(Icons.trending_up, color: AppTheme.greenHash),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            activeIcon: Icon(Icons.lock, color: AppTheme.cyanNeon),
            label: 'Vault',
          ),
        ],
      ),
    );
  }
}
