import 'package:flutter/material.dart';
import '../controllers/base_controller.dart';

abstract class BaseView<T extends BaseController> extends StatefulWidget {
  const BaseView({super.key});

  T createController();
}

abstract class BaseViewState<T extends BaseController, V extends BaseView<T>>
    extends State<V> {
  late T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.createController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Scaffold(
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.error != null
                  ? _buildErrorWidget()
                  : buildView(context, controller),
        );
      },
    );
  }

  Widget buildView(BuildContext context, T controller);

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.clearError(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
