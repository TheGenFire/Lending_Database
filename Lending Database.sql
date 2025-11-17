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
     borrowerID CHAR(5),
     staffID CHAR(5),
	 amount DECIMAL(10,2) NOT NULL,
     paymentTerm VARCHAR(10) NOT NULL,
     interestRate DECIMAL(5,3) NOT NULL,
     startDate DATE NOT NULL,
     maturityDate DATE NOT NULL,
	 status VARCHAR(15) NOT NULL,
     FOREIGN KEY(loanID) REFERENCES LOAN_APPLICATION (loanID)
     ON DELETE RESTRICT ON UPDATE CASCADE,
	 FOREIGN KEY (borrowerID) REFERENCES BORROWER (borrowerID)
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
     amountDue DECIMAL(10,2) NOT NULL,
     FOREIGN KEY (loanID) REFERENCES APPROVED_LOAN (loanID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );
    
CREATE TABLE PAYMENT
	(paymentID CHAR(5) PRIMARY KEY,
     scheduleID CHAR(5),
     paymentDate DATE NOT NULL,
     amountPaid DECIMAL(10,2) NOT NULL,
     paymentMethod VARCHAR(10) NOT NULL,
     FOREIGN KEY (scheduleID) REFERENCES PAYMENT_SCHEDULE (scheduleID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );
    
 CREATE TABLE PENALTY
	(penaltyID CHAR(5) PRIMARY KEY,
     paymentID CHAR(5),
     penaltyFee DECIMAL(10,2) NOT NULL,
     FOREIGN KEY (paymentID) REFERENCES PAYMENT (paymentID)
     ON DELETE CASCADE ON UPDATE CASCADE
    );
    
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
	  ('LN002', '15000', 'APPROVED', 'BR001', 'SF002'),
	  ('LN003', '20000', 'APPROVED', 'BR001', 'SF001');
      
INSERT INTO APPROVED_LOAN (loanID, borrowerID, staffID, amount, paymentTerm, interestRate, startDate, maturityDate, status)
VALUES('LN001', 'BR001', 'SF001', '5000', '3 MONTHS', '0.01', '2025-08-01', '2025-11-01','PAID'),
	  ('LN002', 'BR002', 'SF002', '15000', '6 MONTHS', '0.012', '2025-11-01', '2026-05-01','PENDING'),
      ('LN003', 'BR003', 'SF001', '20000', '6 MONTHS', '0.012', '2025-10-01', '2026-04-01','ACTIVE');
      
INSERT INTO STAFF (staffID, branchID, firstName, lastName, phone, position)
VALUES('SF001', 'BH001', 'ANNIE', 'MAMITAG', '09345123381', 'LOAN OFFICER'),
	  ('SF002', 'BH001', 'NJ', 'ARNADO', '09345127381', 'LOAN OFFICER'),
      ('SF003', 'BH003', 'STEPHEN', 'ALEDON', '09551288174', 'LOAN OFFICER');
      
INSERT INTO BRANCH (branchID, branchName, phone, address)
VALUES('BH001', 'COLON BRANCH', '09623657688', 'COLON CEBU CITY CEBU'),
	  ('BH002', 'MINGLANILLA BRANCH', '09122722478', 'MINGLANILLA CEBU'),
	  ('BH003', 'CARCAR BRANCH', '09712657691', 'CARCAR CITY CEBU');
      
   -- FOR NEOKENT DURANO(schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate, amountDue)
VALUES('SE001', 'LN001', '2025-09-01', '1716.67'),
      ('SE002', 'LN001', '2025-10-01', '1716.67'),
      ('SE003', 'LN001', '2025-11-01', '1716.67');

-- FOR KIER BORNE (schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate, amountDue)
VALUES('SE010', 'LN002', '2025-11-01', '2500.00'),
      ('SE011', 'LN002', '2025-12-01', '2500.00'),
      ('SE012', 'LN002', '2026-01-01', '2500.00'),
      ('SE013', 'LN002', '2026-02-01', '2500.00'),
      ('SE014', 'LN002', '2026-03-01', '2500.00'),
      ('SE015', 'LN002', '2026-04-01', '2500.00');

   -- FOR BEA ANGELA BALUCAN(schedule)
INSERT INTO PAYMENT_SCHEDULE(scheduleID, loanID, dueDate, amountDue)
VALUES('SE004', 'LN003', '2025-11-01', '3573.33'),
	  ('SE005', 'LN003', '2025-12-01', '3573.33'),
      ('SE006', 'LN003', '2026-01-01', '3573.33'),
      ('SE007', 'LN003', '2026-02-01', '3573.33'),
      ('SE008', 'LN003', '2026-03-01', '3573.33'),
      ('SE009', 'LN003', '2026-04-01', '3573.33');
      
      -- NEOKENT DURANO (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, amountPaid, paymentMethod)
VALUEs('PT001', 'SE001', '2025-09-01', '1716.67', 'CASH'),
	  ('PT002', 'SE001', '2025-10-01', '1716.67', 'CASH'),
      ('PT003', 'SE001', '2025-11-01', '1716.67', 'CASH');

-- FOR BEA ANGELA BALUCAN (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, amountPaid, paymentMethod)
VALUES('PT004', 'SE004', '2025-11-01', '3573.33', 'CASH'),
      ('PT005', 'SE005', '2025-12-01', '3573.33', 'CASH'),
      ('PT006', 'SE006', '2026-01-01', '3573.33', 'CASH'),
      ('PT007', 'SE007', '2026-02-01', '3573.33', 'CASH'),
      ('PT008', 'SE008', '2026-03-01', '3573.33', 'CASH'),
      ('PT009', 'SE009', '2026-04-01', '3573.33', 'CASH');

-- FOR KIER BORNE (payment)
INSERT INTO PAYMENT(paymentID, scheduleID, paymentDate, amountPaid, paymentMethod)
VALUES('PT010', 'SE010', '2025-11-01', '2500.00', 'CASH'),
      ('PT011', 'SE011', '2025-12-01', '2500.00', 'CASH'),
      ('PT012', 'SE012', '2026-01-01', '2500.00', 'CASH'),
      ('PT013', 'SE013', '2026-02-01', '2500.00', 'CASH'),
      ('PT014', 'SE014', '2026-03-01', '2500.00', 'CASH'),
      ('PT015', 'SE015', '2026-04-01', '2500.00', 'CASH');

INSERT INTO PENALTY_RATE (penaltyRateID, numOfDays, rate)
VALUES('PR001', '1-3', 0.01),   -- 1% penalty for payments 1–3 days late
	  ('PR002', '4-7', 0.02),   -- 2% penalty for 4–7 days late
      ('PR003', '8-15', 0.03),  -- 3% penalty for 8–15 days late
      ('PR004', '15+', 0.05);  -- 5% penalty for more than 15 days late

SELECT borrowerID "BORROWER ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE NUMBER", address "ADDRESS" FROM BORROWER;
SELECT loanID "LOAN ID", amount "AMOUNT", status "STATUS", borrowerID "BORROWER ID", staffID "STAFF ID" FROM LOAN_APPLICATION;
SELECT loanID "LOAN ID", borrowerID "BORROWER ID", staffID "STAFF ID", amount "AMOUNT", paymentTerm "PAYMENT TERM", interestRate "INTEREST RATE", startDate "START DATE", maturityDate "MATURITY DATE", status "STATUS" FROM APPROVED_LOAN;
SELECT branchID "BRANCH ID", branchName "BRANCH NAME", phone "CONTACT NUMBER", address "ADDRESS" FROM BRANCH;
SELECT staffID "STAFF ID", branchID "BRANCH ID", firstName "FIRST NAME", lastName "LAST NAME", phone "PHONE", position "POSITION" FROM STAFF;
SELECT scheduleID "SCHEDULE ID", loanID "LOAN ID", dueDate "DUE DATE", amountDue "AMOUNT DUE" FROM PAYMENT_SCHEDULE;
SELECT paymentID "PAYMENT ID", scheduleID "SCHEDULE ID", paymentDate "PAYMENT DATE", amountPaid "AMOUNT", paymentMethod "PAYMENT METHOD" FROM PAYMENT;
SELECT penaltyID "PENALTY ID", paymentID "PAYMENT ID", penaltyFee "PENALTY FEE" FROM PENALTY;
SELECT penaltyRateID "PENALTY RATE ID", numOfDays "NUMBER OF LATE DAYS", rate "PENALTY RATE" FROM PENALTY_RATE;




