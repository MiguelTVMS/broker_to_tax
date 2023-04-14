import "dart:io";

import "package:test/test.dart";
import "../bin/main.dart" as app;

void main() {
  var sampleDataLocation = File("./.sample_data/etoro.csv").absolute.path;
  var exchangeDataLocation = File("./data/exchange").absolute.path;

  group("Command:", () {
    group("stock", ([String operation = "stock"]) {
      test("", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g source-country", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "source-country"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g operation", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "operation"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
    });
    group("etf", ([String operation = "etf"]) {
      test("", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g source-country", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "source-country"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g operation", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "operation"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
    });
    group("crypto", ([String operation = "crypto"]) {
      test("", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g operation", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "operation"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
    });
    group("cfd", ([String operation = "cfd"]) {
      test("", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
      test("-g operation", () async {
        var arguments = [
          "etoro",
          operation,
          "--file",
          sampleDataLocation,
          "--exchange-directory",
          exchangeDataLocation,
          "-g",
          "operation"
        ];
        var exitCode = await app.run(arguments);
        expect(exitCode, equals(0));
      }, tags: ["command"]);
    });
  });
}
