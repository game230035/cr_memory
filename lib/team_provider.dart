import 'dart:async';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:idb_shim/idb_client.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/map_utils.dart';

const String dbName = 'team.db';

const int kVersion1 = 1;

String fieldTitle = 'title';
String fieldImagepath = 'imagepath';
String fieldLink = 'link';

class MemoryTeamProvider extends TeamProvider {
  MemoryTeamProvider() : super(idbFactory: idbFactoryMemory);
}

class TeamProvider {
  final IdbFactory idbFactory;
  late Database db;

  static const String teamsStoreName = 'teams';

  TeamProvider({required this.idbFactory});

  // final notesStore = intMapStoreFactory.store(notesStoreName);
  ObjectStore get teamsWritableTxn {
    var txn = db.transaction(teamsStoreName, idbModeReadWrite);
    var store = txn.objectStore(teamsStoreName);
    return store;
  }

  ObjectStore get teamsReadableTxn {
    var txn = db.transaction(teamsStoreName, idbModeReadOnly);
    var store = txn.objectStore(teamsStoreName);
    return store;
  }

  Future<int> getCount() async {
    var store = teamsReadableTxn;
    var count = await store.count();
    return count;
  }

  Future<Team?> getTeam(int id) async {
    var store = teamsReadableTxn;
    var map = asMap<String, Object?>(await store.getObject(id));
    if (map != null) {
      return Team.fromMap(map, id);
    }
    return null;
  }

  Future open() async {
    db = await idbFactory.open(dbName,
        version: kVersion1, onUpgradeNeeded: onUpgradeNeeded);
  }

  void onUpgradeNeeded(VersionChangeEvent event) {
    var db = event.database;
    db.createObjectStore(teamsStoreName, autoIncrement: true);
  }

  /// Add if id is null, update otherwise
  Future saveTeam(Team team) async {
    // devPrint('saveNote $updatedNote');
    var store = teamsWritableTxn;
    if (team.id != null) {
      await store.put(team.toMap(), team.id);
    } else {
      team.id = await store.add(team.toMap()) as int;
    }
  }

  Future deleteTeam(int? id) async {
    if (id != null) {
      await teamsWritableTxn.delete(id);
    }
  }

  Future<List<Team>> getTeams() async {
    // devPrint('getting $offset $limit');
    List<Team?> list = <Team>[];
    var store = teamsReadableTxn;
    // ignore: cancel_subscriptions
    StreamSubscription subscription;
    subscription = store
        .openCursor(direction: idbDirectionPrev, autoAdvance: true)
        .listen((cursor) {
      try {
        var map = asMap<String, Object?>(cursor.value);

        if (map != null) {
          var team = cursorToTeam(cursor);
          // devPrint('adding ${note}');
          list.add(team);
        }
      } catch (e) {
        // devPrint('error getting list notes $e');
      }
    });
    await subscription.asFuture<void>();
    return list as FutureOr<List<Team>>;
  }

  Future clearAllTeams() async {
    var store = teamsWritableTxn;
    await store.openKeyCursor(autoAdvance: true).listen((cursor) {
      cursor.delete();
    }).asFuture<void>();
  }

  Future close() async {
    db.close();
  }
}

Team? cursorToTeam(CursorWithValue/*<int, Map<String, Object?>>*/ cursor) {
  Team? team;
  var snapshot = asMap(cursor.value);
  if (snapshot != null) {
    team = Team.fromMap(snapshot, cursor.primaryKey as int);
  }
  return team;
}

class Team {
  int? id;
  String? title;
  String? imagepath;
  String? link;

  Team({required this.title, required this.imagepath, required this.link, this.id});

  Map<String, String?> toMap() {
    var map = <String, String?>{
      fieldTitle: title,
      fieldImagepath: imagepath,
      fieldLink: link
    };
    return map;
  }

  Team.fromMap(Map map, this.id) {
    title = map[fieldTitle] as String?;
    imagepath = map[fieldImagepath] as String?;
    link = map[fieldLink] as String?;
  }

  @override
  int get hashCode => id ?? 0;

  @override
  bool operator ==(other) {
    return other is Team &&
        other.title == title &&
        other.imagepath == imagepath &&
        other.link == link &&
        other.id == id;
  }
}
