Use Project1;

/*set up hoods and blocks*/
INSERT INTO Hoods(hname, southwest_long, southwest_lat, northeast_long, northeast_lat) VALUES
('Downtown Brooklyn', 40.691928, -73.993051, 40.705222, -73.981389);

INSERT INTO Blocks(bname, southwest_long, southwest_lat, northeast_long, northeast_lat, hid) VALUES
('Downtown Brooklyn Upper Block', 40.694759, -73.991206, 40.705222, -73.981389, 1), /*amberly 2*/
('Downtown Brooklyn Lower Block', 40.691928, -73.993051, 40.695215, -73.981389, 1); /*addison 1*/

/*
set up Users and their addresses
Addison: lower block
Amberly: upper block
*/

INSERT INTO Address (address, city, state, country, longtitude, latitude) VALUES
('The Addison 225 Schermerhorn Street', 'Brooklyn', 'New York', 'U.S', 40.688878, -73.984662),
('The Amberly Apartments 120 Nassau Street', 'Brooklyn', 'New York', 'U.S', 40.698528, -73.986615);

INSERT INTO Users(email, fname, lname, gender, pword, aid, apt) VALUES
('Od356@gmail.com', 'Oliver', 'David', 		'Male', 	'password', 1, '15A'), /*addison*/
('py615@gmail.com', 'Piao', 'Yang', 		'Male', 	'password', 1, '15A'), /*addison*/
('hz2162@gmail.com', 'Hui', 'Zhen', 		'Male', 	'password', 1, '15A'), /*addison*/
('Yc4184@gmail.com', 'Yue', 'Chen', 		'Female', 	'password', 1, '13B'), /*addison*/
('Nj303@gmail.com', 'Nikka', 'Jack', 		'Female', 	'password', 2, '2F'),  /*amberly*/
('Qc690@gmail.com', 'Qi', 'Yang', 			 'Male', 	'password', 2, '9E');  /*amberly*/

call EditProfile('Od356@gmail.com', 'Hi my name is Oliver', 'Od20190801.jpg');

/*
If there is no one in the block, the user can join it directly
otherwise
the default join status is wait and it will be updated when the join is approved*/

call JoinBlock('Od356@gmail.com',  2, '2019-10-01 09:00:00');
call JoinBlock('py615@gmail.com',  2, '2019-10-01 09:00:00');
call JoinBlock('Yc4184@gmail.com',  2, '2019-10-01 09:00:00');
call JoinBlock('hz2162@gmail.com',  2, '2019-10-01 09:00:00');

-- INSERT INTO JOINS (req_email, bid, request_time, jstatus, result_time) VALUES
-- ('Od356@gmail.com',  2, '2019-10-01 09:00:00', 'JOINED', '2019-10-01 09:00:00');

