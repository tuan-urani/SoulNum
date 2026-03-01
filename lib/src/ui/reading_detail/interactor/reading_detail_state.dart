import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class ReadingDetailState extends Equatable {
  const ReadingDetailState({
    required this.pageState,
    this.reading,
    this.errorMessage,
    this.featureKey,
    this.titleKey,
  });

  final PageState pageState;
  final ReadingModel? reading;
  final String? errorMessage;
  final String? featureKey;
  final String? titleKey;

  ReadingDetailState copyWith({
    PageState? pageState,
    ReadingModel? reading,
    String? errorMessage,
    String? featureKey,
    String? titleKey,
  }) {
    return ReadingDetailState(
      pageState: pageState ?? this.pageState,
      reading: reading ?? this.reading,
      errorMessage: errorMessage,
      featureKey: featureKey ?? this.featureKey,
      titleKey: titleKey ?? this.titleKey,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pageState,
        reading,
        errorMessage,
        featureKey,
        titleKey,
      ];
}

