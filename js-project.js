//In your project, display the current date and time using JavaScript: Tuesday 16:00

let now = new Date();

let h2 = document.querySelector("h2");
let date = now.getDate();
let hours = now.getHours();
let minutes = now.getMinutes();
minutes = minutes > 9 ? minutes : "0" + minutes;
let year = now.getFullYear();

let days = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];
let day = days[now.getDay()];

let months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];
let month = months[now.getMonth()];

h2.innerHTML = ` ${day}, ${month} ${date} ${year} ${hours}:${minutes} `;

//On your project, when a user searches for a city (example: New York), it should display
//the name of the city on the result page and the current temperature of the city.
function searchCity(event) {
  event.preventDefault();
  let apiKey = "b20edc16a863f8a69dbcafcfb6c32b14";
  let searchInput = document.querySelector("#search-city-input");
  let city = `${searchInput.value}`;
  let apiUrl = `https://api.openweathermap.org/data/2.5/weather?q=${city}&${apiKey}&units=metric`;

  axios.get(`${apiUrl}&appid=${apiKey}`).then(showTemperature);
}
let button = document.querySelector("#search-button");
button.addEventListener("click", searchCity);

//Add a Current Location button. When clicking on it, it uses the Geolocation API to get
//your GPS coordinates and display and the city and current temperature using the OpenWeather API

function currentPosition(position) {
  let lat = position.coords.latitude;
  let lon = position.coords.longitude;
  let apiKey = "b20edc16a863f8a69dbcafcfb6c32b14";
  let apiUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;

  axios.get(`${apiUrl}&appid=${apiKey}`).then(showTemperature);
}
function showCurrentPosition(event) {
  event.preventDefault();
  navigator.geolocation.getCurrentPosition(currentPosition);
}
let locateButton = document.querySelector("#locate-button");
locateButton.addEventListener("click", showCurrentPosition);

function showTemperature(response) {
  let temperature = Math.round(response.data.main.temp);
  let city = response.data.name;
  let place = response.data.sys.country;
  let condition = response.data.weather[0].description;
  let humidity = response.data.main.humidity;

  let temp = document.querySelector("#current-temp");
  temp.innerHTML = `${temperature}˚C`;
  let location = document.querySelector("#current-city");
  location.innerHTML = `${city}, ${place}`;

  let todaycondition = document.querySelector("#current-temp-description");
  todaycondition.innerHTML = `${condition}`;
  let todayhumidity = document.querySelector("#current-temp-humidity");
  todayhumidity.innerHTML = `Humidity: ${humidity}%`;
}
