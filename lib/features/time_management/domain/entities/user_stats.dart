import 'package:hive/hive.dart';

part 'user_stats.g.dart'; // Nhớ chạy build_runner sau khi tạo file này

@HiveType(typeId: 1) // TypeId khác 0 (TaskModel)
class UserStats extends HiveObject {
  @HiveField(0)
  int level;

  @HiveField(1)
  int currentXp;

  @HiveField(2)
  int xpToNextLevel;

  UserStats({
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
  });

  // Logic cộng XP
  bool addXp(int amount) {
    currentXp += amount;
    if (currentXp >= xpToNextLevel) {
      level++;
      currentXp = currentXp - xpToNextLevel;
      xpToNextLevel = (xpToNextLevel * 1.2).toInt(); // Càng lên cao càng khó
      return true; // Báo hiệu lên cấp
    }
    return false;
  }
}
