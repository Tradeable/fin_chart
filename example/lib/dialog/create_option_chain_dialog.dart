import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/option_chain/screens/option_chain_config.dart';
import 'package:flutter/material.dart';

Future<CreateOptionChainTask?> showOptionChainDialog({
  required BuildContext context,
  CreateOptionChainTask? initialTask,
}) async {
  return showDialog<CreateOptionChainTask>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: OptionChainPage(
          isDialog: true,
          initialTask: initialTask,
        ),
      );
    },
  );
} 