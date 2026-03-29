# Smart Pill Reminder – Frontend (Flutter UI Only)

Act as:

* Senior Flutter Developer
* UI/UX Designer (Elderly-first design)
* Mobile App Architect

Build a **production-quality Flutter frontend application ONLY**.

⚠️ Important:

* NO backend
* NO API calls
* Use ONLY mock/dummy data
* Focus 100% on UI/UX and structure

---

# 🎯 GOAL

Create a **clean, scalable Flutter mobile app UI** for:

**Smart Pill Reminder for Elderly**

The app must feel like a **real startup product**, not a basic demo.

---

# 🧠 DESIGN PRINCIPLES (VERY IMPORTANT)

Design for elderly users:

* Very large buttons
* High contrast colors
* Large readable fonts (18–28+)
* Minimal text
* Clear visual hierarchy
* No clutter
* One action per screen focus
* Emotionally supportive UI
* Voice-first mindset (UI should support it later)

---

# 📱 SCREENS TO BUILD (ONE BY ONE)

## 1. Splash Screen

* App logo
* Soft medical theme
* Simple loading indicator

---

## 2. Login Screen

* Role selection:

  * Patient
  * Caregiver
* Simple input fields
* Large buttons

---

## 3. Patient Dashboard (MAIN SCREEN)

* Greeting (e.g., "Good Morning")
* Today's medicines
* Each medicine card shows:

  * Name
  * Time
  * Status (Taken / Pending)
  * Color indicator
* Big readable cards

---

## 4. 🔴 Reminder Popup (MOST IMPORTANT)

This is the CORE screen.

Requirements:

* Fullscreen modal
* Cannot be ignored easily
* Large medicine image
* Medicine name (BIG font)
* Dosage instructions
* Time
* Notes (optional)

Buttons:

* ✅ TAKEN (Green, very large)
* ❌ NOT TAKEN (Red, very large)

Extra:

* Clean emotional UI
* Clear focus
* No distractions

---

## 5. Medicine List Screen

* List of medicines
* Card layout
* Add/Edit button (UI only)

---

## 6. History Screen

* List of past doses
* Status:

  * Taken
  * Missed
  * Skipped

---

## 7. Caregiver Dashboard

* Patient status overview
* Alerts section
* Simple report cards

---

# 🧩 COMPONENTS TO CREATE

Create reusable widgets:

* MedicineCard
* BigButton
* ReminderModal
* StatusBadge
* SectionHeader

---

# 🏗️ FOLDER STRUCTURE

lib/
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── patient_dashboard.dart
│   ├── reminder_popup.dart
│   ├── medicine_list.dart
│   ├── history_screen.dart
│   └── caregiver_dashboard.dart
│
├── widgets/
│   ├── medicine_card.dart
│   ├── big_button.dart
│   ├── reminder_modal.dart
│   └── status_badge.dart
│
├── models/
├── utils/
└── main.dart

---

# 🎨 UI STYLE GUIDE

Colors:

* Primary: Soft Blue (#4A90E2)
* Success: Green (#27AE60)
* Danger: Red (#E74C3C)
* Background: Light (#F5F7FA)

Typography:

* Headings: Bold, large
* Body: Clean, readable
* Buttons: Very large text

---

# 🧪 MOCK DATA

Use static data:

Example:

* Medicine: Paracetamol
* Time: 8:00 AM
* Status: Pending

Create at least:

* 3 medicines
* Morning / Afternoon / Night

---

# ⚙️ TECH REQUIREMENTS

* Flutter (latest stable)
* Material UI
* Clean architecture
* Separate widgets and screens
* Responsive layout
* No backend integration

---

# 🔥 IMPLEMENTATION RULES

* Write clean, modular code
* Avoid unnecessary comments
* Use meaningful naming
* Keep UI pixel-perfect
* Make components reusable

---

# 🚀 OUTPUT REQUIREMENT

Generate code:

* Screen by screen
* File by file
* Complete runnable Flutter UI

---

# ⚠️ IMPORTANT STRATEGY

Do NOT generate full app at once.

Instead:

1. Build ONE screen
2. Ensure perfect UI
3. Then move to next screen

---

# FINAL GOAL

The UI should feel like:

* A real healthcare product
* Elderly-friendly
* Clean and modern
* Ready to connect with backend later

Focus especially on:
👉 Reminder Popup Screen (highest priority)
