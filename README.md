# Shiftly - Multi-Platform Shift & Salary Tracker

# Shiftly - מערכת מתקדמת לניהול משמרות ושכר

<div dir="rtl">

**Shiftly** היא פלטפורמה מתקדמת ומקיפה לניהול, מעקב וחישוב משמרות עבודה, שכר והוצאות נלוות, המותאמת
במיוחד לשוק העבודה בישראל (כולל חוקי עבודה, שעות נוספות, שבתות וחגים) וכן לשימוש בינלאומי.
האפליקציה מיועדת לספק מענה מדויק לחישובי שכר נטו/ברוטו, ניהול הפסקות, מעקב טיפים, חישובי שבת וחגים
אוטומטיים, והוצאות נלוות.

האפליקציה נבנתה בארכיטקטורת **Cross-Platform** מלאה התומכת ב-Android, iOS, Windows, macOS, Linux
ו-Web, ומציעה אפשרויות סנכרון גמישות החל מעבודה מקומית בלבד, דרך גיבוי פרטי ב-Google Drive (BYOS),
ועד לסנכרון ענן מלא.

---

## 🔑 ניהול משתמשים: התחברות והרשמה

Shiftly מציעה חוויית משתמש גמישה ומותאמת אישית לניהול הזהות והנתונים:

### 1. הרשמה לחשבון (Registration)

* **יצירת חשבון Shiftly Account:** הרשמה באמצעות שם, כתובת אימייל, סיסמה ותאריך לידה.
* **אימות גיל ובדיקת קטינים (Age Verification):** חובת הזנת תאריך לידה בעת ההרשמה עם מנגנון מובנה
  לווידוא גיל (בדיקת גיל מינימלי 12+ בהתאם לחוקי העבודה והגנת הפרטיות).
* **תהליך הגדרה ראשונית מודרך (Onboarding):** לאחר ההרשמה המשתמש עובר תהליך הגדרה מהיר לבחירת מטבע,
  הגדרת הפסקות ברירת מחדל (בתשלום/ללא תשלום), תזכורות משמרת, והגדרת תפקידים ושכר ראשוניים.

### 2. התחברות וניהול סשן (Login & Auth)

* **התחברות מאובטחת:** התחברות מול השרת באמצעות JSON Web Tokens (JWT) ואימות סיסמאות מוצפן (Bcrypt).
* **אימות סשן אוטומטי (Session Restoration):** שמירה מאובטחת של אסימון ההתחברות ב-Device Secure
  Storage (`flutter_secure_storage`). בעת פתיחת האפליקציה מתבצעת בדיקה ואימות אוטומטי של הסשן.
* **עדכון פרופיל ושינוי סיסמה:** אפשרות לעדכון פרטים אישיים (שם, אימייל, תאריך לידה) ושינוי סיסמה
  תוך אימות סיסמה ישנה.
* **מחיקת חשבון (Delete Account):** תמיכה מלאה בפרטיות המשתמש עם אפשרות למחיקת החשבון וכל הנתונים
  הנלווים אליו מהשרת לצמיתות.

### 3. עבודה במצב אורח / מקומי (Guest Mode / Offline)

* אין חובה להירשם! ניתן להשתמש באפליקציה באופן מקומי לחלוטין. כל הנתונים יישמרו במסד הנתונים המקומי
  על גבי המכשיר בלבד.

---

## ☁️ ארכיטקטורת סנכרון כפולה: BYOS מול Shiftly Cloud

Shiftly מציעה שני מודלים מתקדמים לסנכרון וגיבוי נתונים:

```
                  ┌──────────────────────────────────────────┐
                  │           Shiftly Mobile / Desktop       │
                  └─────────────────────┬────────────────────┘
                                        │
             ┌──────────────────────────┴──────────────────────────┐
             ▼                                                     ▼
┌──────────────────────────┐                             ┌───────────────────┐
│ BYOS (Bring Your Own)    │                             │ Shiftly Cloud     │
│ Google Drive AppData     │                             │ Node.js + Postgres│
└────────────┬─────────────┘                             └─────────┬─────────┘
             │                                                     │
             ▼                                                     ▼
┌──────────────────────────┐                             ┌───────────────────┐
│ Private Backup (.json)   │                             │ Multi-Device Sync │
│ Fully controlled by user │                             │ Real-time backend │
└──────────────────────────┘                             └───────────────────┘
```

### 1. BYOS - Bring Your Own Storage (גיבוי פרטי ב-Google Drive)

* **פרטיות מוחלטת:** הנתונים שלכם נשמרים ישירות במיכל הנתונים הפרטי שלכם ב-Google Drive (
  `appDataFolder`). הנתונים אינם עוברים או נשמרים בשרתי Shiftly.
