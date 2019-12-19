DROP PROCEDURE IF EXISTS readMessgesInThread;
DELIMITER $$
CREATE PROCEDURE readMessgesInThread (uid VARCHAR(30), thread_id INT)
BEGIN
    UPDATE Receives SET stat = 'READ'
	WHERE
    email = uid AND stat = 'UNREAD' AND mid IN (SELECT mid FROM Message WHERE tid = thread_id);
END$$ 


DROP PROCEDURE IF EXISTS leaveBlock;
DELIMITER $$
CREATE PROCEDURE leaveBlock (uid VARCHAR(30), block_id INT)
BEGIN
    UPDATE Joins SET jstatus = 'LEAVE'
    WHERE req_email = uid AND bid = block_id;
END$$ 

DROP PROCEDURE IF EXISTS respondToJoinBlock;
DELIMITER $$
CREATE PROCEDURE respondToJoinBlock (uid VARCHAR(30), request_uid VARCHAR(30), request_bid INT, req_time timestamp, result VARCHAR(30))
BEGIN
    INSERT INTO Approves (email, req_email, bid, request_time, choice, choice_time) 
    VALUES (uid, request_uid, request_bid, req_time, result, CURRENT_TIMESTAMP());
        
END$$ 

DROP PROCEDURE IF EXISTS addNeighbour;
DELIMITER $$
CREATE PROCEDURE addNeighbour (uid VARCHAR(30), nei_id VARCHAR(30))
BEGIN
    DECLARE recordExists INT;
    SELECT * FROM Neighbour WHERE uid1 = uid AND uid2 = nei_id;
    IF recordExists = 0 THEN
		INSERT INTO Neighbour (uid1, uid2, request_time, stat) 
        VALUES (uid, nei_id,  CURRENT_TIMESTAMP(), 'VALID');
    END IF;
END$$ 

DROP PROCEDURE IF EXISTS respondToFriendRequest;
DELIMITER $$
CREATE PROCEDURE respondToFriendRequest (respond_uid VARCHAR(30), request_uid VARCHAR(30), result VARCHAR(30))
BEGIN
	
    UPDATE Friend SET stat = result, establish_time = CURRENT_TIMESTAMP()
	WHERE (uid1 = request_uid AND uid2 = respond_uid)
    OR (uid2 = request_uid AND uid1 = respond_uid);    

END$$ 

DROP PROCEDURE IF EXISTS sendFriendRequest;
DELIMITER $$
CREATE PROCEDURE sendFriendRequest (request_uid VARCHAR(30), respond_uid VARCHAR(30))
BEGIN
	DECLARE recordExists INT;
    SELECT count(*) FROM Friend 
    WHERE (uid1 = request_uid AND uid2 = respond_uid)
    OR (uid2 = request_uid AND uid1 = respond_uid)
    INTO recordExists;
    IF recordExists THEN 
		UPDATE Friend SET stat = 'REQUESTED', request_time =  CURRENT_TIMESTAMP()
         WHERE (uid1 = request_uid AND uid2 = respond_uid)
		OR (uid2 = request_uid AND uid1 = respond_uid);
    ELSE 
		INSERT INTO Friend (uid1, uid2, stat, request_time) 
        VALUES (request_uid, respond_uid, 'REQUESTED', CURRENT_TIMESTAMP());
    END IF;
    
END$$ 


DROP PROCEDURE IF EXISTS listAllBlockRequests;
DELIMITER $$
CREATE PROCEDURE listAllBlockRequests (uid VARCHAR(30))
BEGIN
    SELECT thread_id, ttype, sender_id, target_bid, fname, lname, title, start_time
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, ttype, Thread.email AS sender_id, target_bid, title, date(start_time) AS start_time
    FROM (SELECT DISTINCT tid FROM Access WHERE Access.email = uid AND stat = 'ACTIVE') As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'JoinBlock') AS ResultThreads
    WHERE Users.email = sender_id
    ORDER BY ttype, start_time DESC;
END$$ 


/*see if the request is alread read*/
DROP PROCEDURE IF EXISTS listAllFriendRequests;
DELIMITER $$
CREATE PROCEDURE listAllFriendRequests (uid VARCHAR(30))
BEGIN
    SELECT thread_id, ttype, sender_id, fname, lname, title, start_time
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, ttype, Thread.email AS sender_id, title, date(start_time) AS start_time
    FROM (SELECT DISTINCT tid FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'FriendRequest') AS ResultThreads
    WHERE Users.email = sender_id
    ORDER BY ttype, start_time DESC;
END$$ 


DROP PROCEDURE IF EXISTS listAllNews;
DELIMITER $$
CREATE PROCEDURE listAllNews (uid VARCHAR(30))
BEGIN
    SELECT thread_id, ttype, sender_id, fname, lname, title, start_time
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, ttype, Thread.email AS sender_id, title, date(start_time) AS start_time
    FROM (SELECT DISTINCT tid FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'JoinBlock' OR  Thread.ttype = 'FriendRequest') AS ResultThreads
    WHERE Users.email = sender_id
    ORDER BY ttype, start_time DESC;
END$$ 

