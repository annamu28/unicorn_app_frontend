
import 'package:unicorn_app_frontend/views/constants/strings.dart';
import 'package:unicorn_app_frontend/views/dialogs/alert_dialog_model.dart';

class LogoutDialog extends AlertDialogModel<bool> {
  const LogoutDialog()
      : super(
          title: Strings.logOut,
          message: Strings.areYouSureThatYouWantToLogOutOfTheApp,
          buttons: const {
            Strings.cancel: false,
            Strings.logOut: true,
          },
        );
}