# Csound for Atom

This [Atom](https://atom.io) package adds syntax highlighting, snippets, and autocompletion to [Csound](https://en.wikipedia.org/wiki/Csound) files.

## Contributing

[Open an issue](https://github.com/nwhetsell/language-csound/issues), or [fork this project and submit a pull request](https://guides.github.com/activities/forking/).

## Making the List of Opcode Completions

This package uses the list of opcodes in [`resources/opcode-completions.json`](https://github.com/nwhetsell/language-csound/tree/master/resources/opcode-completions.json) for autocompletion. Making this list requires the [source files](https://github.com/csound/manual) of _The Canonical Csound Reference Manual_ and a [Node.js Addon for Csound](https://www.npmjs.com/package/csound-api) that has only been tested on OS&nbsp;X. But, to make `opcode-completions.json` on OS&nbsp;X:

1. In a Terminal, `cd` to this package’s `resources` folder using, for example,

    ```sh
    cd ~/.atom/packages/language-csound/resources
    ```

2. Download the source files of _The Canonical Csound Reference Manual_ to a folder named `csound` using, for example,

    ```sh
    git clone https://github.com/csound/manual.git csound/manual
    ```

3. Install [Boost](http://www.boost.org). The easiest way to install Boost is probably through [Homebrew](http://brew.sh). To install Homebrew, follow the instructions at [http://brew.sh](http://brew.sh). Then, run `brew install boost` in a Terminal.
4. Install Csound. If you aren’t able to build Csound from its [source code](https://github.com/csound/csound), the most reliable way to install Csound is probably to run an installer in a disk image you can download from [SourceForge](http://sourceforge.net/projects/csound/files/csound6/). (While Csound has a [tap](https://github.com/csound/homebrew-csound) on Homebrew, it does not install a necessary framework; this is a [known issue](https://github.com/csound/csound/blob/develop/BUILD.md#known-issues).) When you double-click the installer in the disk image, OS&nbsp;X may block the installer from running because it’s from an unidentified developer. To run the installer after this happens, open System Preferences, choose Security & Privacy, and click Open Anyway in the bottom half of the window.
5. Install the [`csound-api`](https://www.npmjs.com/package/csound-api), [`libxmljs`](https://www.npmjs.com/package/libxmljs), and [`strip-bom`](https://www.npmjs.com/package/strip-bom) packages using

    ```sh
    npm install csound-api
    npm install libxmljs
    npm install strip-bom
    ```

6. Run the script [`make-opcode-completions-json.js`](https://github.com/nwhetsell/language-csound/blob/master/resources/make-opcode-completions-json.js) using

    ```sh
    node make-opcode-completions-json.js
    ```
