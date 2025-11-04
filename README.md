# SynFin

SynFin is an AI-driven loan automation platform built on a multi-agent architecture. It combines intelligent decision-making, real-time context sharing, and seamless orchestration to automate the entire loan journey — from application to approval — while delivering a fast, human-like experience.

Key highlights:
- AI-driven loan automation: end-to-end workflow automation from application to sanction.
- Multi-agent architecture: a MasterAgent orchestrates specialized worker agents (KYC, credit scoring, underwriting, docs, sanctioning) that share context in real time.
- Human-like conversational experience: chat-driven interactions and status updates that feel natural to customers and agents.
- Integration-ready: designed to connect with backend AI services, credit bureaus, and document verification APIs.
- Mobile-first UI: demo and prototype mobile clients (Flutter) with local mocks for testing orchestration and UX.

Demo video: https://youtu.be/TGuGiL23uPU

Related repositories
- Frontend web (historic): https://github.com/MumbaiHacks-NeoMind/Savify-Website.git
- Backend (AI services): https://github.com/MumbaiHacks-NeoMind/Savify-Backend.git

## Quick links
- Architecture: `ARCHITECTURE.md`
- More docs: `docs/README.md`

## Tech stack
- Flutter (see `pubspec.yaml`) — app framework
- State management: Provider
- Storage: SharedPreferences, sqflite
- Charts: fl_chart
- Fonts: google_fonts
- HTTP client: http

The project `pubspec.yaml` shows SDK constraint: Dart SDK ^3.9.2.

## What is included
- Mobile app UI (Android & iOS) — demo client and chat UI
- Multi-agent orchestrator and worker agents (local mocks) in `lib/services/`
- End-to-end loan workflow demonstrations (application intake, KYC mock, credit-check mock, underwriting mock, sanction letter mock)
- Integration points and example clients for backend AI services and APIs

## Getting started (development)
1. Install Flutter (matching the project's SDK). See https://docs.flutter.dev/get-started/install
2. Clone the repo:

```bash
git clone https://github.com/nidhisingh5958/SynFin.git
cd SynFin
```

3. Get packages:

```bash
flutter pub get
```

4. Run on a connected device or simulator:

```bash
flutter run
```

Tips:
- To run Android: start an emulator or connect a device, then `flutter run`.
- To run iOS (macOS): open `ios/Runner.xcworkspace` in Xcode or use `flutter run` with a simulator.

## Project layout (short)

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management (Provider)
├── screens/                  # UI screens (home, transactions, AI chat, chatbot)
├── services/                 # Business logic (AI client + local mocks)
└── widgets/                  # Reusable widgets
```

See `ARCHITECTURE.md` and `docs/` for more detail about data flow and AI integration.

## Multi-agent loan automation (core)
The core of SynFin is a multi-agent system that models the loan lifecycle via a MasterAgent that coordinates specialized worker agents. This codebase includes a local, test-friendly implementation used to prototype and validate orchestration and conversational UX.

Key files (local mock / prototype):
- `lib/services/worker_agents.dart` — mocked worker agents (KYC, credit checks, underwriting, document handling)
- `lib/services/agent_master.dart` — MasterAgent that orchestrates worker agents and manages context propagation
- `lib/screens/chatbot_screen.dart` — chat UI used to interact with agents and show live status updates

Notes:
- The included agents are mocks intended for local testing and UI validation. When wiring to production, replace or extend these modules to call real services (credit bureaus, identity verification, underwriting engines, document managers).

## Running tests & lint
- Unit/widget tests: `flutter test`
- Lint/analyze: `flutter analyze`

## Contributing
- Please file issues or pull requests.
- Follow existing code style (see `analysis_options.yaml`) and add tests for new behavior.

## License
This repository includes a `LICENSE` file in the project root. Follow its terms for reuse.

## Contact
Open issues on GitHub for questions, feature requests, or bug reports.

---

Made with ❤️ using Flutter
