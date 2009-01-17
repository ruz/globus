DROP TABLE IF EXISTS "items";
CREATE TABLE items (
  id INTEGER PRIMARY KEY NOT NULL,
  keyword VARCHAR(255) NOT NULL,
  link VARCHAR(255) NOT NULL,
  date DATETIME DEFAULT '1970-01-01 00:00:00',
  title VARCHAR(255) NOT NULL,
  content TEXT,
  author VARCHAR(255) NOT NULL,
  source VARCHAR(255) NOT NULL,
  lang VARCHAR(255) NOT NULL
);
INSERT INTO "items" VALUES(1,'post1','http://perl6.ru/','1990-01-01 00:00:00','Post Name 1','content 1','Vasya Pupkin','perl6.ru','ru');
INSERT INTO "items" VALUES(2,'post2','http://perl6.ru/','1990-01-02 00:00:00','Post Name 2','content 2','Vasya Pupkin','perl6.ru','ru');
