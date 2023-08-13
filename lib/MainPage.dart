import 'package:flutter/material.dart';
import 'RegistPage.dart';
import 'package:cr_memory/team_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
// import 'package:tekartik_notepad_idb_app/note_provider.dart';

class TeamListPageBloc {
  final TeamProvider? teamProvider;

  TeamListPageBloc(this.teamProvider);
  final _subject = BehaviorSubject<List<Team>>();

  ValueStream<List<Team>> get teams => _subject;

  Future refresh() async {
    _subject.add(await teamProvider!.getTeams());
  }

  void dispose() {
    _subject.close();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.teamProvider}); //追加
  final TeamProvider? teamProvider;

  void _incrementCounter() {
    // setState(() {
    //   // This call to setState tells the Flutter framework that something has
    //   // changed in this State, which causes it to rerun the build method below
    //   // so that the display can reflect the updated values. If we changed
    //   // _counter without calling setState(), then the build method would not be
    //   // called again, and so nothing would appear to happen.
    //   // _counter++;
    // });
  }
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  late TeamListPageBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = TeamListPageBloc(widget.teamProvider);
    bloc.refresh();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder(
      stream: bloc.teams,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('チーム一覧'),
          ),
          body: buildTeamsList(snapshot),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                var result = await Navigator.of(context).push<Object?>(
                    MaterialPageRoute(
                        builder: (_) =>
                            RegistPage(teamProvider: widget.teamProvider!)));
                if (result == true) {
                  await bloc.refresh();
                }
              },
              child: Icon(Icons.add)),
        );
      },
    );
  }

  Widget buildTeamsList(AsyncSnapshot<List<Team>> snapshot) {
    var teams = snapshot.data;
    if (teams != null) {
      return ListView.builder(
        // itemBuilder: (BuildContext context, int index) =>
        //     _createItem(teams, index),
        // itemCount: teams.length);
        itemExtent: 160,
        itemCount: teams.length,
        itemBuilder: (BuildContext context, int index) {
          return _messageItem(teams[index]);
        },
      );
    }
    // print('snapshot ${snapshot.connectionState} ${snapshot.data}');
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        break;
      default:
        if (snapshot.hasError) {
          return Text('Unexected error occurs: ${snapshot.error}');
        }
    }
    return Center(child: CircularProgressIndicator());
  }

  // Widget _createItem(List<Team> teams, int index) {
  // return Dismissible(
  //   key: UniqueKey(),
  //   onDismissed: (direction) async {
  //     await widget.teamProvider!.deleteTeam(teams[index].id);
  //     await bloc.refresh();
  //   },
  //   child: ListTile(
  //     title: Text(teams[index].title!),
  //     subtitle: Text(teams[index].description!.length > 50
  //         ? teams[index].description!.substring(0, 50)
  //         : teams[index].description!),
  //     onTap: () async {
  //       var result = await Navigator.of(context).push<Object?>(
  //           MaterialPageRoute(
  //               builder: (_) => RegistPage(
  //                   teamProvider: widget.teamProvider!, team: teams[index])));
  //       if (result == true) {
  //         await bloc.refresh();
  //       }
  //     },
  //   ),
  // );
  //   return _messageItem(list[index]);
  // }

  Widget _messageItem(Team teams) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: Column(
        children: [
          Text(teams.title ?? ""),
          Flexible(child: 
          Container(
              height: 100,
              width: 600,
              color: Colors.white,
              
              child: Row(
                children: [
                  Image.network(teams.imagepath ?? "",width: 100,height: 100,),

                  const SizedBox(width: 24),

                  // ElevatedButton(
                  //     onPressed: () {},
                  //     style: TextButton.styleFrom(
                  //       textStyle: const TextStyle(fontSize: 12),
                  //       foregroundColor: Colors.white, // foreground
                  //       fixedSize: Size(120, 32),
                  //       alignment: Alignment.center,
                  //     ),
                  //     child: const Text("クリック")),

                  Text(
                    teams.link ?? "",
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