DROP PROCEDURE IF EXISTS replyToThread;
DELIMITER $$
CREATE PROCEDURE replyToThread (thread_id INT, uid VARCHAR(30), reply VARCHAR(100))
BEGIN
    INSERT INTO Message (tid, email, body, send_time) VALUES
    (thread_id, uid, reply, CURRENT_TIMESTAMP());
END$$ 

DROP PROCEDURE IF EXISTS getThreadInfo;
DELIMITER $$
CREATE PROCEDURE getThreadInfo (thread_id INT)
BEGIN
    SELECT tid, ttype, title, start_time
    FROM Thread WHERE tid = thread_id;
END $$ 

DROP PROCEDURE IF EXISTS getMessageFromThread;
DELIMITER $$
CREATE PROCEDURE getMessageFromThread (thread_id INT)
BEGIN
	SELECT mid, email, fname, lname, send_time, body FROM 
    Message JOIN Users USING (email)
    WHERE
    tid = thread_id
    ORDER BY mid ASC;
END $$ 

DROP FUNCTION IF EXISTS BlockContainAddress;
DELIMITER $$
CREATE FUNCTION BlockContainAddress(a_long float, a_lat float, sw_long float, sw_lat float, ne_long float, ne_lat float)
RETURNS BOOL
DETERMINISTIC
BEGIN
	RETURN TRUE;
	-- RETURN ne_long > a_long AND ne_lat < a_lat AND sw_long < a_long AND sw_lat > a_lat;
END $$
/*
list all available blocks for the user
*/
DROP PROCEDURE IF EXISTS ListAvailbleBlocksFor;
DELIMITER $$
CREATE PROCEDURE ListAvailbleBlocksFor (uid VARCHAR(30))
BEGIN
	/*get long and lat of user*/
    DECLARE user_long float;
    DECLARE user_lat float;
    
    SELECT longtitude INTO user_long FROM 
    Users JOIN Address USING (aid) WHERE email = uid;
    
    SELECT latitude INTO user_lat FROM 
    Users JOIN Address USING (aid) WHERE email = uid;
    
    SELECT bid, bname, nPeopleInBlock(bid)
    FROM Blocks
    WHERE BlockContainAddress(user_long, user_lat, southwest_long, southwest_lat, northeast_long, northeast_lat);
END$$

DROP PROCEDURE IF EXISTS CreateAccount;
DELIMITER $$
CREATE PROCEDURE CreateAccount (uid VARCHAR(30), first_name VARCHAR(30), last_name VARCHAR(30),
  gender VARCHAR(30), passW VARCHAR(100))
BEGIN
	INSERT INTO Users(email, fname, lname, gender, pword) 
    VALUES
    (uid, first_name, last_name, gender, passW);
END$$

DROP PROCEDURE IF EXISTS getHoodFeeds;
DELIMITER $$
CREATE PROCEDURE getHoodFeeds (uid VARCHAR(30))
BEGIN
	SELECT thread_id,access_stat, ttype, sender_id, fname, lname, title, start_date
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, access_stat, ttype, Thread.email AS sender_id, title, date(start_time) AS start_date
    FROM (SELECT DISTINCT tid, stat AS access_stat  FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'Hood') AS ResultThreads
    WHERE Users.email = sender_id;
END$$

DROP PROCEDURE IF EXISTS getBlockFeeds;
DELIMITER $$
CREATE PROCEDURE getBlockFeeds (uid VARCHAR(30))
BEGIN
	SELECT thread_id, access_stat, ttype, sender_id, fname, lname, title, start_date
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, access_stat, ttype, Thread.email AS sender_id, title, date(start_time) AS start_date
    FROM (SELECT DISTINCT tid, stat AS access_stat FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE  Thread.ttype = 'Block') AS ResultThreads
    WHERE Users.email = sender_id;
END$$

DROP PROCEDURE IF EXISTS getNeighbourFeeds;
DELIMITER $$
CREATE PROCEDURE getNeighbourFeeds (uid VARCHAR(30))
BEGIN
SELECT thread_id, access_stat, ttype, sender_id, fname, lname, title, start_date
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, access_stat, ttype, Thread.email AS sender_id, title, date(start_time) AS start_date
    FROM (SELECT DISTINCT tid,stat AS access_stat FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'Neighbour') AS ResultThreads
    WHERE Users.email = sender_id;
END$$

DROP PROCEDURE IF EXISTS getFriendFeeds;
DELIMITER $$
CREATE PROCEDURE getFriendFeeds (uid VARCHAR(30))
BEGIN
	SELECT thread_id,access_stat, ttype, sender_id, fname, lname, title, start_date
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id, access_stat, ttype, Thread.email AS sender_id, title, date(start_time) AS start_date
    FROM (SELECT DISTINCT tid, stat AS access_stat FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE Thread.ttype = 'Friend' OR Thread.ttype = 'AllFriends') AS ResultThreads
    WHERE Users.email = sender_id;
END$$

