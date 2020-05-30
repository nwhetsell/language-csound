#!/usr/bin/env node

// To update opcode-completions.json, run:
/*
git clone https://github.com/csound/manual.git
npm install csound-api libxmljs strip-bom
./update-opcode-completions.js
rm -fR manual node_modules
*/

const csound = require("csound-api");
const fs = require("fs");
const libxml = require("libxmljs");
const path = require("path");
const stripBom = require("strip-bom");

// Use OpcodeInfo objects to organize opcode information for creating
// completions.
class OpcodeInfo {
  constructor(opcodeEntry) {
    this.name = opcodeEntry.opname;
    this.inputTypeStrings = [];
    this.inputTypeStringsByLengthByOutputTypeString = {};
    this.addInfoForOpcodeEntry(opcodeEntry);
  }

  addInfoForOpcodeEntry(opcodeEntry) {
    // Ignore array inputs.
    const inputTypeString = opcodeEntry.intypes.replace(/\[\]/g, "");
    if (this.inputTypeStrings.indexOf(inputTypeString) < 0)
      this.inputTypeStrings.push(inputTypeString);
    // According to
    // https://github.com/csound/csound/blob/develop/Engine/entry1.c, the output
    // type "s" is deprecated but means either an a- or k-rate output.
    const outputTypes = (opcodeEntry.outypes === "s") ? ["a", "k"] : [opcodeEntry.outypes];
    for (const outputType of outputTypes) {
      let inputTypeStringsByLength = this.inputTypeStringsByLengthByOutputTypeString[outputType];
      if (inputTypeStringsByLength) {
        const inputTypeStrings = inputTypeStringsByLength[inputTypeString.length];
        if (inputTypeStrings) {
          if (inputTypeStrings.indexOf(inputTypeString) < 0)
            inputTypeStrings.push(inputTypeString);
        } else {
          inputTypeStringsByLength[inputTypeString.length] = [inputTypeString];
        }
      } else {
        inputTypeStringsByLength = {};
        inputTypeStringsByLength[inputTypeString.length] = [inputTypeString];
        this.inputTypeStringsByLengthByOutputTypeString[outputType] = inputTypeStringsByLength;
      }
    }
  }
}

// Create a map from opcode names to opcode properties.
const ignoredOpcodes = [
  // Function opcodes
  "a",
  "abs",
  "ampdb",
  "ampdbfs",
  "birnd",
  "ceil",
  "cent",
  "cos",
  "cosh",
  "cosinv",
  "cosinv",
  "cpsmidinn",
  "cpsoct",
  "cpspch",
  "db",
  "dbamp",
  "dbfsamp",
  "exp",
  "floor",
  "frac",
  "ftchnls",
  "ftcps",
  "ftlen",
  "ftlptim",
  "ftsr",
  "i",
  "int",
  "k",
  "log",
  "log10",
  "log2",
  "logbtwo",
  "nsamp",
  "octave",
  "octcps",
  "octmidinn",
  "octpch",
  "p",
  "pchmidinn",
  "pchoct",
  "powoftwo",
  "qinf",
  "qnan",
  "rnd",
  "round",
  "semitone",
  "signum",
  "sin",
  "sinh",
  "sininv",
  "sqrt",
  "tan",
  "tanh",
  "taninv",
  "urd",
  // Keyword-like opcodes
  "cggoto",
  "cigoto",
  "cingoto",
  "ckgoto",
  "cngoto",
  "endin",
  "endop",
  "goto",
  "igoto",
  "instr",
  "kgoto",
  "opcode",
  "return",
  "rigoto",
  "tigoto",
  // Opcodes that use comma-separated lists of arguments of any type
  "changed2",
  "framebuffer",
  "hdf5read",
  "hdf5write",
  "xin",
  "xout",
  // Opcodes with input arguments that are difficult to parse
  "alwayson"
];
const opcodeInfoByName = {};
const opcodeList = [];
csound.NewOpcodeList(csound.Create(), opcodeList);
for (const opcodeEntry of opcodeList) {
  if (ignoredOpcodes.indexOf(opcodeEntry.opname) < 0) {
    const opcodeInfo = opcodeInfoByName[opcodeEntry.opname];
    if (opcodeInfo)
      opcodeInfo.addInfoForOpcodeEntry(opcodeEntry);
    else
      opcodeInfoByName[opcodeEntry.opname] = new OpcodeInfo(opcodeEntry);
  }
}

