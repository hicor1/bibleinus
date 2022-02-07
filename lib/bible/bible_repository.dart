import 'package:bible_in_us/bible/bible_database.dart';

class BibleRepository {

  // 권(book) = 창세기 / 출애굽기 등등 리스트 가져오기
  static Future<List<Map<String, dynamic>>> GetBookList() async {
    var db = await BibleDatabase.getDb();
    return db.query(
        "bibles",
        columns: ["*"], // ['vcode', 'bcode', 'type', 'name', 'chapter_count'],
        orderBy: "_id"
    );
  }

  // 조건에 맞는 권(book)이 몇개의 챕터로 이루어져있는지 받아오기 ㄱㄱ
  static Future<List<Map<String, dynamic>>> GetChapterNumberList(bcode) async {
    var db = await BibleDatabase.getDb();
    var Query =
        """
          SELECT DISTINCT cnum
          FROM verses 
          WHERE bcode = $bcode
        """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 조건에 맞는 구절(Contents)가져오기
  static Future<List<Map<String, dynamic>>> Getcontents(bcode, cnum, bible) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
          SELECT _id, bcode, cnum, vnum, $bible, highlight_color_index
          FROM verses 
          WHERE bcode = $bcode and cnum = $cnum
      """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 다음 페이지 정보를 확인하기 위한 더미 데이터 조회
  static Future<List<Map<String, dynamic>>> GetVersesDummy() async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
          SELECT DISTINCT bcode, cnum
          FROM verses 
      """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 자유검색 ( 성경 구절에 일치하는 단어를 통해서 검색하는 기능 )
  static Future<List<Map<String, dynamic>>> FreeSearchList(String BibleName, String query) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
        SELECT verses._id, verses.bcode, cnum, vnum, bookmarked, 국문, 영문, $BibleName
        FROM
        (
          SELECT _id, bcode, cnum, vnum, bookmarked, $BibleName
          FROM verses 
        ) AS verses
        INNER JOIN bibles
        ON verses.bcode = bibles.bcode
        WHERE $BibleName like '%$query%'
      """
    );
    return result;
  }
  // 자유검색 ( 각 성경 권(book)이 몇개인지 조회하는 기능 )
  static Future<List<Map<String, dynamic>>> FreeSearchResultCount(String BibleName, String query) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
        SELECT verses.bcode, 국문, count(국문)
        FROM
        (
          SELECT bcode, $BibleName
          FROM verses 
        ) AS verses
        INNER JOIN bibles
        ON verses.bcode = bibles.bcode
        WHERE $BibleName like '%$query%'
        GROUP BY 국문
        ORDER BY count(국문) DESC;
      """
    );
    return result;
  }

  // 사람이 직접클릭한 구절들의 정보 가져오기
  static Future<List<Map<String, dynamic>>> GetClickedVerses(List ContentsIdList_clicked, String BibleName) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
      SELECT verses._id, verses.bcode, cnum, vnum, $BibleName, highlight_color_index, 국문, 영문
       FROM 
      (
        SELECT _id, bcode, cnum, vnum, bookmark_updated_at, $BibleName, highlight_color_index
        FROM verses 
      ) AS verses
      INNER JOIN bibles
      ON verses.bcode = bibles.bcode
      WHERE verses._id IN $ContentsIdList_clicked
      """;
    // WHERE IN 검색을 위해 리스트를 대입하고, 리스트 괄호를 변경해준다 ([] => ())
    Query = Query.replaceAll("[", "(").replaceAll("]", ")");
    var result =  db.rawQuery(Query);
    return result;
  }

  // 사람이 직접클릭한 구절 즐겨찾기 색깔 저장
  static Future<List<Map<String, dynamic>>> ColorCode_save(List ContentsIdList_clicked, int color_index) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
        UPDATE verses
        SET 
          highlight_color_index = $color_index,
          bookmark_updated_at = '${DateTime.now().toString()}'
        WHERE _id IN $ContentsIdList_clicked
      """;
    // WHERE IN 검색을 위해 리스트를 대입하고, 리스트 괄호를 변경해준다 ([] => ())
    Query = Query.replaceAll("[", "(").replaceAll("]", ")");
    var result =  db.rawQuery(Query);
    return result;
  }

  // 즐겨찾기 페이지 _ 즐겨찾기 추가된 녀석들 가져오기 ( 칼라코드가 0이 아닌 녀석들은 전부 가져온다 ㄱㄱ )
  static Future<List<Map<String, dynamic>>> Favorite_list_load_specific(String BibleName, List Favorite_choiced_color_list) async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
      SELECT verses._id, verses.bcode, cnum, vnum, $BibleName, bookmark_updated_at, 국문, 영문, highlight_color_index
      FROM 
      (
        SELECT _id, bcode, cnum, vnum, bookmark_updated_at, $BibleName, highlight_color_index
        FROM verses 
      ) AS verses
      INNER JOIN bibles
      ON verses.bcode = bibles.bcode
      WHERE highlight_color_index IN $Favorite_choiced_color_list
      ORDER by bookmark_updated_at DESC
      """;
    // WHERE IN 검색을 위해 리스트를 대입하고, 리스트 괄호를 변경해준다 ([] => ())
    Query = Query.replaceAll("[", "(").replaceAll("]", ")");
    var result =  db.rawQuery(Query);
    return result;
  }

  // 즐겨찾기 페이지 _ 즐겨찾기 색깔별 갯수 구하기 ( "0"인경우, 인덱스 자체가 없어지므로, 0값이라도 인덱스가 나오게 수정 )
  static Future<List<Map<String, dynamic>>> Get_color_count() async {
    var db = await BibleDatabase.getDb();
    var Query =
    """
      SELECT highlight_color_index, count(highlight_color_index)
      FROM verses
      GROUP BY highlight_color_index
      ORDER BY count(highlight_color_index) DESC;
    """;
    var result =  db.rawQuery(Query);
    return result;
  }




  // 메모 DB 추가 하기(INSERT)
  static Future<List<Map<String, dynamic>>> Memo_save(ContentsIdList_clicked, String memo) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
        INSERT INTO bible_memo(연관구절, 메모)
        VALUES ("$ContentsIdList_clicked", "$memo");
      """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 메모 DB 불러오기(LOAD)
  static Future<List<Map<String, dynamic>>> Memo_load() async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
        SELECT *
        FROM bible_memo
        ORDER by updated_at DESC
      """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 메모 DB 삭제하기(DELETE)
  static Future<List<Map<String, dynamic>>> Memo_delete(int id) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
        DELETE FROM bible_memo
        WHERE _id = $id
      """;
    var result =  db.rawQuery(Query);
    return result;
  }

  // 메모 DB 수정하기(UPDATE)
  static Future<List<Map<String, dynamic>>> Memo_update(int id, String memo) async {
    var db = await BibleDatabase.getDb();
    var Query =
      """
        UPDATE bible_memo
        SET
           메모 = "$memo",
           updated_at = CURRENT_TIMESTAMP
        WHERE _id = $id;
      """;
    var result =  db.rawQuery(Query);
    return result;
  }



















  // (장<chapter> 가져오기)
  static Future<List<Map<String, dynamic>>> ChapterList(int bcode) async {
    var db = await BibleDatabase.getDb();
    return db.query(
        "verses",
        columns: ["cnum"], // ['vcode', 'bcode', 'type', 'name', 'chapter_count'],
        distinct: true, // 중복제거
        where: ' bcode =:bcode', //' vcode ="GAE" and type like "%ld%" ',
        whereArgs: [bcode],
        orderBy: '_id asc'
    );
  }
  // (절<verse> 가져오기)
  static Future<List<Map<String, dynamic>>> VerseList(int bcode, int cnum) async {
    var db = await BibleDatabase.getDb();
    return db.query(
        "verses",
        columns: ["vnum"], // ['vcode', 'bcode', 'type', 'name', 'chapter_count'],
        distinct: true,
        where: ' bcode =:bcode and cnum=:cnum', //' vcode ="GAE" and type like "%ld%" ',
        whereArgs: [bcode, cnum],
        orderBy: '_id asc'
    );
  }

  // 해당구절 _Id 가져오기
  static Future<List<Map<String, dynamic>>> GetContentId(int Bookcode, int ChapterNo, int VerseNo) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
      SELECT *
      FROM verses
      WHERE bcode = $Bookcode and cnum =$ChapterNo and vnum = $VerseNo
    """
    );
    return result;
  }


  // (성경구절<content> 가져오기 with 갯수정보) with id정보와 갯수로
  static Future<List<Map<String, dynamic>>> GetContent(int id, int number, String BibleName) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
          SELECT verses._id, verses.bcode, cnum, vnum, bookmarked, bookmark_updated_at, 국문, 영문, $BibleName
          FROM
          (
            SELECT _id, bcode, cnum, vnum, bookmarked, bookmark_updated_at, $BibleName
            FROM verses 
          ) AS verses
          INNER JOIN bibles
          ON verses.bcode = bibles.bcode
          
          WHERE verses._id BETWEEN $id and ${id+number-1};
        """
    );
    return result;
  }


  // 조건에 맞는 성경이름 가져오기 ( ex: 창세기 / 출애굽기 / 레위기 / 요한계시록 등등 )
  static Future<List<Map<String, dynamic>>> GetBibleName(String vcode, int bcode) async {
    var db = await BibleDatabase.getDb();
    var result =  db.query(
      "bibles",
      columns: ["name"], // ['vcode', 'bcode', 'type', 'name', 'chapter_count'],
      where: ' vcode =:vcode and bcode =:bcode', //' vcode ="GAE" and type like "%ld%" ',
      whereArgs: [vcode, bcode],
    );
    return result;
  }


  // 북마크(즐겨찾기(bookmarked))업데이트 하기 ( 업데이트가 발생한 시간도 함께 입력 )
  Future<void> UpdateBookmarked(int _id, int bookmarked) async {
    var db = await BibleDatabase.getDb();
    final data = {
      'bookmarked': bookmarked,
      'bookmark_updated_at': DateTime.now().toString() // (매우중요)
    };
    await db.update('verses', data, where: "_id = ?", whereArgs: [_id]);
  }

  // 즐겨찾기 리스트 검색, 북마크(즐겨찾기(bookmarked))가져오기
  static Future<List<Map<String, dynamic>>> GetBookmarkedList(String BibleName, String Order) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
        SELECT verses._id, verses.bcode, cnum, vnum, bookmarked, bookmark_updated_at,국문, 영문, $BibleName
        FROM
        (
          SELECT _id, bcode, cnum, vnum, bookmarked, bookmark_updated_at, $BibleName
          FROM verses 
        ) AS verses
        INNER JOIN bibles
        ON verses.bcode = bibles.bcode
        WHERE bookmarked = 1
        ORDER by $Order
      """
    );
    return result;
  }

  // 성경이름 자유검색 ( ex: 창세기, 출애굽기 등등 검색 하는 기능 + 국&영문 동시)
  static Future<List<Map<String, dynamic>>> BibleSearch(String query) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
          SELECT *
          FROM bibles
          WHERE 국문 like '%$query%' or 영문 like '%$query%'
          ORDER by _id ASC
      """
    );
    return result;
  }


  //////////////아래는 안쓰는 녀석들///////////////

  // (성경구절<content> 가져오기 with 갯수정보) JOIN with "Bibles" : 성경(book)이름도 같이 가져오기 위해
  static Future<List<Map<String, dynamic>>> GetContent_temp(int Bookcode, int ChapterNo, int VerseNo, int number, String BibleName) async {
    var db = await BibleDatabase.getDb();
    var result =  db.rawQuery(
        """
          SELECT verses._id, verses.bcode, cnum, vnum, bookmarked, 국문, 영문, $BibleName
          FROM
          (
            SELECT _id, bcode, cnum, vnum, bookmarked, $BibleName
            FROM verses 
          ) AS verses
          INNER JOIN bibles
          ON verses.bcode = bibles.bcode
          
          WHERE verses._id BETWEEN 
            (
              SELECT verses._id
              FROM verses
              WHERE bcode=$Bookcode and cnum=$ChapterNo and vnum=$VerseNo
            )
              and 
            (
              SELECT verses._id
              FROM verses
              WHERE bcode=$Bookcode and cnum=$ChapterNo and vnum=${VerseNo+number-1}
            );
        """
    );
    return result;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems(String TableName, String vcode) async {
    var db = await BibleDatabase.getDb();
    return db.query(
        TableName,
        columns: ["*"], // ['vcode', 'bcode', 'type', 'name', 'chapter_count'],
        where: ' vcode =:vcode ', //' vcode ="GAE" and type like "%ld%" ',
        whereArgs: [vcode],
        orderBy: "_id"
    );
  }

  // 북마크(즐겨찾기(bookmarked))업데이트 하기( ORM 스타일로 변경함 )
  Future<void> UpdateBookmarked_temp(int _id, int bookmarked) async {
    var db = await BibleDatabase.getDb();
    await db.rawUpdate(
        'update verses set bookmarked =:bookmarked where _id=:_id',
        [bookmarked, _id]
    );
  }


}
