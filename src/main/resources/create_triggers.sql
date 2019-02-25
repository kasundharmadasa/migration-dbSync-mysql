USE <DB_NAME>;
DELIMITER $$
CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SYNC (
            TOKEN_ID VARCHAR (255),
            ACCESS_TOKEN VARCHAR(255),
            REFRESH_TOKEN VARCHAR(255),
            CONSUMER_KEY_ID INTEGER,
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
            USER_TYPE VARCHAR (25),
            GRANT_TYPE VARCHAR (50),
            TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            REFRESH_TOKEN_TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
            TOKEN_SCOPE_HASH VARCHAR(32),
            TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',
            TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',
            SUBJECT_IDENTIFIER VARCHAR(255),
            PRIMARY KEY (TOKEN_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
            CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                           TOKEN_STATE,TOKEN_STATE_ID)
)ENGINE INNODB
$$


CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE_SYNC (
            TOKEN_ID VARCHAR (255),
            TOKEN_SCOPE VARCHAR (60),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
            FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE
)ENGINE INNODB$$


CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE_SYNC (
            CODE_ID VARCHAR (255),
            AUTHORIZATION_CODE VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            CALLBACK_URL VARCHAR(1024),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
            TIME_CREATED TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            STATE VARCHAR (25) DEFAULT 'ACTIVE',
            TOKEN_ID VARCHAR(255),
            SUBJECT_IDENTIFIER VARCHAR(255),
            PKCE_CODE_CHALLENGE VARCHAR(255),
            PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),
            PRIMARY KEY (CODE_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
)ENGINE INNODB
$$

CREATE TRIGGER table_token_insert AFTER INSERT
ON IDN_OAUTH2_ACCESS_TOKEN FOR EACH ROW
BEGIN
   INSERT INTO
      IDN_OAUTH2_ACCESS_TOKEN_SYNC ( TOKEN_ID, ACCESS_TOKEN, REFRESH_TOKEN, CONSUMER_KEY_ID, AUTHZ_USER, TENANT_ID,
      USER_DOMAIN, USER_TYPE, GRANT_TYPE, TIME_CREATED, REFRESH_TOKEN_TIME_CREATED, VALIDITY_PERIOD,
      REFRESH_TOKEN_VALIDITY_PERIOD, TOKEN_SCOPE_HASH, TOKEN_STATE, TOKEN_STATE_ID, SUBJECT_IDENTIFIER )
   VALUES
      (
        NEW.TOKEN_ID, NEW.ACCESS_TOKEN, NEW.REFRESH_TOKEN, NEW.CONSUMER_KEY_ID, NEW.AUTHZ_USER, NEW.TENANT_ID,
        NEW.USER_DOMAIN, NEW.USER_TYPE, NEW.GRANT_TYPE, NEW.TIME_CREATED, NEW.REFRESH_TOKEN_TIME_CREATED,
        NEW.VALIDITY_PERIOD, NEW.REFRESH_TOKEN_VALIDITY_PERIOD, NEW.TOKEN_SCOPE_HASH, NEW.TOKEN_STATE,
        NEW.TOKEN_STATE_ID, NEW.SUBJECT_IDENTIFIER
      )
      ON DUPLICATE KEY
      UPDATE
         ACCESS_TOKEN = NEW.ACCESS_TOKEN, REFRESH_TOKEN = NEW.REFRESH_TOKEN, CONSUMER_KEY_ID = NEW.CONSUMER_KEY_ID,
         AUTHZ_USER = NEW.AUTHZ_USER, TENANT_ID = NEW.TENANT_ID, USER_DOMAIN = NEW.USER_DOMAIN,
         USER_TYPE = NEW.USER_TYPE, GRANT_TYPE = NEW.GRANT_TYPE, TIME_CREATED = NEW.TIME_CREATED,
         REFRESH_TOKEN_TIME_CREATED = NEW.REFRESH_TOKEN_TIME_CREATED, VALIDITY_PERIOD = NEW.VALIDITY_PERIOD,
         REFRESH_TOKEN_VALIDITY_PERIOD = NEW.REFRESH_TOKEN_VALIDITY_PERIOD, TOKEN_SCOPE_HASH = NEW.TOKEN_SCOPE_HASH,
         TOKEN_STATE = NEW.TOKEN_STATE, TOKEN_STATE_ID = NEW.TOKEN_STATE_ID, SUBJECT_IDENTIFIER = NEW.SUBJECT_IDENTIFIER;
