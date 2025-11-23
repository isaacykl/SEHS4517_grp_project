function validateForm() {
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value.trim();

    if (email === "" || password === "") {
        alert("Please input email and password");
        return false;
    }
    return true;
}