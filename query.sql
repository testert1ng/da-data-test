# Draft an SQL query (in T-SQL) that would return all fields in the Values table and also pull in the Account, Entity and Upload descriptions.
SELECT v.ID, v.AcctID, ad.AcctDesc, v.EntID, ed.EntDesc, v.LogID, l.UploadDesc, v.Month, v.Value
FROM Values AS v
JOIN AccountDetails AS ad
ON v.AcctID=ad.AcctID
JOIN EntityDetails AS ed
ON v.EntID=ed.EntID
JOIN Logs AS l
ON v.LogID=l.LogID;

# Describe how you would use the logs table to query the most recent data available in the database for each entity/account/month combination.
SELECT v.ID, jt.AcctID, ad.AcctDesc, jt.EntID, ed.EntDesc, l.LogID, jt.TimeStamp, l.UserName, l.UploadDesc, v.Month, v.Value
FROM (
	SELECT v.AcctID, v.EntID, v.Month, MAX(TimeStamp) AS TimeStamp
    FROM Values AS v
    JOIN Logs AS l
	ON v.LogID=l.LogID
	GROUP BY v.AcctID, v.EntID, v.Month
) AS jt
JOIN Logs AS l
ON jt.TimeStamp=l.TimeStamp
JOIN Values AS v
ON jt.AcctID=v.AcctID
AND jt.EntID=v.EntID
AND jt.Month=v.Month
AND l.LogID=v.LogID
JOIN AccountDetails AS ad
ON jt.AcctID=ad.AcctID
JOIN EntityDetails AS ed
ON jt.EntID=ed.EntID