-- INSERT INTO JOINS (req_email, bid, request_time, jstatus) VALUES
-- ('py615@gmail.com',	 2, '2019-10-01 09:00:00', 'WAIT'),
-- ('Yc4184@gmail.com', 2, '2019-10-01 09:00:00', 'WAIT'),
-- ('hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'WAIT');


/*
Join status will be updated
*/

INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES 
('Od356@gmail.com', 'py615@gmail.com',  2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 09:00:00'),
('Od356@gmail.com', 'Yc4184@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 10:00:00'),
('Od356@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 11:00:00'),
('py615@gmail.com', 'Yc4184@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-03 09:00:00'),
('py615@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-03 10:00:00'),
('Yc4184@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-04 09:00:00')
;


call JoinBlock('Nj303@gmail.com', 1, '2019-10-01 09:00:00');
call JoinBlock('Qc690@gmail.com', 1, '2019-10-01 09:00:00');

INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES
('Nj303@gmail.com', 'Qc690@gmail.com', 1, '2019-10-01 09:00:00', 'REJECT', '2019-10-02 09:00:00');

call JoinBlock('Qc690@gmail.com', 1, '2019-11-01 09:00:00');

INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES
('Nj303@gmail.com', 'Qc690@gmail.com', 1, '2019-11-01 09:00:00', 'APPROVE', '2019-11-02 09:00:00');


/*
if there no one is in the block, then the first person joins it automatically
after be rejected, a user can send the join request again
while waiting, the user cannot send the request again
he/she can only re-join after being rejected
*/

INSERT INTO FRIEND (uid1, uid2, stat, request_time) VALUES
('Od356@gmail.com', 'Yc4184@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
('Od356@gmail.com', 'py615@gmail.com',  'REQUESTED', '2019-10-15 09:00:00'),
('Od356@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
('py615@gmail.com', 'Yc4184@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
('py615@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
('Yc4184@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00');

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'Yc4184@gmail.com';

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'py615@gmail.com';

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'hz2162@gmail.com';

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'py615@gmail.com' AND uid2 = 'Yc4184@gmail.com';

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'py615@gmail.com' AND uid2 = 'hz2162@gmail.com';

UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
WHERE uid1 = 'Yc4184@gmail.com' AND uid2 = 'hz2162@gmail.com';

INSERT INTO NEIGHBOUR (uid1, uid2, request_time, stat) VALUES 
('Qc690@gmail.com', 'Nj303@gmail.com', '2019-11-15 09:00:00', 'VALID'),
('Nj303@gmail.com', 'Qc690@gmail.com', '2019-11-15 09:00:00', 'VALID');


INSERT INTO Thread (tid, ttype, title, email, start_time) VALUES
(100,  'AllFriends', 'Does anyone wants to join me?', 		 'Od356@gmail.com', '2019-10-15 09:00:00');

INSERT INTO Message(tid, email, body, send_time) VALUES
(100, 'Od356@gmail.com', 'I am going to the MET this Sat. Anyone wants to join?', '2019-10-15 09:00:00'),
(100, 'py615@gmail.com', "I'm in!", '2019-10-15 09:01:00'),
(100, 'hz2162@gmail.com', "Me too.", '2019-10-15 09:02:00'),
(100, 'Od356@gmail.com', 'Great!', '2019-10-15 09:03:00');

-- INSERT INTO Thread (tid, ttype, title, email, start_time) VALUES
-- (101,  'Block', 	 'To All People in lower Downtown BK', 	 'Od356@gmail.com', '2019-10-15 09:00:00');

-- INSERT INTO Thread (tid, ttype, title, email, start_time) VALUES
-- (200,  'Hood', 		 'Christmas events in Downtown Brooklyn','Od356@gmail.com', '2019-10-15 09:00:00');

-- INSERT INTO Thread (tid, ttype, title, email, start_time) VALUES
-- (201,  'Friend', 	 'Yang lets watch movies tonight', 		 'Od356@gmail.com', '2019-10-15 09:00:00');
-- INSERT INTO Access (tid, email, stat) VALUES
-- (201, 'py615@gmail.com', 'ACTIVE');

--                              
-- INSERT INTO Thread (tid, ttype, title, email, start_time, target_uid) VALUES
-- (202,  'Neighbour',  'Hi Jack, I just want to say hello',       'Qc690@gmail.com', '2019-10-15 09:00:00');

call StartMessageWith('Od356@gmail.com', 'py615@gmail.com', 'Friend',
					'Greeting From Oliver', 'Hi there.');


call StartMessageWith('Qc690@gmail.com', 'Nj303@gmail.com', 'Neighbour',
					'Greeting', 'Hi Jack, I just want to say hello.');

call StartMessageIn('Nj303@gmail.com', 'Hood',
					'First Message in Hood', 'This is the first message in Hood.');
call StartMessageIn('Nj303@gmail.com', 'Block',
					'First Message in Block', 'This is the first message in Block.');

call StartMessageIn('py615@gmail.com', 'Block', 'Block msg', 'Hi friends.');
                    
call sendFriendRequest('Nj303@gmail.com', 'Od356@gmail.com');
call respondToFriendRequest('Od356@gmail.com', 'Nj303@gmail.com', 'APPROVED');


