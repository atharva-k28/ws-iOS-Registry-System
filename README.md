# Registry Together — iOS

> AI-powered collaborative registry platform for weddings, baby showers, housewarmings, birthdays & special events.

A premium SwiftUI starter template built with **MVVM + Supabase + Async/Await**, designed to feel like a luxury ecommerce experience.

---

## ✨ Design Direction

Inspired by **Apple Store**, **Airbnb**, **Arc Browser**, **Notion Mobile**, and premium home & kitchen retail aesthetics.

### Color Palette
| Token | Hex | Usage |
|---|---|---|
| Primary Dark | `#252525` | Featured cards, premium sections |
| Accent Red | `#FF362D` | CTAs, highlights, AI badges |
| Background Gray | `#EFEFEF` | Primary surfaces (65%) |
| White | `#FFFFFF` | Cards, content areas |
| Secondary Gray | `#898989` | Captions, metadata |

### Design Language
- Large Apple-style typography (SF Pro)
- Rounded corners (24–30pt radius)
- Soft premium shadows
- Floating tab bar with matched geometry animation
- Clean card layouts with subtle gradients
- Breathable, luxurious spacing

---

## 📁 Project Structure

```
iOS_Registry_System/
├── App/                          # App entry, state, routing
│   ├── iOS_Registry_SystemApp.swift
│   ├── AppState.swift
│   └── AppRouter.swift
│
├── Core/                         # Shared design system & utilities
│   ├── Theme/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── Shadows.swift
│   ├── Constants/
│   │   └── Constants.swift
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   └── Date+Extensions.swift
│   └── Helpers/
│       └── Helpers.swift
│
├── Models/                       # Codable data models
│   ├── User.swift
│   ├── Event.swift
│   ├── Product.swift
│   ├── RegistryItem.swift
│   └── Contribution.swift
│
├── Services/                     # Business logic services
│   ├── AuthService.swift
│   ├── EventService.swift
│   ├── ProductService.swift
│   └── AIService.swift
│
├── Networking/
│   └── Supabase/
│       ├── SupabaseConfig.swift
│       └── SupabaseManager.swift
│
├── ViewModels/                   # MVVM view models (@Observable)
│   ├── Auth/AuthViewModel.swift
│   ├── Home/HomeViewModel.swift
│   ├── Events/EventsViewModel.swift
│   ├── Friends/FriendsViewModel.swift
│   └── Profile/ProfileViewModel.swift
│
├── Views/                        # SwiftUI views
│   ├── Auth/AuthLandingView.swift
│   ├── Home/HomeView.swift
│   ├── Events/MyEventsView.swift
│   ├── Friends/FriendsView.swift
│   ├── Profile/ProfileView.swift
│   ├── TabBar/MainTabBar.swift
│   └── Shared/Components/
│       ├── Buttons/PrimaryButton.swift
│       ├── Cards/
│       │   ├── EventCard.swift
│       │   ├── ProductCard.swift
│       │   └── ContributionProgressBar.swift
│       └── Loaders/LoadingView.swift
│
├── Resources/
│   ├── Fonts/
│   └── MockData/MockData.swift
│
└── Assets.xcassets/
```

---

## 🧱 Architecture

| Layer | Pattern | Notes |
|---|---|---|
| **UI** | SwiftUI + NavigationStack | iOS 17+ |
| **State** | `@Observable` | Modern observation |
| **Architecture** | MVVM | Clean separation |
| **Backend** | Supabase (SPM) | Auth, DB, Realtime |
| **Async** | Swift Concurrency | async/await throughout |
| **Navigation** | Manual tab routing | Floating tab bar overlay |

---

## 🚀 Getting Started

1. **Open** `iOS_Registry_System.xcodeproj` in Xcode
2. **Wait** for Supabase SPM package to resolve
3. **Configure** your Supabase credentials in `SupabaseConfig.swift`
4. **Uncomment** the Supabase imports in `SupabaseManager.swift`
5. **Build & Run** on iOS 17+ simulator

> The app currently runs with mock data and bypasses auth for development.

---

## 🎨 Reusable Components

| Component | Description |
|---|---|
| `PrimaryButton` | 3 variants: accent, dark, outline with loading state |
| `EventCard` | Dark premium card with gradient, badge, countdown |
| `ProductCard` | Elegant product card with AI recommendation badge |
| `ContributionProgressBar` | Animated progress with currency labels |
| `LoadingView` | Animated dot loading + inline variant |
| `MainTabBar` | Floating tab bar with matched geometry animation |

---

## 📝 Next Steps

- [ ] Implement Supabase auth (email + Apple Sign In)
- [ ] Build full event creation flow
- [ ] Implement AI recommendation engine
- [ ] Add product detail views
- [ ] Build contribution/payment flow
- [ ] Add real-time event updates
- [ ] Implement friend invitations
- [ ] Add push notifications
- [ ] Polish animations & transitions

---

**Built with** SwiftUI · MVVM · Supabase · Swift Concurrency