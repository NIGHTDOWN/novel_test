import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';

import 'package:ng169/model/base.dart';
import 'package:ng169/model/user.dart';

import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/commect/addcomment.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/style/screen.dart' as screenstyle;
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/starbar.dart';

import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

import 'package:ng169/tool/url.dart';

class Lastpage extends LoginBase {
  final Novel novel;

  Lastpage(this.novel);

//   @override
//   State<StatefulWidget> createState() => AddCommentState();
// }

// class AddCommentState extends State<AddComment> {
  TextEditingController comments = new TextEditingController();
  double star = 10.0;
  String api = 'user/urge';
  String cachename = 'lastpagecache';
  bool issbumit = false;
  var cache;
  var json;
  @override
  initState() {
    cachename += novel.type + cachename.hashCode.toString();
    super.initState();
    cache = getcache(cachename);
    if (isnull(cache)) {
      json = cache;
    }
    gethttpdata();
  }

  Future<void> gethttpdata() async {
    var newBook = await http('book/mostlike', {'type':novel.type}, gethead());
    var data1 = getdata(context, newBook);
    if (isnull(data1)) {
      json = data1;
      setcache(cachename, json, '-1');
    }
    refresh();
  }

  @override
  void dispose() {
    // scrollController.dispose();
    super.dispose();
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(novel.name),
        ),
        actions: <Widget>[
        novel.type=='3'?SizedBox():  Container(
              width: 44,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: GestureDetector(
                  onTap: share,
                  child: Icon(
                    Icons.share,
                    // color: Colors.grey,
                  ))),
        ],
      ),
      backgroundColor: SQColor.white,
      body: SingleChildScrollView(
        //?????????????????????
        child: body(),
      ),
    );
  }

  share() {
    sharefun(novel);
  }

  Widget body() {
    var strsty = TextStyle(fontWeight: FontWeight.w700);
    var strsty1 = TextStyle(fontWeight: FontWeight.bold, fontSize: 30);
    var strsty12 = TextStyle(fontWeight: FontWeight.w700, color: Colors.grey);
    return Column(
      children: <Widget>[
       novel.type=='3'?SizedBox(): SizedBox(
          height: 20,
        ),
     novel.type=='3'?SizedBox():   Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          //????????????
          // SizedBox(height: 20),
          novel.status == '1'
              ? Center(
                  child: Text(
                  lang('???????????????'),
                  style: strsty1,
                ))
              : Center(
                  child: Text(
                  lang('????????????..'),
                  style: strsty1,
                )),
          SizedBox(height: 10),
          Center(
              child: Text(
            lang('??????????????????????????????????????????~'),
            style: strsty12,
          )),
        ]),
      novel.type=='3'?SizedBox():  SizedBox(height: 15),
       novel.type=='3'?SizedBox(): Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                gourl(context, AddComment(novel: novel));
              },
              child: Center(
                  child: Column(children: [
                Image.asset(
                  'assets/images/plico.png',
                  width: 65,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    lang('?????????'),
                    style: strsty,
                  ),
                ),
              ])),
            ),
          ),
          novel.status != '1'
              ? Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      //??????????????????
                      // gourl(context, AddComment(novel: novel));
                      if (issbumit) {
                        show(context, lang('???????????????'));
                        return;
                      }
                      if (!User.islogin()) {
                        await gourl(context, Index());
                      }
                      issbumit = true;
                      reflash();
                      var data = {'wid': novel.id, 'type': novel.type};
                      http(api, data, gethead()).then((value) {
                        var tmpdata = getdata(context, value);
                        show(context, lang('????????????????????????'));
                      });
                    },
                    child: Center(
                        child: Column(children: [
                      !issbumit
                          ? Image.asset(
                              'assets/images/cgico2.png',
                              width: 65,
                            )
                          : Image.asset(
                              'assets/images/cgico.png',
                              width: 65,
                            ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(lang('??????'), style: strsty),
                      ),
                    ])),
                  ),
                )
              : SizedBox(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                gourl(
                    context,
                    Bow(
                      url: serverurl + 'index/author/run',
                      title: lang('?????????'),
                    ));
              },
              child: Center(
                  child: Column(children: [
                Image.asset(
                  'assets/images/xzico.png',
                  width: 65,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(lang('?????????'), style: strsty),
                ),
              ])),
            ),
          ),
        ]),
        //??????
        // Container(
        //   height: 10.0,
        //   width: getScreenWidth(context),
        //   color: Colors.grey[300],
        // ),
       novel.type=='3'?SizedBox(): SizedBox(height: 10),
      novel.type=='3'?SizedBox():  Container(
          margin: EdgeInsets.only(top: 10),
          height: 10,
          color: Color(0xfff5f5f5),
        ),
        isnull(json) ? NovelFourGridView(lang('???????????????'), json,false) : Container()
      ],
    );
  }
}
