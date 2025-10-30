import 'package:chat_app/features/chat/widgets/input_toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'toast_provider.g.dart';

@riverpod
class ToastNotifier extends _$ToastNotifier {
  @override
  InputToast? build() {
    return null;
  }

  void setToast(InputToast? toast) => state = toast;
  InputToast? getToast() => state;
}
