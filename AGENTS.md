# AGENTS.md instructions for SoulNum

## Agent Flutter Local Pack
This project uses local instructions installed at `.codex`.

### Available skills
- dart-best-practices: General purity standards for Dart development. (file: .codex/skills/dart-best-practices/SKILL.md)
- dart-language-patterns: Modern Dart standards (3.x+) including null safety and patterns. (file: .codex/skills/dart-language-patterns/SKILL.md)
- dart-model-reuse: Guides model reuse/composition and safe extension. Invoke when adding/updating UI/domain models or preventing duplicate screen-specific models. (file: .codex/skills/dart-model-reuse/SKILL.md)
- dart-tooling-ci: Standards for analysis, linting, formatting, and automation. (file: .codex/skills/dart-tooling-ci/SKILL.md)
- flutter-assets-management: Standards for asset naming, organization, and synchronization with design tools. (file: .codex/skills/flutter-assets-management/SKILL.md)
- flutter-bloc-state-management: Standards for predictable state management using flutter_bloc and equatable. Invoke when implementing BLoCs/Cubits, Events, States, or refactoring page widgets into components. (file: .codex/skills/flutter-bloc-state-management/SKILL.md)
- flutter-dependency-injection-injectable: Standards for dependency injection using GetX Bindings and Service Locator. (file: .codex/skills/flutter-dependency-injection-injectable/SKILL.md)
- flutter-error-handling: No description (file: .codex/skills/flutter-error-handling/SKILL.md)
- flutter-navigation-manager: Routing strategy management (GetX is the Project Standard). (file: .codex/skills/flutter-navigation-manager/SKILL.md)
- flutter-standard-lib-src-architecture: No description (file: .codex/skills/flutter-standard-lib-src-architecture/SKILL.md)
- flutter-standard-lib-src-architecture-dependency-rules: Dependency flow and separation of concerns for the project (UI -> BLoC -> Repository). (file: .codex/skills/flutter-standard-lib-src-architecture-dependency-rules/SKILL.md)
- flutter-ui-widgets: Principles for maintainable UI components and project-specific widget standards. (file: .codex/skills/flutter-ui-widgets/SKILL.md)
- getx-localization-standard: Standards for GetX-based multi-language (locale_key + lang_*.dart). Invoke when generating a new page/feature or adding any user-facing text. (file: .codex/skills/getx-localization-standard/SKILL.md)
- ui-documentation-workflow: Generates and maintains spec/ui-workflow.md for UI flows. Invoke when creating/modifying features or when asked to update documentation. (file: .codex/skills/ui-documentation-workflow/SKILL.md)

### Available rules
- ci-cd-pr.md (file: .codex/rules/ci-cd-pr.md)
- integration-api.md (file: .codex/rules/integration-api.md)
- ui-refactor-convert.md (file: .codex/rules/ui-refactor-convert.md)
- ui.md (file: .codex/rules/ui.md)
- unit-test.md (file: .codex/rules/unit-test.md)
- widget-test.md (file: .codex/rules/widget-test.md)

### Trigger rules
- If a task clearly matches a skill description, apply that skill first.
- Apply matching rule files before making code changes.
- Keep generated docs/specs updated when UI or API behavior changes.

### Location policy
- Project root: /Users/uranidev/Documents/GitHub/SoulNum
- Local pack root: `.codex`
