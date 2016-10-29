# Saldo-EMT
iOS app to log bus rides and manually manage bus pass balance

# TODO
- [ ] Logging framework (2016-10-23)
- [ ] There are lot of prints that can be logs and errors. Maybe I should do a Error and pass a string to it (2016-10-23)
- [x] db2json should upload result to AWS S3 (2016-10-23)
- [x] Add timestamp to db2json script to avoid parsing json if there are no changes (2016-10-23)
- [x] Background fetch of new json file (2016-10-23)
- [ ] Remove iAd and search alternative (2016-10-23)
- [ ] i18n (2016-10-27)
- [ ] App icon (2016-10-27)

# Worklog

- Refactor somehow performFetchWithCompletionHandler, I don't like the dupe code plus unecessary public methods in Store
- Add dev button to download fare file on command
