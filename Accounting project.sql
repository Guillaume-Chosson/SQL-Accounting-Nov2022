

/*
Date: November 2022

Project creating an income statement and a balance sheet using SQL 
Key learnings: stored procedures and temporary tables 


CO-AUTHORS:
LUCAS McFADDEN
GUILLAUME CHOSSON
*/


USE h_accounting;

DROP PROCEDURE IF EXISTS gchosson_profitorloss_sp;

DELIMITER $$
CREATE PROCEDURE gchosson_profitorloss_sp(varCalendarYear1 SMALLINT, varCalendarYear2 SMALLINT)
BEGIN

-- revenues 
DECLARE varTotalRevenues1 DOUBLE DEFAULT 0 ;
DECLARE varTotalRevenues2 DOUBLE DEFAULT 0 ; 
DECLARE varCOGS1 DOUBLE DEFAULT 0 ;
DECLARE varCOGS2 DOUBLE DEFAULT 0 ;
DECLARE varExps1 DOUBLE DEFAULT 0;
DECLARE varExps2 DOUBLE DEFAULT 0;  
DECLARE varOherIncomes1 DOUBLE DEFAULT 0;
DECLARE varOherIncomes2 DOUBLE DEFAULT 0;
DECLARE varIncomeTAX1 DOUBLE DEFAULT 0;
DECLARE varIncomeTAX2 DOUBLE DEFAULT 0;
DECLARE varNetIncome1 DOUBLE DEFAULT 0;
DECLARE varNetIncome2 DOUBLE DEFAULT 0;

SELECT SUM(jel.credit) INTO varTotalRevenues1
FROM h_accounting.journal_entry_line_item as jel
INNER JOIN h_accounting.account as acc on acc.account_id = jel.account_id
    INNER JOIN h_accounting.journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 68 -- revenues
		
	AND YEAR(je.entry_date) = varCalendarYear1
;

SELECT SUM(jel.credit) INTO varTotalRevenues2
FROM h_accounting.journal_entry_line_item as jel
INNER JOIN h_accounting.account as acc on acc.account_id = jel.account_id
    INNER JOIN h_accounting.journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 68 -- revenues
		
	AND YEAR(je.entry_date) = varCalendarYear2
HAVING varCalendarYear1 != varCalendarYear2
;

SELECT SUM(jel.debit) INTO varCOGS1
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 74 -- COSG 
		AND YEAR(je.entry_date) = varCalendarYear1
;

SELECT SUM(jel.debit) INTO varCOGS2
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 74 -- COSG 
		AND YEAR(je.entry_date) = varCalendarYear2
HAVING varCalendarYear1 != varCalendarYear2
;

SELECT SUM(jel.debit) INTO varExps1
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id IN (77, 76) -- Exps 
		AND YEAR(je.entry_date) = varCalendarYear1
; 

SELECT SUM(jel.debit) INTO varExps2
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id IN (77, 76) -- Exps 
		AND YEAR(je.entry_date) = varCalendarYear2
HAVING varCalendarYear1 != varCalendarYear2
; 


SELECT SUM(jel.debit) INTO varOherIncomes1
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 78 -- other Incomes
		AND YEAR(je.entry_date) = varCalendarYear1
;

SELECT SUM(jel.debit) INTO varOherIncomes2
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 78 -- other Incomes
		AND YEAR(je.entry_date) = varCalendarYear2
HAVING varCalendarYear1 != varCalendarYear2
;


SELECT IFNULL(SUM(jel.debit),0) INTO varIncomeTAX1
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 79 -- Income tax
		AND YEAR(je.entry_date) = varCalendarYear1
;

SELECT SUM(jel.debit) INTO varIncomeTAX2
FROM journal_entry_line_item as jel
INNER JOIN account as acc on acc.account_id = jel.account_id
    INNER JOIN journal_entry as je on je.journal_entry_id = jel.journal_entry_id
    WHERE acc.profit_loss_section_id = 79 -- Income tax
		AND YEAR(je.entry_date) = varCalendarYear2
HAVING varCalendarYear1 != varCalendarYear2
;

SELECT varTotalRevenues1 - varCOGS1 - varExps1 + varOherIncomes1 - varIncomeTAX1 INTO varNetIncome1;

SELECT varTotalRevenues2 - varCOGS2 - varExps2 + varOherIncomes2- varIncomeTAX2 INTO varNetIncome2;



DROP TABLE IF EXISTS gchosson_tmp;

CREATE TABLE gchosson_tmp
( profit_loss_line_number INT, 
label VARCHAR(20), 
amount_1 VARCHAR(20),
amount_2 VARCHAR (20),
ratio VARCHAR(5)
);
  
INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (1, 'Total Revenues (k)', format(varTotalRevenues1 / 1000, 2), format(varTotalRevenues2 / 1000, 2) , ( varTotalRevenues2 - varTotalRevenues1)/varTotalRevenues1 * 100 );

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (2, 'Cogs (k)', format(varCOGS1 / 1000, 2), format(varCOGS2 / 1000, 2) , (varCOGS2 - varCOGS1)/varCOGS1 * 100 );

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (3, 'Expenses (k)', format(varExps1 / 1000, 2), format(varExps2 / 1000, 2) , (varExps2 - varExps1)/varExps1 * 100 );

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (4, 'Other Incomes (k)', format(varOherIncomes1 / 1000, 2), format(varOherIncomes2 / 1000, 2) , (varOherIncomes2 - varOherIncomes1)/varOherIncomes1 * 100 );

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (5, 'Income Tax (k)', format(varIncomeTAX1 / 1000, 2), format(varIncomeTAX2 / 1000, 2) , (varIncomeTAX2 -varIncomeTAX1)/ varIncomeTAX2 * 100 );

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (6, '', '', '' , '');

INSERT INTO gchosson_tmp
(profit_loss_line_number, label, amount_1, amount_2, ratio)
VALUES (7,'NET INCOME (k)', format ( varNetIncome1 / 1000, 2) , format ( varNetIncome2 / 1000, 2) , (varNetIncome2 - varNetIncome1)/ varNetIncome1 * 100 );


END$$
DELIMITER ; 

CALL gchosson_profitorloss_sp(2015,2016) ; -- choose years 



SELECT label AS 'Section', amount_1 AS year1_selected, amount_2 AS year2_selected, ratio AS percent_change FROM gchosson_tmp;




/*
AUTHORS:
LUCAS McFADDEN
GUILLAUME CHOSSON
*/

USE h_accounting;

DROP PROCEDURE IF EXISTS lmcfadden_balancesheet_sp;

DELIMITER $$
CREATE PROCEDURE lmcfadden_balancesheet_sp(varCalendarYear1 SMALLINT, varCalendarYear2 SMALLINT)
BEGIN

DECLARE varCurrentAssets1 DOUBLE DEFAULT 0 ;
DECLARE varCurrentAssets2 DOUBLE DEFAULT 0 ; 
DECLARE varFixedAssets1 DOUBLE DEFAULT 0 ;
DECLARE varFixedAssets2 DOUBLE DEFAULT 0 ;
DECLARE varDeferredAssets1 DOUBLE DEFAULT 0;
DECLARE varDeferredAssets2 DOUBLE DEFAULT 0;  
DECLARE varTotalAssets1 DOUBLE DEFAULT 0;
DECLARE varTotalAssets2 DOUBLE DEFAULT 0;
DECLARE varCurrentLiabilities1 DOUBLE DEFAULT 0;
DECLARE varCurrentLiabilities2 DOUBLE DEFAULT 0;
DECLARE varLongTermLiabilities1 DOUBLE DEFAULT 0 ;
DECLARE varLongTermLiabilities2 DOUBLE DEFAULT 0 ; 
DECLARE varDeferredLiabilities1 DOUBLE DEFAULT 0 ;
DECLARE varDeferredLiabilities2 DOUBLE DEFAULT 0 ;
DECLARE varTotalLiabilities1 DOUBLE DEFAULT 0;
DECLARE varTotalLiabilities2 DOUBLE DEFAULT 0;  
DECLARE varEquity1 DOUBLE DEFAULT 0;
DECLARE varEquity2 DOUBLE DEFAULT 0;
DECLARE varTotalEquity1 DOUBLE DEFAULT 0;
DECLARE varTotalEquity2 DOUBLE DEFAULT 0;
DECLARE varTotalLiabilitiesAndEquity1 DOUBLE DEFAULT 0;
DECLARE varTotalLiabilitiesAndEquity2 DOUBLE DEFAULT 0;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varCurrentAssets1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 1

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varCurrentAssets2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 1

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varFixedAssets1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 2

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varFixedAssets2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 2

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varDeferredAssets1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 3

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varDeferredAssets2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 3

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varCurrentLiabilities1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 4

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varCurrentLiabilities2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 4

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varLongTermLiabilities1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 5

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varLongTermLiabilities2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 5

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varDeferredLiabilities1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 6

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT IFNULL(SUM(credit)-SUM(debit),0) INTO varDeferredLiabilities2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 6

AND YEAR(je.entry_date) = varCalendarYear2;

SELECT SUM(COALESCE(jel.credit,0) - COALESCE(jel.debit,0)) INTO varEquity1
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 7

AND YEAR(je.entry_date) = varCalendarYear1;

