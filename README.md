# AudioSessionCoreDataManager
Class for managing CoreData database entries for audio session recordings.

## Getting Started

Import AudioSessionCoreDataManager.swift into your Xcode project.

Insert new session into databse:
```
AudioSessionCoreDataManager.shared.newSession(sessionName:"test")

```
Insert new recording into databse:
```
AudioSessionCoreDataManager.shared.newRecording(sessionName:"test", location:"location", fileName:"test", decible:dec)

```
Delete recording from databse:
```
AudioSessionCoreDataManager.shared.deleteRecording(recordingName:"test", sessionName:"test")

```
Delete session and all recordings associated with session:
```
AudioSessionCoreDataManager.shared.deleteSession(session:sessionObject)

```
Load current sessions recordings into current sessions array:
```
AudioSessionCoreDataManager.shared.loadSessionsRecordings(sessionName:"test")

```
## Authors

* **Ernie Lail** - *Initial work* - [MaranathaTech](https://github.com/MaranathaTech)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


