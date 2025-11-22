/**
 * Node.js Express Server
 * Hotel Booking System - Confirmation Handler
 * 
 * This Express.js server handles reservation confirmations by:
 * - Receiving booking data from PHP
 * - Storing confirmation data temporarily
 * - Generating HTML confirmation page (5th web page)
 * - Serving the confirmation page to users
 */

const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const APACHE_URL = process.env.APACHE_URL || 'http://localhost';

// In-memory storage for booking confirmations (use database in production)
const bookingConfirmations = new Map();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Request logging middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

/**
 * API Endpoint: Receive booking confirmation from PHP
 * POST /api/confirmation
 */
app.post('/api/confirmation', (req, res) => {
    try {
        const bookingData = req.body;
        
        // Validate required fields
        const requiredFields = [
            'bookingReference',
            'userEmail',
            'userName',
            'hotelName',
            'roomType',
            'checkInDate',
            'checkOutDate',
            'totalPrice'
        ];
        
        for (const field of requiredFields) {
            if (!bookingData[field]) {
                return res.status(400).json({
                    success: false,
                    message: `Missing required field: ${field}`
                });
            }
        }
        
        // Store booking confirmation data
        bookingConfirmations.set(bookingData.bookingReference, {
            ...bookingData,
            timestamp: new Date().toISOString()
        });
        
        console.log(`✓ Booking confirmation received: ${bookingData.bookingReference}`);
        
        // Return success response
        res.status(200).json({
            success: true,
            message: 'Booking confirmation received',
            confirmationUrl: `/confirmation/${bookingData.bookingReference}`
        });
        
    } catch (error) {
        console.error('Error processing confirmation:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to process booking confirmation'
        });
    }
});

/**
 * Web Page: Display booking confirmation (5th web page)
 * GET /confirmation/:bookingReference
 */
