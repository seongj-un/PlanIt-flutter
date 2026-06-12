import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/my_page_controller.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _dailyReminderEnabled = true;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: '20:00');
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageControllerProvider);

    return AppScaffold(
      title: '알림 설정',
      body: ListView(
        children: [
          SwitchListTile(
            value: _dailyReminderEnabled,
            onChanged: state.isSaving
                ? null
                : (value) => setState(() => _dailyReminderEnabled = value),
            title: const Text('매일 알림 받기'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _timeController,
            label: '알림 시간',
            hintText: '20:00',
            enabled: !state.isSaving,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: '저장',
            isLoading: state.isSaving,
            onPressed: () async {
              final success = await ref
                  .read(myPageControllerProvider.notifier)
                  .saveNotificationSettings(
                    dailyReminderEnabled: _dailyReminderEnabled,
                    dailyReminderTime: _timeController.text,
                  );
              if (!context.mounted || !success) return;
              context.go(RoutePaths.myPage);
            },
          ),
        ],
      ),
    );
  }
}
