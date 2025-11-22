$(document).ready(function() {
    // State management
    let searchCriteria = {
        checkInDate: '',
        checkOutDate: '',
        regionId: '',
        adultsCount: 1,
        childrenCount: 0
    };
    
    let selectedHotel = null;
    let selectedRoom = null;
    
    // Initialize page
    init();
    
    function init() {
        // Check if user is logged in
        checkSession();
        
        // Load regions
        loadRegions();
        
        // Set minimum date to today
        const today = new Date().toISOString().split('T')[0];
        $('#checkInDate').attr('min', today);
        $('#checkOutDate').attr('min', today);
        
        // Event listeners
        $('#checkInDate').on('change', updateCheckOutMinDate);
        $('#searchForm').on('submit', handleSearchSubmit);
        $('#clearSearchBtn').on('click', clearSearchForm);
        $('#cancelBtn').on('click', () => window.location.href = 'index.html');
        $('#backToHotelsBtn').on('click', showHotelsSection);
        $('#backToRoomsBtn').on('click', showRoomsSection);
        $('#confirmReserveBtn').on('click', handleReservation);
    }
    
    // Check if user session is valid
    function checkSession() {
        $.ajax({
            url: 'php/check-session.php',
            method: 'GET',
            dataType: 'json',
            error: function() {
                // If session check fails, redirect to login
                showMessage('Please login to make a reservation', 'error');
                setTimeout(() => {
                    window.location.href = 'login.html';
                }, 2000);
            }
        });
    }
    
    // Load regions from database
    function loadRegions() {
        $.ajax({
            url: 'php/get-regions.php',
            method: 'GET',
            dataType: 'json',
            success: function(response) {
                if (response.success && response.data) {
                    const $select = $('#regionId');
                    response.data.forEach(region => {
                        $select.append(`<option value="${region.region_id}">${region.region_name}</option>`);
                    });
                }
            },
            error: function() {
                showMessage('Failed to load regions', 'error');
            }
        });
    }
    
    // Update check-out minimum date based on check-in
    function updateCheckOutMinDate() {
        const checkInDate = $('#checkInDate').val();
        if (checkInDate) {
            const minCheckOut = new Date(checkInDate);
            minCheckOut.setDate(minCheckOut.getDate() + 1);
            $('#checkOutDate').attr('min', minCheckOut.toISOString().split('T')[0]);
            
            // Clear check-out if it's before new minimum
            const checkOutDate = $('#checkOutDate').val();
            if (checkOutDate && new Date(checkOutDate) <= new Date(checkInDate)) {
                $('#checkOutDate').val('');
            }
        }
    }
    
    // Clear search form
    function clearSearchForm() {
        $('#searchForm')[0].reset();
        $('.error-message').text('').hide();
        $('#hotelsSection').hide();
        $('#roomsSection').hide();
        $('#confirmationSection').hide();
        const today = new Date().toISOString().split('T')[0];
        $('#checkInDate').attr('min', today);
        $('#checkOutDate').attr('min', today);
    }
    
    // Handle search form submission
    function handleSearchSubmit(e) {
        e.preventDefault();
        
        // Validate form
        if (!validateSearchForm()) {
            return;
        }
        
        // Store search criteria
        searchCriteria = {
            checkInDate: $('#checkInDate').val(),
            checkOutDate: $('#checkOutDate').val(),
            regionId: $('#regionId').val(),
            adultsCount: parseInt($('#adultsCount').val()),
            childrenCount: parseInt($('#childrenCount').val())
        };
        
        // Search for hotels
        searchHotels();
    }
    
    // Validate search form
    function validateSearchForm() {
        $('.error-message').text('').hide();
        let isValid = true;
        
        const checkInDate = $('#checkInDate').val();
        const checkOutDate = $('#checkOutDate').val();
        const regionId = $('#regionId').val();
        const adultsCount = parseInt($('#adultsCount').val());
        
        if (!checkInDate) {
            showError('checkInDate', 'Check-in date is required');
            isValid = false;
        }
        
        if (!checkOutDate) {
            showError('checkOutDate', 'Check-out date is required');
            isValid = false;
        }
        
        if (checkInDate && checkOutDate && new Date(checkOutDate) <= new Date(checkInDate)) {
            showError('checkOutDate', 'Check-out must be after check-in');
            isValid = false;
        }
        
        if (!regionId) {
            showError('regionId', 'Please select a region');
            isValid = false;
        }
        
        if (adultsCount < 1) {
            showError('adultsCount', 'At least one adult is required');
            isValid = false;
        }
        
        return isValid;
    }
    
    // Search for hotels
    function searchHotels() {
        showLoading(true);
        
        $.ajax({
            url: 'php/get-hotels.php',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                regionId: searchCriteria.regionId,
                checkInDate: searchCriteria.checkInDate,
                checkOutDate: searchCriteria.checkOutDate
            }),
            dataType: 'json',
            success: function(response) {
                showLoading(false);
                
                if (response.success && response.data) {
                    displayHotels(response.data);
                } else {
                    showMessage(response.message || 'No hotels found', 'error');
                }
            },
            error: function(xhr) {
                showLoading(false);
                const errorMsg = xhr.responseJSON?.message || 'Failed to search hotels';
                showMessage(errorMsg, 'error');
            }
        });
    }
    
    // Display hotels list
    function displayHotels(hotels) {
        const $hotelsList = $('#hotelsList');
        $hotelsList.empty();
        
        if (hotels.length === 0) {
            $hotelsList.html('<p class="no-results">No hotels available for the selected dates and region.</p>');
        } else {
            hotels.forEach(hotel => {
                const hotelCard = `
                    <div class="hotel-card" data-hotel-id="${hotel.hotel_id}">
                        <h3>${hotel.hotel_name}</h3>
                        <p class="hotel-address">${hotel.address}</p>
                        <p class="available-rooms">${hotel.available_rooms} room(s) available</p>
                        <button type="button" class="btn btn-primary view-rooms-btn" data-hotel='${JSON.stringify(hotel)}'>
                            View Rooms
                        </button>
                    </div>
                `;
                $hotelsList.append(hotelCard);
            });
            
            // Add click handlers
            $('.view-rooms-btn').on('click', function() {
                const hotel = $(this).data('hotel');
                viewHotelRooms(hotel);
            });
        }
        
        $('#hotelsSection').show();
        $('#roomsSection').hide();
        $('#confirmationSection').hide();
    }
    
    // View rooms for selected hotel
    function viewHotelRooms(hotel) {
        selectedHotel = hotel;
        showLoading(true);
        
        $.ajax({
            url: 'php/get-rooms.php',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                hotelId: hotel.hotel_id,
                checkInDate: searchCriteria.checkInDate,
                checkOutDate: searchCriteria.checkOutDate
            }),
            dataType: 'json',
            success: function(response) {
                showLoading(false);
                
                if (response.success && response.data) {
                    displayRooms(response.data);
                } else {
                    showMessage(response.message || 'No rooms found', 'error');
                }
            },
            error: function(xhr) {
                showLoading(false);
                const errorMsg = xhr.responseJSON?.message || 'Failed to load rooms';
                showMessage(errorMsg, 'error');
            }
        });
    }
    
    // Display rooms list
    function displayRooms(rooms) {
        // Display hotel info
        $('#selectedHotelInfo').html(`
            <h3>${selectedHotel.hotel_name}</h3>
            <p>${selectedHotel.address}</p>
        `);
        
        // Display rooms
        const $roomsList = $('#roomsList');
        $roomsList.empty();
        
        if (rooms.length === 0) {
            $roomsList.html('<p class="no-results">No rooms available for the selected dates.</p>');
        } else {
            const nights = calculateNights(searchCriteria.checkInDate, searchCriteria.checkOutDate);
            
            rooms.forEach(room => {
                const totalPrice = room.price_per_night * nights;
                const guestCount = searchCriteria.adultsCount + searchCriteria.childrenCount;
                const canBook = guestCount <= room.max_occupancy;
                
                const roomCard = `
                    <div class="room-card ${!canBook ? 'room-disabled' : ''}" data-room-id="${room.rm_id}">
                        <div class="room-header">
                            <h3>${room.room_type_name}</h3>
                            <span class="room-number">Room ${room.room_number}</span>
                        </div>
                        <div class="room-details">
                            <p><strong>Max Occupancy:</strong> ${room.max_occupancy} guest(s)</p>
                            <p><strong>Price per Night:</strong> $${parseFloat(room.price_per_night).toFixed(2)}</p>
                            <p class="total-price"><strong>Total (${nights} night(s)):</strong> $${totalPrice.toFixed(2)}</p>
                        </div>
                        ${canBook 
                            ? `<button type="button" class="btn btn-primary select-room-btn" data-room='${JSON.stringify(room)}'>Select Room</button>`
                            : `<p class="capacity-warning">Exceeds maximum occupancy</p>`
                        }
                    </div>
                `;
                $roomsList.append(roomCard);
            });
            
            // Add click handlers
            $('.select-room-btn').on('click', function() {
                const room = $(this).data('room');
                selectRoom(room);
            });
        }
        
        $('#hotelsSection').hide();
        $('#roomsSection').show();
        $('#confirmationSection').hide();
    }
    
    // Select room and show confirmation
    function selectRoom(room) {
        selectedRoom = room;
        const nights = calculateNights(searchCriteria.checkInDate, searchCriteria.checkOutDate);
        const totalPrice = room.price_per_night * nights;
        
        const summary = `
            <div class="summary-section">
                <h3>Hotel Information</h3>
                <p><strong>Hotel:</strong> ${selectedHotel.hotel_name}</p>
                <p><strong>Address:</strong> ${selectedHotel.address}</p>
            </div>
            
            <div class="summary-section">
                <h3>Room Information</h3>
                <p><strong>Room Type:</strong> ${room.room_type_name}</p>
                <p><strong>Room Number:</strong> ${room.room_number}</p>
                <p><strong>Max Occupancy:</strong> ${room.max_occupancy} guest(s)</p>
            </div>
            
            <div class="summary-section">
                <h3>Reservation Details</h3>
                <p><strong>Check-in:</strong> ${formatDate(searchCriteria.checkInDate)}</p>
                <p><strong>Check-out:</strong> ${formatDate(searchCriteria.checkOutDate)}</p>
                <p><strong>Nights:</strong> ${nights}</p>
                <p><strong>Adults:</strong> ${searchCriteria.adultsCount}</p>
                <p><strong>Children:</strong> ${searchCriteria.childrenCount}</p>
            </div>
            
            <div class="summary-section summary-total">
                <h3>Total Price</h3>
                <p class="price-breakdown">$${parseFloat(room.price_per_night).toFixed(2)} × ${nights} night(s)</p>
                <p class="total-amount">$${totalPrice.toFixed(2)}</p>
            </div>
        `;
        
        $('#bookingSummary').html(summary);
        $('#roomsSection').hide();
        $('#confirmationSection').show();
    }
    
    // Handle reservation submission
    function handleReservation() {
        if (!selectedRoom || !selectedHotel) {
            showMessage('Please select a room', 'error');
            return;
        }
        
        const reservationData = {
            roomId: selectedRoom.rm_id,
            checkInDate: searchCriteria.checkInDate,
            checkOutDate: searchCriteria.checkOutDate,
            adultsCount: searchCriteria.adultsCount,
            childrenCount: searchCriteria.childrenCount
        };
        
        showLoading(true);
        $('#confirmReserveBtn').prop('disabled', true);
        
        $.ajax({
            url: 'php/reserve.php',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(reservationData),
            dataType: 'json',
            success: function(response) {
                showLoading(false);
                
                if (response.success && response.data) {
                    // Redirect to confirmation page
                    window.location.href = response.data.confirmationUrl;
                } else {
                    $('#confirmReserveBtn').prop('disabled', false);
                    showMessage(response.message || 'Reservation failed', 'error');
                }
            },
            error: function(xhr) {
                showLoading(false);
                $('#confirmReserveBtn').prop('disabled', false);
                const errorMsg = xhr.responseJSON?.message || 'Failed to create reservation';
                showMessage(errorMsg, 'error');
            }
        });
    }
    
    // Show hotels section
    function showHotelsSection() {
        $('#roomsSection').hide();
        $('#confirmationSection').hide();
        $('#hotelsSection').show();
    }
    
    // Show rooms section
    function showRoomsSection() {
        $('#confirmationSection').hide();
        $('#roomsSection').show();
    }
    
    // Calculate number of nights
    function calculateNights(checkIn, checkOut) {
        const start = new Date(checkIn);
        const end = new Date(checkOut);
        const diffTime = Math.abs(end - start);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return diffDays;
    }
    
    // Format date for display
    function formatDate(dateString) {
        const date = new Date(dateString);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    }
    
    // Show error message for field
    function showError(fieldId, message) {
        $(`#${fieldId}Error`).text(message).show();
        $(`#${fieldId}`).addClass('input-error');
    }
    
    // Show general message
    function showMessage(message, type) {
        const $msg = $('#formMessage');
        $msg.text(message)
            .removeClass('success error')
            .addClass(type)
            .show();
        
        setTimeout(() => $msg.fadeOut(), 5000);
    }
    
    // Show/hide loading indicator
    function showLoading(show) {
        if (show) {
            $('#loadingIndicator').show();
        } else {
            $('#loadingIndicator').hide();
        }
    }
});
