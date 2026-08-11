#!/bin/sh

# ==========================================
#  Oracle Cloud Console Connection - PRO
#  نسخة متقدمة جدًا لـ iSH
# ==========================================

KEY="console.key"
LOG="console-pro.log"
INSTANCE="ocid1.instance.oc1.me-jeddah-1.anvgkljr3fyxqwacpfx5rvbipfkmlsr2by26jk6n57im3l67isugwpq3jg6q"
CONSOLE="ocid1.instanceconsoleconnection.oc1.me-jeddah-1.anvgkljr3fyxqwacku7n66soaghd2r6hg2o53bnrnpkvay5wkuaxfm7fszga@instance-console.me-jeddah-1.oci.oraclecloud.com"

ATTEMPT=0

# فحص وجود المفتاح
if [ ! -f "$KEY" ]; then
    echo "❌ المفتاح $KEY غير موجود!"
    exit 1
fi

# فحص صلاحيات المفتاح
PERM=$(stat -c "%a" "$KEY")
if [ "$PERM" != "600" ]; then
    echo "⚠️ إصلاح صلاحيات المفتاح..."
    chmod 600 "$KEY"
fi

echo "🚀 تشغيل Console Connection PRO..."
echo "📄 السجل: $LOG"
echo "--------------------------------------"

while true; do
    ATTEMPT=$((ATTEMPT+1))
    echo "🔄 محاولة رقم: $ATTEMPT — الوقت: $(date)" | tee -a "$LOG"

    # فحص اتصال الإنترنت قبل التشغيل
    ping -c 1 instance-console.me-jeddah-1.oci.oraclecloud.com > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "⚠️ لا يوجد اتصال بالإنترنت — إعادة المحاولة خلال 5 ثوانٍ..." | tee -a "$LOG"
        sleep 5
        continue
    fi

    # تشغيل الاتصال
    ssh -i "$KEY" \
        -o LogLevel=ERROR \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=3 \
        -o ProxyCommand="ssh -i $KEY -W %h:%p -p 443 $CONSOLE" \
        "$INSTANCE" 2>> "$LOG"

    echo "⚠️ الاتصال انقطع — إعادة المحاولة خلال 5 ثوانٍ..." | tee -a "$LOG"
    sleep 5
done
