import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/user_role_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class SetRoleDialog extends StatelessWidget {
  const SetRoleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(S.of(context).selectRoleDialogLabel),
      children: [
        SimpleDialogOption(
          child: Text(S.of(context).roleCoachLabel),
          onPressed: () => Navigator.pop(context, UserRoleEntity.coach),
        ),
        SimpleDialogOption(
          child: Text(S.of(context).roleStudentLabel),
          onPressed: () => Navigator.pop(context, UserRoleEntity.student),
        )
      ],
    );
  }
}
