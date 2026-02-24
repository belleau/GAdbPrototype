DROP VIEW IF EXISTS profileAdmixturePropView;
DROP VIEW IF EXISTS ancestralAdmixturesView;
DROP VIEW IF EXISTS profileView;
DROP VIEW IF EXISTS admixtureProportionView;


CREATE VIEW profileView AS
SELECT m1.*, n1.accession AS accession, n1.name AS name FROM molecularProfile m1
INNER JOIN
nucleicAcidSource n1 ON
m1.nucleicAcidSourceId = n1.nucleicAcidSourceId;


CREATE VIEW admixtureProportionView AS
SELECT a1.*, p1.acronym AS acronym FROM admixtureProportion a1
INNER JOIN
populationDefinition p1 ON
a1.populationDefinitionId = p1.populationDefinitionId;



CREATE VIEW ancestralAdmixturesView AS
SELECT a1.*, p1.experiment AS experiment, 
    p1.bioProject AS bioProject, p1.accession AS accession,
    p1.name AS name, i1.name AS method, 
    i1.description AS methodDescription
FROM ancestralAdmixtures a1
INNER JOIN
profileView p1 ON
a1.molecularProfileId = p1.molecularProfileId
INNER JOIN
inferenceMethodProperties i1 ON
a1.inferenceMethodPropertiesId = i1.inferenceMethodPropertiesId;

CREATE VIEW profileAdmixturePropView AS
SELECT a1.*, 
    c1.proportion AS pAFR,
    c1.accuracy AS accuracyAFR, c1.CILowerBound AS CILowerBoundAFR, 
    c1.CIUpperBound AS CIUpperBoundAFR,
    c2.proportion AS pAMR,
    c2.accuracy AS accuracyAMR, c2.CILowerBound AS CILowerBoundAMR, 
    c2.CIUpperBound AS CIUpperBoundAMR,
    c3.proportion AS pEAS,
    c3.accuracy AS accuracyEAS, c3.CILowerBound AS CILowerBoundEAS, 
    c3.CIUpperBound AS CIUpperBoundEAS,
    c4.proportion AS pEUR,
    c4.accuracy AS accuracyEUR, c4.CILowerBound AS CILowerBoundEUR, 
    c4.CIUpperBound AS CIUpperBoundEUR,
    c5.proportion AS pSAS,
    c5.accuracy AS accuracySAS, c5.CILowerBound AS CILowerBoundSAS, 
    c5.CIUpperBound AS CIUpperBoundSAS
FROM ancestralAdmixturesView a1
INNER JOIN
admixtureProportionView c1 ON
    (a1.ancestralAdmixturesId = c1.ancestralAdmixturesId
    AND c1.acronym == "AFR")
INNER JOIN
admixtureProportionView c2 ON
    (a1.ancestralAdmixturesId = c2.ancestralAdmixturesId
    AND c2.acronym == "AMR")
INNER JOIN
admixtureProportionView c3 ON
    (a1.ancestralAdmixturesId = c3.ancestralAdmixturesId
    AND c3.acronym == "EAS")
INNER JOIN
admixtureProportionView c4 ON
    (a1.ancestralAdmixturesId = c4.ancestralAdmixturesId
    AND c4.acronym == "EUR")
INNER JOIN
admixtureProportionView c5 ON
    (a1.ancestralAdmixturesId = c5.ancestralAdmixturesId
    AND c5.acronym == "SAS");
