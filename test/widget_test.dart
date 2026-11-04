import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:btminer/models/game_state.dart';
import 'package:btminer/main.dart';
import 'package:btminer/ui/screens/arcade_screen.dart';
import 'package:btminer/ui/screens/rigs_screen.dart';
import 'package:btminer/ui/screens/miners_screen.dart';
import 'package:btminer/ui/screens/market_screen.dart';
import 'package:btminer/ui/screens/vault_screen.dart';
import 'package:btminer/ui/screens/tasks_screen.dart';
import 'package:btminer/ui/games/lucky_wheel_game.dart';
import 'package:btminer/ui/games/precision_drill_game.dart';
import 'package:btminer/ui/games/hash_cracker_game.dart';
import 'package:btminer/ui/games/coin_catcher_game.dart';
import 'package:btminer/ui/games/mini_games_catalog.dart';
import 'package:btminer/ui/widgets/airdrop_modal.dart';
import 'package:btminer/ui/widgets/offline_earnings_dialog.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:btminer/game/components/shaft_component.dart';
import 'package:btminer/ui/theme/app_theme.dart';

void main() {
  test('GameState calculation and interactive mini-game test', () {
    final state = GameState();

    // Initial state: starts at 0 SAT and 0% rig power (no passive coin generation on open)
    expect(state.satoshis, equals(0.0));
    expect(state.rigPower, equals(0.0));
    expect(state.shafts.length, equals(5));
    expect(state.shafts[0].isUnlocked, isTrue);
    expect(state.shafts[0].level, equals(1));
    expect(state.totalHashrate, greaterThan(0.0));

    // When opened with 0% power, idle tick does NOT passively increase coins!
    state.idleTick(1.0);
    expect(state.satoshis, equals(0.0));

    // Manual tap earns satoshis and charges power
    final earned = state.manualTap();
    expect(earned, greaterThan(0.0));
    expect(state.satoshis, equals(earned));
    expect(state.totalTaps, equals(1));
    expect(state.rigPower, greaterThan(0.0));

    // Mini-game reward awards satoshis and charges battery
    state.awardMiniGameReward(satoshisEarned: 500.0, powerBonus: 50.0);
    expect(state.satoshis, greaterThanOrEqualTo(500.0));
    expect(state.rigPower, greaterThanOrEqualTo(50.0));
    expect(state.totalMiniGamesPlayed, equals(1));

    // With active power, idle tick now mines satoshis
    final beforeTick = state.satoshis;
    state.idleTick(1.0);
    expect(state.satoshis, greaterThan(beforeTick));

    // Market fluctuation
    state.tickMarket();
    expect(state.btcPrice, greaterThan(0.0));

    // Upgrade shaft
    state.satoshis = 100000.0;
    expect(state.upgradeShaft(0), isTrue);
    expect(state.upgradeShaftCooling(0), isTrue);
    expect(state.upgradeShaftOverclock(0), isTrue);

    // Miner hire
    expect(state.hireOrUpgradeMiner('miner_satoshi'), isTrue);

    // Market sell
    final usd = state.sellSatoshis(100.0);
    expect(usd, greaterThan(0.0));
  });

  testWidgets('App renders BTMinerApp and bottom navigation items', (WidgetTester tester) async {
    await tester.pumpWidget(const BTMinerApp());
    await tester.pump();

    // Verify bottom navigation items exist (Games, Miners, Task, Vault)
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Miners'), findsOneWidget);
    expect(find.text('Task'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);

    // Tap Miners tab
    await tester.tap(find.text('Miners'));
    await tester.pump();

    // Tap Task tab
    await tester.tap(find.text('Task'));
    await tester.pump();

    // Tap Vault tab
    await tester.tap(find.text('Vault'));
    await tester.pump();

    // Tap Games tab (primary)
    await tester.tap(find.text('Games'));
    await tester.pump();
  });

  testWidgets('All individual screens render without errors or overflows', (WidgetTester tester) async {
    final state = GameState();
    state.satoshis = 5000.0;
    state.chargeRigPower(50.0);

    // Test RigsScreen
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: RigsScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(RigsScreen), findsOneWidget);

    // Test MinersScreen (Leaderboard Rankings)
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: MinersScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(MinersScreen), findsOneWidget);
    expect(find.text('GLOBAL MINERS RANKING'), findsOneWidget);
    expect(find.textContaining('Satoshi'), findsWidgets);
    expect(find.textContaining('You'), findsWidgets);

    // Test ArcadeScreen
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: ArcadeScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(ArcadeScreen), findsOneWidget);

    // Test MarketScreen
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: MarketScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(MarketScreen), findsOneWidget);

    // Test VaultScreen
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: VaultScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(VaultScreen), findsOneWidget);

    // Test TasksScreen
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: TasksScreen(gameState: state)),
    ));
    await tester.pump();
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('Mini-games render without errors', (WidgetTester tester) async {
    final state = GameState();

    expect(MiniGamesCatalog.allGames.length, equals(30));

    // Test first 4 original games
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: LuckyWheelGame(gameState: state, onGameOver: () {}),
    ));
    await tester.pump();
    expect(find.byType(LuckyWheelGame), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: PrecisionDrillGame(gameState: state, onGameOver: () {}),
    ));
    await tester.pump();
    expect(find.byType(PrecisionDrillGame), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: HashCrackerGame(gameState: state, onGameOver: () {}),
    ));
    await tester.pump();
    expect(find.byType(HashCrackerGame), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: CoinCatcherGame(gameState: state, onGameOver: () {}),
    ));
    await tester.pump();
    expect(find.byType(CoinCatcherGame), findsOneWidget);

    // Test representative games from each new pack
    // Pack 1: Game 5 (Flappy Miner)
    final game5 = MiniGamesCatalog.allGames[4].builder(tester.element(find.byType(CoinCatcherGame)), state, () {});
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: game5));
    await tester.pump();

    // Pack 2: Game 11 (Mining Brick Breaker)
    final game11 = MiniGamesCatalog.allGames[10].builder(tester.element(find.byType(MaterialApp)), state, () {});
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: game11));
    await tester.pump();

    // Pack 3: Game 20 (Tic Tac Toe)
    final game20 = MiniGamesCatalog.allGames[19].builder(tester.element(find.byType(MaterialApp)), state, () {});
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: game20));
    await tester.pump();

    // Pack 4: Game 29 (Quantum Slots)
    final game29 = MiniGamesCatalog.allGames[28].builder(tester.element(find.byType(MaterialApp)), state, () {});
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: game29));
    await tester.pump();
  });

  testWidgets('Dialogs render cleanly', (WidgetTester tester) async {
    // AirdropModal
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: AirdropModal(
          airdropData: const {'type': 'SATOSHIS', 'value': 250.0, 'title': 'Test Crate'},
          onDismiss: () {},
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(AirdropModal), findsOneWidget);

    // OfflineEarningsDialog
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: OfflineEarningsDialog(
          satoshisEarned: 1250.0,
          timeAway: const Duration(hours: 2, minutes: 15),
          onClaimNormal: () {},
          onClaimDoubled: () {},
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(OfflineEarningsDialog), findsOneWidget);
  });

  test('Locked ShaftComponent is strictly not clickable', () {
    final state = GameState();
    expect(state.shafts[1].isUnlocked, isFalse);

    bool tapped = false;
    final lockedComp = ShaftComponent(
      shaft: state.shafts[1],
      position: Vector2.zero(),
      size: Vector2(400, 110),
      onShaftTapped: (shaft, pos) {
        tapped = true;
      },
    );

    final tapEvent = TapDownEvent(1, FlameGame(), TapDownDetails());
    lockedComp.onTapDown(tapEvent);
    expect(tapped, isFalse, reason: 'Locked floor should NOT be clickable');

    // Unlocked floor is clickable
    final unlockedComp = ShaftComponent(
      shaft: state.shafts[0],
      position: Vector2.zero(),
      size: Vector2(400, 110),
      onShaftTapped: (shaft, pos) {
        tapped = true;
      },
    );
    unlockedComp.onTapDown(tapEvent);
    expect(tapped, isTrue, reason: 'Unlocked floor should be clickable');
  });
}