END
$$

CREATE TRIGGER table_token_update AFTER
UPDATE
   ON IDN_OAUTH2_ACCESS_TOKEN FOR EACH ROW
   BEGIN
      INSERT INTO
         IDN_OAUTH2_ACCESS_TOKEN_SYNC ( TOKEN_ID, ACCESS_TOKEN, REFRESH_TOKEN, CONSUMER_KEY_ID, AUTHZ_USER, TENANT_ID,
         USER_DOMAIN, USER_TYPE, GRANT_TYPE, TIME_CREATED, REFRESH_TOKEN_TIME_CREATED, VALIDITY_PERIOD,
         REFRESH_TOKEN_VALIDITY_PERIOD, TOKEN_SCOPE_HASH, TOKEN_STATE, TOKEN_STATE_ID, SUBJECT_IDENTIFIER)
      VALUES
         (
            NEW.TOKEN_ID, NEW.ACCESS_TOKEN, NEW.REFRESH_TOKEN, NEW.CONSUMER_KEY_ID, NEW.AUTHZ_USER, NEW.TENANT_ID,
            NEW.USER_DOMAIN, NEW.USER_TYPE, NEW.GRANT_TYPE, NEW.TIME_CREATED, NEW.REFRESH_TOKEN_TIME_CREATED,
            NEW.VALIDITY_PERIOD, NEW .REFRESH_TOKEN_VALIDITY_PERIOD, NEW.TOKEN_SCOPE_HASH, NEW.TOKEN_STATE,
            NEW.TOKEN_STATE_ID, NEW.SUBJECT_IDENTIFIER
         )
         ON DUPLICATE KEY
         UPDATE
            ACCESS_TOKEN = NEW.ACCESS_TOKEN, REFRESH_TOKEN = NEW.REFRESH_TOKEN, CONSUMER_KEY_ID = NEW.CONSUMER_KEY_ID,
            AUTHZ_USER = NEW.AUTHZ_USER, TENANT_ID = NEW.TENANT_ID, USER_DOMAIN = NEW.USER_DOMAIN,
            USER_TYPE = NEW.USER_TYPE, GRANT_TYPE = NEW.GRANT_TYPE, TIME_CREATED = NEW.TIME_CREATED,
            REFRESH_TOKEN_TIME_CREATED = NEW.REFRESH_TOKEN_TIME_CREATED, VALIDITY_PERIOD = NEW.VALIDITY_PERIOD,
            REFRESH_TOKEN_VALIDITY_PERIOD = NEW.REFRESH_TOKEN_VALIDITY_PERIOD, TOKEN_SCOPE_HASH = NEW.TOKEN_SCOPE_HASH,
            TOKEN_STATE = NEW.TOKEN_STATE, TOKEN_STATE_ID = NEW.TOKEN_STATE_ID, SUBJECT_IDENTIFIER = NEW.SUBJECT_IDENTIFIER;
END
$$

CREATE TRIGGER table_token_scope_insert AFTER INSERT
ON IDN_OAUTH2_ACCESS_TOKEN_SCOPE FOR EACH ROW
BEGIN
   INSERT INTO
      IDN_OAUTH2_ACCESS_TOKEN_SCOPE_SYNC (TOKEN_ID, TOKEN_SCOPE, TENANT_ID)
   VALUES
      (
         NEW.TOKEN_ID, NEW.TOKEN_SCOPE, NEW.TENANT_ID
      )
;
END
$$

