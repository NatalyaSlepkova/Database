drop trigger if exists triggerAgeACM on competitionsteams;
drop function if exists functionAgeACM();
drop table if exists universities CASCADE;
drop table if exists participants CASCADE;
drop table if exists trainers CASCADE;
drop table if exists teams CASCADE;
drop table if exists competitions CASCADE;
drop table if exists competitionsteams CASCADE;
drop table if exists guests CASCADE;
drop table if exists juri CASCADE;
drop table if exists sponsors CASCADE;
drop table if exists guestscompetitions CASCADE;
drop table if exists sponsorscompetitions CASCADE;
drop table if exists juricompetitions CASCADE;


CREATE TABLE universities(
    unid serial PRIMARY KEY,
    uniname varchar(30) NOT NULL
);


CREATE TABLE teams(
    tid serial PRIMARY KEY,
    tname varchar(30) NOT NULL,
    trainerID integer NOT NULL
);

CREATE TABLE participants(
    pid serial PRIMARY KEY,
    pname varchar(30) NOT NULL,
    rating integer NOT NULL,
    birthday timestamp without time zone NOT NULL,
    universitiesID integer NOT NULL,
    teamID integer NOT NULL
);

CREATE TABLE trainers(
    trid serial PRIMARY KEY,
    trname varchar(30) NOT NULL,
    rating integer NOT NULL,
    job varchar(20) NOT NULL
);


CREATE TABLE competitions(
    cid serial PRIMARY KEY,
    cname varchar(30) NOT NULL,
    ctype integer NOT NULL,
    cdate timestamp without time zone NOT NULL,
    compteamID integer NOT NULL,
    winnerID integer NOT NULL
);

CREATE TABLE competitionsteams(
    teamID integer NOT NULL,
    compID integer NOT NULL,
    PRIMARY KEY(teamID, compID)
);

CREATE TABLE guests(
    gid serial PRIMARY KEY,
    gname varchar(30) NOT NULL
);

CREATE TABLE juri(
    jid serial PRIMARY KEY,
    jname varchar(30) NOT NULL
);

CREATE TABLE sponsors(
    spid serial PRIMARY KEY,
    sname varchar(30) NOT NULL
);

CREATE TABLE guestscompetitions(
    compID integer NOT NULL,
    guestID integer NOT NULL,
    PRIMARY KEY(compID, guestID)
);

CREATE TABLE sponsorscompetitions(
    compID integer NOT NULL,
    sponsorID integer NOT NULL,
    PRIMARY KEY(compID, sponsorID)
);

CREATE TABLE juricompetitions(
    compID integer NOT NULL,
    juriID integer NOT NULL,
    PRIMARY KEY(compID, juriID)
);

ALTER TABLE teams ADD CONSTRAINT FK3 FOREIGN KEY (trainerID)
        REFERENCES trainers (trid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE participants ADD CONSTRAINT FK FOREIGN KEY (universitiesID)
        REFERENCES universities (unid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE participants ADD CONSTRAINT FK2 FOREIGN KEY (teamID)
        REFERENCES teams (tid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE competitions ADD 
    CONSTRAINT FK6 FOREIGN KEY (cid, compteamID) 
        REFERENCES competitionsteams (compID, teamID) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE competitions ADD 
    CONSTRAINT FK11 FOREIGN KEY (winnerID)
        REFERENCES teams (tid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE competitionsteams ADD CONSTRAINT FK5 FOREIGN KEY (compID)
        REFERENCES competitions (cid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE guestscompetitions ADD CONSTRAINT FK9 FOREIGN KEY (compID)
        REFERENCES competitions (cid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE guestscompetitions ADD CONSTRAINT FK10 FOREIGN KEY (guestID)
        REFERENCES guests (gid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

 ALTER TABLE sponsorscompetitions ADD CONSTRAINT FK7 FOREIGN KEY (compID)
        REFERENCES competitions (cid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

 ALTER TABLE sponsorscompetitions ADD CONSTRAINT FK8 FOREIGN KEY (sponsorID)
        REFERENCES sponsors (spid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE juricompetitions ADD CONSTRAINT FK12 FOREIGN KEY (compID)
        REFERENCES competitions (cid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE juricompetitions ADD CONSTRAINT FK13 FOREIGN KEY (juriID)
        REFERENCES juri (jid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

ALTER TABLE competitionsteams ADD CONSTRAINT FK4 FOREIGN KEY (teamID)
        REFERENCES teams (tid) MATCH SIMPLE
        ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

CREATE FUNCTION functionAgeACM() RETURNS trigger AS $triggerAgeACM$ 
    -- DECLARE
    --     variable int; 
    BEGIN
        IF (exists(
            SELECT * FROM competitions WHERE 
                NEW.compID = competitions.cid AND competitions.ctype = 0 AND NEW.teamID IN (
                    -- команды, у которых есть участник старше 25 лет
                    SELECT participants.teamID FROM participants WHERE
                        date_part('year', age( competitions.cdate, participants.birthday)) > 25
                ) 
        )) THEN
            RAISE EXCEPTION 'ACM AGE trigger failed';
        END IF;
        RETURN NEW;
    END;
$triggerAgeACM$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER triggerAgeACM AFTER INSERT or UPDATE
ON competitionsteams 
DEFERRABLE
FOR EACH ROW EXECUTE PROCEDURE functionAgeACM();






-- data initialization

BEGIN;
  SET CONSTRAINTS ALL DEFERRED;

  INSERT INTO universities (uniname)
  VALUES
    ('ITMO');

  INSERT INTO participants (pname, rating, birthday, universitiesID, teamID)
  VALUES
    ('Nata', 1500, timestamp '1996-12-14', 1, 1);

  INSERT INTO trainers (trname, rating, job)
  VALUES
    ('Zabazhta', 1000, 'чистильщик унитазов');

  INSERT INTO teams (tname, trainerID)
  VALUES
   ('Zvezdochka', 1);

  INSERT INTO juri (jname)
  VALUES
  ('Korneev');

  INSERT INTO juricompetitions (compID, juriID)
  VALUES
  (1, 1);

  INSERT INTO competitionsteams (teamID, compID)
  VALUES
  (1, 1);

  INSERT INTO competitions (cname, ctype, cdate, compteamID, winnerID) 
  VALUES
  ('QF', 0, timestamp '2018-12-14', 1, 1);
COMMIT;