# Broker to Tax

[![Test](https://github.com/MiguelTVMS/broker_to_tax/actions/workflows/test.yml/badge.svg?branch=develop&event=push)](https://github.com/MiguelTVMS/broker_to_tax/actions/workflows/test.yml)
[![Build](https://github.com/MiguelTVMS/broker_to_tax/actions/workflows/build.yml/badge.svg?branch=main&event=push)](https://github.com/MiguelTVMS/broker_to_tax/actions/workflows/build.yml)

A simple cli application that transforms information from brokers to the Portuguese tax information.

> **Warning**  
> Use this application at you own risk. This is a hobby project. I'm not a tax expert. I'm not a lawyer. I'm not a financial advisor. I'm just a guy that likes to code and likes to invest. I'm not responsible for any damage this application may cause. If you have any doubts about your taxes, please consult a professional.

## How to use it

Download it form the [releases page](https://github.com/MiguelTVMS/broker_to_tax/releases). It's strongly recommended to use the latest version.

The tool is very simple, you must provide the file where the source operations are available in csv format. Read the [eToro section](#etoro) in [Supported Brokers](#supported-brokers) to know how to generate the csv.

Heres an example of how to use it to generate the csv for eToro stock operations grouped by source country.

```shell
brokertotax etoro stock -f "path/to/etoro_closed_positions.csv" -g source-country
```

This will generate a csv file with stock operations grouped by country. The file will be named `stock_gains_grouped_by_source_country.csv`. This file is ready to be used as base for the Portuguese IRS form categories G or E.

The application support these kinds of operations, `stock`, `crypto`, `CFD`, and `ETF`. The `stock` operations can be grouped in `source-country` and `operations` by using the `-g` or `--group-by` parameter. Other operations can be grouped in other ways, see the help for more information.

```shell
brokertotax etoro -h
```

Will output something like this:

```text
Convert eToro data to a format that can be imported into tax software

Usage: brokertotax etoro <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  cfd      Convert CFD data to a format that can be imported into tax software
  crypto   Convert crypto data to a format that can be imported into tax software
  etf      Convert ETF data to a format that can be imported into tax software
  stock    Convert stock data to a format that can be imported into tax software

Run "brokertotax help" to see global options.
```

Each command has it own help. For example:

```shell
brokertotax etoro stock -h
```

Will output something like this:

```text
Convert stock data to a format that can be imported into tax software

Usage: brokertotax etoro stock [arguments]
-h, --help                  Print this usage information.
-f, --file                  The file to parse.
    --exchange-directory    The directory containing the exchange rates
                            (defaults to "data/exchange")
-c, --currency              The currency to use for the gains.
                            [usd, eur (default)]
-g, --group-by              The grouping to use in the gains.
                            [none (default), source-country, operation]

Run "brokertotax help" to see global options.
```

Check the full help for know more about about the available options.

## Supported Brokers

This first version is being developed to support [eToro](https://www.etoro.com/). But the idea is that new brokers can be added by pull requests. The code is being created to be simple to add a broker.

### eToro

How to get the operations in eToro:

1. Go to the [Account Statement](https://www.etoro.com/documents/accountstatement) page.
2. Select the last year option.
3. Click on create.
4. Click on the green document icon with "xls" written inside it.
5. Save the file.
6. Open the file using excel and go to the Closed Positions sheet.
7. Go to File » Save As and choose CSV as format.
8. Click on save. An alert will rise telling that it will only save the current sheet since CSV doesn't support multiple sheets, click Ok.
9. Run the command as specified in [How to use it](#how-to-use-it) section.

## How to contribute

To contribute to this project you can open an issue or a pull request. If you want to add a new broker, please open an issue first so we can discuss the best way to do it.
