CREATE TABLE ACCOUNT (
	ID SERIAL PRIMARY KEY,
	USERNAME TEXT UNIQUE NOT NULL,
	ROLE TEXT NOT NULL,
	AGE INT NOT NULL,
	STATE TEXT NOT NULL
);

CREATE TABLE CATEGORY (
	ID SERIAL PRIMARY KEY,
	NAME TEXT UNIQUE NOT NULL,
	DESCRIPTION TEXT NOT NULL,
	OWNER TEXT REFERENCES ACCOUNT(USERNAME) NOT NULL
);

CREATE TABLE PRODUCT (
	ID SERIAL PRIMARY KEY,
	NAME TEXT NOT NULL,
	SKU TEXT UNIQUE NOT NULL,
	CATEGORY TEXT REFERENCES CATEGORY(NAME) NOT NULL,
	PRICE INT NOT NULL
);

CREATE TABLE CART (
	ID SERIAL PRIMARY KEY,
	SKU TEXT REFERENCES PRODUCT(SKU) NOT NULL,
	QUANTITY INT NOT NULL,
	USERNAME TEXT REFERENCES ACCOUNT(USERNAME) NOT NULL	
);

CREATE TABLE CONFIRMATION (
	ID SERIAL PRIMARY KEY,
	USERNAME TEXT REFERENCES ACCOUNT(USERNAME) NOT NULL,
	SKU TEXT NOT NULL,
	QUANTITY INT NOT NULL,
	PRICE INT NOT NULL,
	DATE TEXT NOT NULL
);