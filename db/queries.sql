#-----Ricerca-----

#-----per artisti-----
SELECT * 
FROM Artist 
WHERE Artist.name LIKE '%Imagine%';

#-----per utenti-----
SELECT * 
FROM User 
WHERE User.username LIKE '%Emma rock%';

#-----per playlist-----
SELECT * 
FROM Playlist,User 
WHERE User.id=Playlist.creator AND Playlist.name LIKE '%This is Gospel%';

#-----per album-----
SELECT * 
FROM Album, Artist, Making 
WHERE Album.id=Making.album AND Artist.id=Making.artist AND Album.title LIKE '%If I Know Me%';

#-----per tracks-----
SELECT * 
FROM Track,Artist,Album,TrackBelongsToAlbum,Making 
WHERE Track.id=TrackBelongsToAlbum.track AND Album.id=TrackBelongsToAlbum.album AND Making.album=Album.id AND Making.artist=Artist.id AND Track.title LIKE '%What%';

SELECT * 
FROM Track,Features,Artist 
WHERE Track.id=Features.track AND Artist.id=Features.artist AND Track.title LIKE '%What%';


#-----Aggiunta brano in una playlist-----
-- INSERT INTO TrackBelongsToPlaylist(track, playlist, addedDate)
-- VALUES('22zRzwWJp3gfM1O00CsRGm', 'PrsS4E1r054PsZUyl4MTix', NOW());


-- #-----Similarity tra canzoni-----
-- SELECT * FROM Track track1 INNER JOIN Track track2 ON track1.id < track2.id;


-- #-----Inserimento similarity tra canzoni
-- INSERT INTO Similarity(track1,track2,amount)
-- VALUES (track1,track2,'amount');

-- UPDATE Track SET plays = 5 WHERE id='5dVUSdsePmEKkq4ryfrobU';


#-----Visualizzazione numero ascolti dell’ultimo mese per artisti
SELECT  SUM(plays) plays
FROM( 
            SELECT SUM(Track.plays) plays
						FROM ((((Artist JOIN Making ON Making.artist=Artist.id) JOIN Album on Making.Album=Album.id) JOIN TrackBelongsToAlbum on TrackBelongsToAlbum.Album=Album.id) JOIN Track ON TrackBelongsToAlbum.track=Track.id)
						WHERE Artist.id='04gDigrS5kc9YWfZHwBETP'
            UNION ALL
            SELECT SUM(Track.plays) plays
						FROM ((Artist JOIN Features ON Artist.id=Features.artist) JOIN Track ON Track.id=Features.track)
						WHERE Artist.id='04gDigrS5kc9YWfZHwBETP'
) LastMonthPlays;


#-----Visualizzazione numero di like ultimo mese per utenti
SELECT COUNT(LikesTrack.track)
FROM (User JOIN LikesTrack on User.id=LikesTrack.user)
WHERE User.id='QKedDkxLZFOPQS8pAhkj01' AND LikesTrack.date > DATE_ADD(NOW(),INTERVAL -30 DAY);

SELECT COUNT(LikesPlaylist.playlist)
FROM (User JOIN LikesPlaylist on User.id=LikesPlaylist.user)
WHERE User.id='QKedDkxLZFOPQS8pAhkj01' AND LikesPlaylist.date > DATE_ADD(NOW(),INTERVAL -30 DAY); 

SELECT COUNT(LikesAlbum.album)
FROM (User JOIN LikesAlbum on User.id=LikesAlbum.album)
WHERE User.id='QKedDkxLZFOPQS8pAhkj01' AND LikesAlbum.date > DATE_ADD(NOW(),INTERVAL -30 DAY);


#-----Visualizzazione nomi dei followers
SELECT Follower.id,Follower.username
FROM ((User AS MainUser JOIN FollowUser ON MainUser.id=FollowUser.followed) JOIN User AS Follower ON Follower.id=FollowUser.follower)
WHERE MainUser.id='QKedDkxLZFOPQS8pAhkj01';


#-----Richiesta URL tracks
SELECT Track.audio
FROM Track
WHERE Track.id='22zRzwWJp3gfM1O00CsRGm';


#-----Like Bomb playlist
SELECT track
FROM TrackBelongsToPlaylist
WHERE playlist="id_playlist";

#then, inside a loop for each track id
-- INSERT INTO LikesTrack(user,track,date)
-- VALUES ('userid','trackid', NOW());


#-----Classifica autori più ascoltati della settimana [high time complexity]
SELECT  ID, NAME, SUM(NListen) TotalListen
FROM ( 
            SELECT Artist.id ID,Artist.name NAME,COUNT(ListenedTo.track) NListen
						FROM (((((Artist JOIN Making ON Making.artist=Artist.id) JOIN Album on Making.Album=Album.id) JOIN TrackBelongsToAlbum on TrackBelongsToAlbum.Album=Album.id) JOIN Track ON TrackBelongsToAlbum.track=Track.id) JOIN ListenedTo ON ListenedTo.track=Track.id)
						WHERE ListenedTo.date > DATE_ADD(NOW(),INTERVAL -7 DAY)
						GROUP BY Artist.id,Artist.name
            UNION ALL
            SELECT Artist.id ID,Artist.name NAME,COUNT(ListenedTo.track) NListen
						FROM (((Artist JOIN Features ON Artist.id=Features.artist) JOIN Track ON Track.id=Features.track) JOIN ListenedTo ON Track.id=ListenedTo.track)
						WHERE ListenedTo.date > DATE_ADD(NOW(),INTERVAL -7 DAY)
						GROUP BY Artist.id,Artist.name
) WeeklyLeaderboard
GROUP BY ID, NAME
ORDER BY TotalListen DESC;


