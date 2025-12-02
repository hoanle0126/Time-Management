import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

extension EisenhowerDisplay on EisenhowerQuadrant {
  String get title {
    switch (this) {
      case EisenhowerQuadrant.doFirst:
        return 'Làm ngay (Do First)';
      case EisenhowerQuadrant.schedule:
        return 'Sắp xếp (Schedule)';
      case EisenhowerQuadrant.delegate:
        return 'Giao việc (Delegate)';
      case EisenhowerQuadrant.eliminate:
        return 'Loại bỏ (Eliminate)';
    }
  }

  Color get color {
    switch (this) {
      case EisenhowerQuadrant.doFirst:
        return Colors.red.shade100; // Khẩn cấp & Quan trọng
      case EisenhowerQuadrant.schedule:
        return Colors.blue.shade100; // Quan trọng nhưng không gấp
      case EisenhowerQuadrant.delegate:
        return Colors.green.shade100; // Gấp nhưng không quan trọng
      case EisenhowerQuadrant.eliminate:
        return Colors.grey.shade300; // Không gấp, không quan trọng
    }
  }

  Color get headerColor {
    switch (this) {
      case EisenhowerQuadrant.doFirst:
        return Colors.red.shade700;
      case EisenhowerQuadrant.schedule:
        return Colors.blue.shade800;
      case EisenhowerQuadrant.delegate:
        return Colors.green.shade800;
      case EisenhowerQuadrant.eliminate:
        return Colors.grey.shade700;
    }
  }
}
