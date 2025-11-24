//SEHS4517 Web Application Development and Management
// Group Projrct
// Submission date: 29 November 2025
// Full name: Yun Ka Lok
// Student ID: 24056180S

function validateForm() {
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value.trim();

    if (email === "" || password === "") {
        alert("Please input email and password");
        return false;
    }
    return true;
}