#-----Calcolo revenue ( (0.30/100plays+0.8/100like)/settimana )
-- DROP VIEW WeeklyLeaderboard;
-- DROP VIEW WeeklyLikes;

CREATE VIEW WeeklyLeaderboard AS
SELECT  ID, NAME, SUM(NListen) TotalListen
FROM ( 
            SELECT Artist.id ID,Artist.name NAME,COUNT(ListenedTo.track) NListen
						FROM (((((Artist JOIN Making ON Making.artist=Artist.id) JOIN Album on Making.Album=Album.id) JOIN TrackBelongsToAlbum on TrackBelongsToAlbum.Album=Album.id) JOIN Track ON TrackBelongsToAlbum.track=Track.id) JOIN ListenedTo ON ListenedTo.track=Track.id)
						WHERE DATE_ADD(NOW(),INTERVAL -7 DAY) < ListenedTo.date
						GROUP BY Artist.id
            UNION ALL
            SELECT Artist.id ID,Artist.name NAME,COUNT(ListenedTo.track) NListen
						FROM (((Artist JOIN Features ON Artist.id=Features.artist) JOIN Track ON Track.id=Features.track) JOIN ListenedTo ON Track.id=ListenedTo.track)
						WHERE DATE_ADD(NOW(),INTERVAL -7 DAY) < ListenedTo.date
						GROUP BY Artist.id
) WeeklyLeaderboard
GROUP BY ID, NAME
ORDER BY TotalListen DESC;

SELECT * FROM WeeklyLeaderboard;

CREATE VIEW WeeklyLikes AS 
SELECT ID, NAME, SUM(NLikes) TotalLikes
FROM(
						SELECT Artist.id ID,Artist.name NAME,COUNT(LikesTrack.track) NLikes
						FROM (((((Artist JOIN Making ON Making.artist=Artist.id) JOIN Album on Making.Album=Album.id) JOIN TrackBelongsToAlbum on TrackBelongsToAlbum.Album=Album.id) JOIN Track ON TrackBelongsToAlbum.track=Track.id) JOIN LikesTrack ON LikesTrack.track=Track.id)
						WHERE DATE_ADD(NOW(),INTERVAL -7 DAY) < LikesTrack.date
						GROUP BY Artist.id
						UNION ALL
						SELECT Artist.id ID,Artist.name NAME,COUNT(LikesTrack.track) NLikes
						FROM (((Artist JOIN Features ON Artist.id=Features.artist) JOIN Track ON Track.id=Features.track) JOIN LikesTrack ON Track.id=LikesTrack.track)
						WHERE DATE_ADD(NOW(),INTERVAL -7 DAY) < LikesTrack.date
						GROUP BY Artist.id
) WeeklyLikes
GROUP BY ID,NAME
ORDER BY TotalLikes DESC;

SELECT * FROM WeeklyLikes;

#---VERSIONE CHE CONSIDERA I LIKE
SELECT WeeklyLikes.ID,WeeklyLikes.NAME, 
ROUND((
	((WeeklyLikes.TotalLikes/100)*0.8)
	+
	((WeeklyLeaderboard.TotalListen/(SELECT reproduction FROM Revenue))*(SELECT paid FROM Revenue))
), 2) Revenue
FROM WeeklyLeaderboard JOIN WeeklyLikes ON WeeklyLikes.ID=WeeklyLeaderboard.ID;

#----VERSIONE CHE CONSIDERA SOLO LE RIPRODUZIONI
SELECT WeeklyLikes.ID,WeeklyLikes.NAME, 
ROUND (((WeeklyLeaderboard.TotalListen/(SELECT reproduction FROM Revenue))*(SELECT paid FROM Revenue)), 2) Revenue
FROM WeeklyLeaderboard JOIN WeeklyLikes ON WeeklyLikes.ID=WeeklyLeaderboard.ID;

use spotty;
show tables;
SELECT * from Playlist where name = "hip hop2";
SELECT * from Playlist, TrackBelongsToPlaylist where name = "hip hop2" AND playlist = "2Fk174hLD7WUFNrC5Ct54n";

alter table Track modify audio varchar(300);
SELECT * from Track where title = 'Courageous';
INSERT INTO User(id,username,email,password,dob) VALUES('QKedDkxLZFOPQS8pAOkj01','Gabrycina','c.gabriele.info@gmail.com','d95e0c1f964d9fface444659b9db226f0dc45e9d3d5fb1b201b5f211cbaac25b','2001-09-1');

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT distinct Tb.album 
FROM ListenedTo L, TrackBelongsToAlbum Tb 
WHERE L.track=Tb.track and L.user = '9fPfGMn2IJJZG1Sy0J1t03' 
ORDER BY date desc 
limit 6;

SELECT * FROM ListenedTo where user = '9fPfGMn2IJJZG1Sy0J1t03';


SELECT * FROM Playlist;
