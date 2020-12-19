## SQL Test

### Question 1

Draft an SQL query (in T-SQL) that would return all fields in the Values table and also pull in the Account, Entity and Upload descriptions.

```
SELECT v.ID, v.AcctID, ad.AcctDesc, v.EntID, ed.EntDesc, v.LogID, l.UploadDesc, v.Month, v.Value
FROM Values AS v
JOIN AccountDetails AS ad
ON v.AcctID=ad.AcctID
JOIN EntityDetails AS ed
ON v.EntID=ed.EntID
JOIN Logs AS l
ON v.LogID=l.LogID;
```

The extracted results will be 


| ID | AcctID | AcctDesc          | EntID | EntDesc      | LogID | UploadDesc                | Month  | Value |  
| -- | ------ | :---------------- | ----- | ------------ | ----- | :------------------------ | ------ | ----: | 
| 1  | 10020  | Cash at bank      | B1    | XYZ Division | 1     | Initial upload of July TB | Jul-14 | 10    |
| 2  | 20030  | Interest received | B1    | XYZ Division | 1     | Initial upload of July TB | Jul-14 | -10   | 
| 3  | 10020  | Cash at bank      | C1    | ABC Division | 2     | Initial upload of July TB | Jul-14 | 81    |
| 4  | 20030  | Interest received | C1    | ABC Division | 2     | Initial upload of July TB | Jul-14 | -81   | 
| 5  | 10020  | Cash at bank      | B1    | XYZ Division | 3     | Update - found an error!  | Jul-14 | 12    |
| 6  | 20030  | Interest received | B1    | XYZ Division | 3     | Update - found an error!  | Jul-14 | -12   | 

### Question 2

Describe how you would use the logs table to query the most recent data available in the database for each entity/account/month combination.

For this question, assuming both the latest `ID` in `Values` table and latest `LogID` in `Logs` table cannot represent the latest data, only the `TimeStamp` field in `Logs` table can hlep with the situation. 

In this case, to get the most recent data for each entity, account, month combination, the `Values` table can join with `Logs` table and the use `GROUP` to get all the possible combination and also get the latest data by `MAX(TimeStamp)`.

Then, after getting the initial draft table with key IDs, all the other fields can be filled similarlly with `JOIN`.

An example query can be 

```
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
ON jt.EntID=ed.EntID;
```

Also, the extracted results will be 

| ID | AcctID | AcctDesc          | EntID | EntDesc      | LogID | TimeStamp            | UserName   | UploadDesc                | Month  | Value |  
| -- | ------ | :---------------- | ----- | ------------ | ----- | -------------------- | ---------- | :------------------------ | ------ | ----: | 
| 3  | 10020  | Cash at bank      | C1    | ABC Division | 2     | 6/Aug/14 1:21:00 PM  |            | Initial upload of July TB | Jul-14 | 81    |
| 4  | 20030  | Interest received | C1    | ABC Division | 2     | 6/Aug/14 1:21:00 PM  |            | Initial upload of July TB | Jul-14 | -81   | 
| 5  | 10020  | Cash at bank      | B1    | XYZ Division | 3     | 7/Aug/14 10:00:00 AM | Joe Bloggs | Update - found an error!  | Jul-14 | 12    |
| 6  | 20030  | Interest received | B1    | XYZ Division | 3     | 7/Aug/14 10:00:00 AM | Joe Bloggs | Update - found an error!  | Jul-14 | -12   | 