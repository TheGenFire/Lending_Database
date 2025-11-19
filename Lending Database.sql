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
     amountDue DECIMAL(10,2) NULL,
     FOREIGN KEY (loanID) REFERENCES APPROVED_LOAN (loanID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );

DELIMITER $$

CREATE TRIGGER trg_calc_amountDue
BEFORE INSERT ON PAYMENT_SCHEDULE
FOR EACH ROW
BEGIN
    DECLARE termMonths INT;
    DECLARE loanAmount DECIMAL(10,2);
    DECLARE rate DECIMAL(5,3);

    -- Get loan data from APPROVED_LOAN
    SELECT 
        amount, 
        interestRate,
        SUBSTRING(paymentTerm, 1, 2)  -- "3 MONTHS" → 3
    INTO 
        loanAmount,
        rate,
        termMonths
    FROM APPROVED_LOAN
    WHERE loanID = NEW.loanID;

    -- Compute monthly due
    SET NEW.amountDue = (loanAmount * (1 + rate)) / termMonths;

END$$

DELIMITER ;

    
CREATE TABLE PAYMENT
	(paymentID CHAR(5) PRIMARY KEY,
     scheduleID CHAR(5),
     paymentDate DATE NOT NULL,
     amountPaid DECIMAL(10,2) NULL,
     paymentMethod VARCHAR(10) NOT NULL,
     FOREIGN KEY (scheduleID) REFERENCES PAYMENT_SCHEDULE (scheduleID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );

DELIMITER $$

CREATE TRIGGER trg_fill_amountPaid
BEFORE INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    DECLARE dueAmount DECIMAL(10,2);

    SELECT amountDue 
    INTO dueAmount
    FROM PAYMENT_SCHEDULE
    WHERE scheduleID = NEW.scheduleID;

    SET NEW.amountPaid = dueAmount;
END$$

DELIMITER ;

 CREATE TABLE PENALTY
	(penaltyID CHAR(5) PRIMARY KEY,
     paymentID CHAR(5),
     penaltyFee DECIMAL(10,2) NULL,
     FOREIGN KEY (paymentID) REFERENCES PAYMENT (paymentID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );

DELIMITER $$

CREATE TRIGGER trg_calc_penaltyFee
BEFORE INSERT ON PENALTY
FOR EACH ROW
BEGIN
    DECLARE due DATE;
    DECLARE pay DATE;
    DECLARE daysLate INT;
    DECLARE rate DECIMAL(5,2);
    DECLARE amountDue DECIMAL(10,2);

    -- Get dueDate and paymentDate
    SELECT PS.dueDate, P.paymentDate, PS.amountDue
    INTO due, pay, amountDue
    FROM PAYMENT P
    JOIN PAYMENT_SCHEDULE PS ON P.scheduleID = PS.scheduleID
    WHERE P.paymentID = NEW.paymentID;

    -- Compute late days
    SET daysLate = DATEDIFF(pay, due);

    IF daysLate < 1 THEN
        SET NEW.penaltyFee = 0;
    ELSE
        -- Get proper rate from penalty_rate table
        SELECT rate 
        INTO rate
        FROM PENALTY_RATE
        WHERE daysLate BETWEEN 
            CAST(SUBSTRING_INDEX(numOfDays, '-', 1) AS UNSIGNED)
            AND
            CAST(SUBSTRING_INDEX(numOfDays, '-', -1) AS UNSIGNED)
        LIMIT 1;

        SET NEW.penaltyFee = amountDue * rate;
    END IF;

END$$

DELIMITER ;


CREATE TABLE PENALTY_RATE
	(penaltyRateID CHAR(5) PRIMARY KEY,
     numOfDays VARCHAR(10) NOT NULL,
     rate DECIMAL (5,2) NOT NULL
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
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate)
VALUES('SE001', 'LN001', '2025-09-01'),
      ('SE002', 'LN001', '2025-10-01'),
      ('SE003', 'LN001', '2025-11-01');

   -- FOR BEA ANGELA BALUCAN(schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate)
VALUES('SE004', 'LN003', '2025-11-01'),
	  ('SE005', 'LN003', '2025-12-01'),
      ('SE006', 'LN003', '2026-01-01'),
      ('SE007', 'LN003', '2026-02-01'),
      ('SE008', 'LN003', '2026-03-01'),
      ('SE009', 'LN003', '2026-04-01');
      
      -- NEO KENT DURANO (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, paymentMethod)
VALUEs('PT001', 'SE001', '2025-09-01', 'CASH'),
	  ('PT002', 'SE002', '2025-10-01', 'CASH'),
      ('PT003', 'SE003', '2025-11-01', 'CASH');

-- FOR BEA ANGELA BALUCAN (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, paymentMethod)
VALUES('PT004', 'SE004', '2025-11-01', 'CASH'),
      ('PT005', 'SE005', '2025-12-08', 'BPI-BANK'),
      ('PT006', 'SE006', '2026-01-16', 'BPI-BANK'),
    

INSERT INTO PENALTY (penaltyID, paymentID)
VALUES('PY001', 'PT005')
      ('PY002', 'PT006');
	

INSERT INTO PENALTY_RATE (penaltyRateID, numOfDays, rate)
VALUES('PR001', '1-14', 0.02),   -- 2% penalty for payments 1–14 days late
	  ('PR002', '15-21', 0.05),   -- 5% penalty for 15-21 days late
      ('PR003', '21 above', 0.10),  -- 10% penalty for more than 21 days late
     

SELECT borrowerID "BORROWER ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE NUMBER", address "ADDRESS" FROM BORROWER;
SELECT loanID "LOAN ID", amount "AMOUNT", status "STATUS", borrowerID "BORROWER ID", staffID "STAFF ID" FROM LOAN_APPLICATION;
SELECT loanID "LOAN ID", staffID "STAFF ID", amount "AMOUNT", paymentTerm "PAYMENT TERM", interestRate "INTEREST RATE", startDate "START DATE", maturityDate "MATURITY DATE", status "STATUS" FROM APPROVED_LOAN;
SELECT branchID "BRANCH ID", branchName "BRANCH NAME", phone "CONTACT NUMBER", address "ADDRESS" FROM BRANCH;
SELECT staffID "STAFF ID", branchID "BRANCH ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE", position "POSITION" FROM STAFF;
SELECT scheduleID "SCHEDULE ID", loanID "LOAN ID", dueDate "DUE DATE", amountDue "AMOUNT DUE" FROM PAYMENT_SCHEDULE;
SELECT paymentID "PAYMENT ID", scheduleID "SCHEDULE ID", paymentDate "PAYMENT DATE", amountPaid "AMOUNT", paymentMethod "PAYMENT METHOD" FROM PAYMENT;
SELECT penaltyID "PENALTY ID", paymentID "PAYMENT ID", penaltyFee "PENALTY FEE" FROM PENALTY;
SELECT penaltyRateID "PENALTY RATE ID", numOfDays "NUMBER OF LATE DAYS", rate "PENALTY RATE" FROM PENALTY_RATE;




