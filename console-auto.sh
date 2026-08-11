#!/bin/sh

# ==========================================
#  Oracle Cloud Console Connection - Advanced
#  نسخة قوية ومصححة بالكامل لـ iSH
# ==========================================

KEY="console.key"
LOG="console-advanced.log"

INSTANCE="ocid1.instance.oc1.me-jeddah-1.anvgkljr3fyxqwacpfx5rvbipfkmlsr2by26jk6n57im3l67isugwpq3jg6q"
CONSOLE="ocid1.instanceconsoleconnection.oc1.me-jeddah-1.anvgkljr3fyxqwacku7n66soaghd2r6hg2o53bnrnpkvay5wkuaxfm7fszga@instance-console.me-jeddah-1.oci.oraclecloud.com"

# فحص وجود المفتاح
if [ ! -f "$KEY" ]; then
    echo "❌ المفتاح $KEY غير موجود!"
    echo "ضع ملف المفتاح داخل نفس المجلد ثم أعد التشغيل."
    exit 1
fi

# فحص صلاحيات المفتاح
PERM=$(stat -c "%a" "$KEY")
if [ "$PERM" != "600" ]; then
    echo "⚠️ إصلاح صلاحيات المفتاح..."
    chmod 600 "$KEY"
fi

echo "🔐 تشغيل Console Connection المتقدم..."
echo "📄 تسجيل السجل في: $LOG"
echo "--------------------------------------"

while true; do
    echo "⏳ محاولة اتصال جديدة: $(date)" >> "$LOG"
    echo "🔌 الاتصال بالـ Console..."

    ssh -i "$KEY" \
        -o LogLevel=ERROR \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=3 \
        -o ProxyCommand="ssh -i $KEY -W %h:%p -p 443 $CONSOLE" \
        "$INSTANCE" 2>> "$LOG"

    echo "⚠️ الاتصال انقطع — إعادة المحاولة خلال 5 ثوانٍ..." | tee -a "$LOG"
    sleep 5
done
