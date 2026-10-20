/// بيانات مستخرجة من جدول الفصل الدراسي (Fall 2026-2027) - كلية الحاسبات والهندسة.
/// ⚠️ راجع الأسماء بنفسك: الجدول الأصلي كان متحوّل من PDF والترتيب فيه متلخبط.
library;

const Map<int, String> levelNames = {
  1: 'السنة الأولى',
  2: 'السنة الثانية',
  3: 'السنة الثالثة',
  4: 'السنة الرابعة',
};

/// البرامج المتاحة في كل سنة.
const Map<int, List<String>> levelPrograms = {
  1: ['AIS', 'CS'],
  2: ['AIS', 'CS', 'BDI'],
  3: ['AIS', 'CS', 'BDI'],
  4: ['AIS', 'CS', 'BDI'],
};

/// أرقام الجروبات (من - إلى) لكل سنة وبرنامج.
const Map<int, Map<String, List<int>>> _groupRanges = {
  1: {'AIS': [10, 13], 'CS': [14, 22]},
  2: {'AIS': [6, 9], 'CS': [10, 20], 'BDI': [21, 21]},
  3: {'AIS': [5, 7], 'CS': [8, 14], 'BDI': [15, 15]},
  4: {'AIS': [3, 7], 'CS': [8, 11], 'BDI': [12, 12]},
};

List<int> groupsFor(int level, String program) {
  final r = _groupRanges[level]?[program];
  if (r == null) return [];
  return [for (var g = r[0]; g <= r[1]; g++) g];
}

class Course {
  final String code;
  final String name;
  final Map<int, List<String>> offered; // السنة -> البرامج
  final List<String> lecturers; // دكاتره المحاضرات
  final List<String> assistants; // معيدين/دكاتره السكاشن واللابات
  const Course(this.code, this.name, this.offered, this.lecturers, this.assistants);
}

const List<String> _all = ['AIS', 'CS', 'BDI'];

