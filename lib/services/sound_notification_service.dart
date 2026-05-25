import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class SoundNotificationService {
  static final SoundNotificationService _instance = SoundNotificationService._internal();
  factory SoundNotificationService() => _instance;
  SoundNotificationService._internal();

  AudioPlayer? _player;
  
  // Track announcement yang sudah diputar suaranya
  final Set<String> _playedAnnouncements = {};
  
  // Track task yang sudah diputar suaranya
  final Set<String> _playedTasks = {};

  Future<void> playNotificationSound(String id, {String type = 'announcement'}) async {
    // Cek berdasarkan type
    final playedSet = type == 'announcement' ? _playedAnnouncements : _playedTasks;
    
    // Jangan play jika suara sudah pernah diputar untuk item ini
    if (playedSet.contains(id)) return;
    
    try {
      // Inisialisasi player
      _player = AudioPlayer();
      
      // Load file suara dari asset
      await _player?.setAsset('assets/sounds/notification.mp3');
      
      // Putar suara
      await _player?.play();
      
      // Tandai item ini sudah diputar
      playedSet.add(id);
      
      // Bersihkan player setelah selesai
      _player?.dispose();
      _player = null;
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
  
  // Reset tracking (opsional, misal saat logout)
  void reset() {
    _playedAnnouncements.clear();
    _playedTasks.clear();
  }
}