CREATE TRIGGER table_auth_code_insert AFTER INSERT
ON IDN_OAUTH2_AUTHORIZATION_CODE FOR EACH ROW
BEGIN
   INSERT INTO
      IDN_OAUTH2_AUTHORIZATION_CODE_SYNC (CODE_ID, AUTHORIZATION_CODE, CONSUMER_KEY_ID, CALLBACK_URL, SCOPE,
      AUTHZ_USER, TENANT_ID, USER_DOMAIN, TIME_CREATED, VALIDITY_PERIOD, STATE, TOKEN_ID, SUBJECT_IDENTIFIER,
      PKCE_CODE_CHALLENGE, PKCE_CODE_CHALLENGE_METHOD)
   VALUES
      (
         NEW.CODE_ID, NEW.AUTHORIZATION_CODE, NEW.CONSUMER_KEY_ID, NEW.CALLBACK_URL, NEW.SCOPE, NEW.AUTHZ_USER,
         NEW.TENANT_ID, NEW.USER_DOMAIN, NEW.TIME_CREATED, NEW.VALIDITY_PERIOD, NEW.STATE, NEW.TOKEN_ID,
         NEW.SUBJECT_IDENTIFIER, NEW.PKCE_CODE_CHALLENGE, NEW.PKCE_CODE_CHALLENGE_METHOD
      )
      ON DUPLICATE KEY
      UPDATE
         AUTHORIZATION_CODE = NEW.AUTHORIZATION_CODE, CONSUMER_KEY_ID = NEW.CONSUMER_KEY_ID,
         CALLBACK_URL = NEW.CALLBACK_URL, SCOPE = NEW.SCOPE, AUTHZ_USER = NEW.AUTHZ_USER,
         TENANT_ID = NEW.TENANT_ID, USER_DOMAIN = NEW.USER_DOMAIN, TIME_CREATED = NEW.TIME_CREATED,
         VALIDITY_PERIOD = NEW.VALIDITY_PERIOD, STATE = NEW.STATE, TOKEN_ID = NEW.TOKEN_ID,
         SUBJECT_IDENTIFIER = NEW.SUBJECT_IDENTIFIER , PKCE_CODE_CHALLENGE = NEW.PKCE_CODE_CHALLENGE,
         PKCE_CODE_CHALLENGE_METHOD = NEW.PKCE_CODE_CHALLENGE_METHOD;
END
$$

CREATE TRIGGER table_auth_code_update AFTER
UPDATE
   ON IDN_OAUTH2_AUTHORIZATION_CODE FOR EACH ROW
   BEGIN
      INSERT INTO
         IDN_OAUTH2_AUTHORIZATION_CODE_SYNC (CODE_ID, AUTHORIZATION_CODE, CONSUMER_KEY_ID, CALLBACK_URL, SCOPE,
         AUTHZ_USER, TENANT_ID, USER_DOMAIN, TIME_CREATED, VALIDITY_PERIOD, STATE, TOKEN_ID, SUBJECT_IDENTIFIER,
         PKCE_CODE_CHALLENGE, PKCE_CODE_CHALLENGE_METHOD)
      VALUES
         (
            NEW.CODE_ID, NEW.AUTHORIZATION_CODE, NEW.CONSUMER_KEY_ID, NEW.CALLBACK_URL, NEW.SCOPE, NEW.AUTHZ_USER,
            NEW.TENANT_ID, NEW.USER_DOMAIN, NEW.TIME_CREATED, NEW.VALIDITY_PERIOD, NEW.STATE, NEW.TOKEN_ID,
            NEW.SUBJECT_IDENTIFIER, NEW.PKCE_CODE_CHALLENGE, NEW.PKCE_CODE_CHALLENGE_METHOD
         )
         ON DUPLICATE KEY
         UPDATE
            AUTHORIZATION_CODE = NEW.AUTHORIZATION_CODE, CONSUMER_KEY_ID = NEW.CONSUMER_KEY_ID,
            CALLBACK_URL = NEW.CALLBACK_URL, SCOPE = NEW.SCOPE, AUTHZ_USER = NEW.AUTHZ_USER,
            TENANT_ID = NEW.TENANT_ID, USER_DOMAIN = NEW.USER_DOMAIN, TIME_CREATED = NEW.TIME_CREATED,
            VALIDITY_PERIOD = NEW.VALIDITY_PERIOD, STATE = NEW.STATE, TOKEN_ID = NEW.TOKEN_ID,
            SUBJECT_IDENTIFIER = NEW.SUBJECT_IDENTIFIER , PKCE_CODE_CHALLENGE = NEW.PKCE_CODE_CHALLENGE,
            PKCE_CODE_CHALLENGE_METHOD = NEW.PKCE_CODE_CHALLENGE_METHOD;
   END
   $$
DELIMITER ;
COMMIT;