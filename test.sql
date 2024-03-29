Use Project1;

/*set up hoods and blocks*/
INSERT INTO Hoods(hname, southwest_lat, southwest_long, northeast_lat, northeast_long) VALUES
('Downtown Brooklyn', 40.691928, -73.993051, 40.705222, -73.981389);

INSERT INTO Blocks(bname, southwest_lat, southwest_long, northeast_lat, northeast_long, hid) VALUES
('Downtown Brooklyn Upper Block', 40.694535, -74.001419, 40.705189, -73.978338, 1), /*amberly 2*/
('Downtown Brooklyn Lower Block', 40.685888, -74.002498, 40.694797, -73.974655, 1); /*addison 1*/

call CreateAccount('Od356@gmail.com', 'Oliver', 'David', 	'Male', 	'password');
call CreateAccount('py615@gmail.com', 'Piao', 'Yang', 		'Male', 	'password');
call CreateAccount('hz2162@gmail.com', 'Hui', 'Zhen', 		'Male', 	'password');
call CreateAccount('Yc4184@gmail.com', 'Yue', 'Chen', 		'Female', 	'password');
call CreateAccount('Nj303@gmail.com', 'Nikka', 'Jack', 		'Female', 	'password');
call CreateAccount('Qc690@gmail.com', 'Qi', 'Yang', 		'Male', 	'password');

call EnterAddress('Od356@gmail.com', '15A', 40.688919, -73.984866);
call EnterAddress('py615@gmail.com', '15A', 40.688919, -73.984866);
call EnterAddress('hz2162@gmail.com', '15A', 40.688919, -73.984866);
call EnterAddress('Yc4184@gmail.com', '15A', 40.688919, -73.984866);

call EnterAddress('Nj303@gmail.com', '15A', 40.698552, -73.986239);
call EnterAddress('Qc690@gmail.com', '15A', 40.698552, -73.986239);


call listNearBlocks('Od356@gmail.com', 40.688919, -73.984866);
-- SELECT 40.688919 > 40.685888 AND 40.688919 < 40.694797
-- AND -73.984866 >  -74.002498 AND -73.984866 < -73.974655;

-- INSERT INTO Users(email, fname, lname, gender, pword, aid, apt) VALUES
-- ('Od356@gmail.com', 'Oliver', 'David', 		'Male', 	'password', 1, '15A'), /*addison*/
-- ('py615@gmail.com', 'Piao', 'Yang', 		'Male', 	'password', 1, '15A'), /*addison*/
-- ('hz2162@gmail.com', 'Hui', 'Zhen', 		'Male', 	'password', 1, '15A'), /*addison*/
-- ('Yc4184@gmail.com', 'Yue', 'Chen', 		'Female', 	'password', 1, '13B'), /*addison*/
-- ('Nj303@gmail.com', 'Nikka', 'Jack', 		'Female', 	'password', 2, '2F'),  /*amberly*/
-- ('Qc690@gmail.com', 'Qi', 'Yang', 			 'Male', 	'password', 2, '9E');  /*amberly*/

call EditProfile('Od356@gmail.com', 'Hi my name is Oliver', 'Od20190801.jpg');

/*
If there is no one in the block, the user can join it directly
otherwise
the default join status is wait and it will be updated when the join is approved*/

call JoinBlock('Od356@gmail.com', 2);
call JoinBlock('py615@gmail.com', 2);
call JoinBlock('Yc4184@gmail.com', 2);
call JoinBlock('hz2162@gmail.com', 2);

-- INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES 
-- ('Od356@gmail.com', 'py615@gmail.com',  2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 09:00:00'),
-- ('Od356@gmail.com', 'Yc4184@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 10:00:00'),
-- ('Od356@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-02 11:00:00'),
-- ('py615@gmail.com', 'Yc4184@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-03 09:00:00'),
-- ('py615@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-03 10:00:00'),
-- ('Yc4184@gmail.com', 'hz2162@gmail.com', 2, '2019-10-01 09:00:00', 'APPROVE', '2019-10-04 09:00:00')
-- ;

-- call JoinBlock('Nj303@gmail.com', 1, '2019-10-01 09:00:00');
-- call JoinBlock('Qc690@gmail.com', 1, '2019-10-01 09:00:00');

-- INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES
-- ('Nj303@gmail.com', 'Qc690@gmail.com', 1, '2019-10-01 09:00:00', 'REJECT', '2019-10-02 09:00:00');

-- call JoinBlock('Qc690@gmail.com', 1, '2019-11-01 09:00:00');

-- INSERT INTO Approves(email, req_email, bid, request_time, choice, choice_time) VALUES
-- ('Nj303@gmail.com', 'Qc690@gmail.com', 1, '2019-11-01 09:00:00', 'APPROVE', '2019-11-02 09:00:00');


/*
if there no one is in the block, then the first person joins it automatically
after be rejected, a user can send the join request again
while waiting, the user cannot send the request again
he/she can only re-join after being rejected
*/

-- INSERT INTO FRIEND (uid1, uid2, stat, request_time) VALUES
-- ('Od356@gmail.com', 'Yc4184@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
-- ('Od356@gmail.com', 'py615@gmail.com',  'REQUESTED', '2019-10-15 09:00:00'),
-- ('Od356@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
-- ('py615@gmail.com', 'Yc4184@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
-- ('py615@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00'),
-- ('Yc4184@gmail.com', 'hz2162@gmail.com', 'REQUESTED', '2019-10-15 09:00:00');

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'Yc4184@gmail.com';

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'py615@gmail.com';

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'Od356@gmail.com' AND uid2 = 'hz2162@gmail.com';

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'py615@gmail.com' AND uid2 = 'Yc4184@gmail.com';

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'py615@gmail.com' AND uid2 = 'hz2162@gmail.com';

-- UPDATE FRIEND SET stat = 'APPROVED', establish_time = '2019-10-15 10:00:00'
-- WHERE uid1 = 'Yc4184@gmail.com' AND uid2 = 'hz2162@gmail.com';

-- INSERT INTO NEIGHBOUR (uid1, uid2, request_time, stat) VALUES 
-- ('Qc690@gmail.com', 'Nj303@gmail.com', '2019-11-15 09:00:00', 'VALID'),
-- ('Nj303@gmail.com', 'Qc690@gmail.com', '2019-11-15 09:00:00', 'VALID');


-- INSERT INTO Thread (tid, ttype, title, email, start_time) VALUES
-- (100,  'AllFriends', 'Does anyone wants to join me?', 		 'Od356@gmail.com', '2019-10-15 09:00:00');

-- INSERT INTO Message(tid, email, body, send_time) VALUES
-- (100, 'Od356@gmail.com', 'I am going to the MET this Sat. Anyone wants to join?', '2019-10-15 09:00:00'),
-- (100, 'py615@gmail.com', "I'm in!", '2019-10-15 09:01:00'),
-- (100, 'hz2162@gmail.com', "Me too.", '2019-10-15 09:02:00'),
-- (100, 'Od356@gmail.com', 'Great!', '2019-10-15 09:03:00');

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

-- call StartMessageWith('Od356@gmail.com', 'py615@gmail.com', 'Friend',
-- 					'Greeting From Oliver', 'Hi there.');


-- call StartMessageWith('Qc690@gmail.com', 'Nj303@gmail.com', 'Neighbour',
-- 					'Greeting', 'Hi Jack, I just want to say hello.');

-- call StartMessageIn('Nj303@gmail.com', 'Hood',
-- 					'First Message in Hood', 'This is the first message in Hood.');
-- call StartMessageIn('Nj303@gmail.com', 'Block',
-- 					'First Message in Block', 'This is the first message in Block.');

-- call StartMessageIn('py615@gmail.com', 'Block', 'Block msg', 'Hi friends.');
--  --                    