const List<Course> courses = [
  // ---------- السنة الأولى ----------
  Course('CSE014', 'Structured Programming', {1: ['AIS', 'CS']},
      ['د/ Mohamed Handousa', 'د/ Shaymaa Elsabahy'],
      ['م/ Nora Ibrahim', 'م/ Basel Zeyada', 'م/ Saher Mohamed', 'م/ Sandy Samy', 'م/ Rola Tarek']),
  Course('PHY211', 'Physics II', {1: ['AIS', 'CS']},
      ['د/ Mohamed Elhennawy'],
      ['د/ Ali', 'د/ Huda', 'د/ Mayada']),
  Course('MAT114', 'Analytical Geometry & Calculus I', {1: ['AIS', 'CS']},
      ['د/ Ahmed Salah', 'د/ Mohamed Elzayady'], []),

  // ---------- السنة الثانية ----------
  Course('CSE111', 'Data Structures', {2: _all, 3: ['CS']},
      ['د/ Omar Elzeki'],
      ['م/ Mohamed Essam', 'م/ Basant Waheed', 'م/ Abdelfatah Ibrahim', 'م/ Rola Tarek',
       'م/ Merna Kamal', 'م/ Saher Mohamed', 'م/ Basel Zeyada']),
  Course('CSE131', 'Logic Design', {2: _all, 3: ['CS']},
      ['د/ Nesma Abdelmawla'],
      ['م/ Lubna Hassan', 'م/ Nada Seif', 'م/ Nora Ibrahim', 'م/ Merna Kamal',
       'م/ Manar Ashraf', 'م/ Basel Zeyada']),
  Course('MAT231', 'Probability and Statistics', {2: ['AIS', 'CS']},
      ['د/ Ahmed Salah'], []),
  Course('MAT212', 'Linear Algebra', {2: _all},
      ['د/ Samir Shams'], []),
  Course('MAT313', 'Differential Equations & Numerical Analysis', {2: _all},
      ['د/ Abbas Mansour'], []),
  Course('AIE111', 'Artificial Intelligence', {2: ['AIS'], 3: ['CS', 'BDI']},
      ['د/ Hesham Elkady'],
      ['م/ Haneen Fayez', 'م/ Aya Ibrahim', 'م/ Nora Ibrahim', 'م/ Nada Seif', 'م/ Sandy Samy']),
  Course('FT1', 'Field Training 1', {2: ['CS'], 3: ['AIS']}, [], []),
  Course('BIO222', 'Molecular Genetics', {2: ['BDI']},
      ['د/ Amr Mowafy'], ['د/ Engy Elmarkaby', 'Mahmoud Fawzy']),

  // ---------- السنة الثالثة ----------
  Course('AIE241', 'Natural Language Processing', {3: ['AIS'], 4: ['BDI']},
      ['د/ Hesham Elkady'], ['م/ Basant Waheed']),
  Course('AIE323', 'Data Mining', {3: ['AIS']},
      ['د/ Omar Elzeki'], ['م/ Ghada Kamel']),
  Course('CSE261', 'Computer Networks', {3: _all},
      ['د/ Ibrahim Attiya'],
      ['م/ Mariam Moussa', 'م/ Tasneem Mostafa', 'م/ Mostafa Ayman', 'م/ Nouran Khaled',
       'م/ Nesma Mohamed', 'م/ Sandy Samy']),
  Course('CSE241', 'Security of Information Systems', {3: ['CS']},
      ['د/ Naira Elazab'], ['م/ Mostafa Ayman', 'م/ Abdullah Amir']),
  Course('CSE233', 'Operating Systems', {3: ['AIS', 'CS']},
      ['د/ Rasha Abdelkareem'],
      ['م/ Haneen Fayez', 'م/ Aya Ibrahim', 'م/ Saher Mohamed', 'م/ Manar Ashraf', 'م/ Alshaymaa Ehab']),
  Course('CSE211', 'Web Programming', {3: ['CS']},
      ['د/ Ammer'], ['م/ Rola Tarek', 'م/ Tasneem Mostafa']),
  Course('CSE281', 'Image Processing', {3: ['AIS']},
      ['د/ Ahmed Badawy'], ['م/ Nada Mamdouh', 'م/ Ghada Kamel']),
  Course('BMD311', 'Introduction to Bioinformatics', {3: ['BDI']},
      ['د/ Sara Elmetwally'], ['م/ Nora Yehia']),
  Course('BMD351', 'Biomedical Data Acquisition', {3: ['BDI']},
      ['د/ Sara Elmetwally'], ['م/ Nora Yehia']),

  // ---------- السنة الرابعة ----------
  Course('AIE332', 'Deep Learning', {4: ['AIS']},
      ['د/ Heba Kandeel'], ['م/ Abdelfatah Ibrahim', 'م/ Alshaymaa Ehab']),
  Course('AIE417', 'Selected Topics in Artificial Intelligence 1', {4: ['AIS']},
      ['د/ Amr Eledkawy'], ['م/ Sandy Samy', 'م/ Haneen Fayez']),
  Course('AIE322', 'Advanced Machine Learning', {4: ['AIS', 'CS']},
      ['د/ Islam Reda'], ['م/ Salma Alaa', 'م/ Nora Yehia']),
  Course('AIE425', 'Intelligent Recommender Systems', {4: ['AIS']},
      ['د/ Shaymaa Elsabahy'], ['م/ Manar Ashraf', 'م/ Salma Alaa']),
  Course('CSE475', 'Distributed Information Systems', {4: ['CS']},
      ['د/ Ammer'], ['م/ Nesma Mohamed', 'م/ Nada Mamdouh']),
  Course('CSE313', 'Mobile Development', {4: ['CS']},
      ['د/ Ahmed Badawy'], ['م/ Nada Mamdouh']),
  Course('CSE454', 'Advanced Software Engineering', {4: ['CS']},
      ['د/ Ahmed Badawy'], ['م/ Alshaymaa Ehab', 'م/ Abdullah Amir']),
  Course('BMD421', 'Biomedical Information Systems', {4: ['BDI']},
      ['د/ Shaymaa Elsabahy'], ['م/ Abdelfatah Ibrahim']),
  Course('CSE383', 'Computer Vision', {4: ['BDI']},
      ['د/ Naira Elazab'], ['م/ Basel Zeyada']),
  Course('BIO411', 'Genome Regulation', {4: ['BDI']},
      ['د/ Amr Mowafy'], ['د/ Engy Elmarkaby']),
];

List<Course> coursesFor(int level, String program) =>
    courses.where((c) => c.offered[level]?.contains(program) ?? false).toList();
