# 🚀 Virtual Catalog

**Virtual Catalog** is a modern and scalable digital catalog solution designed to empower businesses with an elegant online presence and a robust administrative panel. Built with **Flutter** and powered by **Firebase**, this platform offers a seamless user experience and simplified inventory management.

---

## 📋 Table of Contents
- [Core Features](#-core-features)
- [Tech Stack](#%EF%B8%8F-tech-stack)
- [Project Architecture](#-project-architecture)
- [Project Views](#-project-views)
- [Installation & Setup](#-installation--setup)
- [Next Steps (ToDo)](#-next-steps-todo)

---

## ✨ Core Features

### For Customers (Frontend)
- **Dynamic Catalog**: Fluid product browsing with optimized loading.
- **Product Details**: Technical information, variants, and image galleries.
- **Shopping Cart**: Intuitive order management.
- **Integrated Checkout**: Structured order generation for direct contact (e.g., WhatsApp).

### For Administrators (Backend)
- **Admin Panel**: Centralized management of products and configurations.
- **Product CRUD**: Create, edit, and delete products with full variant support.
- **Security**: Robust authentication via Firebase Auth.
- **Media Management**: Cloudinary integration for efficient image handling.

---

## 🛠️ Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (SDK ^3.10.7)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Navigation**: [Go Router](https://pub.dev/packages/go_router)
- **Backend / Database**: [Firebase Firestore](https://firebase.google.com/)
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth)
- **Image Hosting**: [Cloudinary](https://cloudinary.com/) (via API/Dio)
- **Styling**: Google Fonts & Font Awesome

---

## 🏗️ Project Architecture

The project follows a structure inspired by **Clean Architecture** and **DDD (Domain-Driven Design)**, ensuring scalability and ease of maintenance:

```text
lib/
├── config/           # Global configurations (Routes, Themes, Firebase)
├── data/             # Repository and Datasource implementations
├── domain/           # Entities and Repository interface definitions
├── presentation/     # UI (Screens, Widgets, Providers)
└── main.dart         # Application entry point
```

---

## 📸 Project Views

> [!NOTE]
> This section requires uploading real screenshots for a professional presentation.

| Catalog View | Product Detail | Admin Panel |
|:---:|:---:|:---:|
| ![Catalog Placeholder](https://via.placeholder.com/300x600?text=Catalog+View) | ![Detail Placeholder](https://via.placeholder.com/300x600?text=Product+Detail) | ![Admin Placeholder](https://via.placeholder.com/300x600?text=Admin+Panel) |

---

## 🚀 Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-user/virtual-catalog.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**:
   Create a `.env` file in the project root with the following keys:
   ```env
   CLOUDINARY_URL=your_url
   API_KEY=your_api_key
   # Add other necessary variables
   ```

4. **Run the project**:
   ```bash
   flutter run
   ```

---

## 📝 Next Steps (ToDo)

This section outlines the pending functionalities identified for the project's evolution:

### 🖼️ Visual Documentation
- [ ] **Screenshots**: Replace the placeholders above with real application captures from mobile and web devices.

### 🏢 Administrative Panel (Technical Backlog)
- [ ] **Main Dashboard**: Implement product view analytics and order metrics (currently "Coming Soon").
- [ ] **Banner Management**: Finalize the `/banners` view to allow admins to change the home page carousel.
- [ ] **Business Configuration**: Implement `/settings` to edit contact info, social media links, and business hours.

### 🛠️ UX & Optimization
- [ ] **Dynamic SEO**: Use `flutter_web_plugins` to improve search engine indexing for individual product pages.
- [ ] **Advanced Validations**: Refine product creation forms with improved tactile and visual feedback.
- [ ] **Offline Mode**: Implement basic local persistence for offline browsing.

---

Developed with ❤️ by **André**
