/*calculate numbers of people in the block*/
DROP FUNCTION IF EXISTS nPeopleInBlock;
DELIMITER $$
CREATE FUNCTION nPeopleInBlock(block_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE n INT;
  SELECT COUNT(req_email)
  FROM Joins
  Where bid = block_id AND jstatus = 'JOINED' LIMIT 1
  INTO n;
  RETURN n;
END $$

/*
	jf a user wants to join the block, all people in the block receives that request message
*/
DROP TRIGGER IF EXISTS JoinAfterTrigger;
DELIMITER $$
CREATE TRIGGER JoinAfterTrigger
    AFTER INSERT
    ON Joins FOR EACH ROW
BEGIN

	DECLARE first_name VARCHAR(30);
    DECLARE last_name VARCHAR(30);
    SELECT fname INTO first_name FROM Users WHERE email = new.req_email;
    SELECT lname INTO last_name FROM Users WHERE email = new.req_email;
    
	IF nPeopleInBlock(new.bid)>0 AND NOT (nPeopleInBlock(new.bid) = 1 AND new.jstatus = 'JOINED') THEN
		 /* all people in the block receives that request*/
		INSERT INTO Thread(ttype, email, title, start_time, target_bid)
		SELECT 'JoinBlock', new.req_email, CONCAT('Hi, ', first_name, ' ', last_name, ' wants to join your block.'), new.request_time, new.bid;        
    END IF;

END$$


/*Friend Trigger*/
DROP TRIGGER IF EXISTS FriendTrigger;
DELIMITER $$
CREATE TRIGGER FriendTrigger
    AFTER INSERT
    ON Friend FOR EACH ROW
BEGIN
	DECLARE first_name VARCHAR(30);
    DECLARE last_name VARCHAR(30);
    SELECT fname INTO first_name FROM Users WHERE email = new.uid1;
    SELECT lname INTO last_name FROM Users WHERE email = new.uid1;
    
	INSERT INTO Thread(ttype, email, title, start_time, target_uid)
	SELECT 'FriendRequest', new.uid1, CONCAT('Hi, ', first_name, ' ', last_name, ' wants to be your friend.'), new.request_time, new.uid2;    
    
END $$



/*
Approve Trigger :
update Join status if more than three/all users in a block approves
*/
DROP TRIGGER IF EXISTS ApproveTrigger;
DELIMITER $$
CREATE TRIGGER ApproveTrigger
    AFTER INSERT
    ON Approves FOR EACH ROW
BEGIN	

    DECLARE totaln INT;
	DECLARE approven INT;
    DECLARE rejectn INT;
    
    /*number of people in the block*/
    SELECT nPeopleInBlock(new.bid) INTO totaln;
    /*number of people approves that join*/
    SELECT count(email)
    INTO approven
    FROM Approves
    WHERE Approves.req_email = new.req_email AND
		  Approves.bid = new.bid AND
          Approves.request_time = new.request_time
          AND choice = 'APPROVE';
          
	/*number of people who rejects that join*/
	SELECT count(email)
    INTO rejectn
    FROM Approves
    WHERE Approves.req_email = new.req_email AND
		  Approves.bid = new.bid AND
          Approves.request_time = new.request_time
          AND choice = 'REJECT';
	
    /*if all people in the block rejects that join request, then this join fails*/
    IF  (totaln = rejectn)  THEN
		UPDATE Joins SET jstatus = 'REJECTED', result_time = new.choice_time
        WHERE Joins.req_email = new.req_email AND
        Joins.bid = new.bid AND
        Joins.request_time = new.request_time;
	
    END IF;

    /*if all people approves or at least three approves, then the join succeed*/
    IF   (totaln<3 and totaln = approven) or (totaln >=3 and approven >=3)  THEN
		UPDATE Joins SET jstatus = 'JOINED', result_time = new.choice_time
        WHERE Joins.req_email = new.req_email AND
        Joins.bid = new.bid AND
        Joins.request_time = new.request_time;
    END IF;
	
    
	UPDATE ACCESS SET stat = 'NONACTIVE'
    WHERE tid IN 
		(SELECT tid FROM Thread 
		WHERE ttype = 'JoinBlock' AND email = new.req_email AND target_bid = new.bid)
	AND email = new.email;
    
END$$


 /*people who joined the block will be able to see all previous join requests*/
DROP TRIGGER IF EXISTS JoinStatusUpdateTrigger;
DELIMITER $$
CREATE TRIGGER JoinStatusUpdateTrigger
    AFTER UPDATE
    ON Joins FOR EACH ROW
BEGIN
    /*change access list*/
    IF old.jstatus <>'JOINED' AND new.jstatus = 'JOINED' THEN 
		/*retrieve all threads about join request (in 'WAIT' status) in that block*/
		INSERT INTO Access(tid, email, stat)
		SELECT tid, new.req_email, 'ACTIVE'
		FROM Thread Join Joins 
		WHERE
		ttype = 'JoinBlock' AND
		title = 'Join Request' AND
		target_bid IS NOT NULL and target_bid = new.bid AND
        Thread.email = Joins.req_email AND /*whoever sends the request still waits*/
        Joins.jstatus = 'WAIT';
        
        /*retrieve all messages about join request in that block*/
        INSERT INTO Receives(mid, email, stat, receive_time)
        SELECT mid, new.req_email, 'UNREAD', new.result_time
        FROM Message Join Thread USING (tid) Join Joins 
        WHERE 
        ttype = 'JoinBlock' AND
		title = 'Join Request' AND
		target_bid IS NOT NULL and target_bid = new.bid AND
        Thread.email = Joins.req_email AND /*whoever sends the request still waits*/
        Joins.jstatus = 'WAIT';
        
        
        /*delete thread*/
        DELETE FROM Thread
        WHERE ttype = 'JoinBlock' AND
        email = new.req_email AND target_bid = new.bid;
        
    END IF;
    
    
    /*
		if a user leaves a block, then for all block/hood thread the access state becomes invalid
    */
    IF old.jstatus ='JOINED' AND new.jstatus = 'LEAVE' THEN 
        UPDATE ACCESS SET stat = 'NONACTIVE'
        WHERE Access.tid IN 
        (SELECT tid FROM 
        Thread 
        WHERE 
        ttype = 'Hood'  OR ttype = 'Block' OR ttype = 'JoinBlock' OR ttype = 'Neighbour') 
        AND Access.email = new.req_email;
        
    END IF;
    
END$$

/*
Thread Trigger: 
User who creates the thread will have the access to it
If User specify 'Hoods' in the receipients, then all people in the hood will be added to the receipient list
If User specify 'Blocks' in the receipients, then all people in the block will be added to the receipient list
If User specify 'AllFriends' in the receipients, then all friends will be added to the receipient list 
If User specify 'JoinBlocks', then all people in the block will be added to the receipient list
*/
DROP TRIGGER IF EXISTS ThreadTrigger;
DELIMITER $$
CREATE TRIGGER ThreadTrigger
    AFTER INSERT
    ON Thread FOR EACH ROW
BEGIN
    /*check if the user is in the block*/
    /*all people in block*/
    DECLARE inBlock INT;
    DECLARE isFriend INT;
    DECLARE current_block INT;
    DECLARE current_hood INT;
    
    /* number of blocks that person is in*/
    SELECT count(req_email) INTO inBlock
    FROM Joins 
    WHERE Joins.req_email = new.email AND Joins.jstatus = 'JOINED';

    IF new.ttype = 'FriendRequest' THEN
			
            SELECT count(*) INTO isFriend
			FROM Friend
			WHERE uid1 = new.email AND uid2 = new.target_uid
			AND stat = 'APPROVED'
            OR 
            uid1 = new.target_uid AND uid2 = new.email
			AND stat = 'APPROVED';
            
            if isFriend= 0 AND new.target_uid IS NOT NULL THEN 
				INSERT INTO Access (tid, email, stat)
				SELECT new.tid, new.target_uid, 'ACTIVE';
				
				INSERT INTO Message(tid, email, body, send_time)
				SELECT new.tid, new.email, 
				CONCAT('Hi, ', new.email, ' wants to be your friend.'), new.start_time;
            END IF;

			
    END IF;

	/*the user is not in the block yet, then it is about a join request*/
    IF inBlock=0 AND new.target_bid IS NOT NULL AND new.ttype = 'JoinBlock' THEN
			/*all people in that block can read to the join request*/
			INSERT INTO Access (tid, email, stat)
			SELECT new.tid, Joins.req_email, 'ACTIVE'
			FROM Joins
			WHERE Joins.bid = new.target_bid AND Joins.jstatus = 'JOINED'; 
            
            INSERT INTO Message(tid, email, body, send_time)
			SELECT new.tid, new.email, 
			CONCAT('Hi, ', new.email, ' wants to join your block.'), new.start_time;
        -- END IF;
    END IF;

    IF inBlock=1 THEN
		/*get current_block*/
		SELECT bid INTO current_block
		FROM Joins 
		WHERE Joins.req_email = new.email AND Joins.jstatus = 'JOINED'
		ORDER BY Joins.request_time DESC LIMIT 1;

        /*get current_hood*/
        SELECT hid INTO current_hood
        FROM Blocks 
        WHERE Blocks.bid = current_block;
       
        IF new.ttype = 'Block' OR new.ttype = 'JoinBlock' THEN 
			/*all people in that block*/
			INSERT INTO Access (tid, email, stat)
			SELECT new.tid, req_email, 'ACTIVE'
			FROM Joins
			WHERE Joins.bid = current_block AND Joins.jstatus = 'JOINED'; 
        END IF;
        
		IF new.ttype = 'Hood' THEN 
			/*all people in that hood*/
			INSERT INTO Access (tid, email, stat)
			SELECT new.tid, Joins.req_email, 'ACTIVE'
			FROM Joins JOIN Blocks using (bid)
			WHERE Joins.jstatus = 'JOINED'
            AND Blocks.hid = current_hood; 
        END IF;
        
    END IF;

	IF new.ttype = 'Friend' OR new.ttype = 'Neighbour' THEN
		INSERT INTO Access (tid, email, stat)
        VALUES(new.tid, new.email, 'ACTIVE');
    END IF;
    
    IF new.ttype = 'ALLFRIENDS' THEN 
		INSERT INTO Access (tid, email, stat)
        VALUES(new.tid, new.email, 'ACTIVE');
        
		INSERT INTO Access (tid, email, stat)
        SELECT new.tid, uid2, 'ACTIVE' 
        FROM Friend WHERE uid1 = new.email AND stat = 'APPROVED'
        UNION
        SELECT new.tid, uid1, 'ACTIVE' 
        FROM Friend WHERE uid2 = new.email AND stat = 'APPROVED';
    END IF;
    
END$$

/*
Message Trigger: 
When a new message is sent
update the receives table (all receipients sepecified in the Thread)
*/
DROP TRIGGER IF EXISTS MessageReceiveTrigger;
DELIMITER $$
CREATE TRIGGER MessageReceiveTrigger
    AFTER INSERT
    ON Message FOR EACH ROW
BEGIN
    /*all receipients*/
	INSERT INTO Receives (mid, email, stat, receive_time)
    SELECT new.mid, Access.email, 'UNREAD', Message.send_time FROM 
    Message JOIN Thread USING (tid) JOIN Access USING (tid)
    WHERE Message.mid = new.mid AND
    Access.stat = 'ACTIVE';
END$$

DROP TRIGGER IF EXISTS FriendStatUpdateTrigger;
DELIMITER $$
CREATE TRIGGER FriendStatUpdateTrigger
    AFTER UPDATE
    ON Friend FOR EACH ROW
BEGIN

	/* uid1 uid2*/
    IF old.stat = 'REQUESTED' AND new.stat <> 'REQUESTED' THEN
		/* update thread stat*/
		DELETE FROM Thread 
		WHERE ttype = 'FriendRequest'
		AND email = new.uid1 AND target_uid = new.uid2
		OR email = new.uid2 AND target_uid = new.uid1;
        
	END IF;
   
END$$



