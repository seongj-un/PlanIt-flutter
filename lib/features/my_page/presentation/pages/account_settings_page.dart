import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/my_page_controller.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(myPageControllerProvider).userProfile?.name ?? '',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageControllerProvider);

    return AppScaffold(
      title: '계정 설정',
      body: ListView(
        children: [
          AppTextField(
            controller: _nameController,
            label: '이름',
            hintText: '김민지',
            enabled: !state.isSaving,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _passwordController,
            label: '새 비밀번호',
            hintText: 'NewP@ssw0rd!',
            enabled: !state.isSaving,
            obscureText: true,
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
              final success = await ref.read(myPageControllerProvider.notifier).saveAccountSettings(
                name: _nameController.text,
                password: _passwordController.text,
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