// Use InputArgumentInfo objects to organize input argument types and names for
// completions.
const openingBracket = "(";
const separator = "|";
const closingBracket = ")";
class InputArgumentInfo {
  constructor(inputTypeStrings, nameArray) {
    this.nameArray = nameArray;
    this.typeStringsArray = [];
    this.listArray = [];
    this.optionalArray = [];
    // Resolve input type characters based on
    // <https://github.com/csound/csound/blob/develop/Engine/entry1.c>. The
    // opcodes framebuffer, hdf5read, hdf5write, xin, and xout use the * type
    // character, which is documented in the release notes of Csound 6
    // <https://csound.com/docs/manual/PrefaceWhatsNew.html> as indicating “a
    // var-arg list of any-type”.

    // i  i-time scalar
    // o  optional i-time scalar defaulting to 0
    // j  optional i-time scalar defaulting to -1
    // v  optional i-time scalar defaulting to 0.5
    // p  optional i-time scalar defaulting to 1
    // q  optional i-time scalar defaulting to 10
    // h  optional i-time scalar defaulting to 127
    // m  comma-separated list of any number of i-time scalars

    // k  k-rate scalar
    // O  optional k-rate scalar defaulting to 0
    // J  optional k-rate scalar defaulting to -1
    // V  optional k-rate scalar defaulting to 0.5
    // P  optional k-rate scalar defaulting to 1
    // z  comma-separated list of k-rate scalars

    // a  a-rate vector
    // y  comma-separated list of a-rate vectors

    // S  string
    // W  comma-separated list of strings

    // T  i-time scalar or string
    // U  i-time scalar, k-rate scalar, or string
    // x  k-rate scalar or a-rate vector

    // M  comma-separated list of i-time scalars, k-rate scalars, and a-rate
    //    vectors
    // N  comma-separated list of i-time scalars, k-rate scalars, a-rate vectors,
    //    and strings
    // n  comma-separated list of an odd number of i-time scalars
    // Z  comma-separated list of alternating k-rate scalars and a-rate vectors,
    //    used by mac and outch

    // f  frequency-domain variable, used by phase vocoder opcodes
    // w  frequency-domain variable, used by specaddm, specdiff, specdisp,
    //    specfilt, spechist, specptrk, specscal, specsum, and spectrum
    // B  Boolean, used by cggoto, cigoto, cingoto, and ckgoto
    // l  label, used by goto, igoto, kgoto, loop_ge, loop_gt, loop_le, loop_lt,
    //    rigoto, and tigoto

    // .  required argument of any type, used by init (for arrays), lenarray,
    //    print_type, and slicearray
    // ?  optional argument of any type, possibly unused
    // *  comma-separated list of arguments of any type, used by changed2,
    //    framebuffer, hdf5read, hdf5write, xin, and xout

    const typeInfoByType = {
      "a": {strings: ["a"], optional: false, list: false},
      "B": {strings: ["B"], optional: false, list: false},
      "f": {strings: ["f"], optional: false, list: false},
      "h": {strings: ["i"], optional: true, list: false},
      "i": {strings: ["i"], optional: false, list: false},
      "J": {strings: ["k"], optional: false, list: false},
      "j": {strings: ["i"], optional: true, list: false},
      "k": {strings: ["k"], optional: false, list: false},
      "l": {strings: ["l"], optional: false, list: false},
      "M": {strings: ["a", "i", "k"], optional: false, list: true},
      "m": {strings: ["i"], optional: false, list: true},
      "N": {strings: ["a", "i", "k", "S"], optional: false, list: true},
      "n": {strings: ["i"], optional: false, list: true},
      "O": {strings: ["k"], optional: true, list: false},
      "o": {strings: ["i"], optional: true, list: false},
      "P": {strings: ["k"], optional: true, list: false},
      "p": {strings: ["i"], optional: true, list: false},
      "q": {strings: ["i"], optional: true, list: false},
      "S": {strings: ["S"], optional: false, list: false},
      "T": {strings: ["i", "S"], optional: false, list: false},
      "U": {strings: ["i", "k", "S"], optional: false, list: false},
      "V": {strings: ["k"], optional: true, list: false},
      "v": {strings: ["i"], optional: true, list: false},
      "W": {strings: ["S"], optional: false, list: true},
      "w": {strings: ["w"], optional: false, list: false},
      "x": {strings: ["a", "k"], optional: false, list: false},
      "y": {strings: ["a"], optional: false, list: true},
      "Z": {strings: ["a", "k"], optional: false, list: true},
      "z": {strings: ["k"], optional: false, list: true},
      ".": {strings: ["a", "i", "k", "S"], optional: false, list: false}
    };
    for (const inputTypeString of inputTypeStrings) {
      if (inputTypeString.length > 0) {
        const inputTypes = inputTypeString.match(/(?:[aBfhijklOoPpqSTUVvwx\.]|[MmNnWyZz]+)/g);
        for (let i = 0, length = inputTypes.length; i < length; i++) {
          const typeInfo = typeInfoByType[inputTypes[i]];

          const typeStrings = this.typeStringsArray[i];
          if (typeStrings) {
            for (const string of typeInfo.strings) {
              if (typeStrings.indexOf(string) < 0)
                typeStrings.push(string);
            }
          } else {
            this.typeStringsArray[i] = typeInfo.strings.slice();
          }

          this.listArray[i] = typeInfo.list;
          this.optionalArray[i] = typeInfo.optional;
        }
      }
    }
  }

