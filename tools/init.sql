# SQL to initialize a sqlite database for comics

CREATE TABLE publisher ( 
    id integer primary key,
    name text
);

CREATE TABLE comics (
    id integer primary key,
    title varchar(40),
    issue varchar(10),
    publisher integer,
    notes varchar(256,)
    FOREIGN KEY(publisher) REFERENCES publisher(id) 
);