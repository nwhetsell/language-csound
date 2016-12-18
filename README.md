# Csound for Atom

This [Atom](https://atom.io) package adds syntax highlighting, snippets, and autocompletion to [Csound](https://csound.github.io) files. This package is also used by [GitHub Linguist](https://github.com/github/linguist) to highlight Csound files.

## Contributing

[Open an issue](https://github.com/nwhetsell/language-csound/issues), or [fork this project and make a pull request](https://guides.github.com/activities/forking/).

## Updating the Opcode Regex Pattern

The [Csound grammar](https://github.com/nwhetsell/language-csound/blob/master/grammars/csound.cson) contains a long regex pattern that matches Csound’s built-in opcodes. This regex pattern is generated using tools from [Pygments](http://pygments.org). To update the regex pattern on macOS, enter in Terminal

```sh
cd ~/.atom/packages/language-csound/grammars
curl https://bitbucket.org/nwhetsell/pygments-main/raw/tip/pygments/regexopt.py > regexopt.py
curl https://bitbucket.org/nwhetsell/pygments-main/raw/tip/pygments/lexers/_csound_builtins.py > _csound_builtins.py
python update_csound_grammar.py
```

## Updating the List of Opcode Completions

This package uses the list of opcodes in [resources/opcode-completions.json](https://github.com/nwhetsell/language-csound/tree/master/resources/opcode-completions.json) for autocompletion. To update opcode-completions.json:

1. `cd` to this package’s resources folder using, for example,

    ```sh
    cd ~/.atom/packages/language-csound/resources
    ```

2. Download the source files of _The Canonical Csound Reference Manual_ to a folder named csound using

    ```sh
    git clone https://github.com/csound/manual.git csound/manual
    ```

3. Follow the instructions at https://github.com/nwhetsell/csound-api#installing to install the csound-api [Node.js Addon](https://nodejs.org/api/addons.html).

4. Install the [libxmljs](https://www.npmjs.com/package/libxmljs) and [strip-bom](https://www.npmjs.com/package/strip-bom) packages using

    ```sh
    npm install libxmljs strip-bom
    ```

5. Run the script [update-opcode-completions.js](https://github.com/nwhetsell/language-csound/blob/master/resources/update-opcode-completions.js) using

    ```sh
    node update-opcode-completions.js
    ```
