const app = require("./app");
const pool = require("./pool");


pool.connect({
    host: "localhost",
    port: "30756",
    database: "socialnetwork",
    user: "dare",
    password: "password"
});

app().listen(3005, () => {
    console.log("Listening on port 3005");
});