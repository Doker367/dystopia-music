import 'dart:async';

import 'package:dystopia/domain/entities/song.dart';

class QueueManager {
  List<Song> _queue = [];
  List<Song> _originalQueue = [];
  int _currentIndex = -1;
  bool _isShuffled = false;

  final _queueController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get queueStream => _queueController.stream;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  bool get hasNext => _currentIndex >= 0 && _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  int? get nextIndex => hasNext ? _currentIndex + 1 : null;
  int? get previousIndex => hasPrevious ? _currentIndex - 1 : null;

  void addSong(Song song) {
    _queue.add(song);
    if (!_isShuffled) {
      _originalQueue.add(song);
    }
    _emitQueue();
  }

  void addSongNext(Song song) {
    if (_currentIndex == -1) {
      addSong(song);
      return;
    }
    _queue.insert(_currentIndex + 1, song);
    if (!_isShuffled) {
      _originalQueue.insert(_originalQueue.indexOf(currentSong!) + 1, song);
    }
    _emitQueue();
  }

  void addSongs(List<Song> songs) {
    _queue.addAll(songs);
    if (!_isShuffled) {
      _originalQueue.addAll(songs);
    }
    _emitQueue();
  }

  void removeSong(int index) {
    if (index < 0 || index >= _queue.length) return;

    final song = _queue[index];
    _queue.removeAt(index);
    if (!_isShuffled) {
      _originalQueue.remove(song);
    }

    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      if (_currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
    }
    _emitQueue();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _queue.length ||
        newIndex < 0 ||
        newIndex > _queue.length) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    if (!_isShuffled) {
      _originalQueue = List.from(_queue);
    }

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }

    _emitQueue();
  }

  void clear() {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    _isShuffled = false;
    _emitQueue();
  }

  void shuffle() {
    if (_isShuffled || _queue.isEmpty) return;

    final current = currentSong;
    _originalQueue = List.from(_queue);

    _queue.shuffle();
    if (current != null) {
      _queue.remove(current);
      _queue.insert(0, current);
      _currentIndex = 0;
    }
    _isShuffled = true;
    _emitQueue();
  }

  void unshuffle() {
    if (!_isShuffled) return;

    final current = currentSong;
    _queue = List.from(_originalQueue);

    if (current != null) {
      _currentIndex = _queue.indexOf(current);
      if (_currentIndex == -1) _currentIndex = 0; // fallback
    }
    _isShuffled = false;
    _emitQueue();
  }

  bool skipToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      return true;
    }
    return false;
  }

  void resetIndex() {
    _currentIndex = -1;
  }

  void setQueue(List<Song> newQueue, {int startIndex = 0}) {
    _queue = List.from(newQueue);
    _originalQueue = List.from(newQueue);
    _currentIndex = (startIndex >= 0 && startIndex < _queue.length)
        ? startIndex
        : 0;
    _isShuffled = false;
    _emitQueue();
  }

  void _emitQueue() {
    _queueController.add(List.unmodifiable(_queue));
  }

  void dispose() {
    _queueController.close();
  }
}