app.get('/confirmation/:bookingReference', (req, res) => {
    const { bookingReference } = req.params;
    
    // Retrieve booking data
    const booking = bookingConfirmations.get(bookingReference);
    
    if (!booking) {
        return res.status(404).send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Booking Not Found</title>
                <link rel="stylesheet" href="${APACHE_URL}/css/style.css" />
                <link rel="stylesheet" href="${APACHE_URL}/css/responsive.css" />
            </head>
            <body>
                <div class="container">
                    <div class="registration-container">
                        <div class="logo-section">
                            <img src="${APACHE_URL}/images/logo.svg" alt="Hotel Logo" class="logo" />
                        </div>
                        
                        <h1>Booking Not Found</h1>
                        <p class="subtitle">The booking reference you're looking for does not exist.</p>
                        
                        <div class="form-actions">
                            <a href="${APACHE_URL}/index.html" class="btn btn-primary">Go to Homepage</a>
                        </div>
                    </div>
                </div>
            </body>
            </html>
        `);
    }
    
    // Generate confirmation HTML page
    const confirmationHTML = `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Booking Confirmation - Hotel Booking System</title>
            <link rel="stylesheet" href="${APACHE_URL}/css/style.css" />
            <link rel="stylesheet" href="${APACHE_URL}/css/responsive.css" />
            <style>
                .confirmation-content {
                    text-align: center;
                    padding: 20px 0;
                }
                
                .success-icon {
                    width: 80px;
                    height: 80px;
                    margin: 0 auto 30px;
                    background: #4CAF50;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 48px;
                    color: white;
                    font-weight: bold;
                }
                
                .confirmation-content h1 {
                    color: #2c3e50;
                    font-size: 28px;
                    margin-bottom: 10px;
                }
                
                .confirmation-content > p {
                    color: #7f8c8d;
                    font-size: 16px;
                    margin-bottom: 30px;
                }
                
                .booking-ref {
                    background: #e8f5e9;
                    padding: 15px;
                    border-radius: 5px;
                    font-size: 18px;
                    font-weight: bold;
                    color: #2c3e50;
                    margin-bottom: 30px;
                    border-left: 4px solid #4CAF50;
                }
                
                .booking-details {
                    text-align: left;
                    margin: 30px 0;
                    padding: 25px;
                    background: #f8f9fa;
                    border-radius: 8px;
                    border: 1px solid #e0e0e0;
                }
                
                .detail-row {
                    display: flex;
                    justify-content: space-between;
                    padding: 12px 0;
                    border-bottom: 1px solid #e0e0e0;
                }
                
                .detail-row:last-child {
                    border-bottom: none;
                    padding-top: 20px;
                    margin-top: 10px;
                    border-top: 2px solid #4CAF50;
                }
                
                .detail-label {
                    font-weight: 600;
                    color: #555;
                }
                
                .detail-value {
                    color: #2c3e50;
                    text-align: right;
                }
                
                .total-price {
                    font-size: 20px;
                    font-weight: bold;
                    color: #4CAF50;
                }
                
                .confirmation-note {
                    color: #7f8c8d;
                    font-size: 14px;
                    margin: 20px 0;
                    font-style: italic;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="registration-container">
                    <div class="logo-section">
                        <img src="${APACHE_URL}/images/logo.svg" alt="Hotel Logo" class="logo" />
                    </div>
                    
                    <div class="confirmation-content">
                        <div class="success-icon">✓</div>
                        
                        <h1>Thank You for Your Reservation!</h1>
                        <p>Your booking has been confirmed successfully.</p>
                        
                        <div class="booking-ref">
                            Booking Reference: ${booking.bookingReference}
                        </div>
                        
                        <div class="booking-details">
                            <div class="detail-row">
                                <span class="detail-label">Guest Name:</span>
                                <span class="detail-value">${booking.userName}</span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Email:</span>
                                <span class="detail-value">${booking.userEmail}</span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Hotel:</span>
                                <span class="detail-value">${booking.hotelName}</span>
                            </div>
                            
                            ${booking.hotelAddress ? `
                            <div class="detail-row">
                                <span class="detail-label">Address:</span>
                                <span class="detail-value">${booking.hotelAddress}</span>
                            </div>
                            ` : ''}
                            
                            <div class="detail-row">
                                <span class="detail-label">Room Type:</span>
                                <span class="detail-value">${booking.roomType}</span>
                            </div>
                            
                            ${booking.roomNumber ? `
                            <div class="detail-row">
                                <span class="detail-label">Room Number:</span>
                                <span class="detail-value">${booking.roomNumber}</span>
                            </div>
                            ` : ''}
                            
                            <div class="detail-row">
                                <span class="detail-label">Check-in Date:</span>
                                <span class="detail-value">${formatDate(booking.checkInDate)}</span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Check-out Date:</span>
                                <span class="detail-value">${formatDate(booking.checkOutDate)}</span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Number of Nights:</span>
                                <span class="detail-value">${booking.nights}</span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Guests:</span>
                                <span class="detail-value">
                                    ${booking.adultsCount} Adult${booking.adultsCount > 1 ? 's' : ''}
                                    ${booking.childrenCount > 0 ? `, ${booking.childrenCount} Child${booking.childrenCount > 1 ? 'ren' : ''}` : ''}
                                </span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">Total Price:</span>
                                <span class="detail-value total-price">$${booking.totalPrice}</span>
                            </div>
                        </div>
                        
                        <p class="confirmation-note">
                            A confirmation email has been sent to <strong>${booking.userEmail}</strong>
                        </p>
                        
                        <div class="form-actions">
                            <a href="${APACHE_URL}/index.html" class="btn btn-primary">OK</a>
                        </div>
                    </div>
                </div>
            </div>
        </body>
        </html>
    `;
    
    res.send(confirmationHTML);
});

/**
 * Helper function to format dates
 */
function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        activeBookings: bookingConfirmations.size
    });
});

/**
 * Homepage redirect - redirect to Apache server
 */
app.get('/', (req, res) => {
    res.redirect(`${APACHE_URL}/index.html`);
});

/**
 * 404 handler
 */
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Endpoint not found'
    });
});

/**
 * Error handler
 */
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({
        success: false,
        message: 'Internal server error'
    });
});

/**
 * Start server
 */
app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`Hotel Booking System - Node.js Server`);
    console.log('='.repeat(50));
    console.log(`Server running on: http://localhost:${PORT}`);
    console.log(`Confirmation API: http://localhost:${PORT}/api/confirmation`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`Apache server: ${APACHE_URL}`);
    console.log('='.repeat(50));
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\nShutting down server gracefully...');
    process.exit(0);
});
