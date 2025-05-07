import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/option_chain/screens/option_chain_config.dart';
import 'package:flutter/material.dart';

Future<AddOptionChainTask?> showOptionChainDialog({
  required BuildContext context,
  AddOptionChainTask? initialTask,
}) async {
  return showDialog<AddOptionChainTask>(
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