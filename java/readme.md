# How to use

## Integrating into build

I've used Maven for managing the build. Unfortunately, I am no expert on Maven so I can't help much on integration (but will try my best). There's very little complexity to this project, thankfully. For starters, here is `ve`'s package description as listed in `pom.xml`:

```
<groupId>uk.co.birchlabs.ve</groupId>
<artifactId>ve</artifactId>
<version>1.0-SNAPSHOT</version>
```

You could either:

  * Install this to your global Maven repository (see [the instructions I wrote](https://github.com/shirakaba/sen-mavenized/blob/master/README.md) for a similar project if you don't already know how), and add the `ve` package as a `<dependency>` to your project; or...

  * Give up on modularity and just drag the files straight into your project.
  
No matter how you go about integrating it, please adhere to the rules of the software license.

*Useful info: [official guide to POMs](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html).*
*Note: I would be very interested if someone could teach me how to put this package on the Maven central repository, to make integration much easier for everyone.*
  
## Importing into source

Import via: `import uk.co.birchlabs.ve`

Ve has a dependency on a tokenizer. As [kuromoji](https://github.com/atilika/kuromoji) is the most convenient/portable Mecab interface for Java, I coded it to accept Tokens in the format of the Kuromoji Token class.

*Fun fact: An older (not-to-be-released) version of this project was hooked up with [Sen](https://github.com/shirakaba/sen-mavenized), but its installation turned out to be much, much harder than kuromoji's. If you really want to use Sen (or any other non-Kuromoji Mecab interface) with Ve, I advise you to make a simple tool to convert those incompatible Tokens to Kuromoji-style ones for input into Ve.*

In all, I import:

```
import uk.co.birchlabs.ve
import org.atilika.kuromoji.Token;
import org.atilika.kuromoji.Tokenizer;
```

## Usage

Here's a line-by-line explanation of the `coreUsage` test I provided, detailing `Ve`'s core feature: parsing collections of Tokens into Words (more lexically meaningful groupings of Tokens, using Kim's special recipe).

``` java
// Some nonsense Japanese with interesting word boundaries.
String stringOfJapanese = "金がなければくよくよします女に振られりゃなきまする";
// Output the Kuromoji-style Tokens as a List
List<Token> tokensList = Tokenizer.builder().build().tokenize(stringOfJapanese);
// Convert to a basic Token array (I haven't adapted Ve to accept Lists of Tokens)
Token[] tokensArray = tokensList.toArray(new Token[tokensList.size()]);
// Create a parser instance from the array of Kuromoji-style Tokens.
Parse parser = new Parse(tokensArray);
// Get the Tokens out as 'Words'.
List<Word> words = parser.words();
// The .toString() method of each Word is generally the most useful. It shows the surface form of the Tokens.
// Output: [金, が, なけれ, ば, くよくよ, します, 女に, 振られりゃなき, まする]
System.out.println(words);
```

# How to run the tests (to prove that it works)

These tests auto-pass; they purely exist to show you the command-line output of Ve's `parse` function.

## If using an IDE such as IntelliJ

1. Open `ve/java` in the IDE (the folder containing `pom.xml`)

2. Open `test/java/ve/VeTest.java`

3. Run the JUnit `coreUsage()` test by clicking the 'play' button beside it.

## If using the command line

1. `cd` into the `ve/java` directory

2. Run the command:
  * `mvn test` (whole test suite); or:
  * `mvn test -Dtest=VeTest,coreUsage` (single test)
