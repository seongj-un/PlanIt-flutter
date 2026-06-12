import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';
import '../controllers/my_page_controller.dart';

class MyPagePage extends ConsumerStatefulWidget {
  const MyPagePage({super.key});

  @override
  ConsumerState<MyPagePage> createState() => _MyPagePageState();
}

class _MyPagePageState extends ConsumerState<MyPagePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(myPageControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageControllerProvider);
    final userProfile = state.userProfile;

    if (state.isLoading && userProfile == null) {
      return const AppScaffold(
        body: AppLoadingView(
          title: '내 정보 불러오는 중',
          message: '프로필과 설정을 준비하고 있어요.',
        ),
      );
    }

    if (userProfile == null) {
      return AppScaffold(
        body: AppLoadingView(
          title: '내 정보를 불러올 수 없어요',
          message: state.errorMessage ?? '잠시 후 다시 시도해주세요.',
          isLoading: false,
          actionLabel: '다시 시도',
          onAction: () {
            ref.read(myPageControllerProvider.notifier).load(forceRefresh: true);
          },
        ),
      );
    }

    return AppScaffold(
      body: ListView(
        children: [
          SectionCard(
            title: userProfile.name,
            subtitle: userProfile.email ?? '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '하루 공부 시간 ${userProfile.usualStudyHoursPerDay ?? '-'}시간',
                ),
                const SizedBox(height: 6),
                Text('선호 학습 방식 ${userProfile.preferredStudyMethod ?? '-'}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: '공부 설정',
            onTap: () => context.go(RoutePaths.myPageStudySettings),
          ),
          const SizedBox(height: 10),
          _MenuButton(
            label: '알림 설정',
            onTap: () => context.go(RoutePaths.myPageNotificationSettings),
          ),
          const SizedBox(height: 10),
          _MenuButton(
            label: '계정 설정',
            onTap: () => context.go(RoutePaths.myPageAccountSettings),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              final success = await ref.read(myPageControllerProvider.notifier).logout();
              if (!context.mounted || !success) return;
              context.go(RoutePaths.welcome);
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
