-- call CreateAccount('mp5386@gmail.com', 'Myuan', 'Pang', 'Female', 'password');
-- SELECT ValidateUser('mp5386@gmail.com', 'password');
-- call EnterAddress('mp5386@gmail.com', 'APT 10', '274 Dean Street', 'Brooklyn', 'New York');

use PROJECT1;
-- SELECT * FROM Users;
-- SELECT * FROM Address;

call listAllNews('Od356@gmail.com');
call listAllFriendRequests('Od356@gmail.com');
call listAllBlockRequests('Od356@gmail.com');

-- SELECT getCurrentBlock('Od356@gmail.com');
-- SELECT getCurrentBlock('mp5386@gmail.com');
call ListAvailbleBlocksFor('Od356@gmail.com');
-- SELECT * FROM Access;
SELECT * FROM Thread;  
-- call getProfile('Od356@gmail.com');
call getAllFeeds('Od356@gmail.com');
call getFriendFeeds('Od356@gmail.com');
call getNeighbourFeeds('Od356@gmail.com');
call getBlockFeeds('Od356@gmail.com');
call getHoodFeeds('Od356@gmail.com');

SELECT getCurrentBlock('Od356@gmail.com');
call leaveBlock('Od356@gmail.com', 2);
call getAllFeeds('Od356@gmail.com');
call StartMessageIn('Nj303@gmail.com', 'Hood',
					'Sec Message in Hood', 'This is the second message in Hood.');
                                        
-- call getNeighbourFeeds('Nj303@gmail.com');
-- SELECT hasUnreadRequest('Yc4184@gmail.com');
-- SELECT hasUnreadRequest('mp5386@gmail.com');
SELECT * FROM Access;
SELECT * FROM Thread;
SELECT * FROM Message;
SELECT * FROM Receives;
call getThreadInfo(100);
call getMessageFromThread(100);

-- SELECT getCurrentHood('Od356@gmail.com');
-- SELECT getCurrentHood('mp5386@gmail.com');
call ListAllFriends('Od356@gmail.com');
call ListAllNeighbours('Qc690@gmail.com');


SELECT CURRENT_TIMESTAMP();

SELECT * FROM RECEIVES;

-- call sendFriendRequest('Nj303@gmail.com', 'Od356@gmail.com');
-- call respondToFriendRequest('Od356@gmail.com', 'Nj303@gmail.com', 'APPROVED');
SELECT * FROM Friend;
call listAllFriends('Nj303@gmail.com');
call listAllFriends('Od356@gmail.com');
call addNeighbour('Nj303@gmail.com', 'Od356@gmail.com');
call ListAllNeighbours('Nj303@gmail.com');

call readMessgesInThread('py615@gmail.com', 100);
SELECT * FROM Receives JOIN Message USING (mid) WHERE Receives.email = 'py615@gmail.com';

