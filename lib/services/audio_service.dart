import 'package:flutter/services.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void playTap() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playCoinPickup() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playUpgrade() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playFrenzyStart() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.alert);
  }

  void playAirdrop() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.alert);
  }

  void playSuccess() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playError() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.alert);
  }

  void playTick() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playCrit() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.alert);
  }

  void playSpin() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }
}
