# Music Connect Mobile

Music Connect Mobile is a Flutter application built to bridge the gap between musicians and event contractors. This repository contains the mobile and web client (Flutter) for the Music Connect platform.

## Features

### Authentication
- User registration and login flows.
- Session cookie management customized for Flutter Web cross-origin requests.
- Support for two profile types: Artist (Artista) and Contractor (Contratante).

### Dashboard & Navigation
- A seamless global Bottom Navigation Bar for easy access to features.
- Quick statistical overviews on the main dashboard.

### Explore & Proposals
- **Contractors**: Can search for artists by name, city, or musical genre, and send direct proposals containing event details, dates, and financial offers.
- **Artists**: Can view a dedicated proposals panel where they can manage received offers.

### Profile Customization
- Modern UI for the user profile featuring a gradient header, overlapping avatar, and tab-based organization (About / Portfolio).
- Comprehensive edit mode featuring field validation (e.g., minimum character length, state abbreviation formatting, phone number patterns).

## System Flow & Backend Integration

This application relies on the **Music Connect Backend** (Node.js/Fastify) to function properly. 
The system flow works as follows:

1. **Authentication**: When a user registers or logs in, the app makes an HTTP request to the backend. The backend uses Better Auth to validate the credentials and responds with an HTTP-only session cookie.
2. **Session Persistence**: On the web, the browser automatically stores this cookie. The Flutter app uses a custom HTTP client with `withCredentials = true` so the browser attaches the session cookie to every subsequent request.
3. **Data Fetching**: Screens like Dashboard, Explore, and Profile fetch data directly from the backend API.
4. **Interactive Flows (e.g., Proposals)**: When a contractor sends a proposal, the mobile app sends a POST request to the backend, which validates the payload via Prisma and records the proposal. The target artist can then fetch their received proposals and update their status (accept/reject).

*Note: For everything to work, both the Backend API and the Flutter application must be running simultaneously.*

## Architecture & Technologies

- **Framework**: Flutter (compatible with Android, iOS, and Web).
- **State Management**: Provider (AuthProvider and PropostaProvider) used for reactive UI updates.
- **Networking**: Custom HTTP client using `http` package, designed to handle `withCredentials` in browser environments for secure cookie transmission.
- **Styling**: Google Fonts (Inter) and a custom dark theme design system built with specific color tokens matching the web frontend.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A running instance of the Music Connect Backend

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Music-Connect/Music-Connect-Flutter-2.git
   ```

2. Install dependencies:
   ```bash
   cd Music-Connect-Flutter-2
   flutter pub get
   ```

3. Run the application (Web Development):
   ```bash
   flutter run -d chrome --web-port 8080
   ```
   *Note: Port 8080 is required if testing locally against the backend to respect CORS origin policies.*

## Project Structure

- `lib/core/`: Contains models, global providers, constants, and network services.
- `lib/features/`: Contains feature-specific screens and logic (Dashboard, Explore, Login, Main, Profile, Proposals).
- `lib/shared/`: Reusable UI components, themes, and customized widgets (StatCard, ProposalCard, etc.).

## Development

When contributing or extending features, ensure you follow the existing state management patterns (Provider) and the application's dark theme design system found in `app_theme.dart`.
