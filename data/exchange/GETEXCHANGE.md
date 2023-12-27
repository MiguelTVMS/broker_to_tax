# How to get exchange information for the application

For the development of the application I'm using https://apilayer.com/ to get the historical exchange data.

Here is the request to get the 2023 data.

```shell
curl --location 'https://api.apilayer.com/exchangerates_data/timeseries?start_date=2023-01-01&end_date=2023-12-31&base=USD&symbols=EUR' \
--header 'apikey: XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

> Note that you need to provide your own api key to get the data.

The response for the previews request was:

```json
{
    "success": true,
    "timeseries": true,
    "start_date": "2023-01-01",
    "end_date": "2023-12-31",
    "base": "USD",
    "rates": {
        "2023-01-01": {
            "EUR": 0.934185
        },
        "2023-01-02": {
            "EUR": 0.93656
        },
        "2023-01-03": {
            "EUR": 0.94818
        },
        ... // Removed data to help clarify.
        "2023-12-26": {
            "EUR": 0.905595
        },
        "2023-12-27": {
            "EUR": 0.9003
        },
        "2023-12-28": {
            "EUR": 0.9003
        }
    }
}
```

Get the json object `rates` content and add it the year file, `2023.json` in this case.

This is the example of the content of the `2023.json` file.

```json
{
    "2023-01-01": {
        "EUR": 0.934185
    },
    "2023-01-02": {
        "EUR": 0.93656
    },
    "2023-01-03": {
        "EUR": 0.94818
    },
    ... // Removed data to help clarify.
    "2023-12-26": {
        "EUR": 0.905595
    },
    "2023-12-27": {
        "EUR": 0.9003
    },
    "2023-12-28": {
        "EUR": 0.9003
    }
}
```

The application will get the file when executed.
