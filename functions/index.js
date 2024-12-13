const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
const { logger } = require("firebase-functions");

// Initialize Firebase Admin SDK
admin.initializeApp();
sgMail.setApiKey("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");

/**
 * Trigger: Listen to updates in the 'orders' collection.
 * Purpose: Send an email notification to the manager when an order's status is updated to 'Confirmed'.
 */
exports.sendOrderNotification = onDocumentUpdated("orders/{orderId}", async (event) => {
  const beforeData = event.data.before.data(); // Data before the update
  const afterData = event.data.after.data();   // Data after the update

  // Only proceed if the status has changed to "Confirmed"
  if (beforeData.status !== "Confirmed" && afterData.status === "Confirmed") {
    const managerEmail = "penielbabah7@gmail.com"; // Manager's email address
    const userEmail = afterData.userEmail || "Unknown"; // User's email
    const items = afterData.items || {}; // Ordered items
    const totalAmount = afterData.totalAmount || 0.0; // Total order amount

    // Construct the email content
    const msg = {
      to: managerEmail,
      from: "penielbabah7@gmail.com",
      subject: `Order Confirmation: ${userEmail}`,
      text: `
        A new order has been confirmed.

        Order Details:
        - User Email: ${userEmail}
        - Items: ${Object.entries(items)
          .map(([key, value]) => `${key} x ${value}`)
          .join(", ")}
        - Total Amount: $${totalAmount.toFixed(2)}

        Please process this order at your earliest convenience.
      `,
    };

    try {
      await sgMail.send(msg);
      logger.info("Order notification email sent successfully.");
    } catch (error) {
      logger.error("Error sending email:", error);
      throw new Error("Failed to send email");
    }
  }

  return null; // Required for Firebase Functions
});

