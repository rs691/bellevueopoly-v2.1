# Custom Email Template Setup Guide

## 📧 Password Reset Email Template

This guide helps you set up a custom password reset email template in Firebase Console to replace the default template.

---

## 🎨 Custom Template Content

### Email Details
- **From:** noreply@roberts-web-apps.firebaseapp.com
- **Reply To:** noreply
- **Subject:** Reset your password for %APP_NAME%

### Email Body

```
Hello,

Follow this link to reset your %APP_NAME% password for your %EMAIL% account.

%LINK%

If you didn't ask to reset your password, you can ignore this email.

Thanks,

Your %APP_NAME% team
```

---

## 📋 Template Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `%APP_NAME%` | Your application name | Bellevueopoly |
| `%EMAIL%` | User's email address | user@example.com |
| `%LINK%` | The password reset link | https://.../__/auth/action?... |

---

## 🔧 How to Set Up in Firebase Console

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **bellevueopoly-v2.1**
3. Navigate to **Authentication** → **Templates** (or **Email Templates**)

### Step 2: Find Password Reset Email
1. Look for the section titled **"Password Reset"** or **"Reset Password Email"**
2. Click the **Edit** button (pencil icon)

### Step 3: Customize the Template

#### Subject Line
Replace with:
```
Reset your password for %APP_NAME%
```

#### From Name/Address
Leave as:
```
noreply@roberts-web-apps.firebaseapp.com
```

#### Email Body
Replace the entire body with:
```
Hello,

Follow this link to reset your %APP_NAME% password for your %EMAIL% account.

%LINK%

If you didn't ask to reset your password, you can ignore this email.

Thanks,

Your %APP_NAME% team
```

### Step 4: Save
1. Click **Save Template** or **Update** button
2. Confirm the changes

---

## 🎯 Important Notes

### Dynamic Link - %LINK% Tag
Firebase will automatically replace `%LINK%` with the actual password reset link. This is **required** in the template.

### Variables Available
- `%APP_NAME%` - Name of your Firebase app
- `%EMAIL%` - User's email address  
- `%LINK%` - **REQUIRED** - Full password reset link (Firebase generates this)
- `%OOB_CODE%` - Out-of-band code (alternative if using custom link)

### Authentication Domain
Make sure to replace `roberts-web-apps.firebaseapp.com` with your actual Firebase auth domain. You can find it in:
- Firebase Console → Authentication → Settings → Authorized Domains

---

## 🎨 Enhanced Template Option (With Branding)

If you want a more styled HTML version, you can use this template:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 20px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        .content {
            color: #333;
            line-height: 1.6;
        }
        .reset-button {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border-radius: 6px;
            text-decoration: none;
            margin: 20px 0;
            font-weight: bold;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #999;
            font-size: 12px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🎲 %APP_NAME%</div>
        </div>
        <div class="content">
            <p>Hello,</p>
            <p>We received a request to reset your password. Click the button below to set a new password:</p>
            <center>
                <a href="%LINK%" class="reset-button">Reset Password</a>
            </center>
            <p>Or copy and paste this link in your browser:</p>
            <p style="word-break: break-all; background: #f5f5f5; padding: 10px; border-radius: 4px;">
                %LINK%
            </p>
            <p>This link will expire in 1 hour.</p>
            <p>If you didn't request a password reset, please ignore this email or contact our support team.</p>
            <p>Best regards,<br>The %APP_NAME% Team</p>
        </div>
        <div class="footer">
            <p>This is an automated message, please do not reply to this email.</p>
            <p>© 2026 %APP_NAME%. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
```

---

## 📧 Email Verification Template (Bonus)

If you also want to customize the email verification template, use this:

```
Hello,

Welcome to %APP_NAME%!

Please verify your email address by clicking the link below:

%LINK%

Verification link expires in 24 hours.

If you didn't create this account, please ignore this email.

Thanks,

Your %APP_NAME% team
```

---

## ✅ Verification Checklist

After setting up the custom template:

- [ ] Subject line displays correctly
- [ ] Email shows proper branding
- [ ] Reset link is clickable and functional
- [ ] Variables (%APP_NAME%, %EMAIL%) are replaced correctly
- [ ] Email is not marked as spam
- [ ] Link expiration (1 hour) is working
- [ ] Works on mobile email clients

---

## 🔍 Testing the Template

### Step 1: Trigger a Password Reset
1. Open the app or go to login screen
2. Click "Forgot password?"
3. Enter a test email address
4. Submit the form

### Step 2: Check Email
1. Check your email inbox
2. Look for the custom template
3. Verify all variables are replaced correctly
4. Click the reset link
5. Verify it redirects to the password reset page

### Step 3: Complete Reset
1. Enter a new password
2. Confirm the password reset works
3. Try logging in with new password

---

## 🛠️ Firebase Console Steps (Visual Guide)

```
Firebase Console
    ↓
Authentication
    ↓
Settings (Tab)
    ↓
Email Templates (Section)
    ↓
Password Reset Email (Row)
    ↓
Edit (Click pencil icon)
    ↓
Customize subject, from, body
    ↓
Save Template (Click button)
    ↓
✅ Done!
```

---

## 💡 Tips

1. **Keep it Simple** - Not all email clients support complex HTML
2. **Mobile Friendly** - Ensure the email looks good on mobile
3. **Clear CTA** - Make the reset button/link obvious
4. **Security Info** - Mention that the link expires
5. **No Branding Issues** - Avoid excessive images or custom fonts
6. **Test First** - Always test with a real email before going live

---

## 🚨 Common Issues

### Issue: Variables not replacing
**Solution:** Make sure to use the exact variable names: `%APP_NAME%`, `%EMAIL%`, etc.

### Issue: Link not working
**Solution:** Verify the Firebase auth domain matches your custom domain

### Issue: Email marked as spam
**Solution:** Check SPF, DKIM, and DMARC records are properly configured

### Issue: Template not appearing
**Solution:** Clear browser cache and refresh Firebase Console

---

## 📝 Next Steps

1. ✅ Copy the template content from this guide
2. ✅ Log into Firebase Console
3. ✅ Navigate to Authentication → Email Templates
4. ✅ Edit the Password Reset Email template
5. ✅ Paste the custom content
6. ✅ Click Save
7. ✅ Test by triggering a password reset

---

## 📞 Firebase Documentation

For more information, see:
- [Firebase Email Templates Documentation](https://firebase.google.com/docs/auth/custom-email-handler)
- [Firebase Authentication Settings](https://firebase.google.com/docs/auth/email-link-auth)

---

**Template Created:** January 5, 2026  
**Status:** Ready for Firebase Console Setup  
**App:** Bellevueopoly v2.1
