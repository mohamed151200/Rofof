📚 Rofof (رفوف) - Personal Library Manager

A cross-platform mobile application built with Flutter that allows users to manage their book collections efficiently with full offline support and real-time cloud synchronization.
🏗️ Technical Architecture & Engineering Decisions

As a Systems and Computer Engineer, I built this app with scalability and performance in mind:

    State Management: Utilized GetX for high-performance reactive programming and clean dependency injection.

    Persistent Storage: Implemented a hybrid data strategy:

        Local: Sqflite for lightning-fast offline access.

        Cloud: Firebase Firestore for real-time synchronization across multiple devices.

    Authentication & Security: Integrated Firebase Auth with a custom Email Verification flow and a persistent "Remember Me" logic using GetStorage.

    Networking: Used Dio with specialized interceptors for robust API communication.

🛠️ Advanced Logic Implementation
1. Robust "Remember Me" System

Unlike basic implementations, Rofof handles the synchronization between Firebase Auth Sessions and Local Storage Preferences.

    The Logic: If a user chooses not to be remembered, the app ensures the Firebase session is terminated (signOut) on the next launch to prevent unauthorized access, even if the token hasn't expired.

2. Dual-Layer Sync Strategy

To ensure data integrity, I implemented a unique mapping system where each local SQLite record is indexed by the Firebase UID, allowing for seamless merging when the device comes back online.
3. Error Handling & UX

Integrated AwesomeDialog for professional feedback loops, covering all FirebaseAuthException cases (e.g., weak-password, email-already-in-use) with appropriate visual cues.
🚀 Future Roadmap

    [ ] Add book barcode scanning.

    [ ] Social features to share reading lists.

    [ ] Dark Mode enhancement.

👨‍💻 About the Developer

Mohamed Systems and Computer Engineer | Mobile App Developer [Your LinkedIn Profile Link] | [Your Portfolio Link]