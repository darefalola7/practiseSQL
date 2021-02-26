/* eslint-disable camelcase */

exports.shorthands = undefined;

exports.up = pgm => {
    pgm.sql(`
    ALTER TABLE posts
    DROP column lat,
    DROP column lng; 
    `);
};

exports.down = pgm => {
    pgm.sql(`
    ALTER TABLE posts
    ADD column lat NUMERIC,
    ADD column lng NUMERIC; 
    `);
};
