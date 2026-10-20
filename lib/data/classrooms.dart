/// القاعات والمعامل المذكورة في جدول الفصل الدراسي (Fall 2026-2027).
/// ⚠️ فهمنا الكود بالشكل: مبنى-دور-رقم (مثال 2-1-84 = مبنى 2، الدور الأول، رقم 84).
/// الاتجاهات تفصيلياً (خطوة بخطوة جوه الكلية) لسه ما اتضافتش.
library;

class Classroom {
  final String number; // مثال: 2-1-84
  final int building;
  final int floor; // 0 = الأرضي
  final String kind; // قاعة / معمل / معمل فيزياء
  final List<String> courseCodes; // أمثلة من المواد اللي بتتدرّس فيها
  const Classroom(this.number, this.building, this.floor, this.kind, this.courseCodes);

  String get floorName {
    const names = ['الدور الأرضي', 'الدور الأول', 'الدور الثاني', 'الدور الثالث', 'الدور الرابع'];
    return floor >= 0 && floor < names.length ? names[floor] : 'الدور $floor';
  }

  String get roomNo => number.split('-').last;

  List<String> get directions => [
        'اتجه إلى مبنى رقم $building.',
        floor == 0 ? 'ادخل على الدور الأرضي.' : 'اصعد إلى $floorName.',
        'دوّر على $kind رقم $roomNo.',
      ];
}

const List<Classroom> classrooms = [
  Classroom('2-0-25', 2, 0, 'معمل', ['CSE131', 'AIE111', 'CSE454', 'CSE233']),
  Classroom('2-1-16', 2, 1, 'قاعة', ['CSE014', 'CSE261', 'FT1', 'MAT212']),
  Classroom('2-1-40', 2, 1, 'معمل', ['CSE111', 'CSE261', 'AIE323', 'CSE281']),
  Classroom('2-1-45', 2, 1, 'قاعة', ['CSE383', 'BMD421', 'CSE131', 'BMD311']),
  Classroom('2-1-46', 2, 1, 'قاعة', ['AIE241', 'AIE111', 'CSE241', 'CSE111']),
  Classroom('2-1-47', 2, 1, 'قاعة', ['CSE131', 'CSE313', 'CSE281', 'CSE454']),
  Classroom('2-1-52', 2, 1, 'معمل', ['CSE014']),
  Classroom('2-1-76', 2, 1, 'قاعة', ['CSE211', 'CSE475', 'CSE131']),
  Classroom('2-1-77', 2, 1, 'قاعة', ['CSE131']),
  Classroom('2-1-83', 2, 1, 'قاعة', ['AIE323', 'CSE233', 'AIE322']),
  Classroom('2-1-84', 2, 1, 'قاعة', ['PHY211', 'AIE332', 'MAT231', 'MAT114']),
  Classroom('2-2-84', 2, 2, 'معمل', ['CSE261']),
  Classroom('5-0-99', 5, 0, 'قاعة', ['MAT313']),
  Classroom('5-1-18', 5, 1, 'قاعة', ['AIE417']),
  Classroom('5-2-5', 5, 2, 'معمل', ['CSE233', 'CSE131', 'AIE417', 'CSE111']),
  Classroom('5-2-6', 5, 2, 'معمل', ['AIE323', 'CSE313', 'AIE111', 'CSE261']),
  Classroom('5-2-13', 5, 2, 'معمل', ['AIE241', 'BMD311', 'CSE111', 'BMD351']),
  Classroom('5-2-14', 5, 2, 'معمل', ['AIE417', 'AIE111', 'CSE454', 'CSE111']),
  Classroom('5-2-22', 5, 2, 'معمل', ['AIE332', 'AIE111', 'CSE261', 'CSE111']),
  Classroom('5-2-90', 5, 2, 'معمل', ['AIE322', 'CSE111']),
  Classroom('5-2-92', 5, 2, 'معمل', ['CSE233', 'CSE111', 'AIE111']),
  Classroom('5-3-7', 5, 3, 'معمل', ['CSE313', 'AIE425', 'CSE111']),
  Classroom('5-3-8', 5, 3, 'معمل', ['CSE475', 'AIE111', 'CSE261', 'CSE111']),
  Classroom('5-3-9', 5, 3, 'معمل', ['BMD421', 'CSE383', 'CSE233']),
  Classroom('5-3-10', 5, 3, 'معمل', ['AIE111', 'CSE211']),
  Classroom('5-3-105', 5, 3, 'معمل', ['CSE241']),
  Classroom('5-3-107', 5, 3, 'معمل', ['AIE241', 'CSE111', 'AIE322']),
  Classroom('7-2-103', 7, 2, 'معمل فيزياء', ['PHY211']),
  Classroom('7-2-107', 7, 2, 'معمل فيزياء', ['PHY211']),
  Classroom('7-3-54', 7, 3, 'معمل', ['AIE417', 'CSE111', 'CSE233', 'CSE454']),
  Classroom('7-3-109', 7, 3, 'قاعة', ['BIO222']),
  Classroom('7-3-147', 7, 3, 'معمل', ['CSE111', 'CSE211', 'AIE322', 'CSE233']),
  Classroom('7-3-149', 7, 3, 'معمل', ['CSE211', 'CSE233', 'BIO411']),
  Classroom('8-0-24', 8, 0, 'قاعة', ['AIE241']),
];
