-- SELECT * FROM Users;
-- SELECT * FROM Friend;
-- SELECT * FROM Neighbour;
-- SELECT * FROM Address;
-- SELECT * FROM Blocks;
-- SELECT * FROM Hoods;
-- SELECT * FROM Joins;
-- -SELECT * FROM Approves;
-- SELECT * FROM Thread;
-- SELECT * FROM Message;
-- SELECT * FROM Access;
-- SELECT * FROM Receives;

-- call ListAllNeighbours('Qc690@gmail.com');
-- call ListAllFriends('py615@gmail.com');
-- SELECT bid, req_email, jstatus, hid FROM Joins Join Blocks using (bid) where jstatus = 'JOINED';
	
    
	/* all threads in the friends feed*/
    call ListThreadFeed('py615@gmail.com', 'Friend', 'UNREAD');

    call ListThreadFeed('Qc690@gmail.com', 'Neighbour', 'UNREAD');
    
-- 	SELECT DISTINCT tid
--     FROM Access JOIN Thread USING (tid) JOIN Message USING (tid) JOIN Receives USING (mid)
--     WHERE 
-- 	Access.email = 'py615@gmail.com' AND ttype = 'AllFriends'
--     AND Receives.stat = 'UNREAD' ;

    call SearchMessageWith('py615@gmail.com', 'Great');