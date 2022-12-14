import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/msg.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/rack/rack.dart';
import 'package:ng169/page/user/me_scene.dart';
import 'package:ng169/pay/AdBridge.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/incode.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/listenclip.dart';
import 'package:ng169/tool/notify.dart';
import 'package:ng169/tool/url.dart';
import 'package:uni_links/uni_links.dart';
import 'mall/mall.dart';
import 'package:ng169/obj/novel.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppSceneState();
}

class AppSceneState extends State<App> with WidgetsBindingObserver {
  int _tabIndex = 0;
  bool isFinishSetup = false;
  List<Widget> _tabImages = [
    Image.asset(
      'assets/images/tab_bookshelf_n.png',
      width: 24,
    ),
    // Icon(Icons.access_alarm),
    Image.asset(
      'assets/images/tab_bookstore_n.png',
      width: 24,
    ),
    Image.asset(
      'assets/images/tab_me_n.png',
      width: 24,
    ),
  ];
  List<Widget> _tabSelectedImages = [
    Image.asset(
      'assets/images/tab_bookshelf_p.png',
      width: 24,
      color: SQColor.primary,
    ),
    Image.asset(
      'assets/images/tab_bookstore_p.png',
      width: 24,
      color: SQColor.primary,
    ),
    // Image.asset('assets/images/tab_me_p.png',color: SQColor.primary,),

    Image.asset(
      'assets/images/tab_me_p2.png',
      width: 24,
    ),
  ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //d('????????????');
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //d('????????????');
  }

  @override
  void deactivate() {
    super.deactivate();
    // d('????????????');
  }

// ??????????????????????????????
  void didChangeMetrics() {
    //d('????????????');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // d(state.toString());
    s('gstat', state);

    // globalKeys['listenclip'].send('1');
    switch (state) {
      case AppLifecycleState.inactive: // ?????????????????????????????????????????????????????????????????????????????????

        break;
      case AppLifecycleState.resumed: // ???????????????????????????
        setcache(appstatus, '1', '0');
        break;
      case AppLifecycleState.paused: // ??????????????????????????????
        setcache(appstatus, '0', '0');
        break;
      // case AppLifecycleState.suspending: // ?????????????????????
      //   break;
      case AppLifecycleState.detached:
        break;
    }
  }

  //??????app
  Future<Null> weakAPP() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var _sub = getLinksStream().listen((String link) async {
      d('??????????????????' + link);
      var data = formar_url(link);
      if (!isnull(data, 'action')) {
        // d('??????????????????');
        return false;
      }
      String action = data['action'];
      var datatmp = data['data'];
      var user;
      switch (action) {
        case 'reg':
          //???????????? pid
          if (!isnull(datatmp, 'pid')) {
            return false;
          }
          if (!User.islogin()) {
            await gourl(g('context'), Index());
            // return false;
          }
          user = User.get();
          if (!isnull(user)) {
            ts('?????????');
            return false;
          }
          String uid = User.getuid().toString();
          if (uid == datatmp['pid']) {
            ts('?????????????????????????????????????????????');
            return false;
          }
          if (isnull(user, 'invite_id')) {
            //????????????????????????????????????
            String inviteid = user['invite_id'];
            if (datatmp['pid'] == inviteid) {
              ts('???????????????');
            } else {
              // showbox(Text(
              ts('?????????????????????');
              //   style: new TextStyle(
              //     decoration: TextDecoration.none,
              //     fontSize: 16.0,
              //     color: const Color(0xFF000000),
              //     fontWeight: FontWeight.w200,
              //   ),
              // ));
              // msgbox(g('context'), () {}, Text(lang('?????????????????????')));
            }
            return false;
          }
          bool bind = await User.bindinvite(datatmp['pid']);
          //??????????????????????????????????????????id???????????????id?????????????????????
          if (bind) {
            ts('???????????????');
            return true;
          } else {
            ts('??????????????????');
            return false;
          }

          break;
        case 'read':
          //???????????????????????? ???????????????type ??? bookid(??????) ???secid

          if (!isnull(datatmp, 'bookid')) {
            return false;
          }
          if (!isnull(datatmp, 'type')) {
            return false;
          }
          Novel novel = await Novel.fromID(
              int.parse(datatmp['bookid']), int.parse(datatmp['type']));
          if (isnull(novel)) {
            if (isnull(datatmp, 'secid')) {
              novel.read(context, int.parse(datatmp['secid']));
            } else {
              novel.read(context);
            }
          }
          // widget.novel.read(context, widget.novel.readChapter);
          //??????app????????????
          return true;
          break;
        // default:
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      d('????????????????????????');
    });
  }

  ts(String str) {
    var bo = Container(
      padding: EdgeInsets.all(15),
      child: Center(
          child: Text(
        lang(str),
        style: new TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16.0,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w200,
        ),
      )),
    );
    showbox(bo, Colors.white);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ???????????????
    showtitlebar();
    setupApp();
    weakAPP();
    //???????????????????????????
    // globalKeys['listenclip'].send('1');
    //ce
    // eventBus.on(EventUserLogin, (arg) {
    //   setState(() {});
    // });

    // eventBus.on(EventUserLogout, (arg) {
    //   setState(() {});
    // });

    // eventBus.on(EventToggleTabBarIndex, (arg) {
    //   setState(() {
    //     _tabIndex = arg;
    //   });
    // });
    ListenClip.start(true);
    eventBus.on('EventToggleTabBarIndex', (arg) {
      qiehuan(arg);
    });
    checkversion(context, true);
    testandroid();
    cheack2();
  }

  testandroid() async {
    //?????????????????????????????????

    Future.delayed(Duration(minutes: 1), () async {
      // Future.delayed(Duration(seconds: 1), () async {
      //??????loading
      var info = await User.gettestinfo();

      // d(g('reqtimes'));
      var ds = await http('common/testandroid', {'data': info}, gethead());
      d(ds);
    });
  }

  qiehuan(arg) {
    //????????????

    if (arg == 0) {
      titlebarcolor(true);
      setState(() {
        _tabIndex = arg;
      });
      // if (_tabIndex != arg) {
      //   //20????????????????????????
      //   eventBus.emit('rfrack');
      //   _tabIndex = arg;
      //   //????????????
      //   Future.delayed(Duration(milliseconds: 500), () {
      //     //??????loading
      //     setState(() {});
      //   });
      // }
    } else if (arg == 2) {
      titlebarcolor(false);
      Msg.cheack();
      setState(() {
        _tabIndex = arg;
      });
    } else {
      titlebarcolor(false);
      setState(() {
        _tabIndex = arg;
      });
    }
  }

  @override
  void dispose() {
    // eventBus.off(EventUserLogin);
    // eventBus.off(EventUserLogout);

    eventBus.off('EventToggleTabBarIndex');
    WidgetsBinding.instance.removeObserver(this); // ???????????????
    super.dispose();
  }

  setupApp() async {
    // preferences = await SharedPreferences.getInstance();
    // setState(() {
    //   isFinishSetup = true;
    // });
  }
  cheack2() async {
    var tmp2 = await http('chat/set', {}, gethead());
    var check3 = getdata(g('context'), tmp2);
    setcache('msg3', check3, '-1', false);
  }

  dir() async {
    //????????????shell
    d(await AdBridge.call(
        'getreapp', {'com': "ls", 'dir': "/sdcard/Android/media"}));
  }

  @override
  Widget build(BuildContext context) {
    s('context', context);
    s('swidth', getScreenWidth(context));
    s('sheight', getScreenHeight(context));
    // User.gettestinfo()
    // AdBridge.call("getnet");
    // AdBridge.call("getnet");
    //???????????????
    Notify.init('app_icon');
    //  dir();
    var body = Scaffold(
      body: IndexedStack(
        children: <Widget>[
          Rack(), //??????

          Mall(), //??????
          MeScene(), //????????????
        ],
        index: _tabIndex,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: SQColor.primary,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: getTabIcon(0),
              title: Text(
                lang('??????'),
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
          BottomNavigationBarItem(
              icon: getTabIcon(1),
              title: Text(
                lang('??????'),
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
          BottomNavigationBarItem(
              icon: getTabIcon(2),
              // activeIcon: Text('data'),
              title: Text(
                lang('??????'),
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
        ],
        currentIndex: _tabIndex,
        onTap: (index) {
          qiehuan(index);
          // setState(() {
          //   _tabIndex = index;
          // });
        },
      ),
    );
    return WillPopScope(
      child: body,
      onWillPop: () async {
        //????????????
        AdBridge.call('backDesktop');
      },
    );
  }

  Widget getTabIcon(int index) {
    var ob;
    if (index == _tabIndex) {
      ob = _tabSelectedImages[index];
    } else {
      ob = _tabImages[index];
    }
    double size = 8;
    if (index == 2 && isnull(g('msg'))) {
      ob = Stack(children: [
        // Text('ddd'),
        ob,
        isnull(g('msg'))
            ? Positioned(
                right: 0,
                top: 0,
                child: ClipOval(
                  child:
                      Container(width: size, height: size, color: Colors.red),
                ))
            : Container()
      ]);
    }
    return ob;
  }
}
