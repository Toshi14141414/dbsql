-- call CreateAccount('mp5386@gmail.com', 'Myuan', 'Pang', 'Female', 'password');
-- SELECT ValidateUser('mp5386@gmail.com', 'password');
-- call EnterAddress('mp5386@gmail.com', 'APT 10', '274 Dean Street', 'Brooklyn', 'New York');

use PROJECT1;
-- SELECT * FROM Users;
-- SELECT * FROM Address;

-- SELECT getCurrentBlock('Od356@gmail.com');
-- SELECT getCurrentBlock('mp5386@gmail.com');
  
-- SELECT * FROM Access;
-- SELECT * FROM Thread;  
-- call getProfile('Od356@gmail.com');
call getAllFeeds('Od356@gmail.com');
call getFriendFeeds('Od356@gmail.com');
-- call getNeighbourFeeds('Nj303@gmail.com');
-- SELECT hasUnreadRequest('Yc4184@gmail.com');
-- SELECT hasUnreadRequest('mp5386@gmail.com');
-- SELECT * FROM Access;
-- SELECT * FROM Thread;
-- SELECT * FROM Message;
-- SELECT * FROM Receives;


-- SELECT getCurrentHood('Od356@gmail.com');
-- SELECT getCurrentHood('mp5386@gmail.com');
call ListAllFriends('Od356@gmail.com');
call ListAllNeighbours('Qc690@gmail.com');