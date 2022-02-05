import 'package:bible_in_us/bible/bible_database.dart';

class HymnRepository {

  // 찬송가 메인페이지 _ 타입별 갯수 가져오기
  static Future<List<Map<String, dynamic>>> Get_type_count(String query) async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
      SELECT type, count(type) AS count, min(number) AS start, max(number) AS end
      FROM hymns
      WHERE title like "%$query%"
      GROUP BY type
      ORDER BY number ASC;
    """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 찬송가 메인페이지 _ 해당 찬송가 리스트 가져오기
  static Future<List<Map<String, dynamic>>> Get_Hymn_list(String type, String query) async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
      SELECT *
      FROM hymns
      WHERE type = "$type" and title like "%$query%"
      ORDER BY number ASC;
    """;
    var result =  db.rawQuery(Query);
    return result;
  }


}
