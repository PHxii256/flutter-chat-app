import 'package:bloc/bloc.dart';
import 'package:chat_app/features/chat/widgets/input_toast.dart';

class ToastCubit extends Cubit<InputToast?> {
  ToastCubit() : super(null);

  void setToast(InputToast? toast) => emit(toast);

  InputToast? getToast() => state;

  void clearToast() => emit(null);
}
