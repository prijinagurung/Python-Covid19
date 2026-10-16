DROP TABLE IF EXISTS tests CASCADE;
DROP TABLE IF EXISTS vaccinations CASCADE;
DROP TABLE IF EXISTS daily_cases CASCADE;
DROP TABLE IF EXISTS countries CASCADE;

CREATE TABLE countries (
    iso_code        VARCHAR(10) PRIMARY KEY,
    location        VARCHAR(100) NOT NULL,
    continent       VARCHAR(30)  NOT NULL,
    population      BIGINT CHECK (population > 0),
    median_age      NUMERIC(4,1),
    gdp_per_capita  NUMERIC(12,2),
    life_expectancy NUMERIC(4,1),
    hospital_beds_per_thousand NUMERIC(5,2)
);

CREATE TABLE daily_cases (
    case_id            SERIAL PRIMARY KEY,
    iso_code           VARCHAR(10) NOT NULL REFERENCES countries(iso_code),
    date               DATE NOT NULL,
    new_cases          INT CHECK (new_cases >= 0),
    total_cases        BIGINT CHECK (total_cases >= 0),
    new_deaths         INT CHECK (new_deaths >= 0),
    total_deaths       BIGINT CHECK (total_deaths >= 0),
    case_fatality_rate NUMERIC(6,2),
    stringency_index   NUMERIC(5,2) CHECK (stringency_index BETWEEN 0 AND 100),
    year               INT,
    month              INT CHECK (month BETWEEN 1 AND 12),
    UNIQUE (iso_code, date)        
);

CREATE TABLE vaccinations (
    vacc_id                 SERIAL PRIMARY KEY,
    iso_code                VARCHAR(10) NOT NULL REFERENCES countries(iso_code),
    date                    DATE NOT NULL,
    total_vaccinations      BIGINT,
    people_vaccinated       BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations        BIGINT,
    UNIQUE (iso_code, date)
);

CREATE TABLE tests (
    test_id       SERIAL PRIMARY KEY,
    iso_code      VARCHAR(10) NOT NULL REFERENCES countries(iso_code),
    date          DATE NOT NULL,
    total_tests   BIGINT,
    new_tests     BIGINT,
    positive_rate NUMERIC(5,4) CHECK (positive_rate BETWEEN 0 AND 1),
    UNIQUE (iso_code, date)
);