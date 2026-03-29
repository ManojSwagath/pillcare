# Smart Pill Reminder – Backend (Production-Ready Prompt)

Act as:

* Senior Backend Engineer
* System Architect
* API Designer

Build a **production-ready backend system** for a mobile app called:

**Smart Pill Reminder for Elderly**

The backend must be scalable, secure, and ready for real-world deployment.

---

# 🎯 CORE OBJECTIVE

Create a backend that:

* Manages patients and caregivers
* Handles medicine schedules
* Tracks dose adherence
* Triggers reminders
* Sends alerts when doses are missed

---

# 🏗️ TECH STACK

* Node.js
* Express.js
* MongoDB (Mongoose)
* JWT Authentication
* Socket.io (real-time updates)
* Firebase Cloud Messaging (notifications placeholder)
* Twilio (SMS placeholder)

---

# 📁 PROJECT STRUCTURE

```
backend/
 ├── controllers/
 ├── models/
 ├── routes/
 ├── middleware/
 ├── services/
 ├── utils/
 ├── config/
 ├── server.js
 ├── app.js
 └── .env
```

---

# 🔐 AUTHENTICATION SYSTEM

## Requirements:

* JWT-based authentication
* Password hashing (bcrypt)
* Role-based access

## Roles:

* patient
* caregiver
* admin (optional)

## APIs:

* POST /api/auth/register
* POST /api/auth/login
* POST /api/auth/forgot-password (optional)

---

# 🗄️ DATABASE DESIGN (MONGODB)

## User

* name
* email
* password
* role

## PatientProfile

* userId
* age
* language
* caregiverId

## CaregiverLink

* patientId
* caregiverId

## Medicine

* name
* image
* color
* dosage
* instructions

## ReminderSchedule

* patientId
* medicineId
* time
* repeatType (daily, weekly, etc.)
* mealInstruction

## DoseLog

* patientId
* medicineId
* status (taken/missed/skipped)
* scheduledTime
* responseTime

## Notification

* userId
* type
* message
* status

## AlertHistory

* patientId
* caregiverId
* alertType
* timestamp

---

# 🔌 API DESIGN

## Auth

* POST /api/auth/register
* POST /api/auth/login

## Patient

* GET /api/patient/profile
* PUT /api/patient/profile

## Caregiver

* POST /api/caregiver/link
* GET /api/caregiver/patients

## Medicine

* POST /api/medicine
* GET /api/medicine
* PUT /api/medicine/:id
* DELETE /api/medicine/:id

## Schedule

* POST /api/schedule
* GET /api/schedule
* PUT /api/schedule/:id

## Dose

* POST /api/dose/respond
* GET /api/dose/history

## Alerts

* POST /api/alert/send

## Reports

* GET /api/reports/adherence

---

# ⏰ REMINDER ENGINE (CRITICAL LOGIC)

Implement a background service that:

1. Checks schedules every minute
2. Triggers reminder events
3. Creates DoseLog entries

Escalation logic:

* T0 → reminder triggered
* T+2 min → repeat reminder
* T+5 min → mark missed + send alert

---

# 🔔 ALERT SYSTEM

When dose is missed:

* Create AlertHistory entry
* Notify caregiver

Integrations (mock/stub):

* Firebase push notification
* SMS (Twilio placeholder)
* Email (optional)

---

# 🔊 REAL-TIME SYSTEM

Use Socket.io:

* Emit dose updates instantly
* Caregiver dashboard updates live

Events:

* dose_taken
* dose_missed
* reminder_triggered

---

# 🧠 BUSINESS LOGIC

## If patient clicks "Taken":

* Update DoseLog → taken
* Save timestamp
* Notify caregiver (optional)

## If "Not Taken":

* Mark skipped
* Immediately alert caregiver

## If no response:

* Mark missed
* Trigger alert escalation

---

# 🔐 SECURITY

* JWT middleware
* Protected routes
* Input validation
* Error handling
* Environment variables
* No plain passwords

---

# 📊 ADHERENCE TRACKING

Compute:

* Daily adherence %
* Weekly adherence %
* Missed count

---

# 🧪 SAMPLE DATA (MANDATORY)

Create seed data:

* 1 patient
* 1 caregiver
* 3 medicines:

  * Morning tablet
  * Afternoon tablet
  * Night tablet
* Schedules for each

---

# ⚙️ IMPLEMENTATION REQUIREMENTS

* Modular code (controllers/services separation)
* Clean architecture
* Reusable services
* Async/await usage
* Proper error handling
* Production-level structure

---

# 🚀 DEPLOYMENT

* MongoDB Atlas
* Backend: Render / Railway / AWS
* Use environment variables
* Enable CORS for mobile app

---

# 🔥 FINAL GOAL

This backend must:

* Work with a real mobile app
* Handle real users
* Scale properly
* Be clean and maintainable

Do NOT:

* Write toy/demo code
* Skip validation or security
* Hardcode values

Deliver:

* Full implementation
* File-by-file code
* Ready-to-run backend

---
