#!/system/bin/sh

# הגדרת נתיב היעד כפי שציינת
SD_PATH="/storage/sdcard0/full_rom_backup_$(date +%Y%m%d_%H%M)"
BLOCK_DIR="/dev/block/bootdevice/by-name"

# בדיקת הרשאות שורש (su)
if [ "$(id -u)" -ne 0 ]; then
   echo "שגיאה: יש להריץ סקריפט זה עם הרשאות su"
   exit 1
fi

# יצירת תיקיית הגיבוי
mkdir -p "$SD_PATH"
if [ ! -d "$SD_PATH" ]; then
    echo "שגיאה: לא ניתן ליצור תיקייה בנתיב $SD_PATH"
    exit 1
fi

echo "מתחיל גיבוי מלא לתיקייה: $SD_PATH"
echo "----------------------------------------"

# מעבר על כל המחיצות הקיימות
for part in "$BLOCK_DIR"/*; do
    name=$(basename "$part")
    
    # הגנה מפני לולאה אינסופית אם sdcard0 הוא האחסון הפנימי:
    # אם sdcard0 הוא כרטיס חיצוני נפרד ואתה רוצה לגבות גם את userdata, מחק את 4 השורות הבאות
    if [ "$name" = "userdata" ]; then
        echo "מדלג על userdata למניעת התנגשות עם נתיב השמירה..."
        continue
    fi

    echo "מגבה ודוחס את מחיצת: $name ..."
    
    # גיבוי ודחיסה באמצעות gzip
    dd if="$part" bs=4M 2>/dev/null | gzip -1 > "$SD_PATH/${name}.img.gz"
    
    # סנכרון לכרטיס
    sync
    echo "הסתיים: ${name}.img.gz"
done

echo "----------------------------------------"
echo "הגיבוי הושלם בהצלחה! הקבצים שמורים ב: $SD_PATH"