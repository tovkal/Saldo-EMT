# Saldo-EMT
[![Build Status](https://travis-ci.org/Tovkal/Saldo-EMT.svg?branch=master)](https://travis-ci.org/Tovkal/Saldo-EMT)

iOS app to log bus rides and manually manage bus pass balance from Palma's buses.

# Building the app

A file is needed to run the app properly, `SaldoEMT/Resources/Secrets.plist` that it is not included in the repository and contains a number of credentials for different dependencies.

## Dependencies
We use Carthage for dependency management.

Run `carthage bootstrap --platform iOS --cache-builds` before opening the project in Xcode.

You can install [Carthage](https://github.com/Carthage/Carthage) with Homebrew:
```
brew install carthage
```

## Fastlane

Currently there are two lanes, one for running the tests (`fastlane test`) and one for uploading a new beta to TestFlight (`fastlane beta`).

You can install [Fastlane](https://github.com/fastlane/fastlane) with Homebrew:
```
brew cask install fastlane
```

## SwiftLint

We have a script that runs when building the app, it executes SwiftLint to enforce a style and conventions to the code.

You can install [SwiftLint](https://github.com/realm/SwiftLint/) with Homebrew:
```
brew install swiftlint
```

# Credits

Credit card icon from logo: Icon made by Madebyoliver from www.flaticon.com  
Bus icon from logo: Icon made by Freepik from www.flaticon.com
