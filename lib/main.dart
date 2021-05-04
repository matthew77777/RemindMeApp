import 'package:flutter/material.dart';
import 'package:RemindMe/db/input_text_repository.dart';
import 'package:RemindMe/model/input_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('リマインダ－アプリ'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              var draft = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ListPage(),
                ),
              );
              if (draft != null) {
                setState(() => _textController.text = draft);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[

            //Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2lDHarffZ3bK1ltXSWN90A9vY2xbkl4QJOA&usqp=CAU'),
            Image.asset('images/test01.jpg'),

            SizedBox(height: 20.0),

            Text(
              '予定を入力/変更してください (=^･ω･^=)',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20.0),

            TextFormField(
              //controller: _textController,
              decoration: InputDecoration(
                filled: true,
                labelText: '日付を入力 (例: 20210509)',
              ),
            ),

            TextFormField(
              //controller: _textController,
              decoration: InputDecoration(
                filled: true,
                labelText: '時間を入力 (例: 0900)',
              ),
            ),

            SizedBox(height: 20.0),

            TextFormField(
              autofocus: true,
              controller: _textController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter text';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                filled: true,
                labelText: '予定を入力',
              ),
            ),

            SizedBox(height: 20.0),
            RaisedButton(
              child: Text('登録'),
              onPressed: () {
                InputTextRepository.create(_textController.text);
                _textController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  _ListPageState();

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: InputTextRepository.getAll(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Text('loading...');
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text("Todo list")),
      body: futureBuilder,
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<InputText> inputTextList = snapshot.data;
    //final String remind_date;
    //final String remind_time;



    return ListView.builder(
      itemCount: inputTextList != null ? inputTextList.length : 0,
      itemBuilder: (BuildContext context, int index) {
        InputText inputText = inputTextList[index];
        return Column(
          children: <Widget>[
            ListTile(
              title: Text(inputText.getBody),
              subtitle: Text(inputText.getUpdatedAt.toString()),
              onTap: () {
                final draftBody = inputText.getBody;
                InputTextRepository.delete(inputText.getId);
                Navigator.of(context).pop(draftBody);

              },
              onLongPress: () => showDialog(
                context: context,

                builder: (context) {
                  return SimpleDialog(
                    backgroundColor: Colors.grey,
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          final draftBody = inputText.getBody;
                          InputTextRepository.delete(inputText.getId);
                          // MyHomePageにtextを持っていく（力技っぽい）
                          Navigator.of(context).pop(draftBody);
                          Navigator.of(context).pop(draftBody);
                        },
                        child: Text(
                          "編集する",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          setState(() {
                            InputTextRepository.delete(inputText.id);
                            print('deleted');
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text(
                          "削除する",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Image.asset('images/test02.jpg'),
            Divider(height: 1.0),
          ],
        );
      },
    );
  }
}