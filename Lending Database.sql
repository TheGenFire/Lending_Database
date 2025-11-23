CREATE DATABASE LENDING;

USE LENDING;

CREATE TABLE BORROWER 
	(borrowerID CHAR(5) PRIMARY KEY,
     firstName VARCHAR(20) NOT NULL,
     lastName VARCHAR(20) NOT NULL,
	 phone CHAR(11) NOT NULL UNIQUE,
	 address VARCHAR(100) NOT NULL
	);

CREATE TABLE LOAN_APPLICATION
	(loanID CHAR(5) PRIMARY KEY,
     amount DECIMAL(10,2) NOT NULL,
	 status VARCHAR(15) NOT NULL,
	 borrowerID CHAR(5),
     staffID CHAR(5),
     FOREIGN KEY (borrowerID) REFERENCES BORROWER (borrowerID)
     ON DELETE RESTRICT ON UPDATE CASCADE,
	 FOREIGN KEY (staffID) REFERENCES STAFF (staffID)
     ON DELETE SET NULL ON UPDATE CASCADE
	);

CREATE TABLE APPROVED_LOAN
	(loanID CHAR(5) PRIMARY KEY,
     staffID CHAR(5),
	 amount DECIMAL(10,2) NOT NULL,
     paymentTerm VARCHAR(10) NOT NULL,
     interestRate DECIMAL(5,3) NOT NULL,
     startDate DATE NOT NULL,
     maturityDate DATE NOT NULL,
	 status VARCHAR(15) NOT NULL,
     FOREIGN KEY(loanID) REFERENCES LOAN_APPLICATION (loanID)
     ON DELETE RESTRICT ON UPDATE CASCADE,
	 FOREIGN KEY (staffID) REFERENCES STAFF (staffID)
     ON DELETE RESTRICT ON UPDATE CASCADE
	);	

CREATE TABLE STAFF
	(staffID CHAR(5) PRIMARY KEY,
     branchID CHAR(5),
     firstName VARCHAR(20) NOT NULL,
     lastName VARCHAR(20) NOT NULL,
	 phone CHAR(11) NOT NULL UNIQUE,
	 position VARCHAR(30) NOT NULL,
	 FOREIGN KEY (branchID) REFERENCES BRANCH (branchID)
     ON DELETE SET NULL ON UPDATE CASCADE
	);	

CREATE TABLE BRANCH
	(branchID CHAR(5) PRIMARY KEY,
     branchName VARCHAR(30) NOT NULL,
	 phone CHAR(11) NOT NULL UNIQUE,
	 address VARCHAR(100) NOT NULL
	);
    