DROP PROCEDURE IF EXISTS getAllFeeds;
DELIMITER $$
CREATE PROCEDURE getAllFeeds (uid VARCHAR(30))
BEGIN
	SELECT thread_id, access_stat, ttype, sender_id, fname, lname, title, start_date
    FROM Users JOIN 
    (SELECT Thread.tid AS thread_id,access_stat, ttype, Thread.email AS sender_id, title, date(start_time) AS start_date
    FROM (SELECT DISTINCT tid, stat AS access_stat FROM Access WHERE Access.email = uid) As AccessibleThreads
    JOIN Thread USING (tid)  
	WHERE NOT Thread.ttype = 'JoinBlock' AND NOT Thread.ttype = 'FriendRequest') AS ResultThreads
    WHERE Users.email = sender_id;
END$$

DROP PROCEDURE IF EXISTS getProfile;
DELIMITER $$
CREATE PROCEDURE getProfile (uid VARCHAR(30))
BEGIN
	SELECT email, fname, lname, aid, apt, gender, descrip, img_path
    FROM Users
    WHERE email = uid;
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


DROP FUNCTION IF EXISTS hasUnreadRequest;
DELIMITER $$
CREATE FUNCTION hasUnreadRequest(uid VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE nResults INT;  
  SELECT COUNT(*)
  FROM
  Receives JOIN Message USING (mid) JOIN 
  (SELECT tid
  FROM Access JOIN Thread USING(tid)
  WHERE Access.email = uid AND 
  Thread.ttype = 'JoinBlock' OR Thread.ttype = 'FriendRequest') AS accessThreads USING (tid)
  WHERE Receives.email = uid AND Receives.stat = 'UNREAD'
  INTO nResults;

  IF nResults = 0 THEN 
	RETURN false;
  ELSE 
	RETURN true;
  END IF;
END $$

DROP FUNCTION IF EXISTS getCurrentBlock;
DELIMITER $$
CREATE FUNCTION getCurrentBlock(uid VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE n INT;
  DECLARE nResults INT;
  
  SELECT COUNT(*)
  FROM Joins
  WHERE req_email = uid AND jstatus = 'JOINED'
  INTO nResults;
  
  IF nResults = 0 THEN 
	SELECT -1 INTO n;
  ELSE 
	SELECT bid AS hid
	FROM Joins
	WHERE req_email = uid  AND jstatus = 'JOINED' LIMIT 1
	INTO  n;
  END IF;
  RETURN n;
END $$

DROP FUNCTION IF EXISTS getCurrentHood;
DELIMITER $$
CREATE FUNCTION getCurrentHood(uid VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
   DECLARE block_id INT;
   DECLARE hood_id INT;
   
   SELECT getCurrentBlock(uid) INTO block_id;
   SELECT hid
	   FROM Blocks
	   WHERE bid = block_id
	   LIMIT 1
       INTO hood_id;
       
   IF block_id =-1 OR hood_id IS NULL THEN 
	   RETURN -1;
   ELSE
       RETURN hood_id;
   END IF;
   
END $$



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
	SELECT nei_id, fname, lname, gender, descrip, img_path
    FROM Users JOIN (SELECT uid2 AS nei_id
    FROM Neighbour 
    WHERE uid1 = uid AND stat = 'VALID') AS NList
    WHERE nei_id = email;
END$$

DROP PROCEDURE IF EXISTS ListAllFriends;
DELIMITER $$
CREATE PROCEDURE ListAllFriends (uid VARCHAR(30))
BEGIN
	SELECT friend_id, fname, lname, gender, descrip, img_path
    FROM 
    Users Join (
	SELECT uid2 AS friend_id
	FROM Friend
	WHERE uid1 = uid AND stat = 'APPROVED'
	UNION 
	SELECT uid1 AS friendid
	FROM Friend
	WHERE uid2 = uid AND stat = 'APPROVED') AS FriendList
    WHERE friend_id = email;
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
							 msg_title VARCHAR(100), msg_body VARCHAR(100))
BEGIN
	
    DECLARE last_tid INT;
    
	INSERT INTO Thread (email, ttype, title, start_time, target_uid) VALUES
	(uid,  msg_type, msg_title,CURRENT_TIMESTAMP(), target);
	
    SELECT MAX(tid)
    INTO last_tid
	FROM Thread WHERE email = uid ;
    
	INSERT INTO Access (tid, email, stat) VALUES
    (last_tid, target, 'ACTIVE');
    
	INSERT INTO Message(tid, email, body, send_time) VALUES
	(last_tid, uid, msg_body, CURRENT_TIMESTAMP());
END$$


DROP PROCEDURE IF EXISTS StartMessageIn;
DELIMITER $$
CREATE PROCEDURE StartMessageIn(uid VARCHAR(30), msg_type VARCHAR(30), 
							 msg_title VARCHAR(100), msg_body VARCHAR(100))
BEGIN
	
    DECLARE last_tid INT;
    
	INSERT INTO Thread (email, ttype, title, start_time) VALUES
	(uid, msg_type, msg_title, CURRENT_TIMESTAMP());
	
    SELECT MAX(tid)
    INTO last_tid
	FROM Thread WHERE email = uid ;
    
	INSERT INTO Message(tid, email, body, send_time) VALUES
	(last_tid, uid, msg_body, CURRENT_TIMESTAMP());
    
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