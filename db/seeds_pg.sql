INSERT INTO groups(name) VALUES('sysadmin');
INSERT INTO groups(name) VALUES('admin');
INSERT INTO groups(name) VALUES('staff');

INSERT INTO users(group_id, username, fullname, password_digest) VALUES(1, 'homer', 'Homer Simpson', '$2a$10$FUDIgzUMumeJ3HdDxDBzEOgLBMZLGWyxK41QRFDkqohsRGo7OQ5xG');
INSERT INTO users(group_id, username, fullname, password_digest) VALUES(2, 'bart', 'Bart Simpson', 'abc');
INSERT INTO users(group_id, username, fullname, password_digest) VALUES(3, 'marge', 'Marge Simpson', 'abc');
INSERT INTO users(group_id, username, fullname, password_digest) VALUES(3, 'lisa', 'Lisa Simpson', 'abc');

INSERT INTO programs(program,capacity) VALUES('Microsoft Office', 10);
INSERT INTO programs(program,capacity) VALUES('Desain Grafis', 10);
INSERT INTO programs(program,capacity) VALUES('AutoCAD', 10);
INSERT INTO programs(program,capacity) VALUES('Bahasa Inggris', 10);
INSERT INTO programs(program,capacity) VALUES('Teknik', 10);
INSERT INTO programs(program,capacity) VALUES('Pneumatik/PLC', 10);

INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Word', 1, 1);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Word', 1, 2);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Word', 1, 3);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Word', 1, 4);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Excel', 1, 1);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Excel', 1, 2);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Excel', 1, 3);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS PowerPoint', 1, 1);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS PowerPoint', 1, 2);
INSERT INTO pkgs(pkg, program_id, level) VALUES('MS Access', 1, 1);

INSERT INTO pkgs(pkg, program_id, level) VALUES('CorelDRAW', 2, 1);
INSERT INTO pkgs(pkg, program_id, level) VALUES('CorelDRAW', 2, 2);
INSERT INTO pkgs(pkg, program_id, level) VALUES('Adobe Photoshop', 2, 1);

INSERT INTO pkgs(pkg, program_id, level) VALUES('AutoCAD 2D', 3, 1);
INSERT INTO pkgs(pkg, program_id, level) VALUES('AutoCAD 3D', 3, 1);

INSERT INTO schedules(label, time_slot) VALUES('Jam ke-1', '08:15 - 09:45');
INSERT INTO schedules(label, time_slot) VALUES('Jam ke-2', '09:55 - 11:25');
INSERT INTO schedules(label, time_slot) VALUES('Jam ke-3', '12:50 - 14:20');
INSERT INTO schedules(label, time_slot) VALUES('Jam ke-4', '14:25 - 15:45');

-- populate pkgs_schedules table
SELECT populate_pkgs_schedules();

