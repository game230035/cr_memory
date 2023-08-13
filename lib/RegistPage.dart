import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_io.dart';
import 'package:cr_memory/team_provider.dart';

const String dbName = 'teams.db';
const int kVersion1 = 1;
String fieldTitle = 'title';
String fieldImagePath = 'path';
String fieldLink = 'link';

class RegistPage extends StatefulWidget {
  const RegistPage({super.key, this.team, required this.teamProvider});
  final TeamProvider teamProvider;
  final Team? team;

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  TeamProvider get teamProvider => widget.teamProvider;
  Team? get team => widget.team;

  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _imagepath;
  String? _link;

  // String _text = '';
  XFile? image;
  // インスタンスを生成
  final picker = ImagePicker();

  Future _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await teamProvider.saveTeam(Team(
          title: _title, imagepath: _imagepath, link: _link, id: team?.id));
      Navigator.pop(context, true);
    }
  }

  // void _handleText(String e) {
  //   setState(() {
  //     // _text = e;
  //     _imagepath = e;
  //   });
  // }

  Future getImage() async {
    final XFile? _image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (_image != null) {
        image = XFile(_image.path);
        _imagepath = _image.path;
      }
    });
  }

  // void _regist() async {
  //   final idbFactory = getIdbFactoryPersistent('test/out');

  //   // define the store name
  //   final storeName = 'teams';

  //   // open the database
  //   final db = await idbFactory.open('teams.db', version: 1,
  //       onUpgradeNeeded: (VersionChangeEvent event) {
  //     final db = event.database;
  //     // create the store
  //     db.createObjectStore(storeName, autoIncrement: true);
  //   });

  //   // put some data
  //   var txn = db.transaction(storeName, idbModeReadWrite);
  //   var store = txn.objectStore(storeName);
  //   var key = await store.put({'title': 'aaa'});
  //   await txn.completed;

  //   // read some data
  //   txn = db.transaction(storeName, idbModeReadOnly);
  //   store = txn.objectStore(storeName);
  //   final value = await store.getObject(key) as Map;
  //   await txn.completed;

  //   print(value);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チーム登録'),
      ),
      body: Container(
          margin: const EdgeInsets.all(32.0),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'チーム名',
                        border: InputBorder.none,
                      ),
                      key: const Key('title'),
                      initialValue: team?.title,
                      validator: (val) =>
                          val!.isNotEmpty ? null : 'Title must not be empty',
                      onSaved: (val) => _title = val,
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    const Text('画像読み込み'),
                    Center(
                      child: image == null
                          ? const Text('画像がありません')
                          : Image.network(image!.path,width: 100,height: 100,),
                    
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        getImage();
                      },
                      child: const Icon(Icons.photo),
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Link',
                        border: InputBorder.none,
                      ),
                      key: const Key('link'),
                      initialValue: team?.imagepath,
                      validator: (val) =>
                          val!.isNotEmpty ? null : 'Link must not be empty',
                      onSaved: (val) => _link = val,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                  ]))),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _submit(), child: const Icon(Icons.check)),
    );
  }
}
