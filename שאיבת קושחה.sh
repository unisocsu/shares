#!/system/bin/sh

# הגדרת נתיב היעד בכרטיס
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

echo "מתחיל גיבוי מלא (ללא דחיסה) לתיקייה: $SD_PATH"
echo "----------------------------------------"

# מעבר על כל המחיצות הקיימות
for part in "$BLOCK_DIR"/*; do
    name=$(basename "$part")
    
    # דילוג על מחיצת userdata
    if [ "$name" = "userdata" ]; then
        echo "מדלג על מחיצת userdata..."
        continue
    fi

    echo "מגבה את מחיצת: $name ..."
    
    # העתקת המחיצה ישירות לקובץ img ללא דחיסה
    dd if="$part" of="$SD_PATH/${name}.img" bs=4M 2>/dev/null
    
    # סנכרון לכרטיס
    sync
    echo "הסתיים: ${name}.img"
done

echo "----------------------------------------"
echo "הגיבוי הושלם בהצלחה! הקבצים שמורים ב: $SD_PATH"