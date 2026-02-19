DROP VIEW IF EXISTS ancestryCallView;
DROP VIEW IF EXISTS popSpecificAccuracyView;
DROP TABLE IF EXISTS admixtureProportion;
DROP TABLE IF EXISTS ancestralAdmixtures;
DROP TABLE IF EXISTS popSpecificAccuracy;
DROP TABLE IF EXISTS ancestryCall;
DROP TABLE IF EXISTS inferenceMethodProperties;
DROP TABLE IF EXISTS inferenceMethodPipeline;
DROP TABLE IF EXISTS inferenceMethod;
DROP TABLE IF EXISTS softwarePipeline;
DROP TABLE IF EXISTS software;
DROP TABLE IF EXISTS pipeline;
DROP TABLE IF EXISTS populationDefinition;
DROP TABLE IF EXISTS populationResolution;
DROP TABLE IF EXISTS populationReference;
DROP TABLE IF EXISTS molecularProfile;
DROP TABLE IF EXISTS nucleicAcidSource;
DROP TABLE IF EXISTS source;


CREATE TABLE source (
    sourceId       INTEGER     PRIMARY KEY AUTOINCREMENT,
    database       TEXT (3, 50),
    accession      TEXT (3, 50),
    name           TEXT (3, 50),
    URL            TEXT (3, 300),
    reference      TEXT (3, 300),
    description    TEXT (3, 300),
    comments       TEXT (0, 300)
);

-- Not decide yet if I keep sourceId for both nucleicAcidSource
-- and molecularProfile
CREATE TABLE nucleicAcidSource (
    nucleicAcidSourceId       INTEGER       PRIMARY KEY AUTOINCREMENT,
    accession       TEXT (3, 50),
    name            TEXT (2, 50),
    description     TEXT (2, 200),
    sourceId        INTEGER      REFERENCES source (sourceId),
    comments        TEXT (0, 300)
);

CREATE TABLE molecularProfile (
    molecularProfileId INTEGER      PRIMARY KEY AUTOINCREMENT,
    bioProject           TEXT (3, 30),
    bioSample            TEXT (3, 30),
    experiment           TEXT (3, 30),
    libraryStrategy      TEXT (3, 30),
    description          TEXT (2, 200),
    sourceId             INTEGER      REFERENCES source (sourceId),
    nucleicAcidSourceId  INTEGER      REFERENCES nucleicAcidSource (nucleicAcidSourceId)
);

-- Population reference for the ancestry inferece (ex 1000 genomes)
CREATE TABLE populationReference (
    populationReferenceId INTEGER       PRIMARY KEY AUTOINCREMENT,
    name              TEXT (2, 50),
    description       TEXT (2, 200),
    nickname          TEXT (2, 50),
    sourceId          INTEGER      REFERENCES source (sourceId)
);

CREATE TABLE populationResolution (
    populationResolutionId     INTEGER       PRIMARY KEY AUTOINCREMENT,
    name                       TEXT (2, 50),
    description                TEXT (2, 200),
    populationReferenceId      INTEGER       REFERENCES populationReference (populationReferenceId)
);


-- Population categories include in population project
CREATE TABLE populationDefinition (
    populationDefinitionId     INTEGER       PRIMARY KEY AUTOINCREMENT,
    acronym                    TEXT (2, 8),
    name                       TEXT (2, 50),
    description                TEXT (2, 200),
    latitude                   NUMERIC,
    longitude                  NUMERIC,
    superPop            INTEGER      REFERENCES populationDefinition (populationDefinitionId),
    -- resolution is the level ancestry superPop (AFR, EUR, EAS) or pop (sous group of superPop))
    populationResolutionId INTEGER       REFERENCES populationResolution (populationResolutionId)
);

CREATE TABLE pipeline (
    pipelineId   INTEGER  PRIMARY KEY AUTOINCREMENT,
    name         TEXT (2, 50),
    description  TEXT (2, 200),
    version      TEXT (2, 50),
    sourceId         INTEGER      REFERENCES source (sourceId)
);

CREATE TABLE software (
    softwareId       INTEGER  PRIMARY KEY AUTOINCREMENT,
    name             TEXT (2, 50),
    description      TEXT (2, 200),
    version          TEXT (2, 50),
    sourceId         INTEGER      REFERENCES source (sourceId)
);

CREATE TABLE softwarePipeline (
    softwarePipelineId   INTEGER  PRIMARY KEY AUTOINCREMENT,
    orderSoftware        INTEGER,
    softwareId           INTEGER  REFERENCES software (softwareId),
    pipelineId           INTEGER  REFERENCES pipeline (pipelineId)
);


