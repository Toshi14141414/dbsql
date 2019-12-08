DROP PROCEDURE IF EXISTS CreateAccount;
DELIMITER $$
CREATE PROCEDURE CreateAccount (uid VARCHAR(30), first_name VARCHAR(30), last_name VARCHAR(30),
  gender VARCHAR(30), passW VARCHAR(100))
BEGIN
	INSERT INTO Users(email, fname, lname, gender, pword) 
    VALUES
    (uid, first_name, last_name, gender, passW);
END$$

DROP PROCEDURE IF EXISTS EnterAddress;
DELIMITER $$
CREATE PROCEDURE EnterAddress (uid VARCHAR(30), 
							   apt_info VARCHAR(30),
							   addr VARCHAR(100),
                               city_ VARCHAR(100),
							   state_ VARCHAR(100))
BEGIN
	/*first check if address exists*/
    DECLARE addressExists BOOL;
    DECLARE addressID INT;
    
    SELECT count(*)>0 FROM Address
    WHERE address = addr AND city = city_ AND state = state_
    INTO addressExists;
    
    /*if yes, then update users*/
    /*if not, update address and users table*/
    
    IF (addressExists) THEN 
		SELECT aid FROM Address
		WHERE address = addr AND city = city_ AND state = state_ LIMIT 1
        INTO addressID;
        
--         UPDATE USERS SET aid = addressID, apt = apt_info
--         WHERE email = uid;
	ELSE
		INSERT INTO Address (address, city, state) VALUES
		(addr, city_, state_);
        SELECT MAX(aid) FROM Address
        WHERE address = addr AND city = city_ AND state = state_ LIMIT 1
        INTO addressID;

    END IF;
    
		UPDATE USERS SET aid = addressID, apt = apt_info
        WHERE email = uid;
    
END$$

DROP FUNCTION IF EXISTS ValidateUser;
DELIMITER $$
CREATE FUNCTION ValidateUser(uid VARCHAR(30), passW VARCHAR(30))
RETURNS BOOL
DETERMINISTIC
BEGIN
  DECLARE n INT;
  SELECT COUNT(*)
  FROM Users
  WHERE email = uid AND pword = passW
  INTO n;
  RETURN n=1;
END $$


DROP PROCEDURE IF EXISTS EditProfile;
DELIMITER $$
CREATE PROCEDURE EditProfile (uid VARCHAR(30), u_descrip VARCHAR(100), imgpath VARCHAR(100))
BEGIN
	UPDATE Users 
	SET descrip = u_descrip, img_path = imgpath
	WHERE email = uid;
END$$

DROP PROCEDURE IF EXISTS JoinBlock;
DELIMITER $$
CREATE PROCEDURE JoinBlock (uid VARCHAR(30), target_block INT, req_time timestamp)
BEGIN
	IF nPeopleInBlock(target_block) > 0 THEN 
		INSERT INTO JOINS (req_email, bid, request_time, jstatus) VALUES
		(uid,  target_block, req_time, 'WAIT');
    END IF;
    
	IF nPeopleInBlock(target_block) =0 THEN 
		INSERT INTO JOINS (req_email, bid, request_time, jstatus, result_time) VALUES
		(uid,  target_block, req_time, 'JOINED', req_time);
    END IF;


END$$

DROP PROCEDURE IF EXISTS ListAllNeighbours;
DELIMITER $$
CREATE PROCEDURE ListAllNeighbours (uid VARCHAR(30))
BEGIN
	SELECT uid2 AS Neighbourid
    FROM Neighbour 
    WHERE uid1 = uid AND stat = 'VALID';
END$$

DROP PROCEDURE IF EXISTS ListAllFriends;
DELIMITER $$
CREATE PROCEDURE ListAllFriends (uid VARCHAR(30))
BEGIN
	SELECT uid2 AS friendid
	FROM Friend
	WHERE uid1 = uid AND stat = 'APPROVED'
	UNION 
	SELECT uid1 AS friendid
	FROM Friend
	WHERE uid2 = uid AND stat = 'APPROVED';
END$$

-- DROP PROCEDURE IF EXISTS ListMessages;
-- DELIMITER $$
-- CREATE PROCEDURE ListMessages (uid VARCHAR(30), read_status VARCHAR(30), feed_type VARCHAR(30))
-- BEGIN
-- 	SELECT *
--     FROM Receives JOIN Message USING (mid)
--     WHERE email = uid;
-- END$$

DROP PROCEDURE IF EXISTS ListThreadFeed;
DELIMITER $$
CREATE PROCEDURE ListThreadFeed (uid VARCHAR(30), feed_type VARCHAR(30), read_status VARCHAR(30))
BEGIN	
    DROP TABLE IF EXISTS Temp_tids;
	
    IF feed_type = 'Friend' THEN 
		CREATE TABLE Temp_tids
		SELECT tid
		FROM Thread JOIN Access USING (tid) 
		WHERE 
		Access.email = uid AND ttype = 'Friend' OR ttype = 'AllFriends';
    END IF;
    IF feed_type = 'Neighbour' THEN 
		CREATE TABLE Temp_tids
		SELECT tid
		FROM Thread JOIN Access USING (tid) 
		WHERE 
		Access.email = uid AND ttype = 'Neighbour';
    END IF;
    IF feed_type = 'Block' THEN 
		CREATE TABLE Temp_tids
		SELECT tid
		FROM Thread JOIN Access USING (tid) 
		WHERE 
		Access.email = uid AND ttype = 'Block';
    END IF;
    IF feed_type = 'Hood' THEN 
		CREATE TABLE Temp_tids
		SELECT tid
		FROM Thread JOIN Access USING (tid) 
		WHERE 
		Access.email = uid AND ttype = 'Hood';
    END IF;
    
    IF read_status = 'UNREAD' THEN 
		SELECT DISTINCT tid
		FROM Message JOIN Temp_tids USING (tid) JOIN Receives USING (mid)
		WHERE Receives.email = uid AND Receives.stat = 'UNREAD';
    END IF;
    
	IF NOT (read_status <> 'UNREAD') THEN
		SELECT DISTINCT tid
		FROM Message JOIN Temp_tids USING (tid) JOIN Receives USING (mid)
		WHERE Receives.email = uid;
    END IF;
END$$


DROP PROCEDURE IF EXISTS StartMessageWith;
DELIMITER $$
CREATE PROCEDURE StartMessageWith(uid VARCHAR(30), target VARCHAR(30), msg_type VARCHAR(30), 
							 msg_title VARCHAR(100), msg_body VARCHAR(100), send_time timestamp)
BEGIN
	
    DECLARE last_tid INT;
    
	INSERT INTO Thread (email, ttype, title, start_time, target_uid) VALUES
	(uid,  msg_type, msg_title,send_time, target);
	
    SELECT MAX(tid)
    INTO last_tid
	FROM Thread WHERE email = uid ;
    
	INSERT INTO Message(tid, email, body, send_time) VALUES
	(last_tid, uid, msg_body, send_time);
    
END$$


DROP PROCEDURE IF EXISTS SearchMessageWith;
DELIMITER $$
CREATE PROCEDURE SearchMessageWith(uid VARCHAR(30), keyword VARCHAR(30))
BEGIN
	SELECT mid, body, Message.send_time
    FROM Receives JOIN Message USING (mid)
    WHERE 
	Receives.email = uid AND body LIKE CONCAT('%', keyword,'%');
END$$