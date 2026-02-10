# App Store Privacy Data Type Configuration Guide

## Pregame World Cup - iOS App Store Submission

This guide documents the privacy data collection settings for the App Store Connect submission.

---

## Overview

Each data type requires **3 configuration screens**:

1. **Purpose** (6 possible options - select all that apply)
2. **Linked to Identity** (Yes/No)
3. **Used for Tracking** (Yes/No)

---

## Screen 1: Purpose Options

| Option | Description |
|--------|-------------|
| Third-Party Advertising | Sharing with ad networks |
| Developer's Advertising/Marketing | Your own marketing communications |
| Analytics | Understanding user behavior |
| Product Personalization | Customizing user experience |
| App Functionality | Core features, authentication, security |
| Other Purposes | Anything else |

---

## All 13 Data Types - Configuration Summary

| Data Type | Purpose | Linked to Identity | Tracking |
|-----------|---------|-------------------|----------|
| **Name** | App Functionality | Yes | No |
| **Email Address** | App Functionality | Yes | No |
| **Precise Location** | App Functionality | Yes | No |
| **Photos or Videos** | App Functionality | Yes | No |
| **Audio Data** | App Functionality | Yes | No |
| **Other User Content** | App Functionality | Yes | No |
| **User ID** | App Functionality, Analytics | Yes | No |
| **Device ID** | App Functionality, Analytics | Yes | No |
| **Purchases** | App Functionality | Yes | No |
| **Product Interaction** | Analytics | Yes | No |
| **Advertising Data** | Third-Party Advertising | Yes | No |
| **Crash Data** | App Functionality | No | No |
| **Performance Data** | App Functionality, Analytics | No | No |

---

## Detailed Breakdown by Category

### Contact Info

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Name** | App Functionality | **Yes** | **No** | Used for profiles, chat display |
| **Email Address** | App Functionality | **Yes** | **No** | Firebase Auth login |

### Location

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Precise Location** | App Functionality | **Yes** | **No** | Venue finder feature |

### User Content

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Photos or Videos** | App Functionality | **Yes** | **No** | Chat media sharing |
| **Audio Data** | App Functionality | **Yes** | **No** | Voice messages |
| **Other User Content** | App Functionality | **Yes** | **No** | Chat messages, predictions |

### Identifiers

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **User ID** | App Functionality + Analytics | **Yes** | **No** | Firebase Auth + Analytics |
| **Device ID** | App Functionality + Analytics | **Yes** | **No** | FCM push + Analytics |

### Purchases

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Purchases** | App Functionality | **Yes** | **No** | RevenueCat subscriptions |

### Usage Data

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Product Interaction** | Analytics | **Yes** | **No** | Firebase Analytics |
| **Advertising Data** | Third-Party Advertising | **Yes** | **No** | AdMob |

### Diagnostics

| Data | Purpose | Linked | Tracking | Reason |
|------|---------|--------|----------|--------|
| **Crash Data** | App Functionality | **No** | **No** | Crashlytics (anonymous) |
| **Performance Data** | App Functionality + Analytics | **No** | **No** | Performance monitoring |

---

## Quick Reference Card

```
┌─────────────────────┬──────────────────────────────┬────────┬──────────┐
│ DATA TYPE           │ PURPOSE                      │ LINKED │ TRACKING │
├─────────────────────┼──────────────────────────────┼────────┼──────────┤
│ Name                │ App Functionality            │  YES   │    NO    │
│ Email Address       │ App Functionality            │  YES   │    NO    │
│ Precise Location    │ App Functionality            │  YES   │    NO    │
│ Photos or Videos    │ App Functionality            │  YES   │    NO    │
│ Audio Data          │ App Functionality            │  YES   │    NO    │
│ Other User Content  │ App Functionality            │  YES   │    NO    │
│ User ID             │ App Functionality + Analytics│  YES   │    NO    │
│ Device ID           │ App Functionality + Analytics│  YES   │    NO    │
│ Purchases           │ App Functionality            │  YES   │    NO    │
│ Product Interaction │ Analytics                    │  YES   │    NO    │
│ Advertising Data    │ Third-Party Advertising      │  YES   │    NO    │
│ Crash Data          │ App Functionality            │   NO   │    NO    │
│ Performance Data    │ App Functionality + Analytics│   NO   │    NO    │
└─────────────────────┴──────────────────────────────┴────────┴──────────┘
```

---

## Data Collection Summary (What Was Selected)

The following data types were declared as collected by the app:

### Contact Info
- Name
- Email Address

### Location
- Precise Location

### User Content
- Photos or Videos
- Audio Data
- Other User Content

### Identifiers
- User ID
- Device ID

### Purchases
- Purchase History

### Usage Data
- Product Interaction
- Advertising Data

### Diagnostics
- Crash Data
- Performance Data

---

## Privacy Policy URL

```
https://pregameworldcup.com/privacy
```

---

## Notes

- **Tracking = No** for all data types because the app does not track users across other companies' apps/websites
- **Crash Data** and **Performance Data** are marked as "Not Linked to Identity" because Firebase Crashlytics anonymizes this data
- **Advertising Data** uses Third-Party Advertising purpose because AdMob is a third-party ad network

---

*Last updated: February 2, 2026*