* **גיבוי אוטומטי וידני:** סנכרון אוטומטי של כל שינוי במשמרות, הוצאות ותפקידים, לצד אפשרות לגיבוי
  יזום ושחזור בלחיצת כפתור.
* **שליטה מלאה:** אפשרות לניתוק החשבון ומחיקת קובץ הגיבוי הפרטי מ-Google Drive בכל עת.

### 2. Shiftly Cloud (סנכרון ענן מלא)

* **סנכרון בזמן אמת:** עבודה מול שרת מרכזי המאפשרת מעבר חלק בין מספר מכשירים (סמארטפון, מחשב,
  דפדפן).
* **סנכרון הגדרות אוטומטיות:** סנכרון של משמרות, תפקידים, הוצאות/הכנסות קבועות והגדרות אפליקציה
  מותאמות אישית.

### 3. Offline-First (אחסון מקומי ב-Hive)

* האפליקציה עובדת בגישת **Offline-First** מעל מסד נתונים NoSQL מקומי (Hive). כל הפעולות מבוצעות
  מיידית ובמידת הצורך מסונכרנות ברקע בעת חיבור לרשת.

---

## 🌟 תכונות מרכזיות ומנועי חישוב מתקדמים

* **⏱️ שעון נוכחות וטיימר משמרת חכם:**
    * הפעלה, השהיה, חידוש וסיום משמרת בזמן אמת.
    * ניהול הפסקות בתשלום ושלא בתשלום.
    * בקרת התראות מורחבת מווילון ההתראות במכשיר (`flutter_local_notifications`).

* **⚖️ מנוע חישוב שעות נוספות (Overtime Calculator):**
    * חישוב אוטומטי של שעות נוספות יומיות ושבועיות בהתאם לכללים גמישים או לחוקי העבודה המקובלים (
      שעות 1-2 ראשונות בתעריף מוגדל, ומעבר לכך בתעריף נוסף).

* **✡️ חישוב שבתות וחגים אוטומטי (Shabbat & Holiday Service):**
    * זיהוי מדויק של כניסת ויציאת שבת וחגים (כולל ערבי חג וחג שני) בהתאם ללוח השברי/עברי ולמיקום
      המשתמש.
    * חישוב תעריפי שכר מיוחדים לשבתות וחגים (לדוגמה 150%, 200%) להבטיח שכר מדוייק לכל דקת עבודה.

* **📅 תצוגת לוח שנה (Calendar View):**
    * לוח שנה אינטראקטיבי המציג את כל המשמרות, סיכומי שכר יומיים וחודשיים, ומאפשר ניווט והוספת
      משמרות מהירה ישירות מהתאריך הרצוי.

* **💼 ניהול תפקידים והיסטוריית שכר (Wage Rate History):**
    * תמיכה בשינויי שכר לפי תאריך תחולה (Effective Dates).
    * שמירת היסטוריית שכר לכל תפקיד להבטחת חישוב מדויק - שינויי שכר עתידיים אינם משפיעים על משמרות
      עבר.

* **💰 ניהול טיפים, הוצאות והכנסות:**
    * תיעוד טיפים בודדים לכל משמרת.
    * ניהול הוצאות נלוות (נסיעות, אוכל וכדומה).
    * הגדרת הוצאות והכנסות קבועות אוטומטיות (חודשיות או מחושבות לפי משמרת) לחישוב נטו סופי מדויק.

* **📝 מנוע פיענוח טקסט חופשי (Smart Parser):**
    * הזנת משמרות מרובות בבת אחת על ידי הדבקת טקסט חופשי בפורמט מובנה.
    * *דוגמה:* `24.06.2026 - 17:30 - 23:00 45 דקות + 50`

* **📊 דוחות, ניתוח נתונים וייצוא (Analytics & Export):**
    * גרפים וסטטיסטיקות מתקדמות (פילוח לפי תפקיד, שעות עבודה, ממוצע שכר, הוצאות והכנסות).
    * ייצוא נתונים ודוחות מקצועיים בקבצי **PDF, CSV ו-Excel**.

* **🎨 ממשק משתמש ועיצוב (Adaptive Scaffold & Material 3):**
    * תמיכה מלאה במצב בהיר/כהה (Light/Dark Theme).
    * עיצוב רספונסיבי חכם באמצעות `AdaptiveScaffold` המותאם לכל גודלי המסכים (Mobile, Tablet,
      Desktop, Web).
    * תמיכה מלאה בעברית (RTL) ואנגלית (LTR).
    * באנר אישור עוגיות (Cookie Consent) ומציג מסמכים משפטיים מובנה (`LegalDocumentViewer`).

