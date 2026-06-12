import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../domain/model/plan_generation_input.dart';
import '../controllers/plan_generation_controller.dart';

class PlanGenerationLoadingPage extends ConsumerStatefulWidget {
  const PlanGenerationLoadingPage({this.initialInput, super.key});

  final PlanGenerationInput? initialInput;

  @override
  ConsumerState<PlanGenerationLoadingPage> createState() =>
      _PlanGenerationLoadingPageState();
}

class _PlanGenerationLoadingPageState
    extends ConsumerState<PlanGenerationLoadingPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref
          .read(planGenerationControllerProvider.notifier)
          .initialize(initialInput: widget.initialInput);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PlanGenerationState>(planGenerationControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted || previous?.phase == next.phase) {
        return;
      }

      if (next.phase == PlanGenerationPhase.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(RoutePaths.home);
          }
        });
      }

      if (next.phase == PlanGenerationPhase.failed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          final messenger = ScaffoldMessenger.of(context);
          final message = next.errorMessage ?? '플랜 생성 중 문제가 발생했어요.';
          messenger.showSnackBar(SnackBar(content: Text(message)));
          context.go(RoutePaths.subjectScope);
        });
      }
    });

    final state = ref.watch(planGenerationControllerProvider);
    final progressPercent = state.progressPercent;
    final message = state.message ?? '오늘 할 플랜을 계산하고 있어요.';

    return Scaffold(
      body: AppLoadingView(
        title: progressPercent == null
            ? '플랜 생성 중'
            : '플랜 생성 중 ${progressPercent.clamp(0, 100)}%',
        message: message,
      ),
    );
  }
}
