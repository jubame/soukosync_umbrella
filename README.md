＃ DEV-BackendTask-180520-1526.pdf
Soukosync.Umbrella


## Configuration

The environment variables that appear below can be set either by docker-compose
.env file or command line export. If the same variable is set through both export
and .env file, the latter will take precedence.


### Authentication

Authentication against the API can be configured either by specifying a manual
token or user/password credentials:

- Manual token: environment variable `API_TOKEN`
- Credentials: environment variables `API_USER` and `API_PASSWORD`

In case both manual token and credentials are set, manual token takes
precedence.

Manual token is assumed to never expire. The token will be automatically fetched
and renewed when using credentials.


#### Token retrieval error fallback

Token retrieval will be retried in case of connection error in credential
authentication mode. The execution interval can be set in the environment
variable `INTERVAL_RETRY_TOKEN_SECONDS`


### Warehouse synchronization

### Automatic
The scheduler will call the sync operation periodically. The interval can be
configured in the environment variable `INTERVAL_SCHEDULER_SECONDS`

### Manual
The following endpoints are available at:

- `/api/syncall` (HTTP PATCH): Synchronous call, information returned
- `/api/syncast` (HTTP PATCH): Asynchronous cast, information can be retrieved
later by inspecting the successful sync queue at `/api/synlast` (HTTP GET). If
it is too long, `count` query parameter can be specified to shorten it, e.g.
`/api/synlast?count=2`



```
curl -X PATCH http://localhost/api/syncall
{"data":"全部ＯＫ、6つ　入れちゃった！","date":"2020-08-16T10:25:57.540778Z","response":"ok"}

curl -X PATCH http://localhost/api/syncast
{"data":"Soukosync.Caller.cast_sync casted","date":"2020-08-16T10:26:56.114447Z","response":"ok"}

curl http://localhost/api/synlast
{"data":[{"data":"全部ＯＫ、6つ　入れちゃった！","date":"2020-08-16T10:37:45.915006Z","response":"ok"},{"data":"全部ＯＫ、6つ　入れちゃった！","date":"2020-08-16T10:37:51.911118Z","response":"ok"},{"data":"全部ＯＫ、6つ　入れちゃった！","date":"2020-08-16T10:37:58.397904Z","response":"ok"}]}
```


