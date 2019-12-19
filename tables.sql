DROP DATABASE IF EXISTS PROJECT1;
CREATE DATABASE PROJECT1;
USE PROJECT1;

CREATE TABLE Address(
	aid INT NOT NULL AUTO_INCREMENT,
    address VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    longtitude float NOT NULL,
    latitude float NOT NULL,
    PRIMARY KEY (aid)
);

CREATE TABLE Users(
	email VARCHAR(30) NOT NULL,
    fname VARCHAR(30) NOT NULL,
    lname VARCHAR(30)  NOT NULL,
    gender ENUM ('Male', 'Female', 'Other') NOT NULL,
    pword  BLOB,
    aid INT,
    apt VARCHAR(30),
    descrip VARCHAR(100),
    img_path VARCHAR(100),
    PRIMARY KEY (email),
    CONSTRAINT FK_AID FOREIGN KEY (aid) REFERENCES Address(aid)
);

/* Blocks and Hoods*/

CREATE TABLE Hoods(
	hid int NOT NULL AUTO_INCREMENT,
    hname VARCHAR(30) NOT NULL,
    southwest_long float NOT NULL,
    southwest_lat float NOT NULL, 
    northeast_long float NOT NULL,
    northeast_lat float NOT NULL,
    PRIMARY KEY (hid)
);

CREATE TABLE Blocks(
	bid int NOT NULL AUTO_INCREMENT,
    bname VARCHAR(30) NOT NULL,
    southwest_long float NOT NULL,
    southwest_lat float NOT NULL, 
    northeast_long float NOT NULL,
    northeast_lat float NOT NULL,
    hid int NOT NULL,
    PRIMARY KEY (bid),
    CONSTRAINT FK_HID FOREIGN KEY (hid) REFERENCES Hoods(hid)
);

/*

WAIT: default status
JOINED if all / at least three people approves
REJECTED if all people in the block reject
LEAVE if the user leaves that block

A user can only have 'JOINED' status in one block
*/

CREATE TABLE Joins(
	req_email VARCHAR(30) NOT NULL,
    bid int NOT NULL, 
    jstatus ENUM ('WAIT', 'JOINED', 'REJECTED', 'LEAVE') NOT NULL,
    request_time timestamp NOT NULL,
    result_time timestamp,
	PRIMARY KEY (req_email, bid, request_time),
    CONSTRAINT FK_JOIN_EMAIL FOREIGN KEY (req_email) REFERENCES Users(email),
    CONSTRAINT FK_JOIN_BID FOREIGN KEY (bid) REFERENCES Blocks(bid)
);

CREATE TABLE Approves(
	email VARCHAR(30) NOT NULL,
	req_email VARCHAR(30) NOT NULL,
    bid int NOT NULL, 
    request_time timestamp NOT NULL,
    choice ENUM ('APPROVE', 'REJECT'),
    choice_time timestamp,
	PRIMARY KEY (email, req_email, bid, request_time),
    CONSTRAINT FK_APPROVE_EMAIL FOREIGN KEY (email) REFERENCES Users(email),
    CONSTRAINT FK_JOINS FOREIGN KEY (req_email, bid, request_time) REFERENCES Joins(req_email, bid, request_time)
);

/*
Friend and Neighbour
*/
CREATE TABLE Friend(
	uid1 VARCHAR(30) NOT NULL,
    uid2 VARCHAR(30) NOT NULL,
    stat ENUM ('REQUESTED', 'APPROVED', 'REJECT'),
    request_time timestamp NOT NULL,
    establish_time timestamp,
    PRIMARY KEY (uid1, uid2),
    CONSTRAINT FK_FUID1 FOREIGN KEY (uid1) REFERENCES Users(email),
    CONSTRAINT FK_FUID2 FOREIGN KEY (uid2) REFERENCES Users(email)
);

CREATE TABLE Neighbour(
	uid1 VARCHAR(30) NOT NULL,
    uid2 VARCHAR(30) NOT NULL,
    request_time timestamp NOT NULL,
    stat ENUM ('VALID', 'INVALID') NOT NULL,
    PRIMARY KEY (uid1, uid2),
    CONSTRAINT FK_NUID1 FOREIGN KEY (uid1) REFERENCES Users(email),
    CONSTRAINT FK_NUID2 FOREIGN KEY (uid2) REFERENCES Users(email)
);

/*Thread and Message*/
CREATE TABLE Thread(
	tid int NOT NULL AUTO_INCREMENT,
	ttype ENUM('Hood', 'Block', 'AllFriends', 'Friend' , 'Neighbour', 'JoinBlock', 'FriendRequest') NOT NULL,
    email VARCHAR(30) NOT NULL,
    title VARCHAR(100) NOT NULL,
    start_time timestamp NOT NULL,
    target_bid INT,
    target_uid VARCHAR(30),
    PRIMARY KEY (tid),
    CONSTRAINT FK_THREAD_EMAIL FOREIGN KEY (email) REFERENCES Users(email),
    CONSTRAINT FK_THREAD_BID FOREIGN KEY (target_bid) REFERENCES Blocks(bid),
    CONSTRAINT FK_THREAD_UID FOREIGN KEY (target_uid) REFERENCES Users(email)
);

CREATE TABLE Message(
	mid int NOT NULL AUTO_INCREMENT,
    tid int NOT NULL,
	email VARCHAR(30),
    body  VARCHAR(100) NOT NULL,
    send_time timestamp NOT NULL,
    lat float,
    longt float,
    PRIMARY KEY (mid),
    CONSTRAINT FK_MSG_THREAD FOREIGN KEY (tid) REFERENCES Thread(tid) ON DELETE CASCADE,
	CONSTRAINT FK_MSG_EMAIL FOREIGN KEY (email) REFERENCES Users(email)
);

/*
After user leaves a block/hoods
he/she can still read old messages from the thread, 
but can no longer see future messages or reply to it

What happens to old friends and neighbours? For now just assume the friends and neighbours 
or if user is no longer friends/neighbours of others
same thing 

Trigger needed
*/
CREATE TABLE Access(
	tid int NOT NULL,
	email VARCHAR(30) NOT NULL,
    stat ENUM('ACTIVE', 'NONACTIVE') NOT NULL,
    PRIMARY KEY (tid, email),
    CONSTRAINT FK_ATID FOREIGN KEY (tid) REFERENCES Thread(tid) ON DELETE CASCADE,
    CONSTRAINT FK_AEMAIL FOREIGN KEY (email) REFERENCES Users(email)
);

CREATE TABLE Receives(
	mid int NOT NULL,
    email VARCHAR(30) NOT NULL,
    stat ENUM ('UNREAD', 'READ'),
    receive_time timestamp NOT NULL,
    read_time timestamp,
	PRIMARY KEY (mid, email),
    CONSTRAINT FK_RECEIVE_MID FOREIGN KEY (mid) REFERENCES Message(mid) ON DELETE CASCADE,
    CONSTRAINT FK_RECEIVE_EMAIL FOREIGN KEY (email) REFERENCES Users(email)
);