  get displayText() {
    const length = this.typeStringsArray.length;
    if (length === 0)
      return "";

    const components = [];
    for (let i = 0; i < length; i++) {
      let string = this.typeStringsArray[i].join(separator);
      if (string.length > 1)
        string = openingBracket + string + closingBracket;
      if (this.nameArray[i])
        string += this.nameArray[i];
      components.push(string);
    }
    return " " + components.join(", ");
  }

  get snippet() {
    const length = this.typeStringsArray.length;
    if (length === 0)
      return "";

    let snippet = "";
    let optionalIndex = null;
    for (let i = 0; i < length; i++) {
      let string = this.typeStringsArray[i].join(separator);
      if (string.length > 1)
        string = openingBracket + string + closingBracket;
      if (this.nameArray[i])
        string += this.nameArray[i];
      if (this.listArray[i])
        string += "…";
      if (i === 0) {
        snippet +=  "${1:" + string;
      } else if (optionalIndex === null) {
        if (this.optionalArray[i]) {
          optionalIndex = i - 1;
          snippet += "/*, " + string;
        } else {
          snippet += "}, ${" + (i + 1) + ":" + string;
        }
      } else {
        snippet += ", " + string;
      }
    }
    if (optionalIndex !== null)
      snippet += "*/";
    return " " + snippet + "}";
  }
}

function formatOutputTypeString(string) {
  string = string.replace(/m+/g, "a…");
  string = string.replace(/z+/g, "k…");
  string = string.replace(/I+/g, "i…");
  string = string.replace(/X+/g, openingBracket + ["a", "k", "i"].join(separator) + closingBracket + "…");
  string = string.replace(/N+/g, openingBracket + ["a", "k", "i", "S"].join(separator) + closingBracket + "…");
  string = string.replace(/F+/g, "f…");
  return string;
}

// Create a list of Csound Manual XML file names.
const opcodesPath = path.join("manual", "opcodes");
const opcodeXMLFileNames = fs.readdirSync(opcodesPath).map(opcodePath => path.parse(opcodePath).name);

