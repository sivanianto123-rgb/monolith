# Monolith

A 3D sneaker configurator and e-commerce demo built with Flutter Web and Firebase.

## Overview

Monolith is a portfolio project: a fictional made-to-order sneaker brand's storefront, built to show a real Flutter Web app wired to a real backend rather than a static UI mockup. You can browse a small catalog, spin a sneaker in an actual `<model-viewer>` 3D scene, recolor it panel by panel, check out through a dummy payment flow, and — once signed in with a real Firebase Auth account — see your saved designs and order history come back from Firestore across page reloads.

**Live demo:** _(placeholder — will add the live `monolith.web.app` URL once hosting is deployed)_

## Features

- **3D product configurator** — a real `<model-viewer>` scene (via [`model_viewer_plus`](https://pub.dev/packages/model_viewer_plus)) that you can drag to rotate. You pick one of 5 panels (upper, sole, stripe, laces, toe) and apply a shade from a curated swatch palette. The three source `.glb` models each bake in a single fixed colorway with no separable per-part material slots, so rather than truly recoloring materials live in the scene, the viewer swaps to whichever of the three baked models is the closest overall color match to your current build — an intentional simplification, not a bug.
- **Product catalog with category filtering** — a shop grid over a small fixed catalog (3 sneakers), filterable by category (Running / Lifestyle / Court), plus a detail page per product.
- **Cart and checkout** — a cart persisted locally via `shared_preferences`, and a checkout screen with a shipping form and a Razorpay-styled payment sheet. **This is a demo/dummy payment flow**: the sheet's card/UPI/netbanking fields are static and unread, "paying" just runs a fake processing delay, and no real payment processor is involved or money moved.
- **Firebase Authentication** — email/password sign-up and sign-in, plus Google sign-in (a popup flow on Web via `signInWithPopup`, the native `google_sign_in` flow on mobile).
- **Saved designs and order history** — per-user Firestore collections (`users/{uid}/savedDesigns`, `users/{uid}/orders`), enforced by Firestore security rules that check ownership and validate document shape. Designs are create/delete-only (no in-place edits); orders are immutable once placed.
- **Auth-gated routes** — `/checkout` and `/orders` redirect a signed-out visitor to `/auth` and back to where they were headed once they sign in, via a `go_router` redirect wired to Firebase's auth state stream.

## Tech stack

- **Flutter (Web)** — Dart SDK `^3.13.3`; the project was created against Flutter 3.47.4 stable (see `.metadata`)
- [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) — state management (auth, cart, the configurator, and Firestore-backed streams)
- [`go_router`](https://pub.dev/packages/go_router) — routing, including the auth-gated redirects above
- **Firebase** — `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`, and Firebase Hosting for deployment
- [`model_viewer_plus`](https://pub.dev/packages/model_viewer_plus) — the 3D sneaker viewer/configurator
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — local cart persistence
- [`google_fonts`](https://pub.dev/packages/google_fonts) — the Archivo family used throughout the UI
- [`visibility_detector`](https://pub.dev/packages/visibility_detector) — scroll-triggered fade/slide-in reveals for sections and grid items
- [`intl`](https://pub.dev/packages/intl) — date formatting on the orders screen

## Getting started

Prerequisites:

- Flutter SDK 3.47.x (stable channel)
- A [Firebase](https://firebase.google.com/) project of your own
- [Firebase CLI](https://firebase.google.com/docs/cli) and the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) installed

```bash
git clone <this repo>
cd monolith
flutter pub get
```

This repo's `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` are checked in, but they point at the author's own Firebase project (`monolithe-sneaker`) — they won't work for anyone else. To run against a Firebase project you control:

```bash
flutterfire configure
```

Then, in the Firebase console for your project, enable **Email/Password** and **Google** under Authentication → Sign-in method (both are required for the auth screen to work).

Run it:

```bash
flutter run -d chrome
```

To develop against the local Firebase emulators instead of a live project:

```bash
firebase emulators:start
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

## Project structure

```
lib/
  core/
    data/models/    Plain data classes: Product, CartItem, SavedDesign, ShippingInfo, PartColors
    firebase/        AuthService and FirestoreService wrappers around the Firebase SDKs
    state/            Riverpod providers: auth, cart, the configurator, Firestore-backed streams
    theme/            Design-system widgets (buttons, cards, marquee, the 3D viewer, ...) and app-wide theming
    router/           The go_router route table and its auth-redirect logic
  features/
    home/, shop/, product/, customize/, cart/, checkout/, auth/, orders/, about/   One folder per screen
    shell/            App shell, header, footer, and scroll scaffolding shared across screens
  firebase_options.dart   Generated by `flutterfire configure`
  main.dart               App entrypoint; Firebase init and the MaterialApp.router setup
```

## Deployment

```bash
flutter build web --release
firebase deploy --only hosting
```

`firebase.json` serves `build/web` and rewrites every path to `index.html`, so `go_router`'s client-side routes keep working on a hard refresh or direct link.

## Known limitations / out of scope

- **Checkout is a dummy payment flow.** There is no real payment processor integration; the Razorpay-styled sheet is purely visual and no money ever moves.
- **The 3D configurator approximates per-panel recoloring.** Because the underlying `.glb` assets don't expose separable material slots per panel, the viewer picks the closest of three pre-baked colorways rather than recoloring materials live in the scene.
- **A share-link feature for designs was descoped.** Saved designs are private to the account that created them; there's no public/shareable link for a build.
- **AR viewing was descoped.** `model_viewer_plus` supports AR quick-look/scene-viewer, but it isn't wired up here.
- **Mobile is scaffolded but not the deployed target.** Android/iOS projects and Firebase config exist and `flutter run` works on them, but the live demo and deployment pipeline are Web-only.
- **Test coverage is minimal.** The `test/` directory currently has a single smoke test that checks the app boots to the home screen.
