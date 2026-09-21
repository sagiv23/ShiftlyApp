# Shiftly - Multi-Platform Shift Tracker

<div dir="rtl">

Shiftly היא פלטפורמה מקיפה לניהול ומעקב משמרות עבודה והוצאות נלוות, המיועדת לספק מענה מדויק לחישוב
שכר נטו, ניהול הפסקות ורישום טיפים. האפליקציה תומכת בכל הפלטפורמות (Android, iOS, Windows, macOS,
Linux, Web) ומציעה פתרונות סנכרון מתקדמים.

## תכונות עיקריות

* **מעקב זמן אמת וטיימר חכם:** שעון עצר מובנה לניהול משמרת פעילה, כולל מעבר למצבי הפסקה (בתשלום/ללא
  תשלום) ושליטה מלאה מווילון ההתראות.
* **סנכרון ענן כפול:**
  * **BYOS (Bring Your Own Storage):** גיבוי ושחזור ל-Google Drive הפרטי שלך – השליטה במידע נשארת
    אצלך.
  * **Shiftly Account:** סנכרון מלא בזמן אמת מול שרת מרכזי למעבר חלק בין מכשירים (מובייל ודסקטופ).
* **ניהול היסטוריית שכר:** תמיכה בשינויי שכר לפי תאריך (Effective Dates). המערכת שומרת היסטוריית שכר
  לכל תפקיד ומבטיחה ששינויי שכר עתידיים לא ישפיעו על חישובי העבר.
* **ניהול טיפים והוצאות:** תיעוד הוצאות (נסיעות, אוכל) וטיפים בודדים עם חישוב נטו סופי מדויק.
* **מנוע פיענוח טקסט (Smart Parser):** הזנת משמרות מרובות באמצעות הדבקת טקסט חופשי (פורמט: תאריך -
  שעות - הפסקה + טיפ).
* **ממשק מודרני (Material 3):** תמיכה מלאה במצב בהיר/כהה ועיצוב מותאם לכל גודל מסך.
* **רב-לשוניות:** תמיכה מלאה בעברית ובאנגלית.

## מפרט טכני

### Frontend (Flutter)

* **State Management:** Provider & ProxyProvider.
* **Persistence:** Hive (Local NoSQL) & Google Drive API.
* **Localization:** `flutter_localizations` (HE/EN).
* **Platforms:** Mobile (Android/iOS), Desktop (Windows/macOS/Linux), Web.

### Backend (Shiftly Cloud)

* **Runtime:** Node.js (Express.js).
* **Database:** PostgreSQL.
* **Auth:** JWT (JSON Web Tokens) & Bcrypt.
* **Containerization:** Docker & Docker Compose.
* **Orchestration:** Kubernetes (K8s) Ready.

## התקנה ופיתוח מקומי

###Frontend
1. **התקנת תלויות:** `flutter pub get`
2. **יצירת קבצי Adapters:** `dart run build_runner build --delete-conflicting-outputs`
3. **הרצה:** `flutter run`

### Backend (Docker)

1. וודא ש-Docker Desktop מותקן.
2. הרץ: `docker compose up --build`
3. השרת יהיה זמין ב-`http://localhost:3000` ומסד הנתונים ב-Adminer ב-`http://localhost:8080`.

## פורמט הזנה (Smart Paste)

`[DD.MM.YYYY] - [HH:mm] - [HH:mm] [תיאור הפסקה] + [טיפים]`
*דוגמה:* `24.06.2026 - 17:30 - 23:00 45 דקות + 50`

</div>

---

# English Summary

Shiftly is a comprehensive shift tracking and expense management platform built with Flutter. It
supports Android, iOS, Windows, macOS, Linux, and Web.

## Key Features

- **Real-time Tracking:** Smart timer with break management and notification controls.
- **Dual Sync Options:**
  - **BYOS:** Private backup to your own Google Drive.
  - **Shiftly Cloud:** Real-time sync via Node.js/PostgreSQL backend.
- **Wage History:** Support for effective-dated hourly rates.
- **Smart Parser:** Free-text shift entry for bulk additions.
- **Multilingual:** Full support for Hebrew and English.

## Tech Stack

- **Frontend:** Flutter, Provider, Hive.
- **Backend:** Node.js, Express, PostgreSQL, JWT.
- **DevOps:** Docker, Kubernetes.
