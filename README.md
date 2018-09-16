# PhotoGroove

An interactive web application built in Elm 0.18

### Requirements

* Nodejs
* Npm
* Elm 0.18


```
npm-install -g elm@0.18.0 elm-test elm-css
```

### Install

```
elm-make src/PhotoGroove.elm --output out/elm.js
```

### Intellij
To create a simple project builder, edit configurations and add one for nodejs named `Build PhotoGroove`.

Set the Application parameters to `stop.js`

Under `Before launch` add an external tool called `elm-make` Set the following values :

Program: `~/.npm-global/bin/elm-make` // or the path to your elm-make binary

Arguments: `src/PhotoGroove.elm --output out/elm.js`

Working Directory: `$ProjectFileDir$`