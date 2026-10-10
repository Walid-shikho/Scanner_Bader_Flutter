import '../models/onboarding_model.dart';

class OnboardingService {
  List<OnboardingModel> getPages() => const [
        OnboardingModel(
          title: 'onboarding_1_title',
          description: 'onboarding_1_description',
        ),
        OnboardingModel(
          title: 'onboarding_2_title',
          description: 'onboarding_2_description',
        ),
        OnboardingModel(
          title: 'onboarding_3_title',
          description: 'onboarding_3_description',
        ),
      ];
}
