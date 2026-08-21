# Notification & Push Notification Integration Guide

This guide details the notification API routes, push notification payloads, feature triggers, and environment configuration in MummyMap.

---

## 1. Notification API Routes

These are the REST endpoints exposed by `NotificationsController` (`/notifications`):

| Method | Endpoint | Guards | Description | Request Body / Params |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/notifications/device-token` | `JwtAuthGuard` | Registers/updates a user's OneSignal or FCM push device token | `{ "token": "string", "platform": "IOS" \| "ANDROID" \| "WEB" }` |
| `GET` | `/notifications` | `JwtAuthGuard` | Retrieves in-app notification feed for current user | None |
| `PATCH` | `/notifications/:id/read` | `JwtAuthGuard`, `ProfileGuard` | Marks a specific notification as read | `:id` (notification UUID) |
| `POST` | `/notifications/read-all` | `JwtAuthGuard`, `ProfileGuard` | Marks all notifications as read for current user | None |
| `POST` | `/notifications/test-email` | Public | Verification endpoint to send a test transactional email | `{ "to": "email@example.com" }` |

---

## 2. Send Push Notification Method & Base Payload Structure

Push notifications are dispatched via `OneSignalProvider` implementing the `IPushProvider` interface (`src/modules/notifications/providers/push/onesignal.provider.ts`).

### Method Signature (`IPushProvider`)
```typescript
sendNotification(options: PushNotificationOptions): Promise<any>
```

### TypeScript Interface (`PushNotificationOptions`)
```typescript
export interface PushNotificationOptions {
  token: string | string[];        // Target OneSignal Subscription ID(s)
  title: string;                   // Banner title
  body: string;                    // Banner body message
  data?: Record<string, any>;      // Custom payload (category, IDs for deep-linking)
  priority?: NotificationPriority; // HIGH (10), MEDIUM (10), LOW (5)
}
```

### OneSignal Dispatch Payload (Sent to `@onesignal/node-onesignal`)
```json
{
  "app_id": "your-onesignal-app-id",
  "include_subscription_ids": ["token-1234-5678"],
  "headings": { "en": "Upcoming Appointment Reminder" },
  "contents": { "en": "Your consultation with Dr. Sarah starts in 30 minutes." },
  "priority": 10,
  "android_sound": "default",
  "ios_sound": "default",
  "data": {
    "category": "appointment",
    "appointmentId": "apt-998877",
    "roomId": "room-1234"
  }
}
```

---

## 3. Detailed Payload Specification per Notification Method

### Quick Reference Table

| Notification Method | Priority | Deep-Link Category | Payload Summary |
| :--- | :---: | :--- | :--- |
| `sendAppointmentReminder` | `HIGH` | `"appointment"` | `{ "category": "appointment", "appointmentId": "...", "roomId": "..." }` |
| `sendMedicationReminder` | `HIGH` | `"medication"` | `{ "category": "medication", "medicationId": "...", "time": "..." }` |
| `sendEmergencyAlert` | `HIGH` | `"emergency"` | `{ "category": "emergency", "alertId": "..." }` |
| `sendHealthLogReminder` | `HIGH` | `"health_reminder"` | `{ "type": "health_reminder" }` |
| `sendKickCountReminder` | `HIGH` | `"kick_count_reminder"` | `{ "type": "kick_count_reminder" }` |
| `sendMealPlanUpdate` | `MEDIUM` | `"mealplan"` | `{ "category": "mealplan", "planId": "..." }` |
| `sendOrderStatusChange` | `MEDIUM` | `"order"` | `{ "category": "order", "orderId": "...", "status": "..." }` |
| `sendVendorAssignmentUpdate` | `MEDIUM` | `"vendor"` | `{ "category": "vendor", "vendorId": "..." }` |
| `sendNewChatMessage` | `MEDIUM` | `"chat"` | `{ "category": "chat", "conversationId": "...", "senderId": "..." }` |
| `sendMilestoneNotification` | `LOW` | `"milestone_notification"` | `{ "type": "milestone_notification", "week": "28" }` |
| `sendMilestoneTip` | `LOW` | `"milestone"` | `{ "category": "milestone", "week": "14" }` |
| `sendPromotionalAlert` | `LOW` | `"promotion"` | `{ "category": "promotion", "promoId": "..." }` |
| `sendCommunityActivityAlert` | `LOW` | `"community"` | `{ "category": "community", "postId": "...", "groupId": "..." }` |

---

### Detailed Method & Payload Specifications

#### A. High Priority Notifications

##### 1. `sendAppointmentReminder`
- **Priority**: `HIGH` (Priority Level 10)
- **Title**: `"Upcoming Appointment Reminder"`
- **Body**: `"You have an upcoming appointment with Dr. {doctorName} today at {startTime}."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "appointment",
    "appointmentId": "apt-uuid-1234",
    "roomId": "room-uuid-5678"
  }
  ```

##### 2. `sendMedicationReminder`
- **Priority**: `HIGH` (Priority Level 10)
- **Title**: `"Medication Reminder"`
- **Body**: `"Time to take your {medicationName} ({dose})."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "medication",
    "medicationId": "med-uuid-1234",
    "time": "08:00"
  }
  ```

##### 3. `sendEmergencyAlert`
- **Priority**: `HIGH` (Priority Level 10)
- **Title**: `"Emergency Alert"`
- **Body**: `"{alertDescription}"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "emergency",
    "alertId": "alert-uuid-1234"
  }
  ```

##### 4. `sendHealthLogReminder`
- **Priority**: `HIGH` (Priority Level 10)
- **Title**: `"Daily Health Reminder"`
- **Body**: `"You haven't logged your Weight, Mood, Baby Kicks today. Keep track of your journey!"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "type": "health_reminder"
  }
  ```

##### 5. `sendKickCountReminder`
- **Priority**: `HIGH` (Priority Level 10)
- **Title**: `"Baby Kick Count Reminder"`
- **Body**: `"It is time for your daily baby kick count! Monitoring movement is important in the third trimester."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "type": "kick_count_reminder"
  }
  ```

---

#### B. Medium Priority Notifications

##### 6. `sendMealPlanUpdate`
- **Priority**: `MEDIUM` (Priority Level 10)
- **Title**: `"Meal Plan Update"`
- **Body**: `"Your weekly meal plan for week {week} is ready."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "mealplan",
    "planId": "plan-uuid-1234"
  }
  ```

##### 7. `sendOrderStatusChange`
- **Priority**: `MEDIUM` (Priority Level 10)
- **Title**: `"Order Status Update"`
- **Body**: `"Your order #{orderId} status has changed to {status}."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "order",
    "orderId": "order-uuid-1234",
    "status": "SHIPPED"
  }
  ```

##### 8. `sendVendorAssignmentUpdate`
- **Priority**: `MEDIUM` (Priority Level 10)
- **Title**: `"Vendor Update"`
- **Body**: `"Vendor {vendorName} has been assigned to your order."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "vendor",
    "vendorId": "vendor-uuid-1234"
  }
  ```

##### 9. `sendNewChatMessage`
- **Priority**: `MEDIUM` (Priority Level 10)
- **Title**: `"New Message from {senderName}"`
- **Body**: `"{messagePreview}"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "chat",
    "conversationId": "chat-uuid-1234",
    "senderId": "user-uuid-5678"
  }
  ```

---

#### C. Low Priority Notifications

##### 10. `sendMilestoneNotification`
- **Priority**: `LOW` (Priority Level 5)
- **Title**: `"Week {week} Milestone!"`
- **Body**: `"{milestoneMessage}"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "type": "milestone_notification",
    "week": "28"
  }
  ```

##### 11. `sendMilestoneTip`
- **Priority**: `LOW` (Priority Level 5)
- **Title**: `"Weekly Milestone Tip"`
- **Body**: `"{tipText}"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "milestone",
    "week": "14"
  }
  ```

##### 12. `sendPromotionalAlert`
- **Priority**: `LOW` (Priority Level 5)
- **Title**: `"{promoTitle}"`
- **Body**: `"{promoDescription}"`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "promotion",
    "promoId": "promo-uuid-1234"
  }
  ```

##### 13. `sendCommunityActivityAlert`
- **Priority**: `LOW` (Priority Level 5)
- **Title**: `"New Activity in {groupName}"`
- **Body**: `"{authorName} commented on your post."`
- **Dispatched Payload (`data` JSON)**:
  ```json
  {
    "category": "community",
    "postId": "post-uuid-1234",
    "groupId": "group-uuid-5678"
  }
  ```

---

## 4. Required Environment Variables (`.env`)

Add these configuration variables to your backend `.env` file:

```env
# --- OneSignal Push Notification Config ---
ONESIGNAL_APP_ID=your_onesignal_app_id_here
ONESIGNAL_REST_API_KEY=your_onesignal_rest_api_key_here

# --- Transactional Email Config (Resend) ---
RESEND_API_KEY=re_123456789_your_resend_key
RESEND_ACCOUNT_EMAIL=your_resend_login@example.com
MAIL_FROM_ADDRESS=onboarding@resend.dev
MAIL_FROM_NAME="MummyMap"
```