SELECT SUM(COALESCE(jel.credit,0) - COALESCE(jel.debit,0)) INTO varEquity2
FROM statement_section AS ss
INNER JOIN account AS acc ON acc.balance_sheet_section_id = ss.statement_section_id 
INNER JOIN journal_entry_line_item AS jel ON acc.account_id = jel.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jel.journal_entry_id
WHERE is_balance_sheet_section = 1
AND statement_section_order = 7

AND YEAR(je.entry_date) = varCalendarYear2
;

SELECT varCurrentAssets1 + varFixedAssets1 + varDeferredAssets1 INTO varTotalAssets1;

SELECT varCurrentAssets2 + varFixedAssets2 + varDeferredAssets2 INTO varTotalAssets2;

SELECT varCurrentLiabilities1 + varLongTermLiabilities1 + varDeferredLiabilities1 INTO varTotalLiabilities1;

SELECT varCurrentLiabilities2 + varLongTermLiabilities2 + varDeferredLiabilities2 INTO varTotalLiabilities2;

SELECT varEquity1 INTO varTotalEquity1;

SELECT varEquity2 INTO varTotalEquity2;

SELECT varTotalLiabilities1 + varTotalEquity1 INTO varTotalLiabilitiesAndEquity1;

SELECT varTotalLiabilities2 + varTotalEquity2 INTO varTotalLiabilitiesAndEquity2;

DROP TABLE IF EXISTS lmcfadden_tmp;

CREATE TABLE lmcfadden_tmp
(balance_sheet_line_number INT, 
label VARCHAR (50), 
year_1 VARCHAR (20), 
year_2 VARCHAR (20), 
prcnt_change VARCHAR (5)
);

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (1, 'CURRENT ASSETS (k)', FORMAT(varCurrentAssets1/1000,2), FORMAT(varCurrentAssets2/1000,2),(varCurrentAssets2 - varCurrentAssets1) / varCurrentAssets1 *100 );

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (2, 'FIXED ASSETS (k)', FORMAT(varFixedAssets1/1000,2), FORMAT(varFixedAssets2/1000,2), '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (3, 'DEFERRED ASSETS (k)', FORMAT(varDeferredAssets1/1000,2), FORMAT(varDeferredAssets2/1000,2), '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (4, 'TOTAL ASSETS (k)', FORMAT(varTotalAssets1/1000,2), FORMAT(varTotalAssets2/1000,2), (varTotalAssets2 -varTotalAssets1) / varTotalAssets2 *100 );

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (5, '', '', '', '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (6, 'CURRENT LIABILITIES (k)', FORMAT(varCurrentLiabilities1/1000, 2), FORMAT(varCurrentLiabilities2/1000, 2), ((varCurrentLiabilities2 - varCurrentLiabilities1) * -1) / (varCurrentLiabilities1 *-1) * 100);

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (7, 'LONG-TERM LIABILITIES (k)', FORMAT(varLongTermLiabilities1/1000,2), FORMAT(varLongTermLiabilities2/1000,2), '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (8, 'DEFERRED LIABILITIES (k)', FORMAT(varDeferredLiabilities1/1000,2), FORMAT(varDeferredLiabilities2/1000,2), '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (9, 'TOTAL LIABILITIES (k)', FORMAT(varTotalLiabilities1/1000,2), FORMAT(varTotalLiabilities2/1000,2), (varTotalLiabilities2 - varTotalLiabilities1) / varTotalLiabilities1 *100);

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (10, '', '', '', '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (11, 'EQUITY (k)', FORMAT(varEquity1/1000,2), FORMAT(varEquity2/1000,2), (varEquity2 - varEquity1) / varEquity1 * 100 );

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (12, 'TOTAL EQUITY (k)', FORMAT(varTotalEquity1/1000,2), FORMAT(varTotalEquity2/1000,2), (varTotalEquity2 - varTotalEquity1) / varTotalEquity1 *100 );

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (13, '', '', '', '');

INSERT INTO lmcfadden_tmp
(balance_sheet_line_number, label, year_1, year_2, prcnt_change)
VALUES (14, 'TOTAL LIABILITIES & EQUITY (k)', FORMAT(varTotalLiabilitiesAndEquity1/1000,2), FORMAT(varTotalLiabilitiesAndEquity2/1000,2), (varTotalLiabilitiesAndEquity2 - varTotalLiabilitiesAndEquity1) / (varTotalLiabilitiesAndEquity1 * -1) *100 );

END$$
DELIMITER ;

CALL lmcfadden_balancesheet_sp(2017,2018) ; 

SELECT label AS 'Section', year_1 AS 'Year 1' , year_2  AS 'Year 2', prcnt_change AS 'Percent Change' FROM lmcfadden_tmp;