// Csound manual XML files describing opcodes need a header to be parsed without
// errors.
const XMLHeader = `<?xml version="1.0" encoding="utf-8"?>
  <!DOCTYPE refentry [

  <!-- http://tdg.docbook.org/tdg/4.5/ref-charents.html -->

  <!-- https://www.w3.org/2003/entities/iso8879doc/isodia.html -->
  <!ENTITY circ "ˆ">
  <!ENTITY tilde " ̃">

  <!-- https://www.w3.org/2003/entities/iso8879doc/isogrk3.html -->
  <!ENTITY beta "β">
  <!ENTITY lambda "λ">
  <!ENTITY pi "π">

  <!-- https://www.w3.org/2003/entities/iso8879doc/isolat1.html -->
  <!ENTITY auml "ä">

  <!-- https://www.w3.org/2003/entities/iso8879doc/isonum.html -->
  <!ENTITY nbsp "&#xA0;">
  <!ENTITY num "#">
  <!ENTITY percnt "&#x25;">
  <!ENTITY plusmn "±">
  <!ENTITY shy "&#xAD;">

  <!-- https://www.w3.org/2003/entities/iso8879doc/isotech.html -->
  <!ENTITY le "≤">

  <!-- https://github.com/csound/manual/blob/master/manual.xml -->
  <!ENTITY nameandres "Andrés Cabrera">
  <!ENTITY nameanthony "Anthony Kozar">
  <!ENTITY namebarry "Barry L. Vercoe">
  <!ENTITY nameeduardo "Eduardo Moguillansky">
  <!ENTITY namegabriel "Gabriel Maldonado">
  <!ENTITY namehans "Hans Mikelson">
  <!ENTITY nameistvan "Istvan Varga">
  <!ENTITY namejohn "John ffitch">
  <!ENTITY namekanata "Kanata Motohashi">
  <!ENTITY namekevin "Kevin Conder">
  <!ENTITY nameluis "Luis Jure">
  <!ENTITY namematt "Matt Ingalls">
  <!ENTITY namemichael "Michael Gogins">
  <!ENTITY namemike "Mike Berry">
  <!ENTITY nameoeyvind "Øyvind Brandtsegg">
  <!ENTITY nameparis "Paris Smaragdis">
  <!ENTITY namepaul "Paul Batchelor">
  <!ENTITY nameperry "Perry Cook">
  <!ENTITY namepeter "Peter Brinkmann">
  <!ENTITY namepinot "François Pinot">
  <!ENTITY namerasmus "Rasmus Ekman">
  <!ENTITY namerichard "Richard Dobson">
  <!ENTITY namesean "Sean Costello">
  <!ENTITY namesteven "Steven Yi">
  <!ENTITY nametito "Tito Latini">
  <!ENTITY namevictor "Victor Lazzarini">
  ]>
`;

// Create a map of more descriptive input argument names.
const descriptiveNamesByName = {
  "amp": "Amplitude",
  "atdec": "AttenuationFactor",
  "cps": "Frequency",
  "dec": "DecayTime",
  "del": "DelayTime",
  "dur": "Duration",
  "filname": "Filename",
  "fn": "FunctionTable",
  "freq": "Frequency",
  "frq": "Frequency",
  "ndex": "Index",
  "phs": "InitialPhase",
  "pitch": "Pitch",
  "rise": "RiseTime",
  "sig": "Signal"
};

