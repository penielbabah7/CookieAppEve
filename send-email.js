// Load the .env file
require('dotenv').config();

// Import the SendGrid library
const sgMail = require('@sendgrid/mail');

// Set the SendGrid API key from the .env file
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Function to send an email
const sendEmail = async () => {
    const msg = {
        to: 'penielbabah7@gmail.com', // Recipient email address
        from: {
            email: 'penielbabah7@gmail.com', // Replace with your verified sender email
            name: 'Eves Original Sin Cookies', // Sender's name
        },
        subject: 'Test Email from Cookie App',
        text: 'This is a test email to confirm SendGrid integration!',
    };

    try {
        // Send the email
        await sgMail.send(msg);
        console.log('Email sent successfully!');
    } catch (error) {
        console.error('Error sending email:', error.response ? error.response.body : error.message);
    }
};

// Call the function to send the email
sendEmail();

