const pg = require('pg');

//connects to pg server
const pool = new pg.Pool({
    host: "localhost",
    port: "30756",
    database: "socialnetwork",
    user: "dare",
    password: "password"
});

pool.query(`
    UPDATE posts
    SET loc = POINT(lng, lat)
    WHERE loc IS NULL; 
`).then(() => {
    console.log("Update complete");
    pool.end();
}).catch((err) => {
    console.error(err.message)
});