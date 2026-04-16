import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/matches_tab.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/groups_tab.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/teams_tab.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/favorites_tab.dart';
import 'package:pregame_world_cup/presentation/screens/player_spotlight_screen.dart';
import 'package:pregame_world_cup/presentation/screens/manager_profiles_screen.dart';

void main() {
  group('TabBarView pages use AutomaticKeepAliveClientMixin', () {
    test('MatchesTab is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      final widget = MatchesTab(onMatchTap: (_) {});
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'MatchesTab State should mix in AutomaticKeepAliveClientMixin');
    });

    test('GroupsTab is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      final widget = GroupsTab(onTeamTap: (_) {});
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'GroupsTab State should mix in AutomaticKeepAliveClientMixin');
    });

    test('TeamsTab is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      final widget = TeamsTab(onTeamTap: (_) {});
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'TeamsTab State should mix in AutomaticKeepAliveClientMixin');
    });

    test('PlayerSpotlightScreen is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      const widget = PlayerSpotlightScreen();
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'PlayerSpotlightScreen State should mix in AutomaticKeepAliveClientMixin');
    });

    test('ManagerProfilesScreen is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      const widget = ManagerProfilesScreen();
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'ManagerProfilesScreen State should mix in AutomaticKeepAliveClientMixin');
    });

    test('FavoritesTab is a StatefulWidget whose State uses AutomaticKeepAliveClientMixin', () {
      final widget = FavoritesTab(onMatchTap: (_) {}, onTeamTap: (_) {});
      expect(widget, isA<StatefulWidget>());

      final state = widget.createState();
      expect(state, isA<AutomaticKeepAliveClientMixin>(),
          reason: 'FavoritesTab State should mix in AutomaticKeepAliveClientMixin');
    });
  });
}
