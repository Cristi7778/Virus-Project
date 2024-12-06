# Virus-Project
This is my project for Virus and Antivirus Technologies, a version of CSpawn, which infects files and locks them with a password.

The project is built in assembly x8086 on 16 bits, and it was made to be run on DOS-BOX.

The project.com executable will search for other .com files and infect them. Once infected a file will ask for a password, if you provide the right one the orginal file will run, if not the virus will run again. The password is obtained as cristi+ first 3 letters of the orginal name, caps sensitive.
On the original project.com, it will also ask for a password, any other password than 'cristi' run the virus and infect files, while using this one will be safe.

The repository contains the original ASM code, the assembled file and the executable, and 3 hosts for testing.
