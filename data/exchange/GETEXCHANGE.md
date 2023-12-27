# How to get exchange information for the application.

For the development of the application I'm using https://apilayer.com/ to get the historical echange data.

Here is the request to get the 2023 data.

```shell
curl --location 'https://api.apilayer.com/exchangerates_data/timeseries?start_date=2023-01-01&end_date=2023-12-31&base=USD&symbols=EUR' \
--header 'apikey: XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
> Note that you need to provide your own api key to get the data.
