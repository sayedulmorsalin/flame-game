import 'package:flutter_test/flutter_test.dart';
import 'package:btminer/models/game_state.dart';
import 'package:btminer/main.dart';

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
  });

  testWidgets('App renders BTMinerApp and bottom navigation items', (WidgetTester tester) async {
    await tester.pumpWidget(const BTMinerApp());
    await tester.pump();

    // Verify bottom navigation items exist
    expect(find.text('Mine'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Rigs'), findsOneWidget);
    expect(find.text('Miners'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
  });
}
