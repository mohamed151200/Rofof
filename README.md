# 📚 Rofof – Advanced E-Library App

**Rofof** is a high-performance, cross-platform e-library application built with Flutter. It provides a seamless reading experience by integrating the **Google Books API** with a robust **Firebase backend**, focusing on data integrity, offline resilience, and personalized user experiences.

---

## 🚀 Key Technical Features

### 🔍 1. Smart Search Engine
Engineered a sophisticated search system that prioritizes user speed and data efficiency:
* **Live Suggestions:** Real-time search-as-you-type functionality.
* **LRU Search History:** Implemented **Least Recently Used (LRU) Logic** to manage search history, ensuring that the most relevant and recent searches are always at the top.
* **Debounced Requests:** Optimized API calls to reduce server load and improve performance.

### 🔄 2. Real-time Cloud Synchronization
Ensured a consistent experience across multiple devices and accounts:
* **Multi-User Profiles:** Dedicated settings and favorites for each Google account using **Firebase Authentication**.
* **Preference Sync:** Themes (Dark/Light mode) and Language settings are synced to **Cloud Firestore**, allowing users to find their environment ready on any device.
* **Data Integrity:** Seamlessly merging local state with cloud data.

### 📶 3. Offline-First Architecture
Designed to work flawlessly in unreliable network conditions:
* **Local Persistence:** Leveraged **sqflite** for caching heavy book data and **GetStorage** for lightweight user preferences.
* **Background Sync:** Actions performed offline (like adding to favorites) are queued and automatically synchronized once the connection is restored.
* **Seamless UX:** Users can browse cached content and history without interruption during network outages.

### 🧠 4. State Management & Architecture
* **GetX Expertise:** Utilized GetX for reactive UI updates, efficient dependency injection, and clean route management.
* **Performance Optimization:** Implemented a **10-by-10 Pagination** strategy using **Dio** to fetch data in chunks, significantly reducing initial load times and memory consumption.
* **Clean Code:** Adhered to OOP principles and clean architecture to ensure the codebase is maintainable and scalable.

---

## 🛠 Tech Stack
* **Frontend:** Flutter & Dart
* **State Management:** GetX
* **Backend:** Firebase (Firestore, Auth)
* **Networking:** Dio (REST API)
* **Local Database:** sqflite & GetStorage
* **Utilities:** Google Sign-In, Localization (En/Ar)

---

## 📺 Demo Videos

| 🌐 Cloud Sync & Preferences | 📱 Offline-First Logic |
|---|---|
| <video src="https://github.com/mohamed151200/Rofof/blob/main/assets/videos/sync%20fav.mp4" width="350"> | <video src="https://github.com/mohamed151200/Rofof/blob/main/assets/videos/offline.mp4" width="350"> |

| 🔍 Smart Search Engine | 👥 Multi-Account Isolation |
|---|---|
| <video src="https://github.com/mohamed151200/Rofof/blob/main/assets/videos/searching%20history.mp4" width="350"> | <video src="https://github.com/mohamed151200/Rofof/blob/main/assets/videos/sync%20settings.mp4" width="350"> |

---

## 👷 Technical Challenges & Solutions
* **Challenge:** Handling data conflicts when the user switches accounts.
* **Solution:** Implemented a reactive listener that clears local cache and re-fetches preferences based on the new `UID` from Firebase Auth.

---

## ✉️ Contact
**Mohamed Khaled Saleh** *Computer and Systems Engineer* [LinkedIn](https://www.linkedin.com/in/mohamed-khaled-saleh-328438344/) | [Email](mailto:mohamedkhaledsaleh314@gmail.com)