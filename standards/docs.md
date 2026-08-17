## Documentation

In code:
* Don't document *what* code does. Rewrite code to make what it does self-documenting.
* Document *why* code does what it does and alternative approaches that were purposefuly not taken.

There should be one canonical place where something is documented.
Check on references between documents.
Remove out of date documentation.

Add diagrams to documentation.

Update and add lasting technical documentation. It should be accessible by following links from the README.md.
Documentation should explain things that are not readily available from reading the code, for example:
* useful commands to run (but if they are more than a one liner codify it by addint it to the project script directory)
* purpose and product needs
* technical design trade offs considered (important ones belong in ./docs/adr)