let allCompletions = [];
for (const opcodeName in opcodeInfoByName) {
  let inputArgumentNames = [];

  if (opcodeInfoByName.hasOwnProperty(opcodeName) && opcodeXMLFileNames.indexOf(opcodeName) >= 0) {
    // Get opcode descriptions and input argument names from the Csound Manual
    // XML file.
    let XMLString = fs.readFileSync(path.join(opcodesPath, `${opcodeName}.xml`), "utf8");
    // Csound manual XML files may include a Unicode byte order mark (BOM).
    XMLString = stripBom(XMLString);
    const XMLDocument = libxml.parseXmlString(XMLHeader + XMLString);
    const description = XMLDocument.get("//refpurpose").text().trim().replace(/\s+/g, " ");
    // Assume the XML document contains at least one synopsis element with one
    // child command element.
    const commandElement = XMLDocument.get("//synopsis/command");
    if (commandElement) {
      // Assume the next sibling of the command element is a text node
      // describing input arguments.
      const node = commandElement.nextSibling();
      if (node && node.type() === "text") {
        inputArgumentNames = node.toString().replace(/[\\\[\]]/g, "").replace(/\s+/g, " ").split(",");
        for (let i = 0, length = inputArgumentNames.length; i < length; i++) {
          let name = inputArgumentNames[i].trim();
          if (name.charAt(0) === '"' && name.charAt(name.length - 1) === '"') {
            // If the name is enclosed in double quotes, remove the quotes and
            // create a camel-case name.
            inputArgumentNames[i] = name.replace(/"/g, "").split(" ").map(string => string.charAt(0).toUpperCase() + string.slice(1)).join("");
          } else {
            // Otherwise, remove the first two characters if the first character
            // is a g (indicating a global variable), and just the first
            // character otherwise.
            name = name.slice((name.charAt(0) === "g") ? 2 : 1);
            const descriptiveName = descriptiveNamesByName[name];
            inputArgumentNames[i] = descriptiveName ? descriptiveName : name;
          }
        }
      }
    }

    const completions = [];
    const opcodeInfo = opcodeInfoByName[opcodeName];
    const inputTypeStringsByLengthByOutputTypeString = opcodeInfo.inputTypeStringsByLengthByOutputTypeString;

    // If all input type strings are equal, then the inputTypeStrings property
    // of opcodeInfo will be a length-1 array.
    if (opcodeInfo.inputTypeStrings.length === 1) {
      // Create a single completion for all output type strings.
      const completion = {};
      const leftLabel = formatOutputTypeString(Object.getOwnPropertyNames(inputTypeStringsByLengthByOutputTypeString).join(""));
      if (leftLabel.length > 0)
        completion.leftLabel = leftLabel;
      const inputArgumentInfo = new InputArgumentInfo(opcodeInfo.inputTypeStrings, inputArgumentNames);
      completion.snippet = opcodeName + inputArgumentInfo.snippet;
      completion.displayText = opcodeName + inputArgumentInfo.displayText;
      completions.push(completion);
    } else {
      // Create completions for each output type string and input type string
      // length.
      for (const outputTypeString in inputTypeStringsByLengthByOutputTypeString) {
        if (inputTypeStringsByLengthByOutputTypeString.hasOwnProperty(outputTypeString)) {
          const inputTypeStringsByLength = inputTypeStringsByLengthByOutputTypeString[outputTypeString];
          for (const length in inputTypeStringsByLength) {
            const completion = {leftLabel: formatOutputTypeString(outputTypeString)};
            if (inputTypeStringsByLength.hasOwnProperty(length)) {
              const inputArgumentInfo = new InputArgumentInfo(inputTypeStringsByLength[length], inputArgumentNames);
              completion.snippet = opcodeName + inputArgumentInfo.snippet;
              completion.displayText = opcodeName + inputArgumentInfo.displayText;
              completions.push(completion);
            }
          }
        }
      }
    }

    // Add additional completion properties from the Csound Manual XML file.
    for (const completion of completions) {
      completion.opcode = opcodeName;
      completion.description = description;
      completion.descriptionMoreURL = `https://csound.com/docs/manual/${opcodeName}.html`;
      completion.type = "function";
    }

    allCompletions = allCompletions.concat(completions);
  } else {
    console.log(`Skipping opcode ${opcodeName} because ${opcodeName}.xml is not in the Csound manual repository.`);
  }
}

// Add completions of opcodes that use comma-separated lists of arguments of any
// type, or whose entries are difficult to parse.
allCompletions = allCompletions.concat([
  {
    snippet: "alwayson ${1:(i|S)Instrument/*, p4, p5, …*/}",
    displayText: "alwayson (i|S)Instrument, p4, p5, …",
    opcode: "alwayson",
    description: "Activates the indicated instrument in the orchestra header.",
    descriptionMoreURL: "https://csound.com/docs/manual/alwayson.html",
    type: "function"
  },
  {
    leftLabel: "k[]",
    snippet: "changed2 ${1:kVariableName1/*, kVariableName2, …*/}",
    displayText: "changed2 kVariableName1, kVariableName2, …",
    opcode: "changed2",
    description: "k-rate signal change detector.",
    descriptionMoreURL: "https://csound.com/docs/manual/changed2.html",
    type: "function"
  },
  {
    leftLabel: "k[]",
    snippet: "framebuffer ${1:aInput}, ${2:iSize}",
    displayText: "framebuffer aInput, iSize",
    opcode: "framebuffer",
    description: "Read audio signals into 1 dimensional k-rate arrays and vice-versa with a specified buffer size.",
    descriptionMoreURL: "https://csound.com/docs/manual/framebuffer.html",
    type: "function"
  },
  {
    leftLabel: "a",
    snippet: "framebuffer ${1:kInput}, ${2:iSize}",
    displayText: "framebuffer kInput, iSize",
    opcode: "framebuffer",
    description: "Read audio signals into 1 dimensional k-rate arrays and vice-versa with a specified buffer size.",
    descriptionMoreURL: "https://csound.com/docs/manual/framebuffer.html",
    type: "function"
  },
  {
    leftLabel: formatOutputTypeString("N"),
    snippet: "hdf5read ${1:Sfilename}, ${2:SVariableName1/*, SVariableName2, …*/}",
    displayText: "hdf5read Sfilename, SVariableName1, SVariableName2, …",
    opcode: "hdf5read",
    description: "Read signals and arrays from an hdf5 file.",
    descriptionMoreURL: "https://csound.com/docs/manual/hdf5read.html",
    type: "function"
  },
  {
    snippet: "hdf5write ${1:Sfilename}, ${2:(a|i|k|S)Output1/*, (a|i|k|S)Output2, …*/}",
    displayText: "hdf5write Sfilename, (a|i|k|S)Output1, (a|i|k|S)Output2, …",
    opcode: "hdf5write",
    description: "Write signals and arrays to an hdf5 file.",
    descriptionMoreURL: "https://csound.com/docs/manual/hdf5write.html",
    type: "function"
  },
  {
    leftLabel: formatOutputTypeString("N"),
    snippet: "xin",
    displayText: "xin",
    opcode: "xin",
    description: "Passes variables to a user-defined opcode block.",
    descriptionMoreURL: "https://csound.com/docs/manual/xin.html",
    type: "function"
  },
  {
    snippet: "xout ${1:(a|i|k|S)Output1/*, (a|i|k|S)Output2, …*/}",
    displayText: "xout (a|i|k|S)Output1, (a|i|k|S)Output2, …",
    opcode: "xout",
    description: "Retrieves variables from a user-defined opcode block.",
    descriptionMoreURL: "https://csound.com/docs/manual/xout.html",
    type: "function"
  }
]);

// Write the completions dictionary to a JSON file.
const fileDescriptor = fs.openSync("opcode-completions.json", "w");
fs.writeSync(fileDescriptor, JSON.stringify({
  about: "The contents of this file are derived from the source files of The Canonical Csound Reference Manual <https://github.com/csound/manual>. The Canonical Csound Reference Manual is licensed under the terms of the GNU Free Documentation License, Version 1.2 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. Copyrights of The Canonical Csound Reference Manual are held by the Massachusetts Institute of Technology (1986, 1992), Kevin Conder (2003), and others noted in individual source files. This file is licensed under the terms of the GNU Free Documentation License, Version 1.2 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.",
  completions: allCompletions
}, null, 2));
fs.closeSync(fileDescriptor);
