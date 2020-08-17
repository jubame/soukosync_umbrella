# DEV-BackendTask-180520-1526
Project name: Soukosync, using umbrella: Soukosync.Umbrella


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

Manual token is assumed to be always valid and never expire. The token will be
automatically fetched and renewed when using credentials.


#### Token retrieval error fallback

Token retrieval will be retried in case of connection error in credential
authentication mode. The execution interval can be set in the environment
variable `INTERVAL_RETRY_TOKEN_SECONDS`


## Execution through Docker

Please ensure authentication environment variables have been set.
```
cd soukosync_umbrella
docker-compose build && docker-compose up
```

## Warehouse synchronization

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

Some examples:

```
curl -X PATCH http://localhost:5000/api/syncall | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    74  100    74    0     0    174      0 --:--:-- --:--:-- --:--:--   174
{
    "data": "6 upserted",
    "date": "2020-08-16T11:34:23.588901Z",
    "response": "ok"
}


curl -X PATCH http://localhost:5000/api/syncall | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   116  100   116    0     0    219      0 --:--:-- --:--:-- --:--:--   219
{
    "data": {
        "__exception__": true,
        "id": null,
        "reason": "timeout"
    },
    "date": "2020-08-16T11:34:32.630631Z",
    "response": "error"
}


curl -X PATCH http://localhost:5000/api/syncast | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    97  100    97    0     0   6062      0 --:--:-- --:--:-- --:--:--  6062
{
    "data": "Soukosync.Caller.cast_sync casted",
    "date": "2020-08-16T11:34:37.263700Z",
    "response": "ok"
}


curl http://localhost:5000/api/synlast | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   320  100   320    0     0  20000      0 --:--:-- --:--:-- --:--:-- 20000
{
    "data": [
        {
            "data": "6 upserted",
            "date": "2020-08-16T11:34:23.588901Z",
            "response": "ok"
        },
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "timeout"
            },
            "date": "2020-08-16T11:34:32.630631Z",
            "response": "error"
        },
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "nxdomain"
            },
            "date": "2020-08-16T11:34:37.263788Z",
            "response": "error"
        }
    ]
}


curl http://localhost/api:5000/synlast?count=1 | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   128  100   128    0     0   5565      0 --:--:-- --:--:-- --:--:--  5565
{
    "data": [
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "nxdomain"
            },
            "date": "2020-08-16T11:34:37.263788Z",
            "response": "error"
        }
    ]
}


curl -X PATCH http://localhost:5000/api/syncall | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    74  100    74    0     0    110      0 --:--:-- --:--:-- --:--:--   110
{
    "data": "6 upserted",
    "date": "2020-08-16T11:35:47.295269Z",
    "response": "ok"
}


curl http://localhost:5000/api/synlast | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   513  100   513    0     0  36642      0 --:--:-- --:--:-- --:--:-- 36642
{
    "data": [
        {
            "data": "6 upserted",
            "date": "2020-08-16T11:34:23.588901Z",
            "response": "ok"
        },
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "timeout"
            },
            "date": "2020-08-16T11:34:32.630631Z",
            "response": "error"
        },
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "nxdomain"
            },
            "date": "2020-08-16T11:34:37.263788Z",
            "response": "error"
        },
        {
            "data": {
                "__exception__": true,
                "id": null,
                "reason": "nxdomain"
            },
            "date": "2020-08-16T11:35:17.285021Z",
            "response": "error"
        },
        {
            "data": "6 upserted",
            "date": "2020-08-16T11:35:47.295269Z",
            "response": "ok"
        }
    ]
}
```


## Automated tests
```
cd soukosync_umbrella
mix test
```