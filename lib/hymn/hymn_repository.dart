import 'package:bible_in_us/bible/bible_database.dart';

class HymnRepository {

  // 찬송가 메인페이지 _ 타입별 갯수 가져오기
  static Future<List<Map<String, dynamic>>> Get_type_count(String query) async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
      SELECT hymns.type, count(*) AS count, min(number) AS start, max(number) AS end
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




























  // 찬송가 메인페이지 _ 타입별 갯수 가져오기(잠시 백업 , 너무 투머치한듯 )
  static Future<List<Map<String, dynamic>>> Get_type_count_temp(String query) async {
    var db = await BibleDatabase.getDb();
    var Query =
    /* GroupBy해서 0인녀석들도 가져오기 위해서 두개 테이블 조인 */
    /* "IFNULL"을 통해서 "NULL"인 녀석들은 0으로 치환 */
    """
      SELECT A.type, IFNULL(B.count,0) AS count, A.start, A.end
      FROM 
      (
        SELECT hymns.type, count(*) AS count, min(number) AS start, max(number) AS end
        FROM hymns
        GROUP BY type
        ORDER BY number ASC
      ) AS A
      LEFT JOIN 
      (
        SELECT hymns.type, count(*) AS count
        FROM hymns
        WHERE title like "%$query%"
        GROUP BY type
      ) AS B
      ON A.type = B.type
    """;
    var result =  db.rawQuery(Query);
    return result;
  }



}