CREATE TABLE PAYMENT_SCHEDULE
	(scheduleID CHAR(5) PRIMARY KEY,
     loanID CHAR(5),
     dueDate DATE NOT NULL,
     amountDue DECIMAL(10,2),
     FOREIGN KEY (loanID) REFERENCES APPROVED_LOAN (loanID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );
    
CREATE TABLE PAYMENT
	(paymentID CHAR(5) PRIMARY KEY,
     scheduleID CHAR(5),
     paymentDate DATE NOT NULL,
     amountPaid DECIMAL(10,2),
     paymentMethod VARCHAR(10) NOT NULL,
     FOREIGN KEY (scheduleID) REFERENCES PAYMENT_SCHEDULE (scheduleID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );

 CREATE TABLE PENALTY
	(penaltyID CHAR(5) PRIMARY KEY,
     paymentID CHAR(5),
     penaltyFee DECIMAL(10,2),
     FOREIGN KEY (paymentID) REFERENCES PAYMENT (paymentID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE PENALTY_RATE
	(penaltyRateID CHAR(5) PRIMARY KEY,
     numOfDays VARCHAR(10) NOT NULL,
     rate DECIMAL (5,2) NOT NULL
    );
    
CREATE TABLE LOAN_TERM(
    termID CHAR(5) PRIMARY KEY,
    paymentTerm VARCHAR(20) NOT NULL,       
    termRate DECIMAL(5,3) NOT NULL,     
    loanRange VARCHAR(20) NOT NULL
);
    
INSERT INTO BORROWER (borrowerID, firstName, lastName, phone, address)
VALUES ('BR001','NEOKENT', 'DURANO', '09123456789', 'DANAO CITY'),
	   ('BR002','KIER', 'BORNE', '09558559293', 'CEBU CITY'),	
	   ('BR003', 'BEA ANGELA', 'BALUCAN', '09987654321', 'MANDAUE CITY');
       
INSERT INTO LOAN_APPLICATION (loanID, amount, status, borrowerID, staffID)
VALUES('LN001', '5000', 'APPROVED', 'BR001', 'SF001'),
	  ('LN002', '15000', 'APPROVED', 'BR002', 'SF002'),
	  ('LN003', '20000', 'APPROVED', 'BR003', 'SF001'),
	  ('LN004', '50000', 'DENIED', 'BR001','SF001');
      
INSERT INTO APPROVED_LOAN (loanID, staffID, amount, paymentTerm, interestRate, startDate, maturityDate, status)
VALUES('LN001', 'SF001', '5000', '3 MONTHS', '0.01', '2025-08-01', '2025-11-01','PAID'),
	  ('LN002', 'SF002', '15000', '6 MONTHS', '0.012', '2025-11-01', '2026-05-01','PENDING'),
      ('LN003', 'SF001', '20000', '6 MONTHS', '0.012', '2025-10-01', '2026-04-01','ACTIVE');
      
INSERT INTO STAFF (staffID, branchID, firstName, lastName, phone, position)
VALUES('SF001', 'BH001', 'ANNIE', 'MAMITAG', '09345123381', 'LOAN OFFICER'),
	  ('SF002', 'BH001', 'NJ', 'ARNADO', '09448103254', 'LOAN OFFICER'),
      ('SF003', 'BH002', 'STEPHEN', 'ALEDON', '09551288174', 'LOAN OFFICER');
      
INSERT INTO BRANCH (branchID, branchName, phone, address)
VALUES('BH001', 'COLON BRANCH', '09623657688', 'COLON CEBU CITY CEBU'),
	  ('BH002', 'MINGLANILLA BRANCH', '09122722478', 'MINGLANILLA CEBU'),
	  ('BH003', 'CARCAR BRANCH', '09712657691', 'CARCAR CITY CEBU');
      
   -- FOR NEOKENT DURANO(schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate, amountDue)
VALUES('SE001', 'LN001', '2025-09-01', NULL),
      ('SE002', 'LN001', '2025-10-01', NULL),
      ('SE003', 'LN001', '2025-11-01', NULL);

   -- FOR BEA ANGELA BALUCAN(schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate, amountDue)
VALUES('SE004', 'LN003', '2025-11-01', NULL),
	  ('SE005', 'LN003', '2025-12-01', NULL),
      ('SE006', 'LN003', '2026-01-01', NULL),
      ('SE007', 'LN003', '2026-02-01', NULL),
      ('SE008', 'LN003', '2026-03-01', NULL),
      ('SE009', 'LN003', '2026-04-01', NULL);
      
      -- NEO KENT DURANO (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, amountPaid, paymentMethod)
VALUEs('PT001', 'SE001', '2025-09-01', NULL,'CASH'),
	  ('PT002', 'SE002', '2025-10-01', NULL,'CASH'),
      ('PT003', 'SE003', '2025-11-01', NULL,'CASH');

-- FOR BEA ANGELA BALUCAN (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, amountPaid, paymentMethod)
VALUES('PT004', 'SE004', '2025-11-01', NULL,'CASH'),
      ('PT005', 'SE005', '2025-12-08', NULL,'BPI-BANK'),
      ('PT006', 'SE006', '2026-01-16', NULL,'BPI-BANK');
    

INSERT INTO PENALTY (penaltyID, paymentID, penaltyFee)
VALUES('PY001', 'PT005', NULL),
      ('PY002', 'PT006', NULL);
	

INSERT INTO PENALTY_RATE (penaltyRateID, numOfDays, rate)
VALUES('PR001', '1-14', 0.02),   
	  ('PR002', '15-21', 0.05),   
      ('PR003', '21 above', 0.10);  

INSERT INTO LOAN_TERM (termID, paymentTerm, termRate, loanRange)
VALUES 
('TM001', '3 MONTHS', 0.010, '5000 – 10000'),
('TM002', '6 MONTHS', 0.012, '11000 – 30000'),
('TM003', '12 MONTHS', 0.015, 'more than 30000');

-- STORED FUNCTION AND PROCEDURE FOR AMOUNTDUE IN PAYMENT_SCHEDULE TABLE

DELIMITER $$

CREATE FUNCTION compute_amountDue(p_loanID CHAR(5))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE principal DECIMAL(10,2);
    DECLARE months INT;
    DECLARE interestRate DECIMAL(5,4);
    DECLARE monthly DECIMAL(10,2);

    SELECT amount INTO principal
    FROM approved_loan 
    WHERE loanID = p_loanID;

    SELECT 
        CASE 
            WHEN paymentTerm = '3 MONTHS' THEN 3
            WHEN paymentTerm = '6 MONTHS' THEN 6
            WHEN paymentTerm = '12 MONTHS' THEN 12
            ELSE 1
        END
    INTO months
    FROM approved_loan
    WHERE loanID = p_loanID;

    IF months = 3 AND principal BETWEEN 5000 AND 10000 THEN
        SET interestRate = 0.01;  
    ELSEIF months = 6 AND principal BETWEEN 11000 AND 30000 THEN
        SET interestRate = 0.012;
    ELSEIF months = 12 AND principal > 30000 THEN
        SET interestRate = 0.015;
    ELSE
        SET interestRate = 0; 
    END IF;

    SET monthly = (principal + (principal * interestRate)) / months;

    RETURN monthly;
END$$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE fill_amountDue()
BEGIN
    UPDATE payment_schedule s 
    SET s.amountDue = compute_amountDue(s.loanID)
    WHERE s.amountDue IS NULL;
END$$;fill_amountDue

DELIMITER ;

-- STORED FUNCTION AND PROCEDURE FOR PENALTYFEE IN PENALTY TABLE

DELIMITER $$

CREATE FUNCTION compute_penalty(p_paymentID CHAR(5))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE due DATE;
    DECLARE paid DATE;
    DECLARE baseAmount DECIMAL(10,2);
    DECLARE daysLate INT;
    DECLARE rate DECIMAL(5,2);

    SELECT s.dueDate, p.paymentDate, s.amountDue
    INTO due, paid, baseAmount
    FROM payment p
    JOIN payment_schedule s ON p.scheduleID = s.scheduleID
    WHERE p.paymentID = p_paymentID;

    SET daysLate = DATEDIFF(paid, due);

    IF daysLate BETWEEN 1 AND 14 THEN
        SET rate = 0.02;
    ELSEIF daysLate BETWEEN 15 AND 21 THEN
        SET rate = 0.05;
    ELSEIF daysLate > 21 THEN
        SET rate = 0.10;
    ELSE
        SET rate = 0;
    END IF;

    RETURN baseAmount * rate;
END$$;

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE fill_penaltyFee()
BEGIN
    UPDATE penalty p
    SET p.penaltyFee = compute_penalty(p.paymentID)
    WHERE p.penaltyFee IS NULL;
END$$;

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
CALL fill_amountDue();
SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;
CALL fill_penaltyFee();
SET SQL_SAFE_UPDATES = 1;


ALTER TABLE approved_loan
MODIFY interestRate DECIMAL (5,3);

UPDATE approved_loan
SET interestRate = NULL;

-- UPDATE STATEMENT FOR COLUMN INTERESTRATE IN APPROVED_LOAN TABLE

UPDATE APPROVED_LOAN
SET interestRate = 
    CASE 
        WHEN paymentTerm = '3 MONTHS' THEN 0.01
        WHEN paymentTerm = '6 MONTHS' THEN 0.012
        WHEN paymentTerm = '12 MONTHS' THEN 0.015
        ELSE 0
    END
WHERE interestRate IS NULL;
  
-- BORROWER
SELECT borrowerID "BORROWER ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE NUMBER", address "ADDRESS" FROM BORROWER;

-- LOAN_APPLICATION
SELECT loanID "LOAN ID", amount "AMOUNT", status "STATUS", borrowerID "BORROWER ID", staffID "STAFF ID" FROM LOAN_APPLICATION;

-- APPROVED_LOAN
SELECT loanID "LOAN ID", staffID "STAFF ID", amount "AMOUNT", paymentTerm "PAYMENT TERM", interestRate "INTEREST RATE", startDate "START DATE", maturityDate "MATURITY DATE", status "STATUS" FROM APPROVED_LOAN;

-- BRANCH
SELECT branchID "BRANCH ID", branchName "BRANCH NAME", phone "CONTACT NUMBER", address "ADDRESS" FROM BRANCH;

-- STAFF
SELECT staffID "STAFF ID", branchID "BRANCH ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE", position "POSITION" FROM STAFF;

-- PAYMENT_SCHEDULE
SELECT scheduleID "SCHEDULE ID", loanID "LOAN ID", dueDate "DUE DATE", amountDue "AMOUNT DUE" FROM PAYMENT_SCHEDULE;

-- PAYMENT
SELECT paymentID "PAYMENT ID", scheduleID "SCHEDULE ID", paymentDate "PAYMENT DATE", amountPaid "AMOUNT", paymentMethod "PAYMENT METHOD" FROM PAYMENT;

-- PENALTY
SELECT penaltyID "PENALTY ID", paymentID "PAYMENT ID", penaltyFee "PENALTY FEE" FROM PENALTY;

-- PENALTY_RATE
SELECT penaltyRateID "PENALTY RATE ID", numOfDays "NUMBER OF LATE DAYS", rate "PENALTY RATE" FROM PENALTY_RATE;

-- LOAN_TERM
SELECT termID "TERM ID", paymentTerm "PAYMENT TERM", termRate "INTEREST RATE", loanRange "LOAN RANGE" FROM LOAN_TERM;

select b.branchID, s.staffID from branch b left join staff s on b.branchID = s.branchID;