CREATE TABLE inferenceMethod (
    inferenceMethodId   INTEGER  PRIMARY KEY AUTOINCREMENT,
    name         TEXT (2, 50),
    description  TEXT (2, 200),
    sourceId         INTEGER      REFERENCES source (sourceId)
);

CREATE TABLE inferenceMethodPipeline (
    inferenceMethodPipelineId INTEGER  PRIMARY KEY AUTOINCREMENT,
    inferenceMethodId         INTEGER   REFERENCES inferenceMethod (inferenceMethodId),
    pipelineId        INTEGER   REFERENCES pipeline (pipelineId)
);


-- resolution of ancestry inference
-- join inferenceMethod and populationResolution
-- Ancestryresolution specifies the table where  the ancestry is kept, ancestryCall Admixture
CREATE TABLE inferenceMethodProperties (
    inferenceMethodPropertiesId   INTEGER  PRIMARY KEY AUTOINCREMENT,
    inferenceMethodPipelineId     INTEGER  REFERENCES inferenceMethodPipeline (inferenceMethodPipelineId),
    populationResolutionId   INTEGER  REFERENCES populationResolution (populationResolutionId),
    name                  TEXT (2, 75),
    description           TEXT (2, 200),
    accuracyQuantifier   TEXT (2, 300)
);

-- Ancestry global can be continental or subcontinental
-- define in by AncestryID refere to resolution of ancestry
-- Maybe add a table with the ancestry allowed
CREATE TABLE ancestryCall (
    ancestryCallId      INTEGER      PRIMARY KEY AUTOINCREMENT,
    molecularProfileId      INTEGER      REFERENCES molecularProfile (molecularProfileId),
    inferenceMethodPropertiesId   INTEGER      REFERENCES inferenceMethodProperties (inferenceMethodPropertiesId),
    populationDefinitionId       INTEGER      REFERENCES populationDefinition (populationDefinitionId),
    accuracy              NUMERIC,
    CILowerBound           NUMERIC,
    CIUpperBound           NUMERIC
);

-- from the synthetic data can keep the AUROC specific to an populationDefinitionId

CREATE TABLE popSpecificAccuracy (
    popSpecificAccuracyId   INTEGER      PRIMARY KEY AUTOINCREMENT,
    ancestryCallId      INTEGER      REFERENCES ancestryCall (ancestryCallId),
    populationDefinitionId       INTEGER      REFERENCES populationDefinition (populationDefinitionId),
    accuracy              NUMERIC,
    CILowerBound           NUMERIC,
    CIUpperBound           NUMERIC
);

CREATE TABLE ancestralAdmixtures (
    ancestralAdmixturesId        INTEGER      PRIMARY KEY AUTOINCREMENT,
    molecularProfileId         INTEGER      REFERENCES molecularProfile (molecularProfileId),
    inferenceMethodPropertiesId      INTEGER      REFERENCES inferenceMethodProperties (inferenceMethodPropertiesId),
    accuracy               NUMERIC,
    CILowerBound           NUMERIC,
    CIUpperBound           NUMERICß
);

CREATE TABLE admixtureProportion (
    admixtureProportionId    INTEGER      PRIMARY KEY AUTOINCREMENT,
    ancestralAdmixturesId      INTEGER      REFERENCES ancestralAdmixtures (ancestralAdmixturesId),
    populationDefinitionId   INTEGER      REFERENCES populationDefinition (populationDefinitionId),
    proportion               NUMERIC,
    accuracy                 NUMERIC,
    CILowerBound             NUMERIC,
    CIUpperBound             NUMERIC
);


CREATE VIEW ancestryCallView AS
SELECT * FROM ancestryCall INNER JOIN
populationDefinition ON
ancestryCall.populationDefinitionId = populationDefinition.populationDefinitionId INNER JOIN
molecularProfile ON
molecularProfile.molecularProfileId = ancestryCall.molecularProfileId;


CREATE VIEW popSpecificAccuracyView AS
SELECT * FROM globalAncestry INNER JOIN
popSpecificAccuracy c1 ON
    globalAncestry.globalAncestryId = c1.globalAncestryId
AND c1.populationDefinitionId == 1
INNER JOIN
popSpecificAccuracy c2 ON
    globalAncestry.globalAncestryId = c2.globalAncestryId
AND c2.populationDefinitionId == 2 ;
