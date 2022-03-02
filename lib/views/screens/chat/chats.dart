import 'package:flutter/material.dart';
import 'package:project/views/screens/chat/group_chat/group_chat.dart';
import 'package:project/util/data.dart';
import 'package:project/views/screens/group/all_groups.dart';
import 'package:project/views/screens/group/creation.dart';

import 'one_to_one/dialouges.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  int tab = 0;
  Widget groupCaht = AllGroups();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);
    _tabController.addListener(() {
      setState(() {
        tab = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration.collapsed(
              hintText: 'Search', hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          isScrollable: false,
          tabs: <Widget>[
            Tab(
              text: "Message",
            ),
            Tab(
              text: "Groups",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          DialogueScreen(),
          groupCaht,
        ],
      ),
      floatingActionButton: tab == 1
          ? FloatingActionButton(
              backgroundColor: Color(0xff3E236E),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                if (_tabController.index == 1) {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateGroupScreen()))
                      .then((value) {});
                }
              },
            )
          : Container(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