---

## 🛠️ מפרט טכני וארכיטקטורה

### Frontend (Flutter)

* **Framework:** Flutter 3.x (Dart)
* **State Management:** Provider & ProxyProvider
* **Local Persistence:** Hive (NoSQL) & Flutter Secure Storage
* **Integrations:** Google Drive API & Google Sign-In
* **Localization:** `flutter_localizations` (HE / EN)
* **Supported Platforms:** Android, iOS, Windows, macOS, Linux, Web

### Backend (Shiftly Cloud Server)

* **Runtime:** Node.js (Express.js)
* **Database:** PostgreSQL
* **Authentication:** JWT (JSON Web Tokens) & Bcrypt hashing
* **Containerization & DevOps:** Docker, Docker Compose, Kubernetes Ready (K8s Manifests)

---

## 🚀 התקנה והרצה מקומית

### הרצת ה-Frontend (Flutter)

1. **התקנת תלויות:**
   ```bash
   flutter pub get
   ```
2. **יצירת קבצי Hive Adapters:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **הרצה במצב פיתוח:**
   ```bash
   flutter run
   ```

### בניית גרסאות הפצה מוקטנות (Release Builds)

* **אנדרואיד (APK מפוצל ומוקטן):**
  ```bash
  flutter build apk --split-per-abi --release --obfuscate --split-debug-info=build/app/outputs/symbols
  ```
  *הקבצים ייווצרו ב-`build/app/outputs/flutter-apk/`.*
* **אייפון (IPA ל-iOS):**
  ```bash
  flutter build ipa --release --obfuscate --split-debug-info=build/app/outputs/symbols
  ```
  *הקובץ ייווצר ב-`build/ios/ipa/`.*

### הרצת ה-Backend (Docker)

1. ודא ש-Docker Desktop מותקן במחשבך.
2. הרץ את הקונטיינרים:
   ```bash
   docker compose up --build
   ```
3. השרת יהיה זמין ב-`http://localhost:3000` ומנהל מסד הנתונים (Adminer) ב-`http://localhost:8080`.

</div>

---

# English Summary

**Shiftly** is a cross-platform shift tracking, wage calculation, and expense management system
built with Flutter and Node.js, tailor-made for both Israeli labor regulations (overtime, Shabbat,
and Jewish holidays) and global use.

## Key Highlights

- **User Authentication & Registration:**
    - **Shiftly Account:** Secure login/registration via JWT and Bcrypt encryption.
    - **Age Verification:** Age entry requirement during sign-up to ensure compliance with minor
      employment guidelines (minimum age 12+).
    - **Guided Onboarding:** Initial setup for currency, default break policies, shift reminders,
      and primary job roles.
    - **Profile & Data Management:** Update personal details, change passwords, or permanently
      delete accounts (GDPR-compliant).
    - **Guest / Local Mode:** Full functionality without account creation using local Hive database
      storage.

- **Dual-Sync Architecture:**
    - **BYOS (Bring Your Own Storage):** Private Google Drive backup (`appDataFolder`). Your data
      stays strictly on your personal Google Drive account.
    - **Shiftly Cloud:** Real-time synchronization across devices via a dedicated Node.js/PostgreSQL
      backend.
    - **Offline-First:** All actions are saved locally in Hive NoSQL first, ensuring fast offline
      operations.

- **Advanced Calculation & Features:**
    - **Live Shift Timer:** Real-time tracking with paid/unpaid break management and interactive
      notification actions.
    - **Overtime Calculator:** Automated daily and weekly overtime calculations based on
      customizable rules or standard labor laws.
    - **Shabbat & Holiday Engine:** Automatic detection of Shabbat and Jewish holidays (including
      eves and second days) with specialized wage rate multipliers (e.g., 150%, 200%).
    - **Calendar View:** Interactive monthly/weekly calendar view with daily and monthly wage
      summaries and quick shift creation.
    - **Wage History:** Support for effective-dated hourly rates per job type.
    - **Expenses & Tips:** Individual shift tips, automatic monthly/per-shift expenses & incomes,
      and net salary calculation.
    - **Smart Parser:** Bulk shift entry via free-text paste (
      `24.06.2026 - 17:30 - 23:00 45 min + 50`).
    - **Analytics & Export:** Interactive visual charts and professional data export to **PDF, CSV,
      and Excel**.
    - **Adaptive UI & Compliance:** Adaptive Scaffold for all screen sizes (mobile, tablet, desktop,
      web), full Hebrew (RTL) / English (LTR) support, Cookie Consent banner, and Legal Document
      Viewer.
