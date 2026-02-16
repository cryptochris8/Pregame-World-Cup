import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Groups tab content for the World Cup home screen.
/// Displays all 12 group standings tables in a scrollable list.
class GroupsTab extends StatelessWidget {
  final void Function(String) onTeamTap;

  const GroupsTab({super.key, required this.onTeamTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<GroupStandingsCubit, GroupStandingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<GroupStandingsCubit>().loadGroups(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(l10n.retry),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.groups.isEmpty) {
          return Center(
            child: Text(
              l10n.noGroupDataAvailable,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<GroupStandingsCubit>().refreshGroups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return StandingsTable(
                group: group,
                compact: true,
                onTeamTap: (teamCode) => () => onTeamTap(teamCode),
              );
            },
          ),
        );
      },
    );
  }
}
