import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';

enum LegalDocumentType { privacyPolicy, termsOfService }

class LegalDocumentViewer extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentViewer({super.key, required this.type});

  static void show(BuildContext context, LegalDocumentType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LegalDocumentViewer(type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrivacy = type == LegalDocumentType.privacyPolicy;
    final title = isPrivacy ? l.legal_privacy_policy : l.legal_terms_of_service;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  isPrivacy ? Icons.privacy_tip_outlined : Icons.gavel_outlined,
                  color: AppTheme.primaryDark,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content Scroll View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPrivacy)
                    _buildPrivacyPolicyContent(context, l)
                  else
                    _buildTermsContent(context, l),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Close Footer Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'סגור / Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyContent(BuildContext context, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('מדיניות פרטיות וגילוי עוגיות - Shiftly'),
        _buildSub('תאריך עדכון: 10 באוקטובר 2026'),
        const SizedBox(height: 16),
        _buildParagraph(
          'מסמך זה מפרט כיצד [OPERATOR LEGAL NAME] ("Shiftly", "אנו" או "החברה") אוספת, משתמשת, מאבטחת ומשתפת נתונים אישיים בעת שימוש באפליקציה ובשירותים הנלווים.',
        ),
        _buildHighlight(
          'הודעה חוקית: Shiftly פועלת כפוף לחוק הגנת הפרטיות, התשמ"א-1981 (כולל תיקון מס\' 13 ותקנות אבטחת מידע תשע"ז-2017), חוק התקשורת (סעיף 30א), וכן תאימות ל-GDPR האירופי ו-CCPA בארה"ב.',
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('1. פרטי מפעיל האפליקציה וממונה פרטיות'),
        _buildBullet('שם מפעיל האפליקציה: [OPERATOR LEGAL NAME]'),
        _buildBullet('כתובת למכתבים: [OFFICIAL BUSINESS ADDRESS, ISRAEL]'),
        _buildBullet('דוא"ל ליצירת קשר ופניות פרטיות: [PRIVACY CONTACT EMAIL]'),

        const SizedBox(height: 16),
        _buildSectionTitle('2. נתונים שאנו אוספים'),
        _buildBullet('פרטי חשבון: שם מלא, כתובת דוא"ל, סיסמה מוצפנת, תאריך לידה וגיל.'),
        _buildBullet('נתוני משמרות ושכר: תפקידים, שכר שעתי, היסטוריית עדכוני שכר, שעות כניסה ויציאה, הפסקות, טיפים, הוצאות נסיעה ותיאורי משמרות.'),
        _buildBullet('נתונים טכניים: מזהי מכשיר, גרסת מערכת הפעלה, יומני קריסות (via Firebase Crashlytics) וטוקן התחברות מאובטח.'),
        _buildBullet('גיבוי ענן (BYOS): גיבוי מוצפן ב-Google Drive של המשתמש (תיקיית appDataFolder בלבד).'),

        const SizedBox(height: 16),
        _buildSectionTitle('3. מטרות העיבוד והבסיס החוקי'),
        _buildBullet('אספקת השירות: חישוב שעות, תוספות שכר, שכר שעתי אפקטיבי ונטו.'),
        _buildBullet('סנכרון ענן: סנכרון מאובטח דרך שרת REST API בכתובת https://shiftly-server.onrender.com/api.'),
        _buildBullet('אבטחה ותקינות: זיהוי שגיאות ושיפור ביצועים via Firebase Crashlytics.'),

        const SizedBox(height: 16),
        _buildSectionTitle('4. מדיניות עוגיות ואחסון מקומי (Cookies)'),
        _buildBullet('עוגיות נחוצות בלבד: חיוניות לשמירת טוקן התחברות מאובטח (auth_token) והגדרות שפה/עיצוב.'),
        _buildBullet('עוגיות אנליטיקה ודיווחי שגיאות: Firebase Crashlytics לזיהוי קריסות (ניתן לאשר או לדחות בבאנר ה-Cookies).'),

        const SizedBox(height: 16),
        _buildSectionTitle('5. זכויות המשתמש ומחיקת חשבון'),
        _buildBullet('זכות עיון ותיקון: צפייה ועריכת הפרטים בפרופיל ובמשמרות.'),
        _buildBullet('ייצוא נתונים: ייצוא קבצי CSV ו-TXT ישירות מהאפליקציה.'),
        _buildBullet('מחיקת חשבון: מחיקת החשבון והנתונים באפליקציה במסך הפרופיל, או דרך דף האינטרנט: https://shiftly-server.onrender.com/delete-account.'),
      ],
    );
  }

  Widget _buildTermsContent(BuildContext context, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('תנאי שימוש - Shiftly'),
        _buildSub('תאריך עדכון: 10 באוקטובר 2026'),
        const SizedBox(height: 16),
        _buildParagraph(
          'ברוכים הבאים ל-Shiftly! תנאי שימוש אלה מהווים הסכם מחייב בינך לבין [OPERATOR LEGAL NAME]. השימוש באפליקציה מהווה הסכמה מלאה לתנאים אלו.',
        ),
        _buildHighlight(
          'הבהרה משפטית קריטית בנושא חישובי שכר:\n\n1. אינו תלוש שכר רשמי: Shiftly הינה אפליקציית מעקב אישית בלבד. החישובים באפליקציה אינם מהווים תלוש שכר רשמי לפי חוק הגנת השכר, תשי"ח-1958, ואינם מהווים ייעוץ מס או ייעוץ משפטי.\n2. תלות בנתוני המשתמש: החישובים מתבססים באופן מלא על הנתונים והגדרות השכר שהזנת.\n3. קביעות המעסיק: תלוש השכר הרשמי המונפק ע"י המעסיק הינו המסמך המשפטי המחייב היחיד.',
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('1. כשירות ותנאי הרשמה'),
        _buildBullet('השימוש מיועד למשתמשים מגיל 13 ומעלה.'),
        _buildBullet('המשתמש אחראי לשמירת סודיות פרטי ההתחברות לחשבונו.'),

        const SizedBox(height: 16),
        _buildSectionTitle('2. שימושים מותרים ואסורים'),
        _buildBullet('האפליקציה מיועדת לשימוש אישי בלבד.'),
        _buildBullet('חל איסור להנדס לאחור (Reverse Engineer), להעתיק או לפגוע באבטחת השרתים.'),

        const SizedBox(height: 16),
        _buildSectionTitle('3. הגבלת אחריות'),
        _buildBullet('השירות ניתק כפי שהוא (AS IS) ללא אחריות מכל סוג.'),
        _buildBullet('המפעיל לא ישא באחריות לנזקים עקיפים, הפסד השתכרות או טעויות בחישוב המסתמכות על הזנת נתונים.'),

        const SizedBox(height: 16),
        _buildSectionTitle('4. סמכות שיפוט ודין חל'),
        _buildBullet('על תנאים אלו יחולו אך ורק דיני מדינת ישראל.'),
        _buildBullet('סמכות השיפוט הבלעדית נתונה לבתי המשפט המוסמכים במחוז תל אביב-יפו.'),
      ],
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSub(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.4),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
      ),
    );
  }